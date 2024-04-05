class AddCommentToRegularizations < ActiveRecord::Migration[7.1]
  def change
    add_column :regularizations, :comment, :string
  end
end
