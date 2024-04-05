class CreateJoinTableOrganizationPublicHoliday < ActiveRecord::Migration[7.1]
  def change
    create_join_table :organizations, :public_holidays do |t|
      # t.index [:organization_id, :public_holiday_id]
      # t.index [:public_holiday_id, :organization_id]
    end
  end
end
