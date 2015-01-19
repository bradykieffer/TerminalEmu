# Draws a sub terminal within another window
# Note that this does not extend Gosu::Window or Terminal because 
# Gosu only supports one window at any time
# Attempting to have both a sub window and a window causes segmentation 
# faults. So we will just use the parent window to draw in a sub window

class SubTerminal
  attr_reader :parent, :font

  def initialize(parent, x0, y0, x1, y1)
    raise ArgumentError, "Please pass in a Terminal object as the parent to this sub window" unless parent.is_a? Terminal
    raise ArgumentError, "Invalid subwindow coordinates, (x0, y0, x1, y1) = (#{ x0 }, #{ y0 }, #{ x1 }, #{ y1 })" unless parent.in_bounds?(x0, y0) &&                                                                                                                   parent.in_bounds?(x1, y1)
    @parent = parent
    @font = parent.font

    @x0 = x0 * CharData::CHAR_WIDTH
    @y0 = y0 * CharData::CHAR_HEIGHT
    @x1 = x1 * CharData::CHAR_WIDTH
    @y1 = y1 * CharData::CHAR_HEIGHT
    
    @glyphs = Array.new

    parent.sub_wins << self
  end

  def x
    (@x1 - @x0) / CharData::CHAR_WIDTH
  end

  def y
    (@y1 - @y0) / CharData::CHAR_HEIGHT
  end

  

  def in_bounds?(x, y)
    x <= (@x1 / CharData::CHAR_WIDTH)  && 
    x >= (@x0 / CharData::CHAR_WIDTH)  && 
    y <= (@y1 / CharData::CHAR_HEIGHT) && 
    y >= (@y0 / CharData::CHAR_HEIGHT) ?  true : false
  end

  def draw
    parent.draw_glyphs(@glyphs)
  end 

  def update
    @glyphs.each{ |glyph| glyph.swap_colors if glyph.flashing? == true }
  end

  def put_char(x, y, char, color = Color.new, *attributes)
    x += (@x0 / CharData::CHAR_WIDTH)
    y += (@y0 / CharData::CHAR_HEIGHT)
    if in_bounds? x, y
      parent.put_char(x, y, char, color, *attributes)
    else
      raise ArgumentError, "Called from a SubTerminal!\n" + 
                           "Invalid x and/or y given to put_char. (x,y) = (#{ x },#{ y })\n" + 
                           "Bounds are (x0, y0, x1, y1) = (#{ x0 }, #{ y0 }, #{ x1 }, #{ y1 })"
    end 
  end

  def put_string(x, y, string, color = Color.new, *attributes)
    x += (@x0 / CharData::CHAR_WIDTH)
    y += (@y0 / CharData::CHAR_HEIGHT) 
    if in_bounds?(x, y) && in_bounds?(x + string.length, y)
      parent.put_string(x, y, string, color, *attributes)
    else
      raise ArgumentError, "Called from a SubTerminal!\n" +
                           "Invalid x and/or y given to put_string. (x,y) = (#{ x },#{ y })\n" + 
                           "Bounds are (x0, y0, x1, y1) = (#{ x0 }, #{ y0 }, #{ x1 }, #{ y1 })"
    end
  end

  private
  def x0
    @x0 / CharData::CHAR_WIDTH
  end

  def x1
    @x1 / CharData::CHAR_WIDTH
  end

  def y0 
    @y0 / CharData::CHAR_HEIGHT
  end

  def y1 
    @y1 / CharData::CHAR_HEIGHT
  end
end