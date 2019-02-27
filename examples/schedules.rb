#!/usr/bin/env ruby

require "supersaas-api-client"

puts "\n\r# SuperSaaS Schedules Example\n\r"

unless Supersaas::Client.instance.account_name && Supersaas::Client.instance.api_key
  puts "ERROR! Missing account credentials. Rerun the script with your credentials, e.g.\n\r"
  puts "    SSS_API_ACCOUNT_NAME=<myaccountname> SSS_API_KEY=<xxxxxxxxxxxxxxxxxxxxxx> ./examples/users.rb\n\r"
  return
end

puts "## Account:  #{Supersaas::Client.instance.account_name}"
puts "## API KEY: #{'*' * Supersaas::Client.instance.api_key.size}\n\r"

Supersaas::Client.instance.verbose = true

puts "\n\rlisting schedules..."
puts "\n\r#### Supersaas::Client.instance.schedules.list\n\r"
schedules = Supersaas::Client.instance.schedules.list

puts "\n\rlisting schedule resources..."
[10, schedules.size].min.times do |i|
  puts "\n\r#### Supersaas::Client.instance.schedules.resources(#{schedules[i].id})\n\r"
  Supersaas::Client.instance.schedules.resources(schedules[i].id)
end
puts