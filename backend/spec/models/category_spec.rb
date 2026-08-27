require 'rails_helper'

RSpec.describe Category, type: :model do
  describe "validations" do
    it "requires a name" do
      category = described_class.new(name: "")

      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("can't be blank")
    end

    it "limits names to 100 characters" do
      category = described_class.new(name: "a" * 101)

      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("is too long (maximum is 100 characters)")
    end

    it "requires a unique name" do
      described_class.create!(name: "Food")
      category = described_class.new(name: "Food")

      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("has already been taken")
    end
  end
end
