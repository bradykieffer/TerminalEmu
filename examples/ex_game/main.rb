# Just a little 'game' that uses the terminal emu class to do 
# some fun things. 

#!/usr/bin/ruby -w

require 'terminalemu'
require './examples/ex_game/world_gen.rb'
require './examples/ex_game/display.rb'

module Directions
  UP = '8'
  DOWN = '2'
  LEFT = '4'
  RIGHT = '6'

  UP_RIGHT = '9'
  UP_LEFT = '7'

  DOWN_RIGHT = '3'
  DOWN_LEFT = '1'
end

class GameEngine
  include Display

  attr_accessor :world, :window

  def initialize(window, x, y)
    @world = World.new(x, y)
    @window = window
    
    @input = window.input

    @center_x = screen_width  / 2 
    @center_y = screen_height / 2
    @col = Color.new(ColorList::YELLOW, ColorList::BROWN)
  end

  def game_logic
    # The big logic goes here
    left = get_scroll_x
    top = get_scroll_y


    # Display world
    display_world(@window, left, top)
    window.put_char(center_x - left, center_y - top, 'X', @col, :flashing)
    
    # Display actors
    # Get input
    if @input.text.nil? == false && @input.text != ""
      # Update
      respond_to_input(@input.text)
      @input.text = nil
    end
     
  end

  def center_x
    @center_x
  end

  def center_y
    @center_y
  end

  def get_scroll_x
    [0, [center_x - screen_width / 2, world_width - screen_width].min].max
  end

  def get_scroll_y
    [0, [center_y - screen_height / 2, world_height - screen_height].min].max
  end

  def screen_width
    @window.x
  end

  def screen_height
    @window.y
  end

  def world_width
    @world.x
  end

  def world_height
    @world.y
  end

  private
  def scroll_by(mx, my)
    @center_x = [0, [center_x + mx, world_width  - 1].min].max
    @center_y = [0, [center_y + my, world_height - 1].min].max
  end

  def respond_to_input(input)
    case input
    when '8' 
      scroll_by( 0, -1)
    when '6' 
      scroll_by( 1,  0)
    when '2' 
      scroll_by( 0,  1)
    when '4' 
      scroll_by(-1,  0)
    when '9'
      scroll_by( 1, -1)
    when '7'
      scroll_by(-1, -1)
    when '1'
      scroll_by(-1,  1)
    when '3'
      scroll_by( 1,  1)
    when 'Q'
      @window.close
    end
  end
end

class Terminal < Gosu::Window

  attr_accessor :game_engine

  def update
    update_terminal
    @game_engine.game_logic # called from game_engine!
  end
end

window = Terminal.new(80, 21, "Example Game")
window.game_engine = GameEngine.new(window, 120, 120) 
window.show