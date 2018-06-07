module EvaluationReport
  class AgentEvaluationDetail < EvaluationReportBase

    def initialize(opts={})
      @opts = opts
      @opts[:report_name] = "Agent Evaluation Detail Report"
      initial_report
      initial_header
      
      log "parameters: #{@opts.inspect}"
    end
    
    def initial_header
      @col_quests = []
      row_cnt = @headers.length
      cols = []
      
      # agent info
      cols << new_element("Employee ID", 1, row_cnt)
      cols << new_element("Agent Name", 1, row_cnt)
      
      get_group_columns.each do |c|
        cols << new_element(c[:display_name], 1, row_cnt)
      end

      group_leaders_list.each do |leader|
        cols << new_element(leader.display_name, 1, row_cnt)
      end
      cols << new_element("Call Time", 1, row_cnt)
      cols << new_element("Caller No.", 1, row_cnt)
      cols << new_element("Dialed No.", 1, row_cnt)
      cols << new_element("Duration", 1, row_cnt)
      
      # score sum
      cols << new_element("Grade", 1, row_cnt)
      case @opts[:calc]
      when 'total'
        cols << new_element("Total Score", 1, row_cnt)
      when 'avg'
        cols << new_element("AVG Score", 1, row_cnt)
      end
      # score details
      get_list_questions.each do |c|
        cols << new_element(c["col_title"], 1, row_cnt)
        @col_quests << c["matched_id"].to_i
      end
      # comment
      cols << new_element("Comment", 1, row_cnt)
      # other
      cols << new_element("Evaluated By", 1, row_cnt)
      cols << new_element("Form", 1, row_cnt)
      
      # check info
      cols << new_element("Checked By", 1, row_cnt)
      cols << new_element("Checked Result", 1, row_cnt)
      
      add_header(cols,0,0)
    end
    
    def get_result
      @opts[:limit] = 10000
      
      data = get_data
      ret = {
        headers: @headers,
        data: data
      }
      return ret
    end
    
    def to_xlsx      
      wb = Axlsx::Package.new
      ws = wb.workbook.add_worksheet(name: 'report')
      style = set_sheet_style(ws)      
      
      get_xlsx_titles.each_with_index do |row,i|
        ws.add_row row, style: style[:title]
      end
      
      get_xlsx_filters.each_with_index do |row,i|
        ws.add_row row, style: style[:filter]
      end
      
      headers, spans = get_xlsx_headers
      headers.each_with_index do |row,i|
        ws.add_row row, style: style[:thead]
      end
      spans.each do |cell|
        ws.merge_cells cell
      end
      
      data = get_data
      data.each do |row|
        ws.add_row row, style: style[:all]
      end
      get_average_col_widths(headers.last.length).each_with_index do |w,i|
        ws.column_info[i].width = w
      end

      @out_fpath = xlsx_fname(@opts[:report_name])
      wb.serialize(@out_fpath)

      return {
        path: @out_fpath
      }
    end
    
    def get_data
      data = []
      
      result = select_sql(sql_list_evaluation)
      result_scores = select_sql(sql_details)
      
      # to hash for key-map
      result_scores_tmp = {}
      result_scores.each do |x|
        xkey = "#{x["matched_id"].to_i}-#{x["id"].to_i}"
        result_scores_tmp[xkey] = x
      end
      result_scores = result_scores_tmp
      result_scores_tmp = nil
      
      result.each do |rs|
        d = []
        u = get_user_info(rs["agent_id"], rs["group_id"])
        d << u[:employee_id]
        d << u[:display_name]
        get_group_columns.each do |c|
          d << u[c[:field_name]]
        end
        group_leaders_list.each do |leader|
          d << u[leader.display_name]
        end
        d << rs["start_time"].to_formatted_s(:web)
        d << StringFormat.format_phone(rs["ani"])
        d << StringFormat.format_phone(rs["dnis"])
        d << StringFormat.format_sec(rs["duration"])
        d << nil #7
        d << nil #8
        tt_score = 0
        tt_max = 0
        tt_ws = 0
        tt_cnt = 0
        tt_avg = 0
        cmmts = []
        @col_quests.each do |matched_id|
          xkey = "#{matched_id}-#{rs["id"].to_i}"
          ob = result_scores.delete(xkey)
          #ob = (result_scores.select { |x|
          #  x["matched_id"].to_i == matched_id and rs["id"].to_i == x["id"].to_i
          #}).first
          if ob.blank?
            d << nil
          else
            tt_score += ob["sum_score"].to_f
            tt_max += ob["max_score"].to_f
            tt_ws += ob["ws_score"].to_f
            tt_cnt += 1
            cmmts = cmmts.concat(ob["comments"].to_s.split(","))
            if @opts[:calc] == "total"
              d << StringFormat.score_fmt(ob["sum_score"].to_f)
            else
              # avg
              tt_avg += ob["sum_score"].to_f/ob["max_score"].to_f*100.0
              d << StringFormat.score_fmt(ob["sum_score"].to_f/ob["max_score"].to_f*100.0)
            end
          end
        end
        if tt_max > 0
          if @opts[:calc] == "total"
            d[6+get_group_columns.length+group_leaders_list.length] = get_grade(tt_score/tt_max*100.0, rs["evaluation_plan_id"])
            d[7+get_group_columns.length+group_leaders_list.length] = StringFormat.score_fmt(tt_score/tt_max*100.0)
          else
            d[6+get_group_columns.length+group_leaders_list.length] = get_grade(tt_avg/tt_cnt, rs["evaluation_plan_id"])
            d[7+get_group_columns.length+group_leaders_list.length] = StringFormat.score_fmt(tt_avg/tt_cnt)
          end
        end
        d << cmmts.concat([rs["comment"]]).join(",")
        ue = get_user_info(rs["evaluated_by"])
        d << ue[:display_name]
        p = get_evaluation_form_info(rs["evaluation_plan_id"])
        d << p.name
        uk = get_user_info(rs["checked_by"])
        d << uk[:display_name]
        d << rs["checked_result"]
        data << d
      end
      
      return data
    end

    def sql_list_evaluation
      select = [
        "l.id","l.user_id AS agent_id","l.group_id",
        "l.evaluation_plan_id", "l.evaluated_by", "l.checked_by", "l.checked_result",
        "c.ani, c.dnis, c.duration, TIMESTAMP(c.call_date, c.call_time) AS start_time, m.comment"
      ]
      sql = []
      sql << "SELECT #{jn_select(select)}"
      sql << "FROM evaluation_logs l"
      sql << "JOIN evaluation_plans p ON l.evaluation_plan_id = p.id"
      sql << "JOIN evaluation_calls c ON l.id = c.evaluation_log_id"
      sql << "LEFT JOIN evaluation_comments m ON m.evaluation_log_id = l.id AND m.comment_type = 'E'"
      sql << "WHERE #{jn_where(get_where)}"
      # sql << "AND (m.comment_type = 'E' OR m.comment_type IS NULL)"
      sql << "ORDER BY l.evaluated_at DESC"
      if @opts[:limmit].present?
        sql << "LIMIT #{@opts[:limit]}"
      end
      return jn_sql(sql)
    end
    
    def get_list_questions
      sql = []
      sql << "SELECT DISTINCT s.evaluation_question_id"
      sql << "FROM evaluation_score_logs s"
      sql << "WHERE EXISTS (SELECT 1"
      sql << "FROM evaluation_logs l"
      sql << "JOIN evaluation_calls c ON l.id = c.evaluation_log_id"
      sql << "JOIN evaluation_plans p ON l.evaluation_plan_id = p.id"
      sql << "WHERE #{jn_where(get_where)} AND s.evaluation_log_id = l.id)"
      result = select_sql(jn_sql(sql))
      result = result.map{ |c| c["evaluation_question_id"] }
      return get_column_criteria(@opts[:column_by], result)
    end
    
    def sql_detail_by_question
      sql = []
      sql << "SELECT l.id, l.user_id"
      sql << "FROM evaluation_logs l"
      sql << "JOIN evaluation_plans p ON l.evaluation_plan_id = p.id"
      sql << "JOIN evaluation_calls c ON c.evaluation_log_id = l.id"
      sql << "WHERE #{jn_where(get_where)}"
      sql << "GROUP BY l.id, l.user_id"
      sql << "ORDER BY l.evaluated_at DESC"
      if @opts[:limmit].present?
        sql << "LIMIT #{@opts[:limit]}"
      end
      sql1 = jn_sql(sql)
      sql = []
      sql << "SELECT l.id, l.user_id AS agent_id,"
      sql << "d.question_id AS matched_id,"
      sql << "SUM(s.weighted_score) AS ws_score, SUM(s.max_score) AS max_score, SUM(s.actual_score) AS sum_score,"
      sql << "GROUP_CONCAT(s.comment) AS comments"
      sql << "FROM (#{sql1}) l"
      sql << "JOIN evaluation_score_logs s ON l.id = s.evaluation_log_id"
      sql << "LEFT JOIN evaluation_question_display d ON s.evaluation_question_id = d.question_id"
      sql << "GROUP BY l.id, l.user_id, d.question_id"
      return jn_sql(sql)
    end

    def sql_detail_by_group_question
      sql = []
      sql << "SELECT l.id, l.user_id"
      sql << "FROM evaluation_logs l"
      sql << "JOIN evaluation_plans p ON l.evaluation_plan_id = p.id"
      sql << "JOIN evaluation_calls c ON c.evaluation_log_id = l.id"
      sql << "WHERE #{jn_where(get_where)}"
      sql << "GROUP BY l.id, l.user_id"
      sql << "ORDER BY l.evaluated_at DESC"
      if @opts[:limmit].present?
        sql << "LIMIT #{@opts[:limit]}"
      end
      sql1 = jn_sql(sql)
      sql = []
      sql << "SELECT l.id, l.user_id AS agent_id,"
      sql << "d.question_group_id AS matched_id,"
      sql << "SUM(s.weighted_score) AS ws_score, SUM(s.max_score) AS max_score, SUM(s.actual_score) AS sum_score,"
      sql << "GROUP_CONCAT(s.comment) AS comments"
      sql << "FROM (#{sql1}) l"
      sql << "JOIN evaluation_score_logs s ON l.id = s.evaluation_log_id"
      sql << "LEFT JOIN evaluation_question_display d ON s.evaluation_question_id = d.question_id"
      sql << "GROUP BY l.id, l.user_id, d.question_group_id"
      return jn_sql(sql)
    end
    
    def sql_details
      sql = nil
      case @opts[:column_by]
      when "group_question"
        sql = sql_detail_by_group_question 
      when "question"
        sql = sql_detail_by_question
      end
      return sql
    end
    
    def get_where
      whs = []
      whs << "p.flag <> 'D'"
      whs << "l.flag <> 'D'"
      whs << "l.evaluation_plan_id IN (#{@opts[:form_id].join(",")})" unless @opts[:form_id].nil?
      whs << "c.call_date BETWEEN '#{@opts[:sdate]}' AND '#{@opts[:edate]}'"
      if @opts[:agent_name].present?
        whs << "EXISTS (SELECT 1 FROM users u WHERE #{sqlcond_user_name(@opts[:agent_name])} AND l.user_id = u.id)"
      end
      if @opts[:group_name].present?
        whs << "EXISTS (SELECT 1 FROM groups g WHERE #{sqlcond_group_name(@opts[:group_name])} AND l.group_id = g.id)"
      end
      return whs
    end
    
    # end class
  end
end