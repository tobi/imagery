#!/usr/bin/env rackup -s thin -E none

require 'rubygems'
require 'rack/cache'
require 'image_server'


use FaviconFilter

# 1. Log all incoming requests
use LoggedRequest

# 0. Override server name
use ServerName

use Rack::ContentType, "text/plain"

# 2. Serve converted images directly from cache
use Rack::Cache, 
  :metastore   => ENV['META_STORE'],
  :entitystore => ENV['ENTITY_STORE']

# 3. handle PURGE requests 
use CachePurge

# 4. See if files already exist on remote host, if so handle them directly
use RemoteProxy

# 5. Otherwise run the image server and produce the missing images
run ImageServer.new
