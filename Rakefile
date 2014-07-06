require 'irb'
require 'awesome_print'
require 'retriable'
require 'dotenv'
require 'yaml'

Dotenv.load

desc 'generate a cucumber tag report'
task :tags do sh 'cucumber -d -f Cucumber::Formatter::ListTags' end

# return the device info by reading and parsing the relevant file in the
# ~/.xamarin directory
#
#   read_device_info('neptune', :udid) # => reads the neptune udid (iOS)
#   read_device_info('earp', :ip)      # => reads the earp udid (iOS)
#   read_device_info('r2d2', :serial)  # => read the r2d2 serial number (android)
def read_device_info (device, kind)
  kind = kind.to_sym
  kinds = [:ip, :udid, :serial]
  unless kinds.include?(kind)
    raise "#{kind} must be one of '#{kinds}'"
  end
  cmd = "cat ~/.xamarin/devices/#{device}/#{kind} | tr -d '\n'"
  `#{cmd}`
end

# return a +Hash+ of XTC device sets where the key is some arbitrary description
# and the value is a <tt>XTC device set</tt>
def read_device_sets(path='~/.xamarin/test-cloud/ios-sets.csv')
  ht = Hash.new
  File.read(File.expand_path(path)).split("\n").each do |line|
    unless line[0].eql?('#')
      tokens = line.split(',')
      ht[tokens[0]] = tokens[1]
    end
  end
  ht
end

# return a +String+ representation of an XTC account API token
def read_api_token(account_name)
  path = File.expand_path("~/.xamarin/test-cloud/#{account_name}")

  unless File.exist?(path)
    puts "cannot read account information for '#{account_name}'"
    raise "file '#{path}' does not exist"
  end

  begin
    IO.readlines(path).first.strip
  rescue Exception => e
    puts "cannot read account information for '#{account_name}'"
    raise e
  end
end

desc 'prints a hash of defined XTC device sets'
task :sets do
  ht = read_device_sets
  ap ht
end


# noinspection RubyStringKeysInHashInspection
def ruby_versions
  {
        '21' => '2.1.2',
        '20' => '2.0.0-p353',
        '19' => '1.9.3-p484',
  }
end

def switch_ruby_version(version)
  versions = ruby_versions
  unless versions[version]
    raise "expected version '#{version}' to be one of '#{versions}'"
  end
  sh "rbenv local #{versions[version]}"
  sh 'rbenv rehash'
end

task :ruby19 do switch_ruby_version('19') end
task :ruby20 do switch_ruby_version('20') end
task :ruby21 do switch_ruby_version('21') end

task :clean_gems do
  system 'bundle clean --force'
end

def idv_bundle_installed(udid, bundle_id, installer = '/usr/local/bin/ideviceinstaller')
  cmd = "#{installer} -u #{udid} -l"
  puts cmd
  `#{cmd}`.strip.split(/\s/).include? bundle_id
end

def idv_install(udid, ipa, bundle_id, installer = '/usr/local/bin/ideviceinstaller')
  if idv_bundle_installed udid, bundle_id, installer
    puts "bundle '#{bundle_id}' is already installed"
    return true
  end

  cmd = "#{installer} -u #{udid} --install #{ipa}"
  system cmd
  unless idv_bundle_installed(udid, bundle_id, installer)
    raise "could not install '#{ipa}' on '#{udid}' with '#{bundle_id}'"
  end
  true
end

def idv_uninstall(udid, bundle_id, installer = '/usr/local/bin/ideviceinstaller')
  unless idv_bundle_installed udid, bundle_id, installer
    return true
  end
  cmd = "#{installer} -u #{udid} --uninstall #{bundle_id}"
  system cmd
  if idv_bundle_installed(udid, bundle_id, installer)
    raise "could not uninstall '#{bundle_id}' on '#{udid}'"
  end
  true
end

