require 'RMagick'
require 'fileutils'

class ImageVariantGenerator
  VARIANT_DELIMITER = '_'  
  SupportedImageTypes = ['.gif', '.jpg', '.jpeg', '.png', '.bmp']
  VariantParser = /(.*)\_(#{Transformations.list.join('|')})(#{SupportedImageTypes.join('|')})/i  
  
  attr_accessor :content
  attr_accessor :content_type
            
  def self.from_url(server, path)
    return nil unless path =~ VariantParser
        
    remote_path = "#{$1}#{$3}"     
    
    file = Image.new(server, remote_path)
    if file.found?
      transform_content(file, $2)
      file
    else
      nil
    end
  end 
  
  def initialize(image)
    @image = image
  end
    
  def self.transform_content(image, variant)
    img = Magick::Image.from_blob(image.content).first
    transformation = Transformations[variant]
    
    Logger.current.info_with_time "Transforming image to #{variant}" do
      raise ArgumentError, "#{variant} is not a known transformation. (#{Transformations.list.join(', ')})" if transformation.nil?
      img = transformation.call(img)      
      raise ArgumentError, "Creating variant #{variant} for #{path} produced an error. Please return a Magick::Image" if img.nil?    
      image.content = img.to_blob
    end
    true
  end
  
end

