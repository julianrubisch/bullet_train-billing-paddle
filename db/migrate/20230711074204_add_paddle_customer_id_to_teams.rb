class AddPaddleCustomerIdToTeams < ActiveRecord::Migration[7.0]
  def change
    add_column :teams, :paddle_customer_id, :string
  end
end
