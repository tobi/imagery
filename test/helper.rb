$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '../lib')

require 'rubygems'
require 'test/unit'

require 'fakeweb'
require 'mocha'

require 'rack'
require 'imagery'
require 'config/env'
