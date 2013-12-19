module Calabash
  module Example
    module Device
      def device
        url = URI.parse(ENV['DEVICE_ENDPOINT']|| 'http://localhost:37265/')
        http = Net::HTTP.new(url.host, url.port)
        res = http.start do |sess|
          sess.request Net::HTTP::Get.new(ENV['CALABASH_VERSION_PATH'] || 'version')
        end
        status = res.code

        #noinspection RubyUnusedLocalVariable
        begin
          http.finish if http and http.started?
        rescue Exception => e
          $stderr.puts "\ncould not create Device object: #{e}"
          return nil
        end

        device = nil
        begin
          if status=='200'
            version_body = JSON.parse(res.body)
            device = Calabash::Cucumber::Device.new(url, version_body)
          end
        rescue Exception => e
          $stderr.puts "\ncould not create Device object: #{e}"
          # ignored
        end

        device
      end
    end
  end
end

World(Calabash::Example::Device)


Then(/^I should be able call the device function$/) do
  device()
end