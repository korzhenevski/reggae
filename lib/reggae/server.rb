module Reggae

  class Server < EM::Connection
    include EM::HttpServer

    def initialize host, port 
      @host, @port = host, port
    end
    #   signature: #{@signature}
    # called by the event loop immediately after network connection
    # established, but before resumption of network loop
    def post_init
      super
      no_environment_strings
      @start_time = Time.now
      @header_processing = true
      @streamer = nil
    end

    def set_response_headers
      @response.status = 200
      @response.content_type "audio/x-mpegurl"
      @response.send_response
      {
        "icy-notice1"   => "reggae",
        "icy-notice2"   => "reggae server",
        "icy-name"      => "reggae on #{@host}",
        "icy-genre"     => "funk",
        "icy-url"       => "http://#{@host}:#{@port}",
        "icy-pub"       => false,
        "icy-metaint"   => 16384
      }.each{|h,v| send_data "#{h}: #{v}\r\n"}
    end

    def process_http_request
      puts "#{@http_protocol} #{@http_request_method} #{@http_request_uri} #{@http_path_info}"

      @headers = Hash[*@http_headers.split("\x00").map{|h|h.split(/:\s+/,2)}.flatten]
      @response = EM::DelegatedHttpResponse.new self
      set_response_headers

      case @http_request_method.upcase
        when 'GET' then
          Reggae::Streamer.new self
        when 'POST' then
          puts 'got a post'
      end
    end

    def unbind
      puts "disconnected"
      puts @streamer
    end
  end
end
