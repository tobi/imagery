Transformations.register :square do |image|
  min = [image.columns, image.rows].min
  image.crop_resized(min, min, Magick::CenterGravity)
end

Transformations.register 'max-square' do |image|
  max = [image.columns, image.rows].max
  image.crop_resized(max, max, Magick::CenterGravity)
end

Transformations.register 'pico-square' do |image|  
  image.crop_resized(16,16, Magick::CenterGravity)
end

Transformations.register 'icon-square' do |image|  
  image.crop_resized(32,32, Magick::CenterGravity)
end

Transformations.register 'thumb-square' do |image|  
  image.crop_resized(50,50, Magick::CenterGravity)
end

Transformations.register 'medium-square' do |image|  
  image.crop_resized(240,240, Magick::CenterGravity)
end

Transformations.register 'small-square' do |image|  
  image.crop_resized(100,100, Magick::CenterGravity)
end

Transformations.register 'large-square' do |image|  
  image.crop_resized(480,480, Magick::CenterGravity)
end

