#!/usr/bin/env rackup -s thin -E none

require 'rubygems'
require 'rack/cache'
require 'image_server'

# 1. Forget about stupid favicons
use FaviconFilter

# 2. Log all other incoming requests
use LoggedRequest

# 3. Override server name into something non embarrasing
use ServerName

# 4. Content type needs to be present, default to attachment
use Rack::ContentType, "application/octet-stream"

# 5. Serve converted images directly from cache
use Rack::Cache, 
  :metastore   => ENV['META_STORE'],
  :entitystore => ENV['ENTITY_STORE']

# 6. handle PURGE requests 
use CachePurge

# 7. See if files already exist on remote host, if so handle them directly
use RemoteProxy

# 8. Otherwise run the image server and produce the missing images
run ImageServer.new
