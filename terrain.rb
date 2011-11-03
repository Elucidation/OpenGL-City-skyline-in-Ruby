def see x
  # Shows 2d array in 2d format inspect
  puts x.map{|row| row.inspect}.join("\n")
end

def see_easy x
  puts x.map{ |row| row.map{|val| val.round}.inspect}.join("\n")
end

def avgval map, i, j
  # returns average value of pixel and adjacent neighbors
  
  # Account for edges
  left = i-1 == -1 ? i : i-1
  right = i+1 == map[0].length ? i : i+1
  up = j-1 == -1 ? j : j-1
  down= j+1 == map.length ? j : j+1
  
  sum = map[i][j] + map[left][j] + map[right][j]  +
          map[i][up] + map[left][up] + map[right][up] +
          map[i][down] + map[i-1][down] + map[right][down]
 return sum.to_f/9.0
end
 
def buildTerrainMap worldsize=[10,10], maxpeakheight = 10, peaks = 10, erosion_factor = 1, is_rounded = false
  # Define array size of entire world

   
  #  Build flat plain at lowest level
   
  heightmap = []
  worldsize[0].times do |i|
    heightmap[i] =  []
    worldsize[1].times do |j|
      heightmap[i][j] = 1
    end
  end


  # Create peaks

  peaks.times do |i|
    x = (rand*worldsize[0]).floor
    y = (rand*worldsize[1]).floor
    heightmap[x][y] = maxpeakheight
  end


  # Cause Mass Erosion
  erosion_factor.times do
    nextheightmap = []

    worldsize[0].times do |i|
      nextheightmap[i] = []
      worldsize[1].times do |j|
        nextheightmap[i][j] = avgval(heightmap,i,j)
      end
    end
    heightmap = nextheightmap
  end
  
  # return whole numbers only if is_rounded = true
  if is_rounded
    worldsize[0].times do |i|
      worldsize[1].times do |j|
        heightmap[i][j] = heightmap[i][j].round
      end
    end
  end
  
  return heightmap
end
################################


#a = buildTerrainMap
#see_easy a
