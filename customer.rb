#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

# ruby cust/quiq user_id job_id

conn = Bunny.new
conn.start

channel  = conn.create_channel
exchange = channel.topic("topic_logs") # messages
queue    = channel.queue("", :exclusive => true)

from_type = ARGV.shift
sender_id = ARGV.shift
# recipient_id = ARGV.shift
# order_id = 221
order_id = ARGV.shift
# send_key = "#{from_type}.#{sender_id}.#{recipient_id}.#{order_id}"
send_key = "#{from_type}.#{sender_id}.#{order_id}"
# send_key = ARGV.shift || "customer.1"

# receive_keys = []
# receive_keys << ARGV.shift || "driver.1"
# receive_keys << "csr.1"
#
# receive_keys.each do |key|
#   queue.bind(exchange, :routing_key => key)
# end

# receive_key = "*.*.#{sender_id}.*"
# receive_key = "*.*.*.#{order_id}"
receive_key = "*.*.#{order_id}"
queue.bind(exchange, :routing_key => receive_key)

begin
  queue.subscribe(:block => false) do |delivery_info, properties, body|
    unless body.match("fuck")
    puts " [x] #{delivery_info.routing_key}:#{body}"
    end
  end

  while true
    msg = gets.chomp
    exchange.publish(msg, routing_key: send_key)
  end
rescue Interrupt => _
  channel.close
  conn.close
end
