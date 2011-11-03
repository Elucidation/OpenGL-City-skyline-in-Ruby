# Based off Nehe opengl lesson 2

require 'textures.rb'
require 'opengl'
include Gl, Glu, Glut

window = "" # Used to destroy window with esc key later

@speed = 5
@rotx = 0
@roty = 0
@rotz = 0
@x = 0
@y = 0
@z = -10 # Depth view

@texture_on = true

windows = 1
Windowsize= 1

@textureInstance = WallTexture.new
STDERR.puts "Created Texture"
TextureSize = @textureInstance.texture_size[0]

@textures = []
@textureC = @textureInstance.texture.flatten

def init_gl_window(width = 640, height = 480)
  load_gl_textures
  glEnable(GL_TEXTURE_2D)
  
  # Background color to black
  glClearColor(0.0, 0.0, 0.0, 0)
  # Enables clearing of depth buffer
  glClearDepth(1.0)
  # Set type of depth test
  glDepthFunc(GL_LEQUAL)
  # Enable depth testing
  glEnable(GL_DEPTH_TEST)
  # Enable smooth color shading
  glShadeModel(GL_SMOOTH)

  glMatrixMode(GL_PROJECTION)
  glLoadIdentity
  # Calculate aspect ratio of the window
  gluPerspective(45.0, width / height, 0.1, 1000.0)
  
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)
  
  #glLightfv(GL_LIGHT1, GL_AMBIENT, LightAmbient)
  #glLightfv(GL_LIGHT1, GL_DIFFUSE, LightDiffuse)  
  #glLightfv(GL_LIGHT1, GL_POSITION, LightPosition)
  #glEnable(GL_LIGHT1)
  
  glMatrixMode(GL_MODELVIEW)  
  
  draw_gl_scene
end

def load_gl_textures
  @textures = glGenTextures(1)
  data = @textureC.pack("f*")
  glBindTexture(GL_TEXTURE_2D, @textures[0])
  
  glTexImage2D(
    GL_TEXTURE_2D, # target
    0,             # mipmap level,
    GL_RGB8,       # internal format
    TextureSize,TextureSize,          # width, height
    0,             # border = no
    GL_RGB,        # components per each pixel
    GL_FLOAT,      # component type - floats
    data           # the packed data
  )
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR)	# Linear Filtering
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR)	# Linear Filtering
end



def draw_gl_scene
  # Clear the screen and depth buffer
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
  
  # Reset the view
  glMatrixMode(GL_MODELVIEW)
  glLoadIdentity
  
  glTranslatef(@x,@y,@z)
  glRotate(@rotx,1,0,0)
  glRotate(@roty,0,1,0)
  glRotate(@rotz,0,0,1)
  
  glColor3f(1,1,1)
  glBindTexture(GL_TEXTURE_2D, @textures[0])
  
  glEnable(GL_TEXTURE_2D) if @texture_on == true
  
  w = 15.0 # each unit is a window
  h = 10.0 
  
  glBegin(GL_QUADS)
    # Front
    glNormal3f(0,0,1)
    glTexCoord2f(0,0); glVertex3f(-w/2,-h/2,0)
    glTexCoord2f(8*w/512,0); glVertex3f(w/2,-h/2,0)
    glTexCoord2f(8*w/512,8*h/512); glVertex3f(w/2,h/2,0)
    glTexCoord2f(0,8*h/512); glVertex3f(-w/2,h/2,0)
  glEnd
  glDisable(GL_TEXTURE_2D)

  
  glutSwapBuffers
  
end    

def reshape(width, height)
    height = 1 if height == 0

    # Reset current viewpoint and perspective transformation
    glViewport(0, 0, width, height)

    glMatrixMode(GL_PROJECTION)
    glLoadIdentity
    gluPerspective(45.0, width.to_f / height.to_f, 0.1, 1000.0)
end

# The idle function to handle 
def idle
    glutPostRedisplay
end

###########################
# Keyboard handler to exit when ESC is typed
keyboard = lambda do |key, x, y|
  case(key)
    when 27
      glutDestroyWindow(window)
      exit(0)
    when 91
      # Wireframe mode via [
      glPolygonMode(GL_FRONT_AND_BACK,GL_LINE)
    when 93
      # Flat shading mode via ]
      glPolygonMode(GL_FRONT_AND_BACK,GL_FILL)
    when 61
      # Enable textures via '='
      glEnable(GL_TEXTURE_2D)
      @texture_on = true
    when 45
      # Disable textures via '-'
      glDisable(GL_TEXTURE_2D)
      @texture_on = false
    when 119 #w
      @rotx += @speed
    when 97 #a
      @roty += @speed
    when 115 #s
      @rotx -= @speed
    when 100 #d
      @roty -= @speed
    when 116 #t
      @y += @speed
    when 102 #f
      @x += @speed
    when 103 #g
      @y -= @speed
    when 104 #h
      @x -= @speed
    when 113 #q
      @z -= @speed*2
    when 101 #e
      @z += @speed*2
    end
    #STDERR.puts key
    glutPostRedisplay
end
###########################

# Initliaze our GLUT code
glutInit
# Setup a double buffer, RGBA color, alpha components and depth buffer
glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_ALPHA | GLUT_DEPTH)
glutInitWindowSize(400, 300);
glutInitWindowPosition(0, 0);
window = glutCreateWindow("6th attempt at ruby opengl")
glutDisplayFunc(method(:draw_gl_scene).to_proc)
glutReshapeFunc(method(:reshape).to_proc)
glutIdleFunc(method(:idle).to_proc)
glutKeyboardFunc(keyboard)
init_gl_window(400, 300)
STDERR.puts "Press '[' for wireframe mode"
STDERR.puts "Press ']' for flat shading mode"
STDERR.puts "Press '-' for texture off"
STDERR.puts "Press '+' for texture on"
STDERR.puts "WASD to rotate camera & QE to zoom in and out"
STDERR.puts "TFGH to move camera"
glutMainLoop()
