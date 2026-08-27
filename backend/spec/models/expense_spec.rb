require 'rails_helper'

RSpec.describe Expense, type: :model do
  let(:category) { Category.create!(name: "Food") }

  def expense_with_date(date)
    described_class.new(
      description: "Lunch",
      amount: 100,
      category: category,
      date: date
    )
  end

  describe "date validation" do
    it "allows yesterday" do
      expect(expense_with_date(Date.current.yesterday)).to be_valid
    end

    it "allows today" do
      expect(expense_with_date(Date.current)).to be_valid
    end

    it "rejects tomorrow" do
      expense = expense_with_date(Date.current.tomorrow)

      expect(expense).not_to be_valid
      expect(expense.errors.full_messages).to include("Date cannot be in the future")
    end
  end
end
