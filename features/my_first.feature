Feature: Running a test
  As an iOS developer
  I want to have a sample feature file
  So I can begin testing quickly

  Scenario: device function
    Then I should be able call the device function

  Scenario: example steps
    Given I am on the Welcome Screen
    Then I swipe left
    And I wait until I don't see "Please swipe left"
    And take picture

  Scenario: smoke test the minitest problem
    Then I use the operations module method labels
