#!/usr/bin/env ruby

require 'socket'

s = TCPSocket.new 'adae.co', 1991

while line = s.gets # Read lines from socket
  puts line         # and print them
end

s.close
