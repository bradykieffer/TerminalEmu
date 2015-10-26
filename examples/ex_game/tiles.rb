# List of available tiles

#!/usr/bin/ruby -w
require 'terminalemu'

class Tile
  attr_reader :char, :color, :attributes

  def initialize(char, color, *attributes)
    @char = char
    @color = color
    @attributes = *attributes
  end

end

module TileIndex
  FLOOR = Tile.new('.', Color.new(ColorList::BROWN, ColorList::BLACK))
  WALL =  Tile.new('#', Color.new(ColorList::GRAY, ColorList::BLACK))
end