#!/usr/bin/env ruby

require "pp"
require "supersaas-api-client"

puts "\n\r# SuperSaaS Forms Example\n\r"

unless Supersaas::Client.instance.account_name && Supersaas::Client.instance.password
  puts "ERROR! Missing account credentials. Rerun the script with your credentials, e.g.\n\r"
  puts "    SSS_API_ACCOUNT_NAME=<myaccountname> SSS_API_PASSWORD=<mypassword> ./examples/appointments.rb\n\r"
  return
end

puts "## Account:  #{Supersaas::Client.instance.account_name}"
puts "## Password: #{'*' * Supersaas::Client.instance.password.size}\n\r"

Supersaas::Client.instance.verbose = true

if ENV['SSS_API_FORM']
  form_id = ENV['SSS_API_FORM']
else
  puts "ERROR! Missing form id. Rerun the script with your form id, e.g.\n\r"
  puts "    SSS_API_FORM=<formid> ./examples/forms.rb\n\r"
  return
end

puts "\n\rlisting forms..."
puts "\n\r#### Supersaas::Client.instance.forms.list(#{form_id})\n\r"

forms = Supersaas::Client.instance.forms.list(form_id)

if forms.size > 0
  form_id = forms.sample.id
  puts "\n\rgetting form..."
  puts "\n\r#### Supersaas::Client.instance.forms.get(#{form_id})\n\r"
  form = Supersaas::Client.instance.forms.get(form_id)
end

puts