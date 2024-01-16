#!/usr/bin/env ruby

require "date"
require "pp"
require "supersaas-api-client"

puts "\n\r# SuperSaaS Appointments Example\n\r"

unless Supersaas::Client.instance.account_name && Supersaas::Client.instance.api_key
  puts "ERROR! Missing account credentials. Rerun the script with your credentials, e.g.\n\r"
  puts "    SSS_API_ACCOUNT_NAME=<myaccountname> SSS_API_KEY=<api_key> ./examples/appointments.rb\n\r"
  return
end

puts "## Account:  #{Supersaas::Client.instance.account_name}"
puts "## API Key: #{'*' * Supersaas::Client.instance.api_key.size}\n\r"

Supersaas::Client.instance.verbose = true

if ENV['SSS_API_SCHEDULE']
  schedule_id = ENV['SSS_API_SCHEDULE']
  show_slot = ENV['SSS_API_SLOT'] ? true : false
else
  puts "ERROR! Missing schedule id. Rerun the script with your schedule id, e.g.\n\r"
  puts "    SSS_API_SCHEDULE=<scheduleid> ./examples/appointments.rb\n\r"
  return
end

description = nil
new_appointment_id = nil
user = ENV['SSS_API_USER']
if user
  description = '1234567890.'
  params = {full_name: 'Example', description: description, name: 'example@example.com', email: 'example@example.com', mobile: '555-5555', phone: '555-5555', address: 'addr'}
  if show_slot
    params[:slot_id] = ENV['SSS_API_SLOT']
  else
    days = 1 + rand(30)
    params[:start] = Time.now + (days * 24 * 60 * 60)
    params[:finish] = params[:start] + (60 * 60)
  end
  puts "\n\rcreating new appointment..."
  puts "\n\r#### Supersaas::Client.instance.appointments.create(#{schedule_id}, #{user}, {...})\n\r"
  Supersaas::Client.instance.appointments.create(schedule_id, user, params)
else
  puts "\n\rskipping create/update/delete (NO DESTRUCTIVE ACTIONS FOR SCHEDULE DATA)...\n\r"
end

puts "\n\rlisting appointments..."
puts "\n\r#### Supersaas::Client.instance.appointments.list(#{schedule_id}, nil, nil, 25)\n\r"

appointments = Supersaas::Client.instance.appointments.list(schedule_id, nil, nil, 25)
appointments.each do |appointment|
  puts "#{description} == #{appointment.description}"
  if description == appointment.description
    puts "\n\rupdating appointment..."
    puts "\n\r#### Supersaas::Client.instance.appointments.update(#{schedule_id}, #{new_appointment_id}, {...})\n\r"
    Supersaas::Client.instance.appointments.update(schedule_id, new_appointment_id, {country: 'FR', address: 'Rue 1'})

    puts "\n\rdeleting appointment..."
    puts "\n\r#### Supersaas::Client.instance.appointments.delete(#{schedule_id}. #{new_appointment_id})\n\r"
    Supersaas::Client.instance.appointments.delete(schedule_id, new_appointment_id)
    break
  end
end

if appointments.size > 0
  appointment_id = appointments.sample.id
  puts "\n\rgetting appointment..."
  puts "\n\r#### Supersaas::Client.instance.appointments.get(#{appointment_id})\n\r"
  Supersaas::Client.instance.appointments.get(schedule_id, appointment_id)
end

puts "\n\rlisting changes..."
from = DateTime.now - 120
to = DateTime.now + 360000
puts "\n\r#### Supersaas::Client.instance.appointments.changes(#{schedule_id}, '#{from.strftime("%Y-%m-%d %H:%M:%S")}', '#{to.strftime("%Y-%m-%d %H:%M:%S")}',  #{show_slot || 'false'})\n\r"

Supersaas::Client.instance.appointments.changes(schedule_id, from, show_slot)

puts "\n\rlisting available..."
from = DateTime.now
puts "\n\r#### Supersaas::Client.instance.appointments.available(#{schedule_id}, '#{from.strftime("%Y-%m-%d %H:%M:%S")}')\n\r"

Supersaas::Client.instance.appointments.available(schedule_id, from)

puts "\n\rAppointments for a single user..."
user = Supersaas::Client.instance.users.list(nil, 1).first
from = DateTime.now
puts "\n\r#### Supersaas::Client.instance.appointments.agenda(#{schedule_id}, user.id, '#{from.strftime("%Y-%m-%d %H:%M:%S")}')\n\r"
Supersaas::Client.instance.appointments.agenda(schedule_id, user.id, from.strftime("%Y-%m-%d %H:%M:%S"))