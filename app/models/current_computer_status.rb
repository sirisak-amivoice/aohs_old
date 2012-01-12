# == Schema Information
# Schema version: 20100402074157
#
# Table name: current_computer_statuses
#
#  id                  :integer(11)     not null, primary key
#  check_time          :datetime
#  computer_name       :string(255)
#  login_name          :string(255)
#  os_version          :string(255)
#  java_version        :string(255)
#  watcher_version     :string(255)
#  audioviewer_version :string(255)
#  cti_version         :string(255)
#  versions            :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#

class CurrentComputerStatus < ActiveRecord::Base
  set_table_name('current_computer_status')
end
