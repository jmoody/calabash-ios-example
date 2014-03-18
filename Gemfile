source 'https://rubygems.org'

# use bundle and bundle config to specify local gem locations
# bundle config local.GEM_NAME /path/to/local/git/repository

username = `whoami`.strip

#noinspection GemInspection
#noinspection RailsParamDefResolve
case username

  when 'moody'

    gem 'calabash-cucumber', :github => 'jmoody/calabash-ios', :branch => 'master'
    gem 'briar', '0.1.4.b2'

  when 'your username here'

  else
    gem 'calabash-cucumber'
end
