require "spec_helper"
require "terminalemu"

describe Glyph do
  describe "#initialize" do

    context "given invalid paraments" do
      it "fails without arguments" do
        expect{ Glyph.new() }.to raise_error(ArgumentError)
      end

      it "fails with x/y <= 0" do
        expect{ Glyph.new(-1, -1, '') }.to raise_error(ArgumentError)
      end
    end

    context "given valid parameters" do
      x_pos = rand(100).to_i
      y_pos = rand(100).to_i
      color = Color.new(ColorList::BLUE, ColorList::CYAN)

      glyph = Glyph.new(x_pos, y_pos, '', color)
      
      it "sets coordinates correctly" do
        expect(glyph.x).to eq(x_pos)
        expect(glyph.y).to eq(y_pos)
      end

      it "has pixel width #{ x_pos } * #{ CharData::CHAR_WIDTH } = #{ x_pos * CharData::CHAR_WIDTH }" do
        expect(glyph.pix_x_pos).to eq(x_pos * CharData::CHAR_WIDTH)
      end

      it "has pixel height #{ y_pos } * #{ CharData::CHAR_HEIGHT } = #{ y_pos * CharData::CHAR_HEIGHT }" do
        expect(glyph.pix_y_pos).to eq(y_pos * CharData::CHAR_HEIGHT)
      end

      it "has a color equivalent to #{ color }" do
        expect(glyph.color.equals(color)).to be true
      end

      it "returns a valid center pixel position for (x,y)" do
        expect(glyph.center_x).to eq((x_pos * CharData::CHAR_WIDTH ) + (CharData::CHAR_WIDTH  / 2.0))
        expect(glyph.center_y).to eq((y_pos * CharData::CHAR_HEIGHT) + (CharData::CHAR_HEIGHT / 2.0))
      end
    end
  end

  describe "attributes" do
    subject do  
      Glyph.new(1, 1, '')
    end

    [:x, :y, :char, :attributes, :color, :width, :height, :angle, :scale, :rotating, :flashing, :bottom_line, :top_line, :left_line, :right_line,:pulse].each do |attribute|
      it{ is_expected.to respond_to(attribute)}
    end
  end

end
