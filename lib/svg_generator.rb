require 'RMagick'
require 'fileutils'
require 'net/http'

# http://localhost:9292/s/files/1/0001/8392/assets/fish.svg
# 
class SvgGenerator
  SvgFileTest = /\.svg\.png/i  
  
  def self.from_url(server, path)    
    return nil unless path =~ SvgFileTest
    
    file = Image.new(server, original_path_for(path) )    
    if file.found?    
      file.headers['Content-Type'] = 'image/png'
      file.content = Converter.new(file.content).svg_to_png
      file
    else
      nil
    end
  end
  
  def self.original_path_for(path)
    path.gsub(/\.png/, '')
  end  
      
  class Converter  
    def initialize(blob)
      @blob = blob
    end
        
    def svg_to_png
      logger.info "** rasterize svg to png"
      result = popen("rsvg-convert")
      raise TransformationError, "Data was not a valid SVG image." unless $? == 0       
      result
    end

    private
    
    def logger
      Logger.current
    end
    
    def popen(cmd)
      IO.popen(cmd, 'r+') do |io| 
        io.write @blob     
        io.close_write
        io.read
      end
    end
  end
  
    
end

