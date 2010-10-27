module Reggae

  klass_paths = {
    :Server => 'reggae/server',
    :Streamer => 'reggae/streamer'
  }

  klass_paths.each do |klass,path|
    autoload klass, path
  end

end
