module Reggae

  class Streamer

    def initialize conn
      puts "Starting to stream."
      @conn = conn
      stream
    end

    def bin2dec(n)
      bits = []
      bits.concat(n)
      bits.reverse!
      multi = 1
      value = 0
      bits.each do |bit|
        value += bit*multi
        multi *= 2
      end
      value
    end

    def bytes2bin(bytes, sz = 8)
      if sz < 1 or sz > 8
        puts "Invalid sz value " + sz.to_s
        exit(-1)
      end
      retVal = []
      bytes.each_byte do |b|
        bits = []
        b = b.ord
        while b > 0
          bits.push(b & 1)
          b >>= 1
        end

        if (bits.length < sz)
          bits.concat([0] * (sz - bits.length))
        elsif (bits.length > sz)
          bits = bits[0..sz]
        end

        # Big endian byte order.
        bits.reverse!
        retVal.concat(bits);
      end

      if retVal.length == 0
        retVal = [0]
      end

      retVal
    end

    def start(path)
      f = open(path, 'r')
      id3 = f.read(3)
      return 0 if not id3 == "ID3"
      f.seek(6)
      l = f.read(4)
      start = bin2dec(bytes2bin(l,7)) + 10
      f.close()
      start
    end

    def offset(path)
      start(path)
    end

    def stream
      song = "/home/noah/toodeloo.mp3"
      buffer = 0
      buffer_size = 4096
      interval = 16384
      backpressure_level = 50000
      audio_len = File.stat(song).size?
      byte_count = 0
      total_bytes = self.offset song # audio data begins here
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
