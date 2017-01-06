#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

# if ARGV.empty?
#   abort "Usage: #{$0} [binding key]"
# end

conn = Bunny.new
conn.start

ch  = conn.create_channel
x   = ch.topic("topic_logs")
q   = ch.queue("", :exclusive => true)

# send_key      = "csr.1"
from_type = "csr"
sender_id = 34
# recipient_id = ARGV.shift
order_id = 221
# send_key = [from_type, sender_id, recipient_id, order_id].join(".")
send_key = [from_type, sender_id, order_id].join(".")

# ARGV.each do |severity|
#   q.bind(x, :routing_key => severity)
# end
q.bind(x, :routing_key => "#")

ARGV.shift

begin
  q.subscribe(:block => false) do |delivery_info, properties, body|
    puts " [x] #{delivery_info.routing_key}:#{body}"
  end

  while true
    msg = gets.chomp
    x.publish(msg, :routing_key => send_key)
  end
rescue Interrupt => _
  ch.close
  conn.close
end
