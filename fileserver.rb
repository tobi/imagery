require 'rubygems'
require 'sinatra'
require 'sinatra/async'
require 'eventmachine'

Sinatra.register Sinatra::Async


# http://cdn.shopify.com/s/files/1/0001/4168/products/t5_1_large.jpg?1242853603

aget '/products/:img' do |img|

  conn = EM::Protocols::HttpClient2.connect('cdn.shopify.com', 80)
  
  conn.get("/s/files/1/0001/4168/products/#{img}").callback do |response|    
    status    response.status    
    headers   'Content-Length' => response.headers['content-length'], 'Content-Type' => response.headers['content-type']    
    body      response.content    
  end
end

