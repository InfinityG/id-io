require 'json'
require 'digest'
require 'minitest'
require 'ig-crypto-utils'
require_relative '../../../tests/config'
require_relative '../../../tests/helpers/random_strings'

Before do
  @trusted_domain = 'www.testdomain.com'
  @encoded_domain_aes_key = 'ky4xgi0+KvLYmVp1J5akqkJkv8z5rJsHTo9FcBc0hgo='

  set_trusted_domain
end

Given(/^I have an existing origin user$/) do
  first_name = 'johnny'
  last_name = RandomStrings.generate_alpha 15
  keys = CryptoUtils::EcdsaUtil.new.create_key_pair

  @origin_username = "#{first_name}_#{last_name}@test.com"
  @origin_secret_key = keys[:sk]
  @origin_public_key = keys[:pk]
  @register_origin_result = register_user(first_name, last_name, @origin_username, keys[:pk])
end

Given(/^I have an existing target user$/) do
  first_name = 'bob'
  last_name = RandomStrings.generate_alpha 15
  keys = CryptoUtils::EcdsaUtil.new.create_key_pair

  @target_username = "#{first_name}_#{last_name}@test.com"
  @target_secret_key = keys[:sk]
  @target_public_key = keys[:pk]
  @register_target_result = register_user(first_name, last_name, @target_username, keys[:pk])
end

And(/^I have an authentication token as an origin user$/) do
  @origin_login_token = get_login_token(@origin_username, @origin_secret_key, @trusted_domain)
end

And(/^I have an authentication token as a target user$/) do
  @target_login_token = get_login_token(@target_username, @target_secret_key, @trusted_domain)
end

When(/^I send a connection request to the API$/) do
  @connection_result = create_connection_request(@origin_login_token, @origin_secret_key, @target_username)
end

And(/^the connection status should be "([^"]*)"$/) do |arg|
  assert @connection_result[:status] == arg
end

And(/^I have an unconfirmed connection request$/) do
  @origin_login_token = get_login_token(@origin_username, @origin_secret_key, @trusted_domain)
  @connection_result = create_connection_request(@origin_login_token, @origin_secret_key, @target_username)
  @connection_id = @connection_result[:id]
end

And(/^the origin user has one or more connections$/) do
  # create target
  first_name = 'bob'
  last_name = RandomStrings.generate_alpha 15
  keys = CryptoUtils::EcdsaUtil.new.create_key_pair

  @target_username = "#{first_name}_#{last_name}@test.com"
  @target_secret_key = keys[:sk]
  @target_public_key = keys[:pk]
  @register_target_result = register_user(first_name, last_name, @target_username, keys[:pk])

  @connection_result = create_connection_request(@origin_login_token, @origin_secret_key, @target_username)
end

When(/^I send a connection confirmation request to the API$/) do
  digest = Digest::SHA2.base64digest @origin_username
  signature = CryptoUtils::EcdsaUtil.new.sign digest, @target_secret_key

  puts 'Target login token: ' + @target_login_token

  payload = {
      :digest => digest,
      :signature => signature,
      :status => 'connected'
  }.to_json

  puts "Confirm connection payload: #{payload}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + "/connections/#{@connection_id}", payload, @target_login_token)
  puts "Confirm connection result: #{result.response_body}"
  puts "Response code: #{result.response_code}"

  @connection_result = JSON.parse(result.response_body, :symbolize_names => true)
end

When(/^I send a get connection list request to the API$/) do
  result = RestUtil.new.execute_get(IDENTITY_API_URI + '/connections', @origin_login_token)
  puts "Get connection list result: #{result.response_body}"
  puts "Response code: #{result.response_code}"

  @connection_list_result = JSON.parse(result.response_body, :symbolize_names => true)
end

Then(/^the connection endpoint should respond with a connection id$/) do
  assert @connection_result[:id] != nil
end

Then(/^the connection endpoint should respond with a collection of connections$/) do
  assert @connection_list_result.length > 0
end

###########
# HELPERS #
###########

def set_trusted_domain
  payload = {
      :domain => @trusted_domain,
      :aes_key => @encoded_domain_aes_key
  }.to_json

  puts "Create trusted domain payload: #{payload}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + '/trusts', payload, IDENTITY_API_AUTH_KEY)
  puts "Create trusted domain result: #{result.response_body}"
end

def register_user(first_name, last_name, username, public_key)
  payload = {
      :first_name => first_name,
      :last_name => last_name,
      :username => username,
      :password => 'passW0rd1!',
      :public_key => public_key
  }.to_json

  puts "Create user payload: #{payload}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + '/users', payload, nil)
  puts "Create user result: #{result.response_body}"
  puts "Response code: #{result.response_code}"

  JSON.parse(result.response_body, :symbolize_names => true)
end

def get_challenge(username)
  payload = {
      :username => username
  }.to_json

  puts "Create challenge payload: #{payload}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + '/challenge', payload, nil)
  puts "Create challenge result: #{result.response_body}"
  puts "Response code: #{result.response_code}"

  JSON.parse(result.response_body, :symbolize_names => true)
end

def login_user(username, challenge, secret_key, trusted_domain)
  # sign the challenge
  digest = Digest::SHA2.base64digest challenge
  signature = CryptoUtils::EcdsaUtil.new.sign digest, secret_key

  # now login
  payload = {
      :username => username,
      :challenge => {
          :digest => digest,
          :signature => signature
      },
      domain: trusted_domain
  }.to_json

  puts "Create login payload: #{payload}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + '/login', payload, nil)
  puts "Login user result: #{result.response_body}"
  puts "Response code: #{result.response_code}"

  JSON.parse(result.response_body, :symbolize_names => true)
end

def get_login_token(username, secret_key, trusted_domain)
  # get the challenge
  challenge = get_challenge(username)[:data]

  #login
  login_user(username, challenge, secret_key, trusted_domain)[:token]
end

def create_connection_request(origin_login_token, origin_secret_key, target_username)
  digest = Digest::SHA2.base64digest target_username
  signature = CryptoUtils::EcdsaUtil.new.sign digest, origin_secret_key

  payload = {
      :username => target_username,
      :digest => digest,
      :signature => signature
  }.to_json

  puts "Create connection payload: #{payload}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + '/connections', payload, origin_login_token)
  puts "Create connection user result: #{result.response_body}"
  puts "Response code: #{result.response_code}"

  JSON.parse(result.response_body, :symbolize_names => true)
end