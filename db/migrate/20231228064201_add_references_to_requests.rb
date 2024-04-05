class AddReferencesToRequests < ActiveRecord::Migration[7.1]
  def change
    add_reference :requests, :user, foreign_key: true
  end
end
