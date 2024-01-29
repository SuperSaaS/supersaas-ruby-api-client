#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'supersaas-api-client'

puts "\n# SuperSaaS Appointments Example"

unless Supersaas::Client.instance.account_name && Supersaas::Client.instance.api_key
  puts "ERROR! Missing account credentials. Rerun the script with your credentials, e.g."
  puts "    SSS_API_ACCOUNT_NAME=<myaccountname> SSS_API_KEY=<api_key> ./examples/appointments.rb"
  return
end

puts "## Account:  #{Supersaas::Client.instance.account_name}"
puts "## API Key: #{'*' * Supersaas::Client.instance.api_key.size}"

Supersaas::Client.instance.verbose = true

if ENV['SSS_API_SCHEDULE']
  schedule_id = ENV['SSS_API_SCHEDULE']
  show_slot = ENV['SSS_API_SLOT'] ? true : false
else
  puts "ERROR! Missing schedule id. Rerun the script with your schedule id, e.g."
  puts "    SSS_API_SCHEDULE=<scheduleid> ./examples/appointments.rb"
  return
end

description = nil
new_appointment_id = nil
user = ENV.fetch('SSS_API_USER', nil)
if user
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
  puts "\ncreating new appointment..."
  puts "\n#### Supersaas::Client.instance.appointments.create(#{schedule_id}, #{user}, {...})"
  Supersaas::Client.instance.appointments.create(schedule_id, user, params)
else
  puts "\nskipping create/update/delete (NO DESTRUCTIVE ACTIONS FOR SCHEDULE DATA)..."
end

puts "\nlisting appointments..."
puts "\n#### Supersaas::Client.instance.appointments.list(#{schedule_id}, nil, nil, 25)"

appointments = Supersaas::Client.instance.appointments.list(schedule_id, nil, nil, 25)
appointments.each do |appointment|
  puts "#{description} == #{appointment.description}"
  next unless description == appointment.description

  puts "\nupdating appointment..."
  puts "\n#### Supersaas::Client.instance.appointments.update(#{schedule_id}, #{new_appointment_id}, {...})"
  Supersaas::Client.instance.appointments.update(schedule_id, new_appointment_id, { country: 'FR', address: 'Rue 1' })

  puts "\ndeleting appointment..."
  puts "\n#### Supersaas::Client.instance.appointments.delete(#{schedule_id}. #{new_appointment_id})"
  Supersaas::Client.instance.appointments.delete(schedule_id, new_appointment_id)
  break
end

if appointments.size.positive?
  appointment_id = appointments.sample.id
  puts "\ngetting appointment..."
  puts "\n#### Supersaas::Client.instance.appointments.get(#{appointment_id})"
  Supersaas::Client.instance.appointments.get(schedule_id, appointment_id)
end

puts "\nlisting changes..."
from = DateTime.now - 120
to = DateTime.now + 360_000
puts "\n#### Supersaas::Client.instance.appointments.changes(#{schedule_id},
  '#{from.strftime('%Y-%m-%d %H:%M:%S')}', '#{to.strftime('%Y-%m-%d %H:%M:%S')}', #{show_slot || 'false'})"

Supersaas::Client.instance.appointments.changes(schedule_id, from, show_slot)

puts "\nlisting available..."
from = DateTime.now
puts "\n#### Supersaas::Client.instance.appointments.available(#{schedule_id},
  '#{from.strftime('%Y-%m-%d %H:%M:%S')}')"

Supersaas::Client.instance.appointments.available(schedule_id, from)

puts "\nAppointments for a single user..."
user = Supersaas::Client.instance.users.list(nil, 1).first
from = DateTime.now
puts "\n#### Supersaas::Client.instance.appointments.agenda(#{schedule_id}, user.id,
  '#{from.strftime('%Y-%m-%d %H:%M:%S')}')"
Supersaas::Client.instance.appointments.agenda(schedule_id, user.id, from.strftime('%Y-%m-%d %H:%M:%S'))
