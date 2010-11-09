#!/usr/bin/env ruby
$:.push File.expand_path(File.dirname(__FILE__) + '/lib')
%w[pp rubygems eventmachine evma_httpserver reggae socket].each{|lib| require lib}

EM.run do |conn|
  port = 57715 #     REGGAE
  host = '0.0.0.0'
  EM.start_server host, port, Reggae::Server, host, port
  puts "{ reggae  http://#{host}:#{port} }"
end
