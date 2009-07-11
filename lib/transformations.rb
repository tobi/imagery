require 'RMagick'

module Transformations  
  @transformations = Hash.new 
  
  def self.list
    @transformations.keys
  end
  
  def self.[](name)
    @transformations[name.to_s]
  end
  
  def self.register(name, &block)
    @transformations[name.to_s] = Proc.new(&block)
  end    
end



Dir[ File.dirname(__FILE__) + '/transformations/*.rb'].each { |f| require f } 
