# == Schema Information
# Schema version: 20100402074157
#
# Table name: customer_numbers
#
#  id          :integer(10)     not null, primary key
#  customer_id :integer(10)
#  number      :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class CustomerNumbers < ActiveRecord::Base

end
