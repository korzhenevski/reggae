module Reggae

  class Streamer

    def initialize conn
      puts "Starting to stream."
      @conn = conn
      stream
    end

    def stream
      song = "/home/noah/toodeloo.mp3"
      buffer = 0
      buffer_size = 4096
      interval = 16384
      backpressure_level = 50000
      audio_len = Reggae::Audio.size? song 
      byte_count = 0
      total_bytes = Reggae::Audio.offset song # audio data begins here
      @conn.send_data meta
      loop do
        #return if f.tell >= audio_len
        bytes_until_meta = interval - byte_count
        if bytes_until_meta == 0
          @conn.send_data meta 
          byte_count = 0
        else
          n_bytes = bytes_until_meta < buffer_size ? bytes_until_meta : buffer_size
          if @conn.get_outbound_data_size >= backpressure_level
            puts "@conn.get_outbound_data_size > #{backpressure_level}, scheduling next tick"
            EM::next_tick { stream }
            break
          end
          buffer = IO.read(song, n_bytes, total_bytes)
          @conn.send_data buffer
          byte_count += buffer.length
          total_bytes += buffer.length
          puts "have sent #{total_bytes} bytes"
        end
      end
    end

    def meta
      puts 'sending meta'
      # lifted from amarok
      padding = "\x00" * 16
      title = "mississippi uptown toodeloo"
      url = "http://downbe.at:57715"
      # 28 is the number of static characters in metadata (!)
      l = title.length + url.length + 28
      pad = 16 - l % 16
      meta = "#{(l+pad)/16}StreamTitle='#{title}';StreamUrl='#{url}';#{padding[0..pad]}"
    end

  end # class

end # module
