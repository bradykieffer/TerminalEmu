# Generate some pretty caves 

#!/usr/bin/ruby -w

require '../lib/terminal_emu.rb'

def world_build(x, y, window)
  arr = (0...x).collect do |i|
          (0...y).collect do |j|
              rand(100) > 50 ? 1 : 0 
          end
        end

  arr = smooth(arr, 5)

  (0...x).each do |i|
    (0...y).each do |j|
      if i == 0 || j == 0 || i == x - 1 || j == y - 1
        arr[i][j] = 0
      end
    end
  end

  (0...x).each do |i|
    (0...y).each do |j|
      arr[i][j] == 1 ? window.put_char(i, j, ' ') : window.put_char(i, j, '#', Gosu::Color::BLACK, Gosu::Color::WHITE)
    end
  end
end

def smooth(arr, times)
  (0..times).each do
    for i in (1..arr.length - 2)
      for j in (1..arr[i].length - 2)
        num_floors = 0
        num_rocks = 0
        for io in (-1..1)
          for jo in (-1..1)
            arr[i + io][j + jo] == 1 ? num_floors += 1 : num_rocks += 1
          end
        end
        num_floors >= num_rocks ? arr[i][j] = 1 : arr[i][j] = 0
      end
    end
  end
  arr
end



window = Terminal.new(100, 40, "A PRETTY Cave")
sub_win = SubTerminal.new(window, 0, 0, 35, 0)
world_build(window.x, window.y, window)
sub_win.put_string(0, 0, "This is a demo cave")
window.show