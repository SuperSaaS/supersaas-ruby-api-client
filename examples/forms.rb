#!/usr/bin/env ruby
# frozen_string_literal: true

require 'supersaas-api-client'

puts "# SuperSaaS Forms Example"

unless Supersaas::Client.instance.account_name && Supersaas::Client.instance.api_key
  puts "ERROR! Missing account credentials. Rerun the script with your credentials, e.g."
  puts "    SSS_API_ACCOUNT_NAME=<myaccountname> SSS_API_KEY=<xxxxxxxxxxxxxxxxxxxxxx> ./examples/appointments.rb"
  return
end

puts "## Account:  #{Supersaas::Client.instance.account_name}"
puts "## API Key: #{'*' * Supersaas::Client.instance.api_key.size}"

Supersaas::Client.instance.verbose = true

puts "You will need to create a form, and also attach the form to a booking, see documentation on how to do that"
puts "The below example will take a form in random, and if it is not attached to something then 404 error will be raised"

puts "listing forms..."
puts "#### Supersaas::Client.instance.forms.forms"

template_forms = Supersaas::Client.instance.forms.forms

if template_forms.size.positive?
  template_form_id = template_forms.sample.id

  puts "listing forms from account"
  puts "#### Supersaas::Client.instance.forms.list"
  form_id = Supersaas::Client.instance.forms.list(template_form_id).sample.id
end

puts "getting form..."
puts "#### Supersaas::Client.instance.forms.get(#{form_id})"
Supersaas::Client.instance.forms.get(form_id)
