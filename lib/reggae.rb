module Reggae

  klasses = {
    :Server => 'reggae/server',
    :Streamer => 'reggae/streamer'
  }

  klasses.each do |klass,path|
    autoload klass, path
  end

end
