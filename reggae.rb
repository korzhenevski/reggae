#!/usr/bin/env ruby
#
%w[rubygems eventmachine evma_httpserver].each{|lib| require lib}

# TODO:
#       options


class Reggae < EM::Connection
  include EM::HttpServer

  def post_init
    super
    no_environment_strings
    puts "#{@http_protocol}"
  end

  def process_http_request
    response = EM::DelegatedHttpResponse.new self
    response.status = 200
    response.content_type 'text/html'
    response.content = <<-EOF
    
    <pre>Hello world 
      Protocol: #{@http_protocol}
      Request method: #{@http_request_method}
      Cookie: #{@http_cookie}
      if none match: #{@http_if_none_match}
      content_type: #{@http_content_type}
      path info: #{@http_path_info}
      request_uri: #{@http_request_uri}
      query string: #{@http_query_string}
      post_content: #{@http_post_content}
      http_headers: #{@http_headers}
      proto: #{@http_protocol}
    </pre>
    EOF
    response.send_response
  end

  def unbind
    puts "someone disconnected"
  end
end



EM.run do
  # REGGAE
  port = 57715
  host = '0.0.0.0'
  EM.start_server host, port, Reggae
  puts "Now accepting connections on address #{host}, port #{port}..."
  # EM::add_periodic_timer( 10 ) { $stderr.write "*" }
end
