# == Schema Information
# Schema version: 20100402074157
#
# Table name: voice_log_counters
#
#  id             :integer(20)     not null, primary key
#  voice_log_id   :integer(20)     not null
#  keyword_count  :integer(10)     default(0)
#  ngword_count   :integer(10)     default(0)
#  mustword_count :integer(10)     default(0)
#  bookmark_count :integer(10)     default(0)
#  created_at     :datetime
#  updated_at     :datetime
#

class VoiceLogCounter < ActiveRecord::Base

  belongs_to :voice_log
  belongs_to :voice_log_temp
  
end
