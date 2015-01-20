#!/usr/bin/env ruby

require 'fileutils'

app = File.expand_path('./LPSimpleExample-cal.app')
ipa = File.expand_path('./LPSimpleExample-cal.ipa')

# calabash-ios
rspec_resources_dir = File.expand_path('~/git/calabash-ios/calabash-cucumber/spec/resources')
FileUtils.cp_r(app, rspec_resources_dir)
FileUtils.cp_r(ipa, rspec_resources_dir)

cucumber_dir = File.expand_path('~/git/calabash-ios/calabash-cucumber/test/cucumber')
FileUtils.cp_r(app, cucumber_dir)
