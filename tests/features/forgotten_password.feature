Feature: Reset forgotten password
  Should be able to reset a forgotten password

  Scenario: Create a new password
    Given I am a registered user
    And I have forgotten my password
    When I initiate an OTP request
    And I save the response nonce
    And I have received an OTP via SMS
    When I send a password request to the API
    Then the otp endpoint should respond with a 200 response code