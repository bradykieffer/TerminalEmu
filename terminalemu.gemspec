Gem::Specification.new do |s|
  s.name        = 'terminalemu'
  s.version     = '0.0.0'
  s.date        = '2015-10-25'
  s.summary     = "Make a terminal!"
  s.description = "A simple terminal emulator"
  s.authors     = ["Brady Kieffer"]
  s.email       = 'bradykieffer@gmail.com'
  s.files       = ["lib/terminalemu.rb", 
    "lib/terminalemu/character_data.rb", 
    "lib/terminalemu/colors.rb", 
    "lib/terminalemu/glyphs.rb", 
    "lib/terminalemu/sub_terminal.rb",
    "resources/consola.ttf"]
  s.homepage    =
    'http://rubygems.org/gems/terminalemu'
  s.license       = 'MIT'
end