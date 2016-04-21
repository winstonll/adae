#!/usr/bin/env ruby
require 'rubygems'
require 'daemons'
require 'socket'

Daemons.run('server.rb')

server = TCPServer.new 1991 # Server bound to port 2000

loop do
  client = server.accept    # Wait for a client to connect
  client.puts "Hello !"
  client.puts "Time is #{Time.now}"
  client.close
end
