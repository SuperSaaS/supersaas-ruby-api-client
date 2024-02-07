#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'supersaas-api-client'

puts '# SuperSaaS Appointments Example'

unless Supersaas::Client.instance.account_name && Supersaas::Client.instance.api_key
  puts 'ERROR! Missing account credentials. Rerun the script with your credentials, e.g.'
  puts 'SSS_API_ACCOUNT_NAME=<myaccountname> SSS_API_KEY=<api_key> ./examples/appointments.rb'
  return
end

puts "## Account:  #{Supersaas::Client.instance.account_name}"
puts "## API Key: #{'*' * Supersaas::Client.instance.api_key.size}"

Supersaas::Client.instance.verbose = true

if ENV['SSS_API_SCHEDULE']
  schedule_id = ENV['SSS_API_SCHEDULE']
  show_slot = ENV['SSS_API_SLOT'] ? true : false
else
  puts 'ERROR! Missing schedule id. Rerun the script with your schedule id, e.g.'
  puts '    SSS_API_SCHEDULE=<scheduleid> ./examples/appointments.rb'
  return
end

# give
user_id = ENV.fetch('SSS_API_USER', nil)

unless user_id
  puts 'User is created and then deleted at the end'
  params = { full_name: 'Example', name: 'example@example.com', email: 'example@example.com', api_key: 'example' }
  user = Supersaas::Client.instance.users.create(params)
  user_id = user.match(%r{users/(\d+)\.json})[1]
  puts "#New user created #{user_id}"
end

description = nil
if user_id
  description = '1234567890.'
  params = { full_name: 'Example', description: description, name: 'example@example.com', email: 'example@example.com',
             mobile: '555-5555', phone: '555-5555', address: 'addr' }
  if show_slot
    params[:slot_id] = ENV.fetch('SSS_API_SLOT', nil)
  else
    days = rand(1..30)
    params[:start] = Time.now + (days * 24 * 60 * 60)
    params[:finish] = params[:start] + (60 * 60)
  end
  puts 'creating new appointment...'
  puts "#### Supersaas::Client.instance.appointments.create(#{schedule_id}, #{user_id}, {...})"
  Supersaas::Client.instance.appointments.create(schedule_id, user_id, params)
else
  puts 'skipping create/update/delete (NO DESTRUCTIVE ACTIONS FOR SCHEDULE DATA)...'
end

puts 'listing appointments...'
puts "#### Supersaas::Client.instance.appointments.list(#{schedule_id}, nil, nil, 25)"

appointments = Supersaas::Client.instance.appointments.list(schedule_id, nil, nil, 25)

if appointments.size.positive?
  appointment_id = appointments.sample.id
  puts 'getting appointment...'
  puts "#### Supersaas::Client.instance.appointments.get(#{appointment_id})"
  Supersaas::Client.instance.appointments.get(schedule_id, appointment_id)
end

puts 'listing changes...'
from = DateTime.now - 120
to = DateTime.now + 360_000
puts "#### Supersaas::Client.instance.appointments.changes(#{schedule_id},
  '#{from.strftime('%Y-%m-%d %H:%M:%S')}', '#{to.strftime('%Y-%m-%d %H:%M:%S')}', #{show_slot || 'false'})"

Supersaas::Client.instance.appointments.changes(schedule_id, from, show_slot)

puts 'listing available...'
from = DateTime.now
puts "#### Supersaas::Client.instance.appointments.available(#{schedule_id},
  '#{from.strftime('%Y-%m-%d %H:%M:%S')}')"

Supersaas::Client.instance.appointments.available(schedule_id, from)

puts 'Appointments for a single user...'
user = Supersaas::Client.instance.users.list(nil, 1).first
from = DateTime.now
puts "#### Supersaas::Client.instance.appointments.agenda(#{schedule_id}, user.id,
  '#{from.strftime('%Y-%m-%d %H:%M:%S')}')"
Supersaas::Client.instance.appointments.agenda(schedule_id, user.id, from.strftime('%Y-%m-%d %H:%M:%S'))

# Update and delete appointments
appointments.each do |appointment|
  puts "#{description} == #{appointment.description}"
  next unless description == appointment.description

  puts 'updating appointment...'
  puts "#### Supersaas::Client.instance.appointments.update(#{schedule_id}, #{appointment.id}, {...})"
  Supersaas::Client.instance.appointments.update(schedule_id, appointment.id, { country: 'FR', address: 'Rue 1' })

  puts 'deleting appointment...'
  puts "#### Supersaas::Client.instance.appointments.delete(#{schedule_id}. #{appointment.id})"
  Supersaas::Client.instance.appointments.delete(schedule_id, appointment.id)
  break
end

# Puts delete user
Supersaas::Client.instance.users.delete(user_id) unless ENV.fetch('SSS_API_USER', nil)
