Feature: to reset or not reset


  Scenario: example steps
    Given I am on the Welcome Screen
    Then I swipe left
    And I wait until I don't see "Please swipe left"
    And take picture
