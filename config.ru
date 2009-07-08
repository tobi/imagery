#!/usr/bin/env rackup -s thin

require 'rubygems'
require 'rack/cache'
require 'memcached'
require 'rubygems'
require 'sinatra'
require 'logger'
require 'image_server'

OriginServer = 'static.shopify.com'
$logger      = Logger.new(STDOUT)

use Rack::Cache, 
  :verbose     => true, 
  :metastore   => 'memcache://localhost:11211/meta',
  :entitystore => 'file:/tmp/cache/rack/body'

run Sinatra::Application