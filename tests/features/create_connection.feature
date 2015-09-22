Feature: Create a new connection
  Should be able to connect to a user

  Scenario: Create a new connection as an origin user
    Given I have an existing origin user
    And I have an existing target user
    And I have an authentication token as an origin user
    When I send a connection request to the API
    Then the connection endpoint should respond with a connection id
    And the connection status should be "pending"

  Scenario: Confirm a connection as a target user
    Given I have an existing origin user
    And I have an existing target user
    And I have an authentication token as a target user
    And I have an unconfirmed connection request
    When I send a connection confirmation request to the API
    And the connection status should be "connected"

  Scenario: Get list of connections for an origin user
    Given I have an existing origin user
    And I have an authentication token as an origin user
    And the origin user has one or more connections
    When I send a get connection list request to the API
    Then the connection endpoint should respond with a collection of connections