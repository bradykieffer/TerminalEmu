
#!/usr/bin/ruby -w

require './lib/terminal_emu.rb'

def test_sub_win(parent)
  col_yellow = Color.new(ColorList::YELLOW)

  sub_win = SubTerminal.new(parent, parent.x / 2, parent.y / 2, parent.x / 2 + 20, parent.y / 2 + 10)
  sub_win.put_char(0, 0, '#', col_yellow, :flashing, :dim)
  sub_win.put_string(0, 1, "I'm a sub terminal!", Color.new, :right_line, :left_line, :top_line, :bottom_line)
  # Uncomment the following line to raise an exception
  # sub_win.put_string(0, 1, "Hello!asdadasdasdasdsadasdasd", Color.new, :right_line, :left_line, :top_line, :bottom_line)
end

def test_window(window)
  col_yellow = Color.new(ColorList::YELLOW)

  # Testing traits
  window.put_string(0, 0, "Flash",  Color.new, :flashing)
  window.put_string(0, 2, "Left",   Color.new, :left_line)
  window.put_string(0, 3, "Right",  Color.new, :right_line)
  window.put_string(0, 6, "Top",    Color.new, :top_line)
  window.put_string(0, 7, "Bottom", Color.new, :bottom_line)

  window.put_string(0, 8, "Now let's test the lines together", col_yellow, :left_line, :right_line, :top_line, :bottom_line)  

  window.put_string(0, window.y - 1, "I don't even know why I'm doing this....", Color.new(ColorList::CYAN, ColorList::BLACK), :left_line, :right_line, :top_line, :bottom_line, :dim, :flashing)

  window.put_string(6, 0, "Bold", Color.new, :bold)
  window.put_string(6, 2, "Italic", Color.new, :italic)
  window.put_string(6, 4, "Bold-Italic", Color.new, :bold_italic)
end

def dim_white_example
  window.put_string(0, 12, "Testing dim colours", Color.new(0xefffffff))
  window.put_string(0, 13, "Testing dim colours", Color.new(0xefffffff))
  window.put_string(0, 14, "Testing dim colours", Color.new(0xdfffffff))
  window.put_string(0, 15, "Testing dim colours", Color.new(0xcfffffff))
  window.put_string(0, 16, "Testing dim colours", Color.new(0xbfffffff))
  window.put_string(0, 17, "Testing dim colours", Color.new(0xafffffff))
  window.put_string(0, 18, "Testing dim colours", Color.new(0x9fffffff))
  window.put_string(0, 19, "Testing dim colours", Color.new(0x8fffffff))
  window.put_string(0, 20, "Testing dim colours", Color.new(0x7fffffff))
  window.put_string(0, 21, "Testing dim colours", Color.new(0x6fffffff))
  window.put_string(0, 22, "Testing dim colours", Color.new(0x5fffffff))
  window.put_string(0, 23, "Testing dim colours", Color.new(0x4fffffff))
  window.put_string(0, 24, "Testing dim colours", Color.new(0x3fffffff))
end

def test_colors(window)
  window.put_string(0, 10, "Green", Color.new(ColorList::GREEN))
  window.put_string(0, 11, "Dim green", Color.new(ColorList::GREEN), :dim)

  window.put_string(0, 13, "Yellow", Color.new(ColorList::YELLOW))
  window.put_string(0, 14, "Dim yellow", Color.new(ColorList::YELLOW), :dim)

  window.put_string(0, 16, "Orange", Color.new(ColorList::ORANGE))
  window.put_string(0, 17, "Dim orange", Color.new(ColorList::ORANGE), :dim)

  window.put_string(0, 19, "Brown", Color.new(ColorList::BROWN))
  window.put_string(0, 20, "Dim brown", Color.new(ColorList::BROWN), :dim)

  window.put_string(0, 22, "Bright green", Color.new(ColorList::BRIGHT_GREEN))
  window.put_string(0, 23, "Dim bright green", Color.new(ColorList::BRIGHT_GREEN), :dim)

  window.put_string(0, 25, "Blue", Color.new(ColorList::BLUE))
  window.put_string(0, 26, "Dim blue", Color.new(ColorList::BLUE), :dim)

  window.put_string(0, 28, "Cyan", Color.new(ColorList::CYAN))
  window.put_string(0, 29, "Dim cyan", Color.new(ColorList::CYAN), :dim)

  window.put_string(0, 31, "Red", Color.new(ColorList::RED))
  window.put_string(0, 32, "Dim red", Color.new(ColorList::RED), :dim)

  window.put_string(0, 34, "Gray", Color.new(ColorList::GRAY))
  window.put_string(0, 35, "Dim gray", Color.new(ColorList::GRAY), :dim)

  window.put_string(0, 37, "White", Color.new(ColorList::WHITE))
  window.put_string(0, 38, "Dim white", Color.new(ColorList::WHITE), :dim)
  # RED    = 0xffff0000 
  # GRAY  = 0xffaaaaaa 
  # WHITE = 0xffffffff
end

def get_font_widths(window)
  font = Gosu::Font.new(window, CharData::FONT, CharData::FONT_SIZE)

  max_width = 0
  (1..126).each do |x|
    next if x == 10 # the new line character
    max_width = font.text_width(x.chr) if font.text_width(x.chr) > max_width
  end
  puts max_width
end

window = Terminal.new(80, 50, "Test")

test_window(window)
# dim_white_example(window)
test_colors(window)
test_sub_win(window)
window.put_string(6, 6, "ALL THE TRAITS", Color.new(ColorList::BLACK, ColorList::BRIGHT_GREEN), :flashing, :bold_italic, :dim, :top_line, :left_line, :bottom_line, :right_line)
# get_font_widths(window)
window.show