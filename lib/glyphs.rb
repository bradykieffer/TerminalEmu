# A class that defines how a glyph within the terminal works
# These store the following:
# => A character
# => (x, y) coords
# => Background color
# => Foreground color
# => Whether the glyph is flashing or not 

#!/usr/bin/ruby -w

require 'gosu'
require './lib/character_data.rb'
require './lib/colors.rb'


class Point < Struct.new(:x, :y)
end

class Glyph
  attr_reader :attributes, :char, :color, :angle, :scale
  def initialize(x, y, char, color = Color.new, *attributes)
    @x = x
    @y = y
    @char = char

    @color = Color.new(color.foreground, color.background)
    
    @attributes = attributes
    @updated_last = Hash.new

    @angle = 0
    @scale = 1.0
    @growing = true

    # Set these all to false initially
    @left_line =  @right_line = @top_line = @bottom_line = false

    @col_fore_orig = @color.foreground
    @col_back_orig= @color.background

    # Now set the lines for the glyph, this is sorta a hack
    manip_attributes

  end

  def bottom_line?
    @bottom_line
  end

  def bold?
    @bold
  end

  def italic?
    @italic
  end

  def center_x
    pix_x_pos + (CharData::CHAR_WIDTH / 2.0)
  end

  def center_y
    pix_y_pos + (CharData::CHAR_HEIGHT / 2.0)
  end

  def colors
    return @color.foreground, @color.background
  end

  def dim
    @color.dim!
  end

  def flashing(last_update)
    @updated_last[:flashing].nil? ? @updated_last[:flashing] = 0 : @updated_last[:flashing] += last_update
    if @updated_last[:flashing] >= CharData::FLASH_LAG
      @color.swap! 
      @updated_last[:flashing] = 0
    end
  end

  def font
    if self.bold? && self.italic?
      return :bold_italic
    elsif self.bold? 
      return :bold
    elsif self.italic?
      return :italic
    else
      return :default
    end
  end

  def rotating
    if @angle != 360
      @angle += 5 
    else
      @angle = 5
    end
  end

  def left_line?
    @left_line
  end

  def on_update(last_update = 0)
    @attributes.each do |attribute|
      if self.respond_to?(attribute)
        self.method(attribute).arity > 0 ? self.send(attribute, last_update) : self.send(attribute)
      else
        puts "Warning, invalid attribute passed to glyph: #{ attribute }"
      end 
    end
  end

  def pulse(last_update)
    @updated_last[:pulse].nil? ? @updated_last[:pulse] = 0 : @updated_last[:pulse] += last_update
    if @updated_last[:pulse] >= CharData::SCALE_LAG
      @growing = !@growing if @scale > CharData::SCALE_MAX || @scale < CharData::SCALE_MIN
      @growing == true ? @scale += CharData::SCALE_INCREMENT : @scale -= CharData::SCALE_INCREMENT 
      @updated_last[:pulse] = 0
    end
  end

  def left_line
    @left_line = true
  end

  def right_line
    @right_line = true
  end

  def top_line
    @top_line = true
  end

  def bottom_line
    @bottom_line = true
  end

  def pix_x_pos
    @x * CharData::CHAR_WIDTH
  end

  def pix_y_pos
    @y * CharData::CHAR_HEIGHT
  end

  def right_line?
    @right_line
  end

  def top_line?
    @top_line
  end

  def width_padding(font)
    (CharData::CHAR_WIDTH - font.text_width(@char)) / 2.0
  end

  def x
    @x
  end

  def y 
    @y
  end

  private
  def manip_attributes
    @attributes.each do |attribute|
      # set_attr_hash(attribute)
      set_lines(attribute)
    end
  end
  def set_lines(attribute)
    case attribute
    when :left_line
      @left_line = true
    when :right_line
      @right_line = true
    when :top_line
      @top_line = true
    when :bottom_line
      @bottom_line = true
    end
  end

  def set_attr_hash(attribute)
    @updated_last[':#{ attribute }'] = 0
  end
end