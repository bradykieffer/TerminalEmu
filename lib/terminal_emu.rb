# A super simple but pretty sweet terminal 


# To fix the flashing glyph issue maybe assign each type of glyph a SPECIFIC colour
# OR keep an a record of glyphs (based on coordinates) that are currently flashing, updating their colors as it goes.
# make the flashing occur during the draw stage ?
#
# => Make a list of the flashing colors and use it to keep the flashes consistent
# 

#!/usr/bin/ruby -w
require 'rubygems'
require 'gosu'
require './lib/glyphs.rb'
require './lib/sub_terminal.rb'

module ZOrder
  BACKGROUND = 0
end

module CharData
  FONT = "./resources/consola.ttf" # "./resources/cour.ttf" 
                                   # Gosu::default_font_name
  FONT_SIZE = 18

  CHAR_WIDTH = 16
  CHAR_HEIGHT = 18
  UPDATE_TIME = 20

  LINE_WIDTH = 1.0

  DIM_CONSTANT = 0x70000000
end

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

    # This array is used to track our flashing colors, so that we can keep them updating consistently
    @flashing_colors = Hash.new

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
        draw_left_line(glyph)   if glyph.left_line?
        draw_right_line(glyph)  if glyph.right_line?
        draw_top_line(glyph)    if glyph.top_line?
        draw_bottom_line(glyph) if glyph.bottom_line?
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

  def is_equal?(new_glyph, curr_glyph)
    new_glyph.color.foreground == curr_glyph.color.foreground &&
    new_glyph.color.background == curr_glyph.color.background &&
    new_glyph.char             == curr_glyph.char             &&
    new_glyph.attributes       == curr_glyph.attributes
  end
  
  # Enables the cursor to be visible within the terminal.
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

  # The loop that will be run when Terminal.show is called
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
  def draw_left_line(glyph)
    x = glyph.x
    y = glyph.y
    

    width  = CharData::CHAR_WIDTH
    height = CharData::CHAR_HEIGHT

    line_col  = ColorList::WHITE
    x_offset  = CharData::LINE_WIDTH

    # Draw a left line
    # Images are drawn in this order when calling draw_quad:
    # 1-----2
    # |     |
    # |     |
    # 3-----4
    draw_quad(x * width,            y * height,          line_col, # First corner
              x * width + x_offset, y * height,          line_col, # Second corner
              x * width,            y * height + height, line_col, # Third corner
              x * width + x_offset, y * height + height, line_col) # Fourth Corner
  end

  def draw_right_line(glyph)
    x = glyph.x + 1
    y = glyph.y
    
    width  = CharData::CHAR_WIDTH
    height = CharData::CHAR_HEIGHT

    line_col  = ColorList::WHITE
    x_offset  = CharData::LINE_WIDTH

    # Draw a left line
    # Images are drawn in this order when calling draw_quad:
    # 1-----2
    # |     |
    # |     |
    # 3-----4
    draw_quad(x * width - x_offset, y * height,          line_col, # First corner
              x * width,            y * height,          line_col, # Second corner
              x * width - x_offset, y * height + height, line_col, # Third corner
              x * width,            y * height + height, line_col) # Fourth Corner
  end

  def draw_top_line(glyph)
    x = glyph.x
    y = glyph.y
    
    width  = CharData::CHAR_WIDTH
    height = CharData::CHAR_HEIGHT

    line_col = ColorList::WHITE
    
    y_offset = CharData::LINE_WIDTH

    # Draw a left line
    # Images are drawn in this order when calling draw_quad:
    # 1-----2
    # |     |
    # |     |
    # 3-----4
    draw_quad(x * width,         y * height,            line_col, # First corner
              x * width + width, y * height,            line_col, # Second corner
              x * width,         y * height + y_offset, line_col, # Third corner
              x * width + width, y * height + y_offset, line_col) # Fourth Corner
  end

  def draw_bottom_line(glyph)
    # I wonder what the bottom line actually is
    x = glyph.x
    y = glyph.y + 1
    
    width  = CharData::CHAR_WIDTH
    height = CharData::CHAR_HEIGHT

    line_col = ColorList::WHITE
    y_offset = CharData::LINE_WIDTH

    # Draw a left line
    # Images are drawn in this order when calling draw_quad:
    # 1-----2
    # |     |
    # |     |
    # 3-----4
    draw_quad(x * width,         y * height - y_offset, line_col, # First corner
              x * width + width, y * height - y_offset, line_col, # Second corner
              x * width,         y * height,            line_col, # Third corner
              x * width + width, y * height,            line_col) # Fourth Corner
  end

  def push_char(x, y, char, color, *attributes)
    if @drawn_coords["#{ x }, #{ y }"] != nil
      # To avoid rewriting the same glyph when the screen hangs we will check for equality
      curr_glyph = @glyphs[@drawn_coords["#{ x }, #{ y }"]]
      
      if is_equal? Glyph.new(Point.new(x, y), char, color, *attributes), curr_glyph
        # Do nothing
      else
        @glyphs[@drawn_coords["#{ x }, #{ y }"]] = Glyph.new(Point.new(x, y), char, color, *attributes)
      end
    else
      @drawn_coords["#{ x }, #{ y }"] = @glyphs.length
      @glyphs << Glyph.new(Point.new(x, y), char, color, *attributes)
    end

    arr = *attributes
    if arr.include? :flashing
      @flashing_colors["#{ color.foreground }, #{ color.background }"] = color
      inverse = color.get_inverse
      @flashing_colors["#{ inverse.foreground }, #{ inverse.background }"] = inverse
    end
  end

  # Updates all of the current glyphs within the terminal
  # Note that this only occurs roughly every second
  # 
  # => If the flashing flag is enabled the glyphs' colors will be inverted to give it a flashing effect
  # => If there are any sub windows under this terminal, their update methods are called
  def update_terminal
    @time_for_updates += update_interval
    if time_for_updates > update_interval * CharData::UPDATE_TIME
      # @glyphs.each do |glyph|
      #   x = glyph.x
      #   y = glyph.y
      # 
      #   # Flashing
      #   # glyph.color.swap! if glyph.flashing?
      # end

      @flashing_colors.each { |key, col| col.swap! }
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
    x = glyph.x
    y = glyph.y
    width = CharData::CHAR_WIDTH
    height = CharData::CHAR_HEIGHT
    back_col = glyph.color.background
    fore_col = glyph.color.foreground

    if glyph.dim?
      back_col -= CharData::DIM_CONSTANT 
      fore_col -= CharData::DIM_CONSTANT
    end
    
    # Background
    # Images are drawn in this order when calling draw_quad:
    # 1-----2
    # |     |
    # |     |
    # 3-----4
    draw_quad(x * width,         y * height,          back_col, # First corner
              x * width + width, y * height,          back_col, # Second corner
              x * width,         y * height + height, back_col, # Third corner
              x * width + width, y * height + height, back_col) # Fourth Corner

    # Foreground
    width_padding = (CharData::CHAR_WIDTH - @font.text_width(glyph.char)) / 2.0
    @font.draw(glyph.char, x * width + width_padding, y * height, ZOrder::BACKGROUND, 1.0, 1.0, fore_col)
  end
end