source 'https://rubygems.org'

# use bundle and bundle config to specify local gem locations
# bundle config local.GEM_NAME /path/to/local/git/repository

username = `whoami`.strip

#noinspection GemInspection
#noinspection RailsParamDefResolve
case username

  when 'moody'

    gem 'calabash-cucumber', :github => 'calabash/calabash-ios', :branch => 'fix/operations-and-minitest-should-be-19-compat'

    #gem 'xamarin-test-cloud', :git => 'git@github.com:jmoody/test-cloud-command-line.git', :branch => 'master'

  when 'your username here'

  else
    gem 'calabash-cucumber'
end

gem 'xcpretty'
