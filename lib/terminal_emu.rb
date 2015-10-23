# A super simple but pretty sweet terminal 

#!/usr/bin/ruby -w
require 'rubygems'
require 'gosu'
require './lib/glyphs.rb'
require './lib/sub_terminal.rb'
require './lib/character_data.rb'
class Terminal < Gosu::Window

  attr_reader  :font, :input, :time_for_updates
  attr_accessor :sub_wins
  
  def initialize(x, y, title)
    # The magic numbers for x & y make it look best on my machine, you may have to change this  
    @x = x * CharData::CHAR_WIDTH
    @y = y * CharData::CHAR_HEIGHT

    super @x, @y, false

    self.caption = title
    
    # This will be used to track flashing characters :) 
    @time_for_updates = 0
    
    # Set up our font renderer
    @font = Gosu::Font.new(self, CharData::FONT, CharData::FONT_SIZE)
    @glyphs = Array.new

    # This hash will track all of the drawn tiles and will overwrite 
    # any of the ones that have already been drawn on 
    @drawn_coords = Hash.new

    # The subwindows within our Terminal
    @sub_wins = Array.new

    @input = Gosu::TextInput.new
    self.text_input = @input
    
  end
  
  def draw
    draw_glyphs
    draw_sub_wins
  end

  def draw_glyphs(sub_win_glyphs = nil)
    if sub_win_glyphs.nil? == true
      @glyphs.each do |glyph|
        next if glyph.nil?
        write_glyph glyph
        # Drawing lines
        determine_line(glyph)
      end
    else
      sub_win_glyphs.each do |glyph|
        next if glyph.nil?
        write_glyph glyph
      end
    end
  end

  def draw_sub_wins
    @sub_wins.each { |sub_win| sub_win.draw }
  end

  # Returns a glyph at a given coordinate on the screen
  #
  def glyph_at(x, y)
    @glyphs[@drawn_coords["#{ x }, #{ y }"]]
  end

  def in_bounds?(x, y)
    x < self.x && x >= 0 && y < self.y && y >= 0 ? true : false
  end

  # Enables the cursor to be visible within the terminal.
  #
  def needs_cursor?
    true 
  end
  
  # Draws a character to the Terminal
  #
  def put_char(x, y, char, color = Color.new, *attributes)
    if in_bounds? x, y
        push_char(x, y, char, color, *attributes)
    else
      raise ArgumentError, "Invalid x and/or y given to put_char. (x,y) = (#{ x },#{ y })"
    end 
  end
  
  # Draws a string to the Terminal
  #
  def put_string(x, y, string, color = Color.new, *attributes)
    if in_bounds?(x, y) && in_bounds?(x + string.length, y)
      (0...string.length).each { |i| push_char(x + i, y, string[i], color, *attributes) }
    else
      raise ArgumentError, "Invalid x and/or y given to put_string. (x,y) = (#{ x },#{ y })"
    end
  end

  # Starts the terminal, takes a proc to insert into our update function...
  #


  # The loop that will be run when Terminal.show is called
  #
  def update
    update_terminal
  end

  # Returns the width of the current terminal in characters
  def x
    @x / CharData::CHAR_WIDTH
  end

  # Returns the height of the current terminal in characters
  def y
    @y / CharData::CHAR_HEIGHT
  end

  private

  def determine_line(glyph)
    x = glyph.pix_x_pos - 1
    y = glyph.pix_y_pos - 1
    
    if glyph.left_line?
      draw_line(x, y,                         ColorList::WHITE,
                x, y + CharData::CHAR_HEIGHT, ColorList::WHITE)
    end

    if glyph.right_line?
      draw_line(x + CharData::CHAR_WIDTH, y,                         ColorList::WHITE, 
                x + CharData::CHAR_WIDTH, y + CharData::CHAR_HEIGHT, ColorList::WHITE)
    end

    if glyph.top_line?
      draw_line(x,                        y, ColorList::WHITE, 
                x + CharData::CHAR_WIDTH, y, ColorList::WHITE)
    end

    # But seriously wtf is the bottom line here??!?!??!!?
    if glyph.bottom_line?
      draw_line(x,                        y + CharData::CHAR_HEIGHT, ColorList::WHITE,
                x + CharData::CHAR_WIDTH, y + CharData::CHAR_HEIGHT, ColorList::WHITE)
      # I think I found it.... Somewhere in here....
    end
  end

  def draw_character(x, y, color, glyph)
    # I'm so sorry
    # This is a complete hack
    # But I don't want to change it yet 
    case glyph.font
    when :bold
      @font.draw(glyph.char, x,       y, 0, 1.0, 1.0, color)
      @font.draw(glyph.char, x + 1.0, y, 0, 1.0, 1.0, color)
    when :italic
      rotate(10.0, glyph.center_x, glyph.center_y){ 
        @font.draw(glyph.char, x, y, 0, 1.0, 1.0, color)
      }
    when :bold_italic
      rotate(10.0, glyph.center_x, glyph.center_y){ 
        @font.draw(glyph.char, x, y, 0, 1.0, 1.0, color)
        @font.draw(glyph.char, x + 0.5, y, 0, 1.0, 1.0, color)
      }
    else
      @font.draw(glyph.char, x, y, 0, 1.0, 1.0, color)
    end
  end
 
  def push_char(x, y, char, color, *attributes)
    if @drawn_coords["#{ x }, #{ y }"] != nil
      @glyphs[@drawn_coords["#{ x }, #{ y }"]] = Glyph.new(Point.new(x, y), char, color, *attributes)
    else
      @drawn_coords["#{ x }, #{ y }"] = @glyphs.length
      @glyphs << Glyph.new(Point.new(x, y), char, color, *attributes)
    end
  end

  # Updates all of the current glyphs within the terminal
  # Note that this only occurs roughly every second
  # 
  # => If the flashing flag is enabled the glyphs' colors will be inverted to give it a flashing effect
  # => If there are any sub windows under this terminal, their update methods are called
  #
  def update_terminal
    @time_for_updates += update_interval
    if time_for_updates > update_interval * CharData::UPDATE_TIME
      @glyphs.each do |glyph|
        next if glyph.nil?
        glyph.swap_colors if glyph.flashing?
      end
      update_sub_wins
      @time_for_updates = 0
    end
  end

  def update_sub_wins
    @sub_wins.each { |sub| sub.update }
  end
  
  # Writes the glyph to the terminal
  # Starts by using Gosus' draw_quad method to draw the background 
  # Then uses the font render to write the character into the foreground
  def write_glyph(glyph)
    x = glyph.pix_x_pos
    y = glyph.pix_y_pos
    width_padding = glyph.width_padding(@font)
    
    fore_col, back_col = glyph.dim? ? glyph.dim_colors : glyph.colors
    # Background
    # Images are drawn in this order when calling draw_quad:
    # 1-----2
    # |     |
    # |     |
    # 3-----4
    draw_quad(x,                        y,                         back_col, # First corner
              x + CharData::CHAR_WIDTH, y,                         back_col, # Second corner
              x,                        y + CharData::CHAR_HEIGHT, back_col, # Third corner
              x + CharData::CHAR_WIDTH, y + CharData::CHAR_HEIGHT, back_col) # Fourth Corner

    # Now draw the font
    draw_character(x + width_padding, y, fore_col, glyph)
  end
end