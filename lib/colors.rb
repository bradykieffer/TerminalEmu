module ColorList
  YELLOW = 0xffffff00
  BROWN  = 0xffbb9900 

  GREEN        = 0xaa00ff00
  BRIGHT_GREEN = 0xff00ff00

  BLUE = 0xff00aaff
  CYAN = 0xff00ffff

  RED    = 0xffff0000
  ORANGE = 0xffff9900


  BLACK = 0xff000000 
  GRAY  = 0xffaaaaaa 
  WHITE = 0xffffffff
end

class Color
  attr_accessor :foreground, :background 
  def initialize(foreground = ColorList::WHITE, background = ColorList::BLACK)
    @foreground_orig = @foreground = foreground
    @background_orig = @background = background
    @switched = false
  end

  def equals(other_col)
    @foreground == other_col.foreground && @background == other_col.background ? true : false
  end

  def dim!
    @foreground = @switched == false ? (@foreground_orig - CharData::DIM_CONSTANT) : (@background_orig - CharData::DIM_CONSTANT)
    @background = @switched == false ? (@background_orig - CharData::DIM_CONSTANT) : (@foreground_orig - CharData::DIM_CONSTANT)
  end

  def swap!
    @foreground, @background, @switched = @background, @foreground, !@switched
    self
  end
end