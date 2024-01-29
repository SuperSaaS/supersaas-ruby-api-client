#!/usr/bin/env ruby
# frozen_string_literal: true

require 'supersaas-api-client'

puts "# SuperSaaS Schedules Example"

unless Supersaas::Client.instance.account_name && Supersaas::Client.instance.api_key
  puts "ERROR! Missing account credentials. Rerun the script with your credentials, e.g."
  puts "SSS_API_ACCOUNT_NAME=<myaccountname> SSS_API_KEY=<xxxxxxxxxxxxxxxxxxxxxx> ./examples/users.rb"
  return
end

puts "## Account:  #{Supersaas::Client.instance.account_name}"
puts "## API KEY: #{'*' * Supersaas::Client.instance.api_key.size}"

Supersaas::Client.instance.verbose = true

puts "listing schedules..."
puts "#### Supersaas::Client.instance.schedules.list"
schedules = Supersaas::Client.instance.schedules.list

puts "listing schedule resources..."
[10, schedules.size].min&.times do |i|
  puts "#### Supersaas::Client.instance.schedules.resources(#{schedules[i].id})"
  # Capacity schedules bomb
  begin
  Supersaas::Client.instance.schedules.resources(schedules[i].id)
  rescue
    next
  end
end

puts "puts listing fields..."
[10, schedules.size].min&.times do |i|
  puts "#### Supersaas::Client.instance.schedules.field_list(#{schedules[i].id})"
  Supersaas::Client.instance.schedules.field_list(schedules[i].id)
end
puts
