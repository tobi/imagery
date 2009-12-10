# Image server configuration file
RACK_ENV    = ENV['RACK_ENV'] || 'development'

$settings = if File.exist?('/etc/imagery/config.yml') 
  YAML.load_file('/etc/imagery/config.yml')  
else
  {}
end

# Upstream Server where the assets live

ORIGIN_SERVER = $settings['origin_server'] || 'shopify.s3.amazonaws.com'


# Middleware configuration
# recommended to be memcached for meta and disk for entities. 

require 'memcached'

ENV['CACHE_LOCATION'] = '/mnt/data/cache/rack/body'
ENV['META_STORE']   = 'memcache://127.0.0.1:11211/meta'
ENV['ENTITY_STORE'] = "file:#{ENV['CACHE_LOCATION']}"


# Logging
if RACK_ENV == 'production'
  Logger.current = SyslogLogger.new('rack.imagery')  
else
  Logger.current = Logger.new(File.dirname(__FILE__) + "/../log/#{RACK_ENV}.log")
end

