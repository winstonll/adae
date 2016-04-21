require 'rubygems'
require 'bundler/setup' 
require 'daemons'

Daemons.run('server.rb')
