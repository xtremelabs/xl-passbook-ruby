class Create<%= class_name.pluralize %> < ActiveRecord::Migration
  def change
    create_table :<%= plural_name %> do |t|
      t.string :serial_number
      t.string :authentication_token
      t.string :card_id

      t.timestamps
    end
  end
end
