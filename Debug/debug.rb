# Debugging for the terminal

#!/usr/bin/ruby -w

require './lib/terminal_emu.rb'

class Terminal < Gosu::Window

  def draw
    draw_glyphs
    draw_boxes
    draw_sub_wins
    draw_debug
  end

  def draw_debug
    @glyphs.each do |glyph|
      draw_debug_lines glyph
      highlight_center glyph
    end
  end

  def draw_debug_lines(glyph)
    x = glyph.pix_x_pos
    y = glyph.pix_y_pos

    debug_line_col = ColorList::BLUE

    # Standard highlighting lines... 
    draw_line(x, y, debug_line_col, x + CharData::CHAR_WIDTH, y, debug_line_col)
    draw_line(x, y + CharData::CHAR_HEIGHT, debug_line_col, x + CharData::CHAR_WIDTH, y + CharData::CHAR_HEIGHT, debug_line_col)
    draw_line(x + CharData::CHAR_WIDTH, y, debug_line_col, x + CharData::CHAR_WIDTH, y + CharData::CHAR_HEIGHT, debug_line_col)
    draw_line(x, y, debug_line_col, x, y + CharData::CHAR_HEIGHT, debug_line_col)


    # Diagonals
    draw_line(x, y, debug_line_col, x + CharData::CHAR_WIDTH, y + CharData::CHAR_HEIGHT, debug_line_col)
    draw_line(x, y + CharData::CHAR_HEIGHT, debug_line_col, x + CharData::CHAR_WIDTH, y, debug_line_col)
  end

  def highlight_center(glyph)
    x = glyph.pix_x_pos + (CharData::CHAR_WIDTH  / 2.0)
    y = glyph.pix_y_pos + (CharData::CHAR_HEIGHT / 2.0)

    # Background
    # Images are drawn in this order when calling draw_quad:
    # 1-----2
    # |     |
    # |     |
    # 3-----4
    draw_quad(x - 1.0, y - 1.0, ColorList::RED, # First corner
              x + 1.0, y - 1.0, ColorList::RED, # Second corner
              x - 1.0, y + 1.0, ColorList::RED, # Third corner
              x + 1.0, y + 1.0, ColorList::RED) # Fourth Corner
  end
end

window = Terminal.new(80, 25, "Debug")

string = "Used for debugging"

blank_str = '                                   ' # Why not 

window.put_string((window.x - string.length)/2.0, window.y / 2.0, string, Color.new, :italic)
window.put_string((window.x - string.length)/2.0 + string.length, window.y / 2.0, ".....", Color.new)
# window.put_string(0, 0, blank_str)
window.outline_box(1, 1, 60, 20, ColorList::CYAN)


window.show
