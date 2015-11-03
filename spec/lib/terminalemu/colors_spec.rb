require "spec_helper"
require "terminalemu"

describe Color do
  describe "responds to attribute " do
    subject do 
      Color.new(ColorList::BLUE, ColorList::CYAN)
    end



  end

  describe "#initialize" do
    context "given no parameters" do
      
      color = Color.new

      it "has a white foreground" do
        expect(color.foreground).to eq(ColorList::WHITE)
      end

      it "has a black background" do
        expect(color.background).to eq(ColorList::BLACK)
      end

      it "has an original foreground of white" do
        expect(color.foreground_orig).to eq(ColorList::WHITE)
      end

      it "has an original background of black" do
        expect(color.background_orig).to eq(ColorList::BLACK)
      end
    end
    
    context "given valid parameters" do
      color = Color.new(ColorList::BLUE, ColorList::CYAN)

      it "has a blue foreground" do
        expect(color.foreground).to eq(ColorList::BLUE)
      end

      it "has a cyan background" do
        expect(color.background).to eq(ColorList::CYAN)
      end

      it "has an original foreground of blue" do
        expect(color.foreground_orig).to eq(ColorList::BLUE)
      end

      it "has an original background of cyan" do
        expect(color.background_orig).to eq(ColorList::CYAN)
      end
    end

    context "given invalid parameters" do
      it "raises ArgumentError" do
        expect{ Color.new(-1, -1) }.to raise_error(ArgumentError)
        expect{ Color.new('a', 'b') }.to raise_error(ArgumentError)
        expect{ Color.new(nil, nil) }.to raise_error(ArgumentError)
        expect{ Color.new(0xffffffff + 1, 0xffffffff + 1) }.to raise_error(ArgumentError)
      end
    end

  end

  describe "#equals" do
    color = Color.new(ColorList::GREEN, ColorList::BRIGHT_GREEN)
    
    it "is equivalent to itself" do
      expect(color.equals(color)).to be true
    end

    it "does not equal an inverted color" do 
      inv_col = Color.new(ColorList::BRIGHT_GREEN, ColorList::GREEN).swap!
      expect(color.equals(inv_col)).to be false
    end

    it "does not equal the inverse of an inverted color" do
      inv_col = Color.new(ColorList::GREEN, ColorList::BRIGHT_GREEN).swap!
      expect(color.equals(inv_col)).to be false
    
    end
  end

  describe "#dim" do
    it "should dim the color by #{ CharData::DIM_CONSTANT }" do
      color = Color.new(ColorList::RED, ColorList::GREEN)
      expect(color.dim!.foreground).to eq(ColorList::RED   - CharData::DIM_CONSTANT)
      expect(color.dim!.background).to eq(ColorList::GREEN - CharData::DIM_CONSTANT)
    end

    it "should not make the color values less than zero " do
      color = Color.new(0, 0)
      expect(color.dim!.equals(Color.new(0, 0))).to be true
    end
  end
end