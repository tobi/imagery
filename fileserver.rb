require 'rubygems'
require 'sinatra'
require 'sinatra/async'
require 'eventmachine'

require 'lib/transformations'
require 'lib/remote_image'

Sinatra.register Sinatra::Async


# http://localhost:4567/s/files/1/0001/4168/products/t5_1_large.jpg
# http://cdn.shopify.com/s/files/1/0001/4168/products/t5_1_large.jpg?1242853603

aget '/s/files/1/0001/4168/products/:img' do |img|

  image = RemoteImage.new('static.shopify.com', request.path)
  
  image.create_from_original do |image|
    headers   'Content-Length' => image.content.length.to_s, 'Content-Type' => image.content_type
    body      image.content
  end
end

