# Creates a 

Transformations.register :border do |image|  
  # Add Polaroid border
  image.border!(5, 5, "white")  
end

Transformations.register :shadow do |image|
  shadow = image.flip
  shadow = shadow.colorize(1, 1, 1, "#ccc")
  shadow.background_color = "white"
  shadow.border!(10, 10, "white")
  shadow = shadow.blur_image(0, 7)
  
  x = (shadow.columns - image.columns) / 2 
  y = (shadow.rows - image.rows) / 2 

  ## Composite original image on top of shadow and save
  shadow.composite(image, x, y-3, Magick::OverCompositeOp)    
end

Transformations.register :polaroid do |image|
  image.border!(10, 10, "white")  

  shadow = image.colorize(1, 1, 1, "#ccc")
  shadow.background_color = "white"
  shadow.border!(10, 10, "white")
  shadow = shadow.blur_image(0, 7)
  
  x = (shadow.columns - image.columns) / 2 
  y = (shadow.rows - image.rows) / 2 

  ## Composite original image on top of shadow and save
  shadow.composite(image, x, y-3, Magick::OverCompositeOp)      
end