Feature: Logging in with a challenge
  Should be able to login with a username and challenge data

  Scenario: Login with a challenge
    Given I am a registered user
    And I want to login to a trusted domain
    And I have requested a challenge
    And I have signed the challenge data
    When I log in with a challenge
    Then the login endpoint should respond with an encrypted auth response

  Scenario: Login with a challenge with missing username
    Given I am a registered user
    And I want to login to a trusted domain
    And I have requested a challenge
    And I have a missing username
    When I log in with a challenge
    Then the login endpoint should respond with a 400 response code

  Scenario: Login with a challenge with missing signature
    Given I am a registered user
    And I want to login to a trusted domain
    And I have requested a challenge
    And I have a missing challenge signature
    When I log in with a challenge
    Then the login endpoint should respond with a 400 response code

  Scenario: Login with a challenge with invalid signature
    Given I am a registered user
    And I want to login to a trusted domain
    And I have requested a challenge
    And I have an invalid challenge signature
    When I log in with a challenge
    Then the login endpoint should respond with a 401 response code

  Scenario: Login with a challenge with invalid challenge data
    Given I am a registered user
    And I want to login to a trusted domain
    And I have invalid challenge data
    And I have signed the challenge data
    When I log in with a challenge
    Then the login endpoint should respond with a 401 response code

  Scenario: Login with a challenge with invalid username
    Given I am a registered user
    And I want to login to a trusted domain
    And I have requested a challenge
    And I have an invalid challenge username
    When I log in with a challenge
    Then the login endpoint should respond with a 401 response code