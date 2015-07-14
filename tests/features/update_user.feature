Feature: Update an existing user
  Should be able to update an existing user

  Scenario: Update user with new username and public key
    Given a username
    And a password
    And a public ECDSA key
    And a new password
    And a new public ECDSA key
    When I send an update request to the API
    Then the registration endpoint should respond with a user id