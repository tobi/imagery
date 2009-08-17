#!/usr/bin/env rackup -s thin -E none

require 'rubygems'
require 'rack/cache'
require 'rack/contrib'
require 'image_server'

# Add rack sendfile extension.
# Allows us to serve cache hits directly from file system 
# by nginx (big speed boost). read: 
# http://github.com/rack/rack-contrib/blob/5ea5e585a43669842314aa07f1e603be70d6e288/lib/rack/contrib/sendfile.rb
use Rack::Sendfile

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
