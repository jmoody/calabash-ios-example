module Calabash
  module Example
    module Device

    end
  end
end

World(Calabash::Example::Device)

Then(/^I should be able call the device function$/) do
  default_device()
end

Given /^I am on the Welcome Screen$/ do
  element_exists("view")
  sleep(STEP_PAUSE)
end

Then /^I use the operations module method labels$/ do
  # defined in operations.rb - trying to force bad output
  res = label("*")
end
