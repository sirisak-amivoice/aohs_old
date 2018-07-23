class ApplicationController < ActionController::Base
  
  protect_from_forgery
  
  include AuthenticatedSystem
  include AmiPermission
  include AmiLog
  include Format

  before_filter :initial_config
  before_filter :valid_sql_injection
  
  def initial_config
    
    $CF = AmiConfig::UserConf.new(session[:user_id])
    $PER_PAGE = $CF.get('client.aohs_web.number_of_display_list').to_i
    $SERVER_ROOT_URL = Aohs::SITE_ROOT
    
    ## fixed
    AmiTool.switch_table_voice_logs
    
  end
<<<<<<< HEAD
  
  def valid_sql_injection
    ctls_names = [
      'voice_logs', 'customer', 'customers', 'keywords',
      'statistics', 'favorites', 'call_tags', 'agents',
      'bookmark', 'call_browser', 'event'
    ]
    acts_names = ['edit','update','delete','destroy','update_group']  
    if ctls_names.include?(controller_name.to_s) and (not acts_names.include?(action_name.to_s))
      params.each do |kname,val|
        next if ['controller','action'].include?(kname)
        next if val.blank?
        # perform check
        if found_sql_injection?(kname, val)
          render :status => 400
=======

  def valid_sql_injection
    if [
          'voice_logs','customer','customers','keywords',
          'statistics','favorites','call_tags','agents',
          'bookmark','call_browser','event'
        ].include?(controller_name.to_s)
      params.each do |kname,val|
        next if ['controller','action'].include?(kname)
        next if val.blank?

        # perform check
        if found_sql_injection?(val)
          render :status => 500
>>>>>>> 8a5dd4b11c5a12382fe1b364eba08d887ec703c4
        end
      end
    end
  end
  
<<<<<<< HEAD
  def found_sql_injection?(kname, val)
    txt = val.to_s.chomp.strip
    regexp = /\b(OR|AND|ALTER|CREATE|DELETE|DROP|EXEC(UTE){0,1}|INSERT( +INTO){0,1}|MERGE|SELECT|UPDATE|UNION( +ALL){0,1})\b/i
    if txt.match(regexp)
      STDOUT.puts "(valid-sql) - rejected parameter #{kname}=#{val}"
      return true
    end
    STDOUT.puts "(valid-sql) - accepted parameter #{kname}=#{val}"
    return false
  end

  def encrypt_voice_url(surl,key)
    ourl = surl.clone
    toinsert = []
    n=0
    while true
      nn=n*(n+1)/2
      if nn < surl.length
        toinsert.push(nn)
        n = n + 1
      else
        break
      end
    end
    key_arr = key.to_s.scan(/./)
    toinsert.each_with_index { |pos,idx|
      str2insert = (str2insert.nil? ? "0" : key_arr[idx])
      ourl.insert(pos,str2insert)
    }
    return ourl
  end
  
=======
  def found_sql_injection?(val)
    txt = val.to_s.chomp.strip

    regexp = /\b(OR|AND|ALTER|CREATE|DELETE|DROP|EXEC(UTE){0,1}|INSERT( +INTO){0,1}|MERGE|SELECT|UPDATE|UNION( +ALL){0,1})\b/i

    if txt.match(regexp)
      return true
    end

    return false
  end
    
>>>>>>> 8a5dd4b11c5a12382fe1b364eba08d887ec703c4
end
