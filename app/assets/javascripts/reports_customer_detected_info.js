var fnRp = {
  oTbl: null,
  
  loadTable: function(){
    var params = fn_reports.getCallFilter();
    var renderTable = function(data){
      var o = $("#call_report");
      var t = appl.getHtmlTemplate("#table_template");
      if (fnRp.oTbl !== null) {
        fnRp.oTbl.destroy();
      }
      o.html(t(data));
      var topts = {};
      jQuery.extend(topts,{ data: data.data },fn_reports.tblOptions);
      fnRp.oTbl = o.DataTable(topts);
    };
    jQuery.getJSON(Routes.customer_detected_info_reports_path({format: 'json'}),params,renderTable);
  },
  
  downloadFile: function(){
    var params = fn_reports.getCallFilter();
    appl.fileDownload(appl.mkUrl(Routes.customer_detected_info_reports_path({format: 'xlsx'}), params));
  },
};
