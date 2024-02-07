# frozen_string_literal: true

require 'supersaas-api-client'

puts '# SuperSaaS Groups Example'

unless Supersaas::Client.instance.account_name && Supersaas::Client.instance.api_key
  puts 'ERROR! Missing account credentials. Rerun the script with your credentials, e.g.'
  puts 'SSS_API_ACCOUNT_NAME=<myaccountname> SSS_API_KEY=<xxxxxxxxxxxxxxxxxxxxxx> ./examples/users.rb'
  return
end

puts "## Account:  #{Supersaas::Client.instance.account_name}"
puts "## API KEY: #{'*' * Supersaas::Client.instance.api_key.size}"

Supersaas::Client.instance.verbose = true

puts 'listing groups...'
puts '#### Supersaas::Client.instance.groups.list'
Supersaas::Client.instance.groups.list
