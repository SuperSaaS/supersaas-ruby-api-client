# frozen_string_literal: true

require 'supersaas-api-client'

puts "# SuperSaaS Promotions Example"

unless Supersaas::Client.instance.account_name && Supersaas::Client.instance.api_key
  puts "ERROR! Missing account credentials. Rerun the script with your credentials, e.g."
  puts "SSS_API_ACCOUNT_NAME=<myaccountname> SSS_API_KEY=<xxxxxxxxxxxxxxxxxxxxxx> ./examples/users.rb"
  return
end

puts "## Account:  #{Supersaas::Client.instance.account_name}"
puts "## API KEY: #{'*' * Supersaas::Client.instance.api_key.size}"

Supersaas::Client.instance.verbose = true

puts "listing promotions..."
puts "#### Supersaas::Client.instance.promotions.list"
promotions = Supersaas::Client.instance.promotions.list

[10, promotions.size].min&.times do |i|
  puts "A promotion"
  puts "#### Supersaas::Client.instance.promotion(#{promotions[i].id})"
  Supersaas::Client.instance.promotions.promotion(promotions[i].code)
end

# Uncomment to try out duplicating a promotional code
# puts "duplicate promotional code"
# puts "#### Supersaas::Client.instance.promotions.duplicate_promotion_code('new_id', 'id_to_duplicate')"
# Supersaas::Client.instance.promotions.duplicate_promotion_code("pcode#{SecureRandom.hex(4)}", promotions.first.code)
# puts
