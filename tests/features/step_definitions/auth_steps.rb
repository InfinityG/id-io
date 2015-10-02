require 'json'
require 'securerandom'
require 'digest'
require 'minitest'
require 'ig-crypto-utils'

require_relative '../../../api/utils/rest_util'
require_relative '../../../tests/config'
require_relative '../../../tests/helpers/random_strings'

Before do
  @random_uuid = SecureRandom.uuid.to_s
end

Given(/^I am a registered user$/) do
  @first_name = 'Johnny'
  @last_name = RandomStrings.generate_alpha 15

  @username = 'johnny_' + @last_name + '@test.com'
  @password = 'passWOrd1!'
  @encoded_public_key = 'Ag7PunGy2BmnAi+PGE4/Dm9nCg1URv8wLZwSOggyfmAn' # already base64 encoded
  @encoded_secret_key = 'gCrHtl8VVWs6EuJLy7vPqVdBZWzRAR9ZCjIRRpoWvME=' # already base64 encoded
  @email = @email = "#{@first_name}_#{@last_name}@test.com"
  @mobile_number = '+21234567890'
  @meta = 'iwut748324'

  payload = {
      :first_name => @first_name,
      :last_name => @last_name,
      :username => @username,
      :password => @password,
      :public_key => @encoded_public_key,
      :email => @email,
      :mobile_number => @mobile_number,
      :meta => @meta
  }.to_json

  puts "Create user payload: #{payload}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + '/users', IDENTITY_API_AUTH_KEY, payload)
  puts "Create user result: #{result.response_body}"

  @user_id = JSON.parse(result.response_body, :symbolize_names => true)
end

And(/^I want to login to a trusted domain$/) do
  @trusted_domain = 'www.testdomain.com'
  @encoded_domain_aes_key = 'ky4xgi0+KvLYmVp1J5akqkJkv8z5rJsHTo9FcBc0hgo='

  payload = {
      :domain => @trusted_domain,
      :aes_key => @encoded_domain_aes_key,
      :login_uri => "https://#{@trusted_domain}/login"
  }.to_json

  puts "Create trusted domain payload: #{payload}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + '/trusts', IDENTITY_API_AUTH_KEY, payload)
  puts "Create trusted domain result: #{result.response_body}"

  assert result.response_code == 200
end

And(/^I have requested a challenge$/) do
  payload = {
      :username => @username
  }.to_json

  puts "Create challenge payload: #{payload}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + '/challenge', IDENTITY_API_AUTH_KEY, payload)
  puts "Create challenge result: #{result.response_body}"

  @challenge_result = JSON.parse(result.response_body, :symbolize_names => true)

end

And(/^I have invalid challenge data$/) do
  @challenge_result = {:data => 'hsodufgasfgasdfgaofga123'}
end

And(/^I have signed the challenge data$/) do
  digest = Digest::SHA2.base64digest @challenge_result[:data]
  signature = CryptoUtils::EcdsaUtil.new.sign digest, @encoded_secret_key

  payload = {
      :username => @username,
      :challenge => {
          :digest => digest,
          :signature => signature
      },
      :domain => @trusted_domain
  }.to_json

  @signed_challenge = payload

end

And(/^I want to redirect to a 3rd party on login$/) do
  current_challenge = JSON.parse(@signed_challenge, :symbolize_names => true)
  current_challenge[:redirect] = true
  @signed_challenge = current_challenge.to_json
end

And(/^I have a missing challenge signature$/) do
  digest = Digest::SHA2.base64digest @challenge_result[:data]

  payload = {
      :username => @username,
      :challenge => {
          :digest => digest,
          :signature => nil
      },
      :domain => @trusted_domain
  }.to_json

  @signed_challenge = payload
end

And(/^I have an invalid challenge signature$/) do
  digest = Digest::SHA2.base64digest @challenge_result[:data]

  payload = {
      :username => @username,
      :challenge => {
          :digest => digest,
          :signature => 'ijfqipwunprcqnrc9pqyewborciquybroiqu'
      },
      :domain => @trusted_domain
  }.to_json

  @signed_challenge = payload
end

And(/^I have a missing username$/) do
  digest = Digest::SHA2.base64digest @challenge_result[:data]
  signature = CryptoUtils::EcdsaUtil.new.sign digest, @encoded_secret_key

  payload = {
      :username => nil,
      :challenge => {
          :digest => digest,
          :signature => signature
      },
      :domain => @trusted_domain
  }.to_json

  @signed_challenge = payload
end

And(/^I have an invalid challenge username$/) do
  digest = Digest::SHA2.base64digest @challenge_result[:data]
  signature = CryptoUtils::EcdsaUtil.new.sign digest, @encoded_secret_key

  payload = {
      :username => 'fafhasdfoaisdhfids',
      :challenge => {
          :digest => digest,
          :signature => signature
      },
      :domain => @trusted_domain
  }.to_json

  @signed_challenge = payload

end

When(/^I log in with a challenge$/) do
  puts "Login payload: #{@signed_challenge}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + '/login', IDENTITY_API_AUTH_KEY, @signed_challenge)
  puts "Login result: #{result.response_body}"

  @login_result = JSON.parse(result.response_body, :symbolize_names => true)
  @login_response_code = result.response_code

end

When(/^I log in with a password$/) do
  payload = {
      :username => @username,
      :password => @password,
      :domain => @trusted_domain
  }.to_json

  puts "Login payload: #{payload}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + '/login', IDENTITY_API_AUTH_KEY, payload)
  puts "Login result: #{result.response_body}"

  @login_result = JSON.parse(result.response_body, :symbolize_names => true)
  @login_response_code = result.response_code
end

Then(/^the login endpoint should respond with an encrypted auth response$/) do
  assert @login_result[:auth] != nil
  assert @login_result[:iv] != nil
  end

Then(/^the login endpoint should respond with a redirection uri$/) do
  assert @login_result[:redirect_uri] != nil
end

Then(/^the login endpoint should respond with a (\d+) response code$/) do |arg|
  assert @login_response_code.to_s == arg.to_s
end
