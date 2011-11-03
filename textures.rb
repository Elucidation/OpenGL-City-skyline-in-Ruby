class WallTexture
  attr_reader :texture, :texture_link, :texture_size, :windows
  
  DARK_TO_LIGHT_RATIO = 0.2 # ratio of dark to light windows [ lower = more dark windows]
  
  
  def initialize texture_size = [512,512]
    @texture_size = texture_size
    @texture = Array.new(@texture_size[0]) { Array.new(@texture_size[1]) { Array.new(3){1} } }
    @windows = [@texture_size[0]/8, @texture_size[1]/8]
    @texture_link = [0]
    
    @windows[0].times do |i|
      @windows[1].times do |j|
        px_origin = i*8
        py_origin = j*8
        # Got a little 8x8 window with pixel coords starting in px/py origin being topleft corner of window
        
        # Walls
        8.times do |x|
          @texture[px_origin + x][py_origin] = [0,0,0]
          @texture[px_origin + x][py_origin+7] = [0,0,0]
          @texture[px_origin][py_origin + x] = [0,0,0]
          @texture[px_origin + 7][py_origin + x] = [0,0,0]
        end
        
        # Inside color, either mostly on or mostly off
        if rand > DARK_TO_LIGHT_RATIO
          cr = rand/4.0
        else
          cr = 3.0/4 + rand/4.0
        end
        c = [cr,cr,cr]
        
        # Inside
        6.times do |x|
          6.times do |y|
            px = px_origin + 1 + x
            py = py_origin + 1 + y
            
            @texture[px][py] = c
          end
        end        
      end
    end
    
    loadTexture
  end
  
  def loadTexture
    @texture_link = glGenTextures(1)
    data = @texture.flatten.pack("f*")
    glBindTexture(GL_TEXTURE_2D, @texture_link[0])
    
    glTexImage2D(
      GL_TEXTURE_2D, # target
      0,             # mipmap level,
      GL_RGB8,       # internal format
      @texture_size[0],@texture_size[1],          # width, height
      0,             # border = no
      GL_RGB,        # components per each pixel
      GL_FLOAT,      # component type - floats
      data           # the packed data
    )
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)	# Linear Filtering min
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)	# Linear Filtering mag
  end
end