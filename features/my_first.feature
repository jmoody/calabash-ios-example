Feature: to reset or not reset

  @reset_app
  Scenario: device function
    Then I should be able call the device function

  @reset_simulator
  Scenario: example steps
    Given I am on the Welcome Screen
    Then I swipe left
    And I wait until I don't see "Please swipe left"
    And take picture

  Scenario: smoke test the minitest problem
    Then I use the operations module method labels
