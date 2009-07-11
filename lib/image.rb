require 'RMagick'
require 'fileutils'

class Image
  attr_accessor :content
  attr_accessor :content_type
  
  ContentTypes = {'.gif' => 'image/gif', '.jpg' => 'image/jpeg', '.jpeg' => 'image/jpeg', '.png' => 'image/png', '.bmp' => 'image/x-bitmap'}

  VariantParser = /(.*)\_(#{Transformations.list.join('|')})(#{ContentTypes.keys.join('|')})/      
        
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
  def image?
    ContentTypes.has_key?(ext)
  end

  def content_type
    @content_type || ContentTypes[ext] || 'application/octet-stream'
  end
  
  def cache_control
    'public, max-age: 31557600'
  end
  
  def transform_content!(variant)
    img = Magick::Image.from_blob(@content).first
    transformation = Transformations[variant]
    
    Logger.current.info_with_time "Transforming image to #{variant}" do
      raise ArgumentError, "#{variant} is not a known transformation. (#{Transformations.list.join(', ')})" if transformation.nil?
      img = transformation.call(img)      
      raise ArgumentError, "Creating variant #{variant} for #{path} produced an error. Please return a Magick::Image" if img.nil?    
      self.content = img.to_blob
    end
    true
  end
  
  def variant
    basename =~ VariantParser ? $2 : nil
  end
  
  def variant?
    variant
  end
  
  def to_response
    [200, {'Content-Type' => content_type, 'Cache-Control' => cache_control}, [content]]
  end
      
  # Reverse the filename to find the original image from which we can generate the desired 
  # transformation
  def find_original_path    
    basename =~ VariantParser ? File.join(dirname, $1) + $3 : nil
  end

  
end

