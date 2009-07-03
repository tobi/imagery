require 'RMagick'
require 'fileutils'

class RemoteImage  
  VARIANT_DELIMITER = '_'
  attr_reader :server, :path
  attr_accessor :content
  
  ContentTypes = {'.gif' => 'image/gif', '.jpg' => 'image/jpeg', '.jpeg' => 'image/jpeg', '.png' => 'image/png', '.bmp' => 'image/x-bitmap'}
  VariantParser = /(.*)\_(#{Transformations.list.join('|')})(#{ContentTypes.keys.join('|')})/      
    
  def initialize(server, path)
    @server = server
    @path = path    
    
    if not transformable?
      raise ArgumentError, "Image cannot be transformed. Unknown image format."
    end      
  end
        
  def basename
    File.basename(@path)
  end

  def basename_no_ext
    File.basename(@path, ext)
  end
  
  def ext
    File.extname(@path)
  end
  
  def dirname
    File.dirname(@path)
  end  
  
  # Returns true if the file is of a image type
  def transformable?
    ContentTypes.has_key?(ext)
  end
  
  def content_type
    ContentTypes[ext]
  end
  
  def create_from_original(&block)
    conn = EM::Protocols::HttpClient2.connect(@server, 80)
      
    conn.get( find_original_path ).callback do |response|
      
      if response.status == 200        
        self.content = response.content
        
        transform!
                                
        block.call(self)
      else
        raise ArgumentError, "Original Image cannot be recieved."        
      end
    end  
  end
    
  private
  
  def transform!
    img = Magick::Image.from_blob(@content).first
    transformation = Transformations[variant]
    raise ArgumentError, "#{variant} is not a known transformation. (#{Transformations.list.join(', ')})" if transformation.nil?
    img = transformation.call(img)      
    raise ArgumentError, "Creating variant #{variant} for #{path} produced an error. Please return a Magick::Image" if img.nil?
    
    @content = img.to_blob
  end
  
  def variant
    basename =~ VariantParser ? $2 : nil
  end
    
  # Reverse the filename to find the original image from which we can generate the desired 
  # transformation
  def find_original_path    
    basename =~ VariantParser ? File.join(dirname, $1) + $3 : nil
  end

  
end

