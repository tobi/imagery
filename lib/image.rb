require 'RMagick'
require 'fileutils'

class Image  
  VARIANT_DELIMITER = '_'
  attr_reader :path, :content
  
  def initialize(path, content = nil)
    @path = path, @content = content
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
  
  def full_dirname
    File.dirname(@path)
  end
  
  def dirname
    File.dirname(@path)
  end  
  
  # Returns true if the file is of a image type
  def transformable?
    ['.gif', '.jpg', '.jpeg', '.png', '.bmp', '.tiff', '.tif'].include?(ext)
  end
    
  # create the image from an original 
  def create_from_original!
    
    if original = find_original      
      transform_with_transformations(transformations_from_to(original, @path), original, @path)
    else
      nil
    end
    
    self
  end
  
  def transform_to(target)
    content = transform_with_transformations(transformations_from_to(@path, target), @path, target)
    
    Image.new(target, content)
  end
  
  private
  
  def transform_with_transformations(transformations, source, target)
    img = transformations.inject( Magick::Image.read(source).first ) do |image, variation|
      transformation = Transformations[variation]
      raise ArgumentError, "#{variation} is not a known transformation. (#{Transformations.list.join(', ')})" if transformation.nil?
      image = transformation.call(image)      
      raise ArgumentError, "Creating variant #{variation} for #{path} produced an error. Please return a Magick::Image" if image.nil?
      
      image
    end
    
    img.to_blob
  end
  
  def transformations_from_to(from, to)    
    source = File.basename(from, File.extname(from))
    target = File.basename(to, File.extname(to))  
    
    variants = target.dup
    variants.sub!(/^#{Regexp.escape(source)}_?/,'')
    
    variants.split(VARIANT_DELIMITER)
  end
    
  # Reverse the filename to find the original image from which we can generate the desired 
  # transformation
  def find_original
    fragments = basename_no_ext.split(VARIANT_DELIMITER)
    
    possibilities = []
    
    (fragments.size-1).downto(1) do |pos|
      possibilities.push File.join(dirname, fragments[0..pos-1].join(VARIANT_DELIMITER) + ext)
    end
    
    possibilities.find { |path| File.exists?(path) }
  end

  
end

