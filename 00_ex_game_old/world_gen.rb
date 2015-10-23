# Makes some caves for us to use and writes them to an array

#!/usr/bin/ruby -w
require './lib/terminal_emu.rb'
require './examples/ex_game/tiles.rb'

module WorldBuilder
  def gen_world(x, y)
    fill_edges(smooth(gen_random_walls(x, y), 8))
  end

  def smooth(arr, times)
    (0..times).each do
      (1...x - 1).collect do |i|
        (1...y - 1).collect do |j|
          floors = 0
          walls = 0
          # Get the number of walls and floors around the current cell
          (-1..1).each do |io|
            (-1..1).each do |jo|
              arr[i + io][j + jo] == TileIndex::WALL.tile_index ? walls += 1 : floors += 1
            end
          end
        walls > floors ? arr[i][j] = TileIndex::WALL.tile_index : arr[i][j] = TileIndex::FLOOR.tile_index 
        end
      end
    end
    arr
  end

  def gen_random_walls(x, y)
    (0...x).collect do |i|
      (0...y).collect do |j|
        rand(100) < 49 ? TileIndex::FLOOR.tile_index : TileIndex::WALL.tile_index
      end
    end
  end

  def fill_edges(arr)
    (0...arr.length).each do |i|
      (0...arr[i].length).each { |j| arr[i][j] = TileIndex::WALL.tile_index if i == 0 || j == 0 || i == arr.length - 1 || j == arr[i].length - 1 }
    end
    arr
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


