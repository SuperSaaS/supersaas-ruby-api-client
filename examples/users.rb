#!/usr/bin/env ruby
# frozen_string_literal: true

require 'supersaas-api-client'

puts '# SuperSaaS Users Example'

unless Supersaas::Client.instance.account_name && Supersaas::Client.instance.api_key
  puts 'ERROR! Missing account credentials. Rerun the script with your credentials, e.g.'
  puts 'SSS_API_ACCOUNT_NAME=<myaccountname> SSS_API_KEY=<xxxxxxxxxxxxxxxxxxxxxx> ./examples/users.rb'
  return
end

puts "## Account:  #{Supersaas::Client.instance.account_name}"
puts "## API Key: #{'*' * Supersaas::Client.instance.api_key.size}"

Supersaas::Client.instance.verbose = true

puts 'creating new user...'
puts '#### Supersaas::Client.instance.users.create({...})'
params = { full_name: 'Example', name: 'example@example.com', email: 'example@example.com', api_key: 'example' }
Supersaas::Client.instance.users.create(params)
new_user_id = nil

puts 'listing users...'
puts '#### Supersaas::Client.instance.users.list(nil, 50)'

users = Supersaas::Client.instance.users.list(nil, 50)
users.each do |user|
  new_user_id = user.id if user.name == params[:email]
end

if new_user_id
  puts 'getting user...'
  puts "#### Supersaas::Client.instance.users.get(#{new_user_id})"
  user = Supersaas::Client.instance.users.get(new_user_id)

  puts 'updating user...'
  puts "#### Supersaas::Client.instance.users.update(#{new_user_id})"
  Supersaas::Client.instance.users.update(new_user_id, { country: 'FR', address: 'Rue 1' })

  puts 'deleting user...'
  puts "#### Supersaas::Client.instance.users.delete(#{user.id})"
  Supersaas::Client.instance.users.delete(user.id)
else
  puts '... did not find user in list'
end

puts 'creating user with errors...'
puts '#### Supersaas::Client.instance.users.create'
begin
  Supersaas::Client.instance.users.create({ name: 'error' })
rescue Supersaas::Exception => e
  puts "This raises an error #{e.message}"
end

puts '#### Supersaas::Client.instance.users.field_list'
Supersaas::Client.instance.users.field_list
puts
