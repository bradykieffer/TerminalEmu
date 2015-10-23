# Makes some caves for us to use and writes them to an array

#!/usr/bin/ruby -w
require 'terminalemu'
require './examples/ex_game/tiles.rb'

module WorldBuilder
  def gen_world(x, y)
    smooth(gen_random_walls(x, y), 8) # Maze.new(x, y).maze
  end

  def smooth(arr, times)
    arr_two = Array.new(arr.length) { Array.new(arr[0].length) }

    (0..times).each do
      (0...x).collect do |i|
        (0...y).collect do |j|
          floors = 0
          walls = 0
          # Get the number of walls and floors around the current cell
          (-1..1).each do |io|
            (-1..1).each do |jo|
              next if i + io < 0 || i + io >= x || j + jo < 0 || j + jo >= y

              arr[i + io][j + jo] == TileIndex::WALL ? walls += 1 : floors += 1
            end
          end
          arr_two[i][j] = walls > floors ?  TileIndex::WALL : TileIndex::FLOOR 
        end
      end
      arr = arr_two
    end
    arr
  end

  def gen_random_walls(x, y)
    (0...x).collect do |i|
      (0...y).collect do |j|
        rand(100) < 49 ? TileIndex::FLOOR : TileIndex::WALL
      end
    end
  end
end

class Maze
  attr_reader :maze

  DIRECTIONS = [
                [ 0,  1], # Down
                [ 0, -1], # Up
                [ 1,  0], # Right
                [-1,  0], # Left
               ]

  def initialize(x, y)
    @x = x
    @y = y

    @maze = Array.new(x) { Array.new(y) }
    @valid_coords = Array.new
    gen_maze
  end

  def gen_maze
    fill_edges
    
    # Gives us the entrance and exit
    make_opening
    make_opening

    place_walls

  end

  def fill_edges
    (0...@x).each do |i|
      (0...@y).each do |j|
        @maze[i][j] = i == 0 || i == @x - 1 || j == 0 || j == @y - 1 ? TileIndex::WALL : TileIndex::FLOOR
      end
    end
  end

  def make_opening
    side = rand(4)
    case side
    when 0 # Top
      @maze[rand(@x)][0] = TileIndex::FLOOR
    when 1 # Right
      @maze[@x - 1][rand(@y)] = TileIndex::FLOOR 
    when 2 # Bottom
      @maze[rand(@x)][@y - 1] = TileIndex::FLOOR
    when 3 # Left
      @maze[0][rand(@y)] = TileIndex::FLOOR
    end
  end

  def maze_done?
    complete = true
    (0...@x).each do |i|
      (0...@y).each do |j|
        if num_neighbours(i, j) < 3
          complete = false
          @valid_coords << [i, j] 
        end
      end
    end
    complete
  end

  def next_direction(i, j)
    next_dir = DIRECTIONS[rand(DIRECTIONS.length)]
    i += next_dir[0]
    j += next_dir[1]
    return i, j
  end

  def num_neighbours(i, j)
    num_walls = 0
    (-1..1).each do |io|
      next if i + io < 0 || i + io >= @x
      (-1..1).each do |jo|
        next if j + jo < 0 || j + jo >= @y

        num_walls += 1 if @maze[i + io][j + jo] == TileIndex::WALL
      end
    end
    num_walls
  end

  def place_walls
    i = rand(1...@x - 1)
    j = rand(1...@y - 1)
    while maze_done? == false

      loop do
        break if num_neighbours(i, j) > 2
        @maze[i][j] = TileIndex::WALL
        i, j = next_direction(i, j)
      end
      i = @valid_coords[rand(@valid_coords.length)][0]
      j = @valid_coords[rand(@valid_coords.length)][1]
    end
  end
end

class World
  include WorldBuilder
  
  attr_accessor :world_map
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
    
    @world_map = gen_world(@x, @y)
  end
end


