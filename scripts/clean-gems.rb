#!/usr/bin/env ruby

raw = `gem list --no-version`
gems = raw.split("\n")

excluded = ['bundler', 'bigdecimal', 'io-console', 'json', 'minitest', 'psych', 'rake', 'rdoc', 'test-unit']

skipped_msgs = []
skipped_bundler = false

gems.each do |gem|
  if gem == 'bundler'
    skipped_bundler = true
  elsif excluded.include?(gem)
    skipped_msgs << "#{gem}\n"
  else
    system "gem uninstall -Vax --force --no-abort-on-dependent #{gem}"
  end
end

puts '=== INFO ==='
puts 'skipped the following default gems'
puts skipped_msgs

if skipped_bundler
  puts ''
  puts '=== WARN =='
  puts 'skipped bundler because it is necessary gem'
end
