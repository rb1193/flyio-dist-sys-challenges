#!/usr/bin/env ruby

require 'json'

class BroadcastServer
  def initialize
    @node_id = nil
    @next_msg_id = 0
    @messages = []
    @neighbours = []
  end

  def reply!(request, body)
    STDERR.puts "Replying to req from #{request[:src]}"
    id = @next_msg_id += 1
    body = body.merge msg_id: id, in_reply_to: request[:body][:msg_id]
    msg = { src: @node_id, dest: request[:src], body: body }
    JSON.dump msg, STDOUT
    STDOUT << "\n"
    STDOUT.flush
  end

  def forward!(request)
    STDERR.puts "Forwarding request #{request[:body]}"
    @neighbours.each do |neighbour|
      id = @next_msg_id += 1
      body = { msg_id: id, message: request[:body][:message], type: "broadcast" }
      msg = { src: @node_id, dest: neighbour, body: body }
      JSON.dump msg, STDOUT
      STDOUT << "\n"
    end
    STDOUT.flush
  end

  def main!
    STDERR.puts "Online"

    while line = STDIN.gets
      req = JSON.parse line, symbolize_names: true
      STDERR.puts "Received #{req.inspect}"

      body = req[:body]
      case body[:type]
        # Initialize this node
      when "init"
        @node_id = body[:node_id]
        STDERR.puts "Initialized node #{@node_id}"
        reply! req, { type: :init_ok }

      when "broadcast"
        STDERR.puts "Acknowledging broadcast #{body}"
        @messages << body[:message] unless @messages.include? body[:message]
        reply! req, { type: "broadcast_ok" }
        forward! req

      when "read"
        STDERR.puts "Acknowledging read #{body}"
        reply! req, { type: "read_ok", messages: @messages }

      when "topology"
        STDERR.puts "Acknowledging topology #{body}"
        @neighbours = body[:topology][@node_id.to_sym]
        reply! req, { type: "topology_ok" }
      end
    end
  end
end

BroadcastServer.new.main!

# Extend for following commands:
# ./maelstrom/maelstrom test -w broadcast --bin workloads/broadcast.rb --node-count 5 --time-limit 20 --rate 10
# ./maelstrom/maelstrom test -w broadcast --bin workloads/broadcast.rb --node-count 5 --time-limit 20 --rate 10 --nemesis partition