#!/usr/bin/env ruby

require "supersaas-api-client"

puts "\n\r# SuperSaaS Users Example\n\r"

unless Supersaas::Client.instance.account_name && Supersaas::Client.instance.api_key
  puts "ERROR! Missing account credentials. Rerun the script with your credentials, e.g.\n\r"
  puts "    SSS_API_ACCOUNT_NAME=<myaccountname> SSS_API_KEY=<xxxxxxxxxxxxxxxxxxxxxx> ./examples/users.rb\n\r"
  return
end

puts "## Account:  #{Supersaas::Client.instance.account_name}"
puts "## API Key: #{'*' * Supersaas::Client.instance.api_key.size}\n\r"

Supersaas::Client.instance.verbose = true

puts "creating new user..."
puts "\n\r#### Supersaas::Client.instance.users.create({...})\n\r"
params = {full_name: 'Example', name: 'example@example.com', email: 'example@example.com', api_key: 'example'}
Supersaas::Client.instance.users.create(params)
new_user_id = nil

puts "\n\rlisting users..."
puts "\n\r#### Supersaas::Client.instance.users.list(nil, 50)\n\r"

users = Supersaas::Client.instance.users.list(nil, 50)
users.each do |user|
  new_user_id = user.id if user.name == params[:email]
end

if new_user_id
  puts "\n\rgetting user..."
  puts "\n\r#### Supersaas::Client.instance.users.get(#{new_user_id})\n\r"
  user = Supersaas::Client.instance.users.get(new_user_id)

  puts "\n\rupdating user..."
  puts "\n\r#### Supersaas::Client.instance.users.update(#{new_user_id})\n\r"
  Supersaas::Client.instance.users.update(new_user_id, {country: 'FR', address: 'Rue 1'})

  puts "\n\rdeleting user..."
  puts "\n\r#### Supersaas::Client.instance.users.delete(#{user.id})\n\r"
  Supersaas::Client.instance.users.delete(user.id)
else
  puts "\n\r... did not find user in list"
end

puts "\n\rcreating user with errors..."
puts "\n\r#### Supersaas::Client.instance.users.create\n\r"
Supersaas::Client.instance.users.create({name: 'error'})
puts

puts "\n\r#### Supersaas::Client.instance.users.field_list\n\r"
Supersaas::Client.instance.users.field_list
puts