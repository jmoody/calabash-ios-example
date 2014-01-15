source 'https://rubygems.org'
if `whoami`.strip.eql? 'moody'

  # i use bundle and bundle config to specify local gem locations
  # bundle config local.GEM_NAME /path/to/local/git/repository
  #noinspection GemInspection,RailsParamDefResolve
  gem 'calabash-cucumber', :github => 'jmoody/calabash-ios', :branch => '0.9.x-escaping-backslash-issue-284'

else
  #noinspection GemInspection
  gem 'calabash-cucumber'
end

gem 'rake'
#gem 'mime-types', '1.25'
