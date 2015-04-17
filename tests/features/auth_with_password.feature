Feature: Logging in with a password
  Should be able to login with a username and password

  Scenario: Login with a password
    Given I am a registered user
    And I want to login to a trusted domain
    When I log in with a password
    Then the login endpoint should respond with an encrypted auth response