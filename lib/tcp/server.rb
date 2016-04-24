#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'socket'
require 'eventmachine'
require 'pg'
require 'active_record'

conn = PGconn.open(:username => "postgres",
                    :password => "123456",
                    :database => "test_dev")



 module EchoServer
   def post_init
     puts "-- someone connected to the echo server!"
     puts User.first.name
   end

   def receive_data data
     send_data ">>>you sent: #{data}"
     close_connection if data =~ /quit/i
   end

   def unbind
     puts "-- someone disconnected from the echo server!"
  end
end

# Note that this will block current thread.
EventMachine.run {
  EventMachine.start_server "adae.co", 1991, EchoServer
}
