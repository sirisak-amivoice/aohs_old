class AddVoiceLogsColumns < ActiveRecord::Migration
  
  def self.up
    add_column :voice_logs, :ori_call_id, :string, :limit => 50
    add_column :voice_logs, :flag_tranfer, :string, :limit => 1
    add_column :voice_logs, :xfer_ani, :string, :limit => 45
    add_column :voice_logs, :xfer_dnis, :string, :limit => 45
    add_column :voice_logs, :log_trans_ani, :string
    add_column :voice_logs, :log_trans_dnis, :string
  end

  def self.down
  
  end
  
end
