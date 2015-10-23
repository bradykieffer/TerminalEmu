# Define a screen for our game

#!/usr/bin/ruby -w
require './lib/terminal_emu.rb'

class Screen
  attr_reader :width, :height
  def initialize(width, height)
    @width = width
    @height = height
    
  end
end