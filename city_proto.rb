require "buildings.rb" # used to make actual buildings
require "textures.rb" # used to texture buildings with windows
#require "terrain.rb" # used to find heights of buildings
require 'opengl' # used to see anything
include Gl, Glu, Glut

#srand(2234256)

class City
  attr_reader :size, :all_buildings
  
  POS = [5.0, 5.0, 10.0, 0.0]
  RED = [0.8, 0.1, 0.0, 1.0]
  GREEN = [0.0, 0.8, 0.2, 1.0]
  BLUE = [0.2, 0.2, 1.0, 1.0]
  BLACK = [0,0,0,1]
  WHITE = [1,1,1,1]
  BACKGROUND_COLOR = BLACK
  
  TEXTURE_SIZE = [32,32]
  
  MAX_BUILDING_HEIGHT = 100
  
  def initialize size = [1,1]
    GLUT.Init()
    GLUT.InitDisplayMode(GLUT::RGB | GLUT::DEPTH | GLUT::DOUBLE)

    GLUT.InitWindowPosition(400, 150)
    GLUT.InitWindowSize(500, 500)
    GLUT.CreateWindow('City')
    init(size)
    
    # Background color to black
    glClearColor(*BACKGROUND_COLOR)
    # Enables clearing of depth buffer
    glClearDepth(1.0)
    # Set type of depth test
    glDepthFunc(GL_LEQUAL)
    # Enable depth testing
    glEnable(GL_DEPTH_TEST)
    # Enable smooth color shading
    glShadeModel(GL_SMOOTH)
    
    # Lights
    GL.Lightfv(GL::LIGHT0, GL::POSITION, POS)
    GL.Enable(GL::CULL_FACE)
    GL.Enable(GL::LIGHTING)
    GL.Enable(GL::LIGHT0)
    GL.Enable(GL::DEPTH_TEST)

    GLUT.DisplayFunc(method(:draw).to_proc)
    GLUT.ReshapeFunc(method(:reshape).to_proc)
    GLUT.KeyboardFunc(method(:key).to_proc)
    GLUT.SpecialFunc(method(:special).to_proc)
    GLUT.VisibilityFunc(method(:visible).to_proc)
    @t0 = GLUT.Get(GLUT::ELAPSED_TIME)
  end
  
  def init size = [1,1]
    @size = size
    @all_buildings = Array.new(size[0]) { Array.new(size[1]) }   
    @bufferx,@buffery = [15,15] # Maximum footprint of all buildings, ought be larger than buildings
    
    # Load textures
    @texture_inst = WallTexture.new(TEXTURE_SIZE)
    @texture_on = true
    glEnable(GL_TEXTURE_2D)
    STDERR.puts "Building Textures created & loaded"
    
    # Build building height map
    @height_map = Array.new(size[0]) { Array.new(size[1]) { 5 + (rand*15).floor }}   
    @height_map.each_index do |i|
      @height_map[i].each_index do |j|
        d = Math.sqrt( (i-size[0]/2.0)**2 + (j-size[1]/2.0)**2 )
        if d < size[0] / 4
          @height_map[i][j] *= 4
        elsif d < size[0] / 3
          @height_map[i][j] *= 3
        elsif d < size[0] / 2
          @height_map[i][j] *= 2
        end
      end
    end
    STDERR.puts "Building height map finished"
    
    # Make buildings in grid
    @all_buildings.each_index do |i|
      @all_buildings[i].each_index do |j|
        @all_buildings[i][j] = Building.new( @texture_inst, @height_map[i][j], 10,10)
      end
    end
    #STDERR.puts @all_buildings[0].map{|b| b.height}.inspect
    
    @rotx, @roty, @rotz = 30.0, 30.0, 0.0
    @x,@y,@z = 0,0,-100
    
    polycount = size[0]*size[1]*6 # raw number of polgyons
    STDERR.puts "Rendering #{polycount} polygons"
    @frames = 0 # frame counter
  end
  
  def start
    GLUT.MainLoop()
  end
  
  def reshape(width, height)
    height = 1 if height == 0
    glViewport(0, 0, width, height)
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity
    gluPerspective(45.0, width.to_f / height.to_f, 0.1, 1000.0)
  end
  
  def idle
    GLUT.PostRedisplay()
  end
  
  def visible(vis)
    GLUT.IdleFunc((vis == GLUT::VISIBLE ? method(:idle).to_proc : nil))
  end
  
  # Change view angle, exit upon ESC
  def key(k, x, y)
    case k
      when ?z
        @z += 5.0
      when ?Z
        @z -= 5.0
      when ?w
        glPolygonMode(GL_FRONT_AND_BACK,GL_LINE) # Wireframe
      when ?W
        glPolygonMode(GL_FRONT_AND_BACK,GL_FILL) # Solid
      when ?t
        @texture_on = true
        glEnable(GL_TEXTURE_2D)
      when ?T
        @texture_on = false
        glDisable(GL_TEXTURE_2D)
      when ?l
        GL.Enable(GL::LIGHTING)
      when ?L
        GL.Disable(GL::LIGHTING)
      when 27 # Escape
        t = GLUT.Get(GLUT::ELAPSED_TIME)
        seconds = (t - @t0) / 1000.0
        fps = @frames / seconds
        printf("%d frames in %6.3f seconds = %6.3f FPS\n", @frames, seconds, fps)
        exit
    end
    GLUT.PostRedisplay()
  end

  # Change view angle
  def special(k, x, y)
    case k
      when GLUT::KEY_UP
        @rotx += 5.0
      when GLUT::KEY_DOWN
        @rotx -= 5.0
      when GLUT::KEY_LEFT
        @roty += 5.0
      when GLUT::KEY_RIGHT
        @roty -= 5.0
    end
    GLUT.PostRedisplay()
  end
  
  def draw
    # Clear the screen and depth buffer
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    
    # Reset the view
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity
    
    GL.PushMatrix()
    glTranslatef(@x,@y,@z)
    glRotate(@rotx,1,0,0)
    glRotate(@roty,0,1,0)
    glRotate(@rotz,0,0,1)
    
    # Draw here    
    glBindTexture(GL_TEXTURE_2D, @texture_inst.texture_link[0])
    drawAllBuildings
    
    GL.PopMatrix()
    glutSwapBuffers
    @frames += 1
  end
  
  def drawAllBuildings
    GL.Translate(0.5*@bufferx*(1-@size[0]),0,0.5*@buffery*(1-@size[1])) # Center building matrix
    
    @all_buildings.each_index do |i|
      @all_buildings[i].each_index do |j|
        
        @all_buildings[i][j].draw
        GL.Translate(0,0,@buffery)
        
      end
      GL.Translate(@bufferx,0,-@buffery*@size[1]) # reset x pos
    end
  end
end

City.new([1,1]).start