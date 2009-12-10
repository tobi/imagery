require 'time'

module SendFile
  
  CopyHeaders = ['Content-Type', 'Cache-Control', 'Last-Modified', 'ETag']
  
  ContentTypes = { 
      '.gif'  => 'image/gif', 
      '.jpg'  => 'image/jpeg', 
      '.jpeg' => 'image/jpeg', 
      '.png'  => 'image/png', 
      '.bmp'  => 'image/x-bitmap',
      '.svg'  => 'image/svg+xml'
    }
  
  def send_file(file)    
    headers = {'Content-Length' => file.content.length.to_s}
    
    if file.respond_to?(:headers)
      CopyHeaders.each do |key|
        headers[key] = file.headers[key] if file.headers.has_key?(key)
      end
    end
    
    headers['ETag']           ||= Digest::MD5.hexdigest(file.content)
    headers['Cache-Control']  ||= 'public, max-age=31557600'
    headers['Last-Modified']  ||= Time.new.httpdate

    [200, headers, [file.content]]
  end  
end