require 'RMagick'
require 'fileutils'

class Image
  VARIANT_DELIMITER = '_'
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
  
  def transform_content(variant)
    img = Magick::Image.from_blob(@content).first
    transformation = Transformations[variant]
    raise ArgumentError, "#{variant} is not a known transformation. (#{Transformations.list.join(', ')})" if transformation.nil?
    img = transformation.call(img)      
    raise ArgumentError, "Creating variant #{variant} for #{path} produced an error. Please return a Magick::Image" if img.nil?    
    

    image = Image.new 
    image.content_type = content_type
    image.content = img.to_blob    
    image
  end
  
  def variant
    basename =~ VariantParser ? $2 : nil
  end
  
  def variant?
    variant
  end
      
  # Reverse the filename to find the original image from which we can generate the desired 
  # transformation
  def find_original_path    
    basename =~ VariantParser ? File.join(dirname, $1) + $3 : nil
  end

  
end

