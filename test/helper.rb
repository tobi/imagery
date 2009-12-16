$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..')

require 'rubygems'
require 'test/unit'

require 'fakeweb'
require 'mocha'

require 'rack'
require 'image_server'
require 'config/env'
