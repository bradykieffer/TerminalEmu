# A super simple but pretty sweet terminal 

#!/usr/bin/ruby -w
require 'rubygems'
require 'gosu'
require './lib/terminalemu/glyphs.rb'
require './lib/terminalemu/sub_terminal.rb'
require './lib/terminalemu/character_data.rb'
class Terminal < Gosu::Window

  attr_reader  :font, :input, :time_for_updates, :title, :width, :height, :glyphs
  attr_accessor :sub_wins
  
  def initialize(x, y, title = "", logic_class = nil, *methods_to_call)
    # The magic numbers for x & y make it look best on my machine, you may have to change this  
    
    # Validate and set the dimensions for the terminal first
    set_terminal_dimensions(x, y) 

    super @x, @y, false

    self.caption = @title = title.to_s
    
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
  def get_glyph_at(x, y)
    raise ArgumentError if !in_bounds? x, y
    @drawn_coords["#{ x }, #{ y }"].nil? ? nil : @glyphs[@drawn_coords["#{ x }, #{ y }"]]
  end

  def in_bounds?(x, y)
    x.nil? || y.nil? || (x < self.x && x >= 0 && y < self.y && y >= 0) ? true : false
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
        push_char(Glyph.new(x, y, char, color, *attributes))
    else
      raise ArgumentError, "Invalid x and/or y given to put_char. (x,y) = (#{ x },#{ y })"
    end 
  end

  def put_glyph(glyph)
    if in_bounds?(glyph.x, glyph.y) && glyph.nil? == false
      push_char(glyph)
    else
      raise ArgumentError, "Invalid glyph given to put_glyph. Glyph = #{ glyph }"
    end
  end
  
  # Draws a string to the Terminal
  #
  def put_string(x, y, string, color = Color.new, *attributes)
    if x.nil? == false && in_bounds?(x, y) && in_bounds?(x + string.length, y)
      (0...string.length).each { |i| push_char(Glyph.new(x + i, y, string[i], color, *attributes)) }
    else
      raise ArgumentError, "Invalid x and/or y given to put_string. (x,y) = (#{ x },#{ y })"
    end
  end

  def put_circle(x, y, r = 1, color = Color.new, *attributes)

    if in_bounds?(x, y) && in_bounds?(x + r, y) && in_bounds?(x - r, y) && in_bounds?(x, y + r) && in_bounds?(x, y - r) 
      (x-r..x+r).each do |xo|
        (y-r..y+r).each do |yo|
          push_char(Glyph.new(xo, yo, ' ', color, *attributes)) unless (xo - x)**2 + (yo - y)**2 > r**2
        end
      end
    else
      raise ArgumentError, "Invalid x and/or y given to put_string. (x,y) = (#{ x },#{ y })"
    end
  end

  # Sets a class that will call logic before an update
  #
  def set_logic_class(logic_class, *methods_to_call)
    @logic_class = logic_class
    @methods_to_call = methods_to_call
  end

  # The loop that will be run when Terminal.show is called
  #
  def update
    if @logic_class.nil? == false
      @methods_to_call.each do |method|
        next if method.nil? 
        if @logic_class.respond_to?(method)
          @logic_class.send(method)
        else 
          puts "Warning Invalid method called on #{ @logic_class.class }, method: #{ method }"
        end
      end
    end
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
    x = glyph.pix_x_pos
    y = glyph.pix_y_pos
    
    if glyph.left_line?
      draw_line(x + 1, y + 1,                         ColorList::WHITE,
                x + 1, y + CharData::CHAR_HEIGHT - 1, ColorList::WHITE)
    end

    if glyph.right_line?
      draw_line(x + CharData::CHAR_WIDTH - 1, y + 1,                         ColorList::WHITE, 
                x + CharData::CHAR_WIDTH - 1, y + CharData::CHAR_HEIGHT - 1, ColorList::WHITE)
    end

    if glyph.top_line?
      draw_line(x + 1,                        y + 1, ColorList::WHITE, 
                x + CharData::CHAR_WIDTH - 1, y + 1, ColorList::WHITE)
    end

    # But seriously wtf is the bottom line here??!?!??!!?
    if glyph.bottom_line?
      draw_line(x + 1,                        y + CharData::CHAR_HEIGHT - 1, ColorList::WHITE,
                x + CharData::CHAR_WIDTH - 1, y + CharData::CHAR_HEIGHT - 1, ColorList::WHITE)
      # I think I found it.... Somewhere in here....
    end
  end

  def draw_character(x, y, color, glyph)
    scale(glyph.scale, glyph.scale, glyph.center_x, glyph.center_y){
      rotate(glyph.angle, glyph.center_x, glyph.center_y){ @font.draw(glyph.char, x, y, 0, 1.0, 1.0, color) }
    }
  end
 
  def push_char(glyph)
    if @drawn_coords["#{ glyph.x }, #{ glyph.y }"] != nil
      @glyphs[@drawn_coords["#{ glyph.x }, #{ glyph.y }"]] = glyph
    else
      @drawn_coords["#{ glyph.x }, #{ glyph.y }"] = @glyphs.length
      @glyphs << glyph
    end
  end

  def set_terminal_dimensions(x, y)
    # If dimensions that are 0 or negative are passed raise an argument error
    if x <= 0 || y <= 0
      raise ArgumentError, "Invalid (x,y) when creating new Terminal instance (x,y) = (#{ x },#{ y })" 
    else

    end

    @x = x * CharData::CHAR_WIDTH
    @y = y * CharData::CHAR_HEIGHT 

    @width = x
    @height = y 
  end

  # Updates all of the current glyphs within the terminal
  # Note that this only occurs roughly every second
  # 
  # => Calls the on update method for each glyph, this will update it based on its' attributes
  #
  def update_terminal
    @time_for_updates += update_interval
    if time_for_updates > update_interval * CharData::UPDATE_TIME
      @glyphs.each do |glyph|
        next if glyph.nil?

        glyph.on_update(@time_for_updates)
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
    
    fore_col, back_col = glyph.colors
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