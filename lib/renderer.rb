#
# Handles the glyph drawing within the terminal
#
#
#

require 'gosu'

module FontInfo
  FONT_NORMAL = "./resources/consola.ttf"
  FONT_BOLD = ""
  FONT_ITALIC = ""
  FONT_ITAL_BOLD = ""
  FONT_SIZE = 18

  CHAR_WIDTH = 16
  CHAR_HEIGHT = 18
  UPDATE_TIME = 20

  LINE_WIDTH = 1.0

  DIM_CONSTANT = 0x70000000
end

# => draw glyphs
# => distinguish between the font types 
# => for the type of font, set up the character size etc (not hardcoded)
# => Anything that is drawn has to be through the renderer
# => I think it should accept a list of updated glyphs to draw on every draw call 
class Renderer
  def initialize(window)
    @window = window
    @glyphs_to_draw = Array.new
  end

  def set_glyphs_to_draw(glyphs)
    @glyphs_to_draw << glyphs
  end

  def render_window

    @glyphs_to_draw = @glyphs_to_draw.clear
  end

  def render_sub_win(glyphs)
    
  end
end

rend = Renderer.new(0)
rend.render_glyphs