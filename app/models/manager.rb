# == Schema Information
# Schema version: 20100402074157
#
# Table name: users
#
#  id                        :integer(11)     not null, primary key
#  login                     :string(255)
#  email                     :string(255)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(255)
#  remember_token_expires_at :datetime
#  activation_code           :string(40)
#  activated_at              :datetime
#  state                     :string(255)     default("passive")
#  deleted_at                :datetime
#  display_name              :string(255)
#  type                      :string(255)
#  group_id                  :integer(10)     default(0), not null
#  lock_version              :integer(10)
#  role_id                   :integer(10)     default(0), not null
#  sex                       :string(1)       default("u"), not null
#  expired_date              :datetime
#  flag                      :boolean(1)
#  cti_agent_id              :integer(10)
#

# Manager can do supervisor tasks.
class Manager < User
  attr_accessible :role_id,:state,:expired_date
  
  def deleted_releated_data
    
    manager_id = self.id
    
    # group leader
    groups = Group.where(:leader_id => manager_id).all
    unless groups.empty?
      groups.each do |g|
        g.update_attributes(:leader_id => nil)
      end
    end
    
    # group manager
    group_managers = GroupManager.where(:manager_id => manager_id).all
    unless group_managers.empty?
      GroupManager.delete(group_managers)
    end
    
  end
  
end
