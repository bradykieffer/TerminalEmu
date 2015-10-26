# Stores various constants related to the actual characters

module CharData
  FONT = "./resources/consola.ttf" 

  FONT_SIZE = 18

  CHAR_WIDTH = 16
  CHAR_HEIGHT = 18
  UPDATE_TIME = 5 # How often the each glyph is updated, lower means more updates

  LINE_WIDTH = 1.0

  DIM_CONSTANT = 0x70000000

  SCALE_MIN = 0.5
  SCALE_MAX = 1.1
  SCALE_INCREMENT = 0.1

  FLASH_LAG = 200 # want to flash every 200 cycles 
  SCALE_LAG = 1
end