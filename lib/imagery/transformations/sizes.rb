Imagery::Transformations.register :pico do |image|
  image.change_geometry("16x16>") { |x, y, image| image.resize!(x,y) }
end

Imagery::Transformations.register :icon do |image|
  image.change_geometry("32x32>") { |x, y, image| image.resize!(x,y) }
end

Imagery::Transformations.register :thumb do |image|
  image.change_geometry("50x50>") { |x, y, image| image.resize!(x,y) }
end

Imagery::Transformations.register :small do |image|
  image.change_geometry("100x100>") { |x, y, image| image.resize!(x,y) }
end

Imagery::Transformations.register :compact do |image|
  image.change_geometry("160x160>") { |x, y, image| image.resize!(x,y) }
end

Imagery::Transformations.register :medium do |image|
  image.change_geometry("240x240>") { |x, y, image| image.resize!(x,y) }
end

Imagery::Transformations.register :large do |image|
  image.change_geometry("480x480>") { |x, y, image| image.resize!(x,y) }
end

Imagery::Transformations.register :grande do |image|
  image.change_geometry("600x600>") { |x, y, image| image.resize!(x,y) }
end
