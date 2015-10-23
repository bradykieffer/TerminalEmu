# Now let's make a perfect (but boring) maze
# I hacked this together too quickly so it won't be all that 
# good but oh well it's more of a proof of concept :)

#!/usr/bin/ruby -w

require '../lib/terminal_emu.rb'

def make_maze(window)
  arr = Array.new(window.x)
  (0...arr.length).each { |i| arr[i] = Array.new(window.y) }
  render_maze(window, gen_arr(fill_edges(arr)))
end

def fill_edges(arr)
  (0...arr.length).each do |x|
    (0...arr[x].length).each do |y|
      if x == 0 || y == 0 || x == arr.length - 1 || y == arr[x].length - 1
        arr[x][y] = 1
      else
        arr[x][y] = 0
      end
    end
  end
  arr
end
def first_coords(arr)
  x = y = 0
  if rand(100) < 50
    x = rand(arr.length)
    
    if rand(100) < 50
      # x is rand, y is 0
      y = 0
    else
      # x is rand, y is max
      y = arr[0].length - 1
    end
  
  else
    y = rand(arr[0].length)

    if rand(100) < 50
      # x is 0, y is rand
      x = 0
    else
      # x is max, y is rand
      x = arr.length - 1
    end
  end
  return x, y
end

def get_dir(x, y, arr)
  xo = yo = 0
  if rand(100) < 50
    # x is up
    loop do
      xo = rand(100) < 50 ? 1 : -1 
      break if x + xo >= 0 && x + xo < arr.length
    end
  else
    # y is up
    loop do
      yo = rand(100) < 50 ? 1 : -1 
      break if y + yo >= 0 && y + yo < arr[0].length
    end
  end

  return x + xo, y + yo
end

def gen_arr(arr)
  # first get a random coord along the outside walls 
  x = y = 0
  loop do
    x, y = first_coords(arr)
    x, y = get_dir(x, y, arr)
    arr = place_wall(x, y, arr)
    break if arr[x][y] = 1
  end
  (0..10_000).each do
    x = rand(1...arr.length)
    y = rand(1...arr[0].length)
    x, y = get_dir(x, y, arr)
    arr = place_wall(x, y, arr)
  end
  arr
end

def place_wall(x, y, arr)
  num_neighbours = 0
  if x - 1 > 0
    num_neighbours += arr[x - 1][y] == 1 ? 1 : 0
  end
  if x + 1 < arr.length
    num_neighbours += arr[x + 1][y] == 1 ? 1 : 0
  end

  if y - 1 > 0
    num_neighbours += arr[x][y - 1] == 1 ? 1 : 0
  end

  if y + 1 < arr[0].length 
    num_neighbours += arr[x][y + 1] == 1 ? 1 : 0
  end

  arr[x][y] = 1 if num_neighbours == 1
  arr
end

def render_maze(window, arr)
  (0...arr.length).each do |x|
    (0...arr[x].length).each do |y|
      arr[x][y] == 1 ? window.put_char(x, y, '#', Color::WHITE) : window.put_char(x, y, '.', Color::YELLOW)
    end
  end
end
window = Terminal.new(80, 25, "A Perfect Maze")
make_maze(window)
window.put_char(0, 0, "X", Color::RED)
window.put_char(79, 0, "X", Color::RED)
window.put_char(0, 24, "X", Color::RED)
window.put_char(79, 24, "X", Color::RED)
window.show