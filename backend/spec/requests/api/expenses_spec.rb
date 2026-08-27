require 'rails_helper'

RSpec.describe "Api::Expenses", type: :request do
  let!(:food_category) { Category.create!(name: "Food") }
  let!(:transport_category) { Category.create!(name: "Transport") }

  describe "GET /api/expenses" do
    let!(:january_expense) do
      Expense.create!(
        description: "Lunch",
        amount: 100.00,
        category: food_category,
        date: Date.new(2026, 1, 20),
        created_at: Time.zone.local(2026, 8, 1)
      )
    end
    let!(:earlier_january_expense) do
      Expense.create!(
        description: "Taxi",
        amount: 50.00,
        category: transport_category,
        date: Date.new(2026, 1, 10),
        created_at: Time.zone.local(2026, 8, 2)
      )
    end

    it "returns all expenses with category information" do
      get "/api/expenses"

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
    end

    it "returns expenses in descending order by date when creation order conflicts" do
      get "/api/expenses"

      json = JSON.parse(response.body)
      expect(json.pluck("id")).to eq([ january_expense.id, earlier_january_expense.id ])
    end

    it "orders expenses with the same date by newest creation first" do
      newer_expense = Expense.create!(
        description: "Coffee",
        amount: 25.00,
        category: food_category,
        date: january_expense.date,
        created_at: Time.zone.local(2026, 8, 1, 11)
      )

      get "/api/expenses"

      json = JSON.parse(response.body)
      expect(json.pluck("id")).to eq([ newer_expense.id, january_expense.id, earlier_january_expense.id ])
    end

    context "with year and month parameters" do
      let!(:august_expense) do
        Expense.create!(
          description: "Hotel",
          amount: 200.00,
          category: transport_category,
          date: Date.new(2026, 8, 15),
          created_at: Time.zone.local(2026, 1, 5)
        )
      end

      it "filters expenses by their expense date" do
        get "/api/expenses", params: { year: 2026, month: 8 }

        json = JSON.parse(response.body)
        expect(json.pluck("id")).to eq([ august_expense.id ])
      end

      it "includes a January expense created in August in January results" do
        get "/api/expenses", params: { year: 2026, month: 1 }

        json = JSON.parse(response.body)
        expect(json.pluck("id")).to include(january_expense.id)
        expect(json.pluck("id")).not_to include(august_expense.id)
      end
    end
  end

  describe "POST /api/expenses" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          expense: {
            description: "Team Lunch",
            amount: 150.50,
            category_id: food_category.id,
            date: Date.today
          }
        }
      end

      it "creates a new expense" do
        expect {
          post "/api/expenses", params: valid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["description"]).to eq("Team Lunch")
        expect(json["amount"]).to eq(150.5)
      end
    end

    context "with invalid parameters" do
      it "with negative amounts" do
        invalid_params = {
          expense: {
            description: "Invalid expense",
            amount: -100.00,
            category_id: food_category.id,
            date: Date.today
          }
        }

        expect {
          post "/api/expenses", params: invalid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it "with empty descriptions" do
        invalid_params = {
          expense: {
            description: "",
            amount: 100.00,
            category_id: food_category.id,
            date: Date.today
          }
        }

        expect {
          post "/api/expenses", params: invalid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end
  end
end
