module Calabash
  module Example
    module Device

    end
  end
end

begin

  World(Calabash::Example::Device)

  Then(/^I should be able call the device function$/) do
    default_device()
  end

rescue
  puts 'loaded Calabash::Example::Device'
end