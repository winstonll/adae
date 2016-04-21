require 'rubygems'
require 'daemons'
require 'bundler/setup'

Daemons.run('server.rb')
