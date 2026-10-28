# frozen_string_literal: true

require 'supersaas-api-client'

puts '# SuperSaaS Slots Example'

unless Supersaas::Client.instance.account_name && Supersaas::Client.instance.api_key
  puts 'ERROR! Missing account credentials. Rerun the script with your credentials, e.g.'
  puts 'SSS_API_SCHEDULE=<capacityscheduleid> SSS_API_ACCOUNT_NAME=<myaccountname> SSS_API_KEY=<xxxxxxxxxxxxxxxxxxxxxx> ./examples/slots.rb'
  return
end

schedule_id = ENV.fetch('SSS_API_SCHEDULE', nil)
unless schedule_id
  puts 'ERROR! Missing capacity type schedule id. Rerun the script with SSS_API_SCHEDULE=<scheduleid>'
  return
end

puts "## Account:  #{Supersaas::Client.instance.account_name}"
puts "## API KEY: #{'*' * Supersaas::Client.instance.api_key.size}"

Supersaas::Client.instance.verbose = true

puts 'creating slot...'
start = DateTime.now + 1
finish = start + (1.0 / 24)
attributes = { start: start.strftime('%Y-%m-%d %H:%M:%S'), finish: finish.strftime('%Y-%m-%d %H:%M:%S'),
               title: 'Example slot', capacity: 5 }
puts "#### Supersaas::Client.instance.slots.create(#{schedule_id}, #{attributes})"
location = Supersaas::Client.instance.slots.create(schedule_id, attributes)
slot_id = location.to_s[%r{/slots/(\d+)}, 1]

puts 'listing slots...'
puts "#### Supersaas::Client.instance.slots.list(#{schedule_id})"
Supersaas::Client.instance.slots.list(schedule_id, nil, nil, 10)

if slot_id
  puts 'getting, updating and deleting slot...'
  Supersaas::Client.instance.slots.get(schedule_id, slot_id)
  Supersaas::Client.instance.slots.update(schedule_id, slot_id, { title: 'Updated example slot', capacity: '-' })
  Supersaas::Client.instance.slots.delete(schedule_id, slot_id)
end
