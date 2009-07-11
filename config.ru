#!/usr/bin/env rackup -s thin -e none

require 'rubygems'
require 'rack/cache'
require 'lib/middlewear/cache_purge'
require 'lib/middlewear/logged_request'
require 'image_server'


use LoggedRequest

use Rack::Cache, 
  :metastore   => ENV['META_STORE'],
  :entitystore => ENV['ENTITY_STORE']

use CachePurge

run ImageServer.new
