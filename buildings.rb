class Building
  attr_reader :length, :width, :height
  def initialize texture, height=10, length=5, width=5
    @length, @width, @height = length,width, height    
    @hw = @width/2.0
    @hl = @length/2.0
    @texture = texture
    @texture_ratio = [8/@texture.texture_size[0].to_f,
                             8/@texture.texture_size[0].to_f ] # basically normalized value of value to show just one window
    @texture_start = [ (@texture.windows[0]*rand).floor * 8 / @texture.texture_size[0].to_f , # Front 
                              (@texture.windows[1]*rand).floor * 8 / @texture.texture_size[1].to_f ,
                              
                              (@texture.windows[1]*rand).floor * 8 / @texture.texture_size[1].to_f , # Left
                              (@texture.windows[1]*rand).floor * 8 / @texture.texture_size[1].to_f ,
                              
                              (@texture.windows[1]*rand).floor * 8 / @texture.texture_size[1].to_f , # Right
                              (@texture.windows[1]*rand).floor * 8 / @texture.texture_size[1].to_f ,
                              
                              (@texture.windows[1]*rand).floor * 8 / @texture.texture_size[1].to_f , # Back
                              (@texture.windows[1]*rand).floor * 8 / @texture.texture_size[1].to_f ,
                              ] # normalized in [0,1] range, don't use texture_ratio cause rand needs to floor at windows
    #STDERR.puts @texture_start.inspect
    @it = GL.GenLists(1)
    GL.NewList(@it, GL::COMPILE)
    draw_gl_Building
    GL.EndList
  end
  
  def draw
    GL.PushMatrix()
    GL.CallList(@it)
    GL.PopMatrix()
  end  
    # Each function starts with the center base of the building as the initial point.
  def draw_gl_Building
    # Draw building, replace this simple cube with actual building eventually
    draw_textured_gl_cube
  end
  
  def draw_textured_gl_cube #tx,ty is texture range to go to
    glBegin(GL_QUADS)
      #glColor3f(1,0,0)
      # Front
      glNormal3f(0,0,1)
      glTexCoord2f(@texture_start[0]                    , @texture_start[1] );                        glVertex3f(-@hw,0,@hl)
      glTexCoord2f(@texture_start[0] + @hw*@texture_ratio[0] , @texture_start[1] );                       glVertex3f(@hw,0,@hl)
      glTexCoord2f(@texture_start[0] + @hw*@texture_ratio[0] , @texture_start[1] + @height*@texture_ratio[1]);     glVertex3f(@hw,@height,@hl)
      glTexCoord2f(@texture_start[0]                    , @texture_start[1] + @height*@texture_ratio[1] );    glVertex3f(-@hw,@height,@hl)
      #glColor3f(1,1,1)
      # Back
      glNormal3f(0,0,-1)
      glTexCoord2f(@texture_start[2]                    , @texture_start[3] ); glVertex3f(@hw,0,-@hl)
      glTexCoord2f(@texture_start[2] + @hw*@texture_ratio[0] , @texture_start[3] ); glVertex3f(-@hw,0,-@hl)
      glTexCoord2f(@texture_start[2] + @hw*@texture_ratio[0] , @texture_start[3] + @height*@texture_ratio[1]); glVertex3f(-@hw,@height,-@hl)
      glTexCoord2f(@texture_start[2]                    , @texture_start[3] + @height*@texture_ratio[1] ); glVertex3f(@hw,@height,-@hl)
      # Left Side
      glNormal3f(-1,0,0)
      glTexCoord2f(@texture_start[4]                    , @texture_start[5] ); glVertex3f(-@hw,0,-@hl)
      glTexCoord2f(@texture_start[4] + @hl*@texture_ratio[0] , @texture_start[5] ); glVertex3f(-@hw,0,@hl)
      glTexCoord2f(@texture_start[4] + @hl*@texture_ratio[0] , @texture_start[5] + @height*@texture_ratio[1]); glVertex3f(-@hw,@height,@hl)
      glTexCoord2f(@texture_start[4]                    , @texture_start[5] + @height*@texture_ratio[1] ); glVertex3f(-@hw,@height,-@hl)
      # Right Side
      glNormal3f(1,0,0)
      glTexCoord2f(@texture_start[6]                    , @texture_start[7] ); glVertex3f(@hw,0,@hl)
      glTexCoord2f(@texture_start[6] + @hl*@texture_ratio[0] , @texture_start[7] ); glVertex3f(@hw,0,-@hl)
      glTexCoord2f(@texture_start[6] + @hl*@texture_ratio[0] , @texture_start[7] + @height*@texture_ratio[1]); glVertex3f(@hw,@height,-@hl)
      glTexCoord2f(@texture_start[6]                    , @texture_start[7] + @height*@texture_ratio[1] ); glVertex3f(@hw,@height,@hl)
      
      # Bottom
      glNormal3f(0,-1,0)
      #glTexCoord2f(0,0); 
      glVertex3f(@hw,0,@hl)
      #glTexCoord2f(1,0); 
      glVertex3f(-@hw,0,@hl)
      #glTexCoord2f(1,1);
      glVertex3f(-@hw,0,-@hl)
      #glTexCoord2f(0,1); 
      glVertex3f(@hw,0,-@hl)
      
      # Top
      glNormal3f(0,1,0)
      #glTexCoord2f(0,0); 
      glVertex3f(-@hw,@height,@hl)
      #glTexCoord2f(1,0); 
      glVertex3f(@hw,@height,@hl)
      #glTexCoord2f(1,1); 
      glVertex3f(@hw,@height,-@hl)
      #glTexCoord2f(0,1); 
      glVertex3f(-@hw,@height,-@hl)
      
      
      
    glEnd
  end
  
end