task :test_devices do

  system 'xtc-prepare.sh'

  candidates = ['venus', 'mars', 'saturn', 'neptune', 'earp']
  connected = `instruments -s devices`.strip.split(/\s/)
  devices = []
  candidates.each do |candidate|
    if connected.include? candidate
      devices << candidate
    end
  end

  #devices = ['earp']
  ipa = './xtc-staging/LPSimpleExample-cal.ipa'
  installer = '/usr/local/bin/ideviceinstaller'
  bundle_id = 'com.lesspainful.example.LPSimpleExample-cal'
  devices.each do |device|
    udid = read_device_info(device, :udid)

    Retriable.retriable do
      idv_uninstall udid, bundle_id, installer
    end

    Retriable.retriable do
      idv_install udid, ipa, bundle_id, installer
    end

    system "cucumber -p #{device}"

    Retriable.retriable do
      idv_uninstall udid, bundle_id, installer
    end
  end
end


namespace :not_working do
# not working
  desc "submit a job to the XTC - $ rake xtc['0b00ad15','default']"
#noinspection RubyUnusedLocalVariable
  task :xtc, :device_set, :profile do |t, args|
    unless args.count == 2
      puts 'Usage: rake xtc[<device-set>,<profile>]'
      puts 'ex.    rake xtc[airs,login]'
      puts 'ex.    rake xtc[0b00ad15,default]'
      puts "expected 2 args - device set, profile, account - found '#{args}'"
      exit 1
    end

    dotenv = File.expand_path('./.env')
    unless File.exists?(dotenv)
      puts 'expected a .env file'
      puts "if you haven't already, copy the dotenv-example to .env and update the contents"
      puts '1. $ cp dotenv-example .env'
      puts '2. update the contents of .env'
      exit 1
    end

    system 'xtc-prepare.sh'

    staging_dir = './xtc-staging'
    config_dir = './config'
    xtc_profiles = "#{config_dir}/xtc-profiles.yml"

    features_dir = './features'


    ipa = ENV['IPA']
    if ipa.nil? or ipa == ''
      raise 'expected IPA to be defined - check your .env file'
    end

    ipa = File.expand_path(ipa)
    unless File.exists?(ipa)
      puts "IPA points to a file that does not exist '#{ipa}'"
      exit 1
    end

    series = ENV['XTC_SERIES']
    if series.nil? or series == ''
      puts 'expected XTC_SERIES to be defined - check your .env file'
      exit 1
    end

    locale = ENV['XTC_LOCALE']
    if locale.nil? or locale == ''
      puts 'expected XTC_LOCALE to be defined - check your .env file'
      exit 1
    end

    xtc_account = ENV['XTC_ACCOUNT']
    if xtc_account.nil? or xtc_account == ''
      puts 'expected XTC_ACCOUNT to be defined - check your .env file'
      exit 1
    end

    api_token = read_api_token xtc_account


    profile = args.profile
    profiles = YAML.load_file(xtc_profiles)
    unless profiles[profile]
      puts "expected '#{profile}' to be one of '#{profiles.keys}'"
      puts "could not find '#{profile}' in '#{xtc_profiles}'"
      exit 1
    end

    device_set = args.device_set
    sets = read_device_sets
    if sets[device_set]
      device_set = sets[device_set]
    end

    async = '--async'
    if ENV['XTC_WAIT_FOR_RESULTS'] == '1'
      async = '--no-async'
    end

    app_name = 'LPSimpleExample'

    args = [ipa,
            api_token,
            "-d #{device_set}",
            '-c cucumber.yml',
            "-p #{profile}",
            "-a \"#{app_name}\"",
            "--series  \"#{series}\"",
            "--locale \"#{locale}\"",
            async]

    shasum = `shasum #{staging_dir}/#{ipa}`
    puts "INFO: ipa sha => #{shasum}"
    cmd = "bundle exec test-cloud submit #{args.join(' ')}"
    puts "cd xtc-staging; #{cmd}"
    Dir.chdir(staging_dir) do
      system 'bundle install'
      exec cmd
    end
  end
end
