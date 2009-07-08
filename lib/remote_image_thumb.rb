require 'remote_image'

class RemoteImageThumb < RemoteImage
    
  def find_original_path
    super.sub(/thumbs\//, '')
  end
  
end