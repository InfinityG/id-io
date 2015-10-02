require 'json'
require 'minitest'

require_relative '../../../tests/config'
require_relative '../../../tests/helpers/random_strings'

Before do
  @trusted_domain = 'www.testdomain.com'
  @encoded_domain_aes_key = 'ky4xgi0+KvLYmVp1J5akqkJkv8z5rJsHTo9FcBc0hgo='

  set_trusted_domain
end

Given(/^a first name$/) do
  @first_name = 'Johnny'
end

And(/^a last name$/) do
  @last_name = RandomStrings.generate_alpha 15
end

And(/^a username$/) do
  @username =  "#{@first_name}_#{@last_name}"
end

And(/^a password$/) do
  @password = 'passWOrd1!'
  end

And(/^a mobile number$/) do
  @mobile_number = '+21234567890'
end

And(/^an invalid password$/) do
  @password = 'password'
end

And(/^a public ECDSA key$/) do
  @encoded_public_key = 'Ag7PunGy2BmnAi+PGE4/Dm9nCg1URv8wLZwSOggyfmAn' # already base64 encoded
end

And(/^an email address$/) do
  @email = "#{@first_name}_#{@last_name}@test.com"
end

When(/^I send a registration request to the API$/) do
  payload = {
      :first_name => @first_name,
      :last_name => @last_name,
      :username => @username,
      :password => @password,
      :public_key => @encoded_public_key,
      :email => @email,
      :mobile_number => @mobile_number,
      :meta => 'KHJG9809890'
  }.to_json

  puts "Create user payload: #{payload}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + '/users', nil, payload)
  puts "Create user result: #{result.response_body}"
  puts "Response code: #{result.response_code}"

  @final_response_code = result.response_code
  @final_result = JSON.parse(result.response_body, :symbolize_names => true)
end

Then(/^the registration endpoint should respond with a (\d+) response code$/) do |arg|
  assert @final_response_code.to_s == arg.to_s
end

Then(/^the registration endpoint should respond with a user id$/) do
  assert @final_result[:id] != nil
end

And(/^an error message of "([^"]*)"$/) do |arg|
  errors = @final_result[:errors]
  assert errors[0] == arg
end


# update steps

Given(/^I am logged in$/) do
  steps '
    Given a first name
    And a last name
    And a username
    And a password
    And a public ECDSA key
    And an email address
    And a mobile number
    When I send a registration request to the API
  '
  result = login
  login_result = JSON.parse(result.response_body, :symbolize_names => true)
  @auth_header = login_result[:token]
end

And(/^a new password$/) do
  @new_password = 'passWOrd2!'
end

And(/^a new public ECDSA key$/) do
  @new_encoded_public_key = 'A7Py51+u02FKpTyA0AaJpYseuUSmrFvg89qlr73CvOt6' # already base64 encoded
end

When(/^I send an update request to the API$/) do

  payload = {
      :password => @new_password,
      :public_key => @new_encoded_public_key
  }.to_json

  puts "Update user payload: #{payload}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + "/users/#{@username}", @auth_header, payload)
  puts "Update user result: #{result.response_body}"
  puts "Response code: #{result.response_code}"

  @final_response_code = result.response_code
  @final_result = JSON.parse(result.response_body, :symbolize_names => true)
end

#########
# HELPERS
#########

def set_trusted_domain
  payload = {
      :domain => @trusted_domain,
      :aes_key => @encoded_domain_aes_key
  }.to_json

  puts "Create trusted domain payload: #{payload}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + '/trusts', IDENTITY_API_AUTH_KEY, payload)
  puts "Create trusted domain result: #{result.response_body}"
end

def login
  payload = {
      :username => @username,
      :password => @password,
      :domain => @trusted_domain
  }.to_json

  puts "Login payload: #{payload}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + '/login', nil, payload)
  puts "Login result: #{result.response_body}"
  puts "Response code: #{result.response_code}"

  result
end


