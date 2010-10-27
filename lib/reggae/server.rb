module Reggae

  class Server < EM::Connection
    include EM::HttpServer
    #   signature: #{@signature}
    #   Protocol: #{@http_protocol}
    #   Request method: #{@http_request_method}
    #   path info: #{@http_path_info}
    #   request_uri: #{@http_request_uri}
    #   proto: #{@http_protocol}
    # called by the event loop immediately after network connection
    # established, but before resumption of network loop
    def post_init
      super
      no_environment_strings
      @start_time = Time.now
      @header_processing = true
      #@streamer = Streamer.new
    end

    def set_response_headers
      @response.status = 200
      @response.content_type 'audio/x-mpegurl'
      {
        'icy-notice1'   => 'reggae',
        'icy-notice2'   => 'reggae server',
        'icy-name'      => 'reggae on #{gethostbyname}',
        'icy-genre'     => 'pfunk',
        'icy-url'       => 'http://downbe.at:57715',
        'icy-pub'       => false,
        'icy-metaint'   => 16384
      }.each { |h,v| send_data "#{h}: #{v}\r\n" }
    end

    def process_http_request
      @headers = Hash[*@http_headers.split("\x00").map{|h|h.split(/:\s+/,2)}.flatten]
      @response = EM::DelegatedHttpResponse.new self
      set_response_headers

      case @http_request_method.upcase
        when 'GET' then
          @response.send_response
          # Reggae::Streamer.new 
        when 'POST' then
          puts 'got a post'
      end
      # response.content =
      # response.send_response
    end

    def unbind
      puts "disconnected"
    end
  end
end
