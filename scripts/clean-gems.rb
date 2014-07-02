#!/usr/bin/env ruby

rubygems_version = `gem --version`.strip!

if rubygems_version != '2.3.0'
  puts "FAIL: found rubygems gem version '#{rubygems_version}'"
  puts "FAIL: please run"
  puts "FAIL:   $ gem system --update"
  puts "FAIL: and rerun this command"
  exit 1
end

raw = `gem list --no-version`
gems = raw.split("\n")

excluded = ['bundler', 'bigdecimal', 'io-console', 'json', 'minitest', 'psych', 'rake', 'rdoc', 'test-unit']

skipped_msgs = []
skipped_bundler = false

gems.each do |gem|
  if gem == 'bundler'
    skipped_bundler = true
  elsif excluded.include?(gem)
    skipped_msgs << "* #{gem}\n"
  else
    system "gem uninstall -Vax --force --no-abort-on-dependent #{gem}"
  end
end

puts ''
puts '=== INFO ==='
puts ''
puts 'skipped the following default gems which cannot be uninstalled'
puts ''
puts skipped_msgs

if skipped_bundler
  puts ''
  puts '=== WARN =='
  puts 'skipped bundler because it is necessary gem'
end
