require "spec_helper"
require "terminalemu"

describe Terminal do
  terminal_height = 25
  terminal_width = 80

  describe "#initialize" do
    context "given a title" do
      it "is defaults to a blank title (zero width string)" do
        terminal = Terminal.new(terminal_width, terminal_height)
        expect(terminal.title).to  eq("")
      end

      it "is titled Test" do
        terminal = Terminal.new(terminal_width, terminal_height, "Test")
        expect(terminal.title).to  eq("Test")
      end

      it "attempts to convert a title to a string" do 
        expect(Terminal.new(terminal_width, terminal_height, 1).title).to eq(1.to_s)
        expect(Terminal.new(terminal_width, terminal_height, nil).title).to eq(nil.to_s)
      end
    end

    context "given invalid dimensions" do
      it "raises an ArgumentError if dimensions are negative" do
        expect{ Terminal.new(-1, -1, "") }.to raise_error(ArgumentError)
      end

      it "raises an ArgumentError is dimensions are zero" do
        expect{ Terminal.new(-1, -1, "") }.to raise_error(ArgumentError)
      end
    end

    context "given valid dimensions" do
      it "is width #{ terminal_width }" do
        terminal = Terminal.new(terminal_width, terminal_height, "")
        expect(terminal.width).to  eq(terminal_width)
      end

      it "is height #{ terminal_height }" do
        terminal = Terminal.new(terminal_width, terminal_height, "")
        expect(terminal.height).to  eq(terminal_height)
      end

      it "is #{ terminal_width } * #{ CharData::CHAR_WIDTH } = #{ terminal_width * CharData::CHAR_WIDTH } pixels wide" do
        terminal = Terminal.new(terminal_width, terminal_height, "")
        expect(terminal.width * CharData::CHAR_WIDTH).to eq(terminal_width * CharData::CHAR_WIDTH)
      end

      it "is #{ terminal_height } * #{ CharData::CHAR_HEIGHT } = #{ terminal_height * CharData::CHAR_HEIGHT } pixels tall" do
        terminal = Terminal.new(terminal_width, terminal_height, "")
        expect(terminal.height * CharData::CHAR_HEIGHT).to eq(terminal_height * CharData::CHAR_HEIGHT)
      end
      
      it "has no sub-terminals" do
        terminal = Terminal.new(terminal_width, terminal_height, "")
        expect(terminal.sub_wins.length).to eq(0)
      end
    end
  end

  describe "#get_glyph_at" do
    let(:terminal) { Terminal.new(terminal_width, terminal_height) }
    let(:x_pos) { rand(terminal_width - 1).to_i }
    let(:y_pos) { rand(terminal_height - 1).to_i }
    let(:glyph) { Glyph.new(x_pos, y_pos, '!') }

    it "returns a glyph given a valid (x,y)" do
      terminal.put_glyph(glyph)
      expect(terminal.get_glyph_at(x_pos, y_pos)).to eq(glyph)
    end

    it "raises an ArgumentError given an invalid (x,y)" do
      expect{ terminal.get_glyph_at(-1, -1) }.to raise_error(ArgumentError)
    end

    it "returns nil if no glyph is present at the given (x, y)" do
      expect(terminal.get_glyph_at(x_pos, y_pos)).to be nil
    end
  end

  describe "#put_char" do
    
    let(:terminal){ Terminal.new(terminal_width, terminal_height) }
    let(:x_pos) { rand(terminal_width - 1).to_i }
    let(:y_pos) { rand(terminal_height - 1).to_i }
    let(:glyph) { Glyph.new(x_pos, y_pos, '!') }

    it "puts a character at a valid (x,y)" do
      terminal.put_char(glyph.x, glyph.y, glyph.char, glyph.color, glyph.attributes)
      tst = terminal.get_glyph_at(x_pos, y_pos)

      expect(tst.x).to eq(glyph.x)
      expect(tst.y).to eq(glyph.y)
      expect(tst.char).to eq(glyph.char)
      expect(tst.color.equals(glyph.color)).to be true 

    end 

    it "raises an ArgumentError if invalid (x,y) are passed" do
      [[-1, -1], ["a", "b"], [nil, nil], [1, -1], [-1, 1], ["a", 1], [1, "b"], [nil, 1], [1, nil], [terminal.width + 1, terminal.height + 1]].each do |coord|
        expect{ terminal.put_char(coord[0], coord[1], glyph.char) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#put_string" do
    let(:str){ "This is a test string" }
    let(:terminal) { Terminal.new(terminal_width, terminal_height) }
    let(:y_pos) { rand(terminal_height - 1).to_i }
    let(:x_pos) { rand(terminal_width - 1 - str.length).to_i }
    
    it "puts a string on screen given valid (x, y)" do
      terminal.put_string(x_pos, y_pos, str)

      expect(terminal.get_glyph_at(x_pos, y_pos).char).to eq(str[0])
      expect(terminal.get_glyph_at(x_pos + str.length - 1, y_pos).char).to eq(str[str.length-1])
    end

    it "raises an ArgumentError error given an invalid (x, y)" do
      [[-1, -1], ["a", "b"], [nil, nil], [1, -1], [-1, 1], ["a", 1], [1, "b"], [nil, 1], [1, nil], [terminal.width + 1, terminal.height + 1]].each do |coord|
        expect{ terminal.put_string(coord[0], coord[1], str) }.to raise_error(ArgumentError)
      end
    end
  end
end
