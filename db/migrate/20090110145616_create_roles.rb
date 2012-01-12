class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string  :name
      t.string  :description
      t.integer :lock_version
      t.integer :order_no
      t.timestamps
    end
  end

  def self.down
    drop_table :roles
  end
end
