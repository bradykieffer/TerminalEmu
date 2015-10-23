# Demos the SubTerminal class

#!/usr/bin/ruby -w

require '../lib/terminal_emu.rb'

window = Terminal.new(160, 50, "SubTerminal Demo")
(0...window.x).each do |x|
  (0...window.y).each do |y|
    window.put_char(x, y, ' ', Gosu::Color::BLACK, Gosu::Color::YELLOW) unless y % 2 == 0
    window.put_char(x, y, ' ', Gosu::Color::YELLOW, Gosu::Color::BLACK) unless y % 2 == 1
  end
end
window.put_string(0, window.y - 1, "I'm a window!")


sub_win = SubTerminal.new(window, 0, 0, window.x / 4, window.y / 5)
(0...sub_win.x).each do |x|
  (0...sub_win.y).each do |y|
    sub_win.put_char(x, y, 'X', Gosu::Color::WHITE, Gosu::Color::BLACK)
  end
end
sub_win.put_string(0, sub_win.y - 1, "I'm a sub window!-----------------------")

sub_win2 = SubTerminal.new(window, 0, 0, sub_win.x / 4, sub_win.y / 5)

(0...sub_win2.x).each do |x|
  (0...sub_win2.y).each do |y|
    sub_win.put_char(x, y, 'X', Gosu::Color::BLACK, Gosu::Color::CYAN)
  end
end

sub_win2.put_string(0, sub_win2.y - 1, "blah blah-", Gosu::Color::BLACK, Gosu::Color::CYAN, true)

window.show