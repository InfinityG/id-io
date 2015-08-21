Feature: Register a new user
  Should be able to register a new user

  Scenario: Register user with full details
    Given a first name
    And a last name
    And a username
    And a password
    And a public ECDSA key
    And an email address
    When I send a registration request to the API
    Then the registration endpoint should respond with a user id

  Scenario: Register user with no public ECDSA key
    Given a first name
    And a last name
    And a username
    And a password
    When I send a registration request to the API
    Then the registration endpoint should respond with a 400 response code
    And an error message of "Invalid public key"

  Scenario: Register user with missing first name
    Given a last name
    And a username
    And a password
    When I send a registration request to the API
    Then the registration endpoint should respond with a 400 response code
    And an error message of "Invalid first name"

  Scenario: Register user with missing last name
    Given a first name
    And a username
    And a password
    When I send a registration request to the API
    Then the registration endpoint should respond with a 400 response code
    And an error message of "Invalid last name"

  Scenario: Register user with missing username
    Given a first name
    And a last name
    And a password
    When I send a registration request to the API
    Then the registration endpoint should respond with a 400 response code
    And an error message of "Invalid username"

  Scenario: Register user with invalid password
    Given a first name
    And a last name
    And a username
    And an invalid password
    When I send a registration request to the API
    Then the registration endpoint should respond with a 400 response code
    And an error message of "Invalid password. Minimum 8 characters length, with at least 1 upper case, 1 numeric and 1 special character"

  Scenario: Register user with missing password
    Given a first name
    And a last name
    And a username
    When I send a registration request to the API
    Then the registration endpoint should respond with a 400 response code
    And an error message of "Invalid password. Minimum 8 characters length, with at least 1 upper case, 1 numeric and 1 special character"