# Move a character around the terminal 

#!/usr/bin/ruby -w

require './lib/terminal_emu.rb'

class Terminal < Gosu::Window
  attr_accessor :player 

  # Shameless monkeypatching
  def update
    update_glyph_traits
    listen_for_input
  end

  def listen_for_input
    @player.move(self,  0, -1) if button_down? Gosu::KbNumpad8
    @player.move(self,  1,  0) if button_down? Gosu::KbNumpad6
    @player.move(self,  0,  1) if button_down? Gosu::KbNumpad2
    @player.move(self, -1,  0) if button_down? Gosu::KbNumpad4
    @player.move(self,  1, -1) if button_down? Gosu::KbNumpad9
    @player.move(self,  1,  1) if button_down? Gosu::KbNumpad3
    @player.move(self, -1,  1) if button_down? Gosu::KbNumpad1
    @player.move(self, -1, -1) if button_down? Gosu::KbNumpad7
    sleep 1.0/8.0 # Because we don't wanna zip around too quickly ;)
  end
end

class Player
  attr_accessor :x, :y, :char

  def initialize(x, y)
    @char = '@'
    
    @x = x
    @y = y
  end

  def move(window, dx, dy)
    if window.in_bounds? @x + dx, @y + dy
      window.put_char(@x, @y, ' ')
      @x += dx
      @y += dy
      window.put_char(@x, @y, @char)
    end
  end
end

window = Terminal.new(80, 25, "Moving a Character Demo")
window.player = Player.new(window.x / 2, window.y / 2)
# window.put_char(player.x, player.y, player.char)
window.show
