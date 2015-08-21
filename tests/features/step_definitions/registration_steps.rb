require 'json'
require 'minitest'

require_relative '../../../tests/config'
require_relative '../../../tests/helpers/random_strings'

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
  @auth_header = IDENTITY_API_AUTH_KEY

  payload = {
      :first_name => @first_name,
      :last_name => @last_name,
      :username => @username,
      :password => @password,
      :public_key => @encoded_public_key,
      :email => @email
  }.to_json

  puts "Create user payload: #{payload}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + '/users', @auth_header, payload)
  puts "Create user result: #{result.response_body}"
  puts "Response code: #{result.response_code}"

  @registration_response_code = result.response_code
  @registration_result = JSON.parse(result.response_body, :symbolize_names => true)
end

Then(/^the registration endpoint should respond with a (\d+) response code$/) do |arg|
  assert @registration_response_code.to_s == arg.to_s
end

Then(/^the registration endpoint should respond with a user id$/) do
  assert @registration_result[:id] != nil
end

And(/^an error message of "([^"]*)"$/) do |arg|
  errors = @registration_result[:errors]
  assert errors[0] == arg
end


# update steps

And(/^a new password$/) do
  pending
end

And(/^a new public ECDSA key$/) do
  pending
end

When(/^I send an update request to the API$/) do
  pending
end