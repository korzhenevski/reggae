module Reggae
  class Streamer
    def initialize response
      begin
        f = File.open("mp3/gd89-07-04d1t01_vbr.mp3", (File::RDONLY | File::NONBLOCK))
        while chunk = f.read_nonblock(4096)
          # throws exception
          response.send_data chunk
        end
      rescue EOFError
        return
      rescue IOError => e
        puts e.exception
      rescue Errno::ENOENT
        puts "no such file #{fname}"
      end
    end
  end
end
