And(/^I have forgotten my password$/) do
  @password = nil
end

When(/^I initiate an OTP request$/) do
  payload = {
      :username => @username
  }.to_json

  puts "Create OTP payload: #{payload}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + '/users/otp', payload, nil)
  puts "Create OTP result: #{result.response_body}"

  @otp_response = JSON.parse(result.response_body, :symbolize_names => true)
end


And(/^I save the response nonce$/) do
  @nonce = @otp_response[:nonce]
end

And(/^I have received an OTP via SMS$/) do
  @otp = '9999'
end

When(/^I send a password request to the API$/) do
  payload = {
      :username => @username,
      :otp => @otp,
      :nonce => @nonce,
      :password => 'Passw0rd3!'
  }.to_json

  puts "Create password reset payload: #{payload}"

  result = RestUtil.new.execute_post(IDENTITY_API_URI + '/users/reset', payload, nil)
  puts "Create passwprd reset result: #{result.response_body}"

  @reset_response_code = result.response_code
  @reset_response = JSON.parse(result.response_body, :symbolize_names => true)
end

Then(/^the otp endpoint should respond with a (\d+) response code$/) do |arg|
  assert @reset_response_code.to_s == arg.to_s
end