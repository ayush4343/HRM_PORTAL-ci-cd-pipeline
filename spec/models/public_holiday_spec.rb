require 'rails_helper'

RSpec.describe PublicHoliday, type: :model do
  describe "associations" do
    it "has and belongs to many organizations with dependent destroy" do
      association = described_class.reflect_on_association(:organizations)
      expect(association.macro).to eq(:has_and_belongs_to_many)
      expect(association.options[:dependent]).to eq(:destroy)
      expect(association.options[:join_table]).to eq(:organizations_public_holidays)
    end
  end

  describe "validations" do
    it "validates presence of name" do
      public_holiday = PublicHoliday.new(name: nil)
      expect(public_holiday).not_to be_valid
      expect(public_holiday.errors[:name]).to include("can't be blank")
    end

    it "validates uniqueness of name" do
      existing_public_holiday = FactoryBot.create(:public_holiday, name: "Test Holiday")
      new_public_holiday = PublicHoliday.new(name: "Test Holiday")
      new_public_holiday.valid?
      expect(new_public_holiday.errors[:name]).to include("has already been taken")
    end
  end
  
end
