#!/usr/bin/env ruby -w
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "/lib"))
%w[pp rubygems eventmachine evma_httpserver reggae socket].each{|lib| require lib}

trap "SIGINT" do
  puts "Caught SIGINT, exiting."
  exit
end

EM.run do |conn|
  host, port = "127.0.0.1", 57715
  EM.start_server host, port, Reggae::Server, host, port
  puts ['{', "reggae", "http://#{host}:#{port}", '}'].join ' '
end
