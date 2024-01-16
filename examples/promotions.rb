require "supersaas-api-client"

puts "\n\r# SuperSaaS Promotions Example\n\r"

unless Supersaas::Client.instance.account_name && Supersaas::Client.instance.api_key
  puts "ERROR! Missing account credentials. Rerun the script with your credentials, e.g.\n\r"
  puts "    SSS_API_ACCOUNT_NAME=<myaccountname> SSS_API_KEY=<xxxxxxxxxxxxxxxxxxxxxx> ./examples/users.rb\n\r"
  return
end

puts "## Account:  #{Supersaas::Client.instance.account_name}"
puts "## API KEY: #{'*' * Supersaas::Client.instance.api_key.size}\n\r"

Supersaas::Client.instance.verbose = true

puts "\n\rlisting promotions..."
puts "\n\r#### Supersaas::Client.instance.promotions.list\n\r"
promotions = Supersaas::Client.instance.promotions.list

[10, promotions.size].min&.times do |i|
  puts "\n\rA promotion"
  puts "\n\r#### Supersaas::Client.instance.promotion(#{promotions[i].id})\n\r"
  Supersaas::Client.instance.promotions.promotion(promotions[i].code)
end

# Uncomment to try out duplicating a promotional code
# puts "\n\rduplicate promotional code"
# puts "\n\r#### Supersaas::Client.instance.promotions.duplicate_promotion_code('new_id', 'promotion_id_to_duplicate')\n\r"
# Supersaas::Client.instance.promotions.duplicate_promotion_code("pcode" + SecureRandom.hex(4), promotions.first.code)
# puts