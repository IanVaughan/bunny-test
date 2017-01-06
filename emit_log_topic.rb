#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"

conn = Bunny.new
conn.start

ch       = conn.create_channel
x        = ch.topic("topic_logs")
severity = ARGV.shift || "anonymous.info"
msg      = ARGV.empty? ? "Hello World!" : ARGV.join(" ")

begin
  while true
    msg = gets.chomp
    x.publish(msg, :routing_key => severity)
    # puts " [x] Sent #{severity}:#{msg}"
  end
rescue Interrupt => _
  ch.close
  conn.close
end
