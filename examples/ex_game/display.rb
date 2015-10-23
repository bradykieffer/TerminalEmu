# Displays our world and actors

#!/usr/bin/ruby -w

require './examples/ex_game/tiles.rb'

module Display
  def display_world(window, left, top)
    width = window.x
    height = window.y
    world = window.game_engine.world.world_map

    (0...width).each do |i|
      (0...height).each do |j|
        wi = i + left      
        wj = j + top

        if world[wi][wj].char == "#" && rand(100) < 50
          window.put_char(i, j, world[wi][wj].char, world[wi][wj].color, *world[wi][wj].attributes, :flashing)
        else
          window.put_char(i, j, world[wi][wj].char, world[wi][wj].color, *world[wi][wj].attributes)
        end
      end
    end
    
    # Just a demo message
    window.put_string(0,0, "Demo of Caves - Enjoy", Color.new(ColorList::BLACK, ColorList::ORANGE), :bottom_line, :dim)
    window.put_char("Demo of Caves - Enjoy".length, 0, '!', Color.new(ColorList::BLACK, ColorList::ORANGE), :right_line, :bottom_line, :dim)
  end
end