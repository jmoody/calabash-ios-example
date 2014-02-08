source 'https://rubygems.org'

if File.exists?('.calabash-gem')
  branch_info = IO.readlines('.calabash-gem')
  path = branch_info[0].strip
  branch = branch_info[1].strip
  #noinspection GemInspection
  gem 'calabash-cucumber', :path => path, :branch => branch
else
  gem 'calabash-cucumber'
end

gem 'rake'
# required for 1.8.7 compat
gem 'mime-types', '1.25'