module SendFile
  ContentTypes = { 
      '.gif'  => 'image/gif', 
      '.jpg'  => 'image/jpeg', 
      '.jpeg' => 'image/jpeg', 
      '.png'  => 'image/png', 
      '.bmp'  => 'image/x-bitmap',
      '.svg'  => 'image/svg+xml'
    }
  
  def send_file(file)
    
    cache_control = file.respond_to?(:cache_control) ? file.cache_control : 'public, max-age: 31557600'
    content_type  = file.respond_to?(:content_type)  ? file.content_type || ContentTypes[file.ext] || raise(ArgumentError, 'illegal content type') : 'application/octet-stream'
    
    [200, {'Content-Type' => content_type, 'Cache-Control' => cache_control}, [file.content]]
  end  
end