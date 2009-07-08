require 'rubygems'
require 'sinatra'
require 'lib/transformations'
require 'lib/image'
require 'lib/remote_image'

configure :development do
  puts "Development mode active"
end

configure :production do
  puts "Production mode active"
end

get '/' do
  body "img: <img src='http://localhost:9292/s/files/1/0001/4168/products/t5_1_pico.jpg?1242853601'/>"
end

get '/s/files/*' do 

  requested_file = RemoteImage.new(OriginServer, request.path, request.query_string)  
  
  # If file exists we simply sent it to the client. 
  if requested_file.download

    headers 'Content-Type' => requested_file.content_type, 'Cache-Control' => requested_file.headers['Cache-Control']
    body requested_file.content    

  # If it doesn't exist but it's an image and a variant was requested we will
  # go look for the original image and resize it according to the request.  
  elsif requested_file.image? && requested_file.variant?
    origin_file = requested_file.download_original

    $logger.info "Applying transformation #{requested_file.variant}"

    image = origin_file.transform_content(requested_file.variant)

    headers 'Content-Type' => origin_file.content_type, 'Cache-Control' => origin_file.headers['Cache-Control']
    body image.content
    
  # Otherwise we will have to raise a not found exception.
  else
    raise NotFound
  end
end