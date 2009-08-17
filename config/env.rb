# Image server configuration file
RACK_ENV    = ENV['RACK_ENV'] || 'development'


# Upstream Server where the assets live

ORIGIN_SERVER = ENV['ORIGIN_SERVER'] || 'static.shopify.com'


# Middleware configuration
# recommended to be memcached for meta and disk for entities. 

require 'memcached'

ENV['META_STORE']   = 'memcache://127.0.0.1:11211/meta'
ENV['ENTITY_STORE'] = 'file:/data/cache/rack/body'


# Logging
Logger.current = RequestAwareLogger.new(File.dirname(__FILE__) + "/../log/#{RACK_ENV}.log")
