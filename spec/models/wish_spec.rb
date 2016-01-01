require 'spec_helper'

describe Wish do
  let(:wish) { FactoryGirl.build :wish }
  subject { wish }

  it { should respond_to(:name) }
  it { should respond_to(:price) }
  it { should respond_to(:image_url) }
  it { should respond_to(:page_url) }
  it { should respond_to(:user_id) }

  it { should belong_to :user }

  describe ".above_or_equal_to_price" do
    before(:each) do
      @wish1 = FactoryGirl.create :wish, price: 100
      @wish2 = FactoryGirl.create :wish, price: 50
      @wish3 = FactoryGirl.create :wish, price: 150
      @wish4 = FactoryGirl.create :wish, price: 99
    end

    it "returns the wishes which are above or equal to the price" do
      expect(Wish.above_or_equal_to_price(100).sort).to match_array([@wish1, @wish3])
    end
  end

  describe ".below_or_equal_to_price" do
    before(:each) do
      @wish1 = FactoryGirl.create :wish, price: 100
      @wish2 = FactoryGirl.create :wish, price: 50
      @wish3 = FactoryGirl.create :wish, price: 150
      @wish4 = FactoryGirl.create :wish, price: 99
    end

    it "returns the wishes which are above or equal to the price" do
      expect(Wish.below_or_equal_to_price(99).sort).to match_array([@wish2, @wish4])
    end
  end

  describe ".recent" do
    before(:each) do
      @wish1 = FactoryGirl.create :wish, price: 100
      @wish2 = FactoryGirl.create :wish, price: 50
      @wish3 = FactoryGirl.create :wish, price: 150
      @wish4 = FactoryGirl.create :wish, price: 99

      @wish2.touch
      @wish3.touch
    end

    it "returns the most updated records" do
      expect(Wish.recent).to match_array([@wish3, @wish2, @wish4, @wish1])
    end
  end

  describe ".search" do
    before(:each) do
      @wish1 = FactoryGirl.create :wish, price: 100, name: "Plasma tv"
      @wish2 = FactoryGirl.create :wish, price: 50, name: "Videogame console"
      @wish3 = FactoryGirl.create :wish, price: 150, name: "MP3"
      @wish4 = FactoryGirl.create :wish, price: 99, name: "Laptop"
    end

    context "when name 'videogame' and '100' a min price are set" do
      it "returns an empty array" do
        search_hash = { keyword: "videogame", min_price: 100 }
        expect(Wish.search(search_hash)).to be_empty
      end
    end

    context "when name 'tv', '150' as max price, and '50' as min price are set" do
      it "returns the wish1" do
        search_hash = { keyword: "tv", min_price: 50, max_price: 150 }
        expect(Wish.search(search_hash)).to match_array([@wish1]) 
      end
    end

    context "when an empty hash is sent" do
      it "returns all the wishes" do
        expect(Wish.search({})).to match_array([@wish1, @wish2, @wish3, @wish4])
      end
    end

    context "when wish_ids is present" do
      it "returns the wish from the ids" do
        search_hash = { wish_ids: [@wish1.id, @wish2.id]}
        expect(Wish.search(search_hash)).to match_array([@wish1, @wish2])
      end
    end
  end
end
