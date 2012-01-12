class AddTagGroupId < ActiveRecord::Migration
  def self.up
    add_column  :tags,  :tag_group_id, :integer 
  end

  def self.down
    remove_column  :tags,  :tag_group_id
  end
end
