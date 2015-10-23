# List of available tiles

#!/usr/bin/ruby -w
require './lib/terminal_emu.rb'

class Tile
  attr_reader :tile_index, :char, :color

  def initialize(tile_val, char, color)
    @tile_index = tile_val
    @char = char
    @color = color
  end
end

module TileIndex
  FLOOR = Tile.new(0, '.', Color.new(ColorList::BROWN, ColorList::BLACK))
  WALL = Tile.new(1, '#', Color.new(ColorList::GRAY, ColorList::BLACK))
end

