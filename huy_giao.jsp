<%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:setProperty name="n" property="language" value="${not empty param.language ? param.language : 'vi_VN'}"/>
<html>
<%@include file="header.jsp"%>
<link href="/assets/bootstrap/plugins/iCheck/all.css" rel="stylesheet" type="text/css" />
<script src="/assets/bootstrap/plugins/iCheck/icheck.min.js" type="text/javascript"></script>
<script src="/assets/bootstrap/plugins/autocomplete/jquery.autocomplete.min.js" type="text/javascript"></script>
<link href="/assets/bootstrap/plugins/autocomplete/styles.css" rel="stylesheet" type="text/css" />
<!-- Content Wrapper. Contains page content -->
      <div class="content-wrapper">
        <!-- Content Header (Page header) -->
        <section class="content">
		  <div class="row">
            <div class="col-md-12">
                
              <!-- Block buttons -->
              <div class="box box-primary">
              	<div class="box-header with-border">
                  <h3 class="box-title">Giao phiếu cho nhân viên đi thu</h3>
                  <div class="box-tools">
                  </div>
                </div><!-- /.box-header -->
                <div class="box-body no-padding">
                    
                    <table id="nnts" class='table table-condensed'>
                    <tr>
                        <td width="7%" title="${n.i18n.crud_valid_length_prefix} 100 ${n.i18n.crud_valid_length_postfix}" id="ma_nv_label">Mã NV</td>
                        <td width="60%">
                            <input  type="text" class="form-control" name="ma_nv" id="ma_nv"><span id="ma_nv_msg"></span></td>
                        <td colspan="2">Tổng phiếu: <small class="label label-success"><i class="fa fa-dashcube"></i> <font id="tong_phieu">0</font></small> - Tổng tiền <small class="label label-danger"><i class="fa fa-usd"></i> <font id="tong_tien">0</font></small>
                        </td>
                     </tr>
                </table>
                    <section class="content"><div class="box box-primary box-body no-padding" id='data-list' style="height:460px;overflow:auto;margin:auto"></div></section>
                    
                 </div><!-- /.box-body -->
              </div><!-- /.box -->
            </div><!-- /.col -->   
            <div class="col-md-12"><span id="result"></span>
                <button onClick="giao_phieu()" class="btn btn-primary"><i class="fa fa-caret-square-o-right"></i> Giao phiếu</button>&nbsp;
                <button onClick="print()" class="btn btn-primary"><i class="fa fa-print"></i> In bản kê giao phiếu</button>
            </div><!-- /.col -->            
          </div><!-- /. row -->
        </section>
      </div><!-- /.content-wrapper -->
    </div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script>
function tong_tien(){
	var c=0,s=0;
	$('input[name="nnts_rad"]:checked').each(function(){
		c+=1;
		s+=$("#so_tien"+$(this).attr('id')).text().replace(/,/g,"")*1;
	});
	$("#tong_phieu").text(c);
	$("#tong_tien").text(fnumber(s+""));
}
var ma_nv="";
var tasks = {
	<n:value service="danh_sach_nv_tc_theo_tinh" serviceType="query" paramSize="1" p1="${province}">
	#set ($k = 0 )
	#foreach ($i in $list )
		#if ($k!=0),#end"$!i['ID']":"$!i['NAME']"
		#set ($k=$k+1)
	#end
	</n:value>
};
var tasksArray = $.map(tasks, function (value, key) { return { value: value, data: key }; });
$('#ma_nv').autocomplete({
	lookup: tasksArray,
	onSelect: function (suggestion) {
		$('#data-list').html('${n.i18n.crud_process_message}');
		ma_nv = suggestion.data;
		$.ajax({
			url: 'crud_exec.jsp?crud_type=nnts/ajax_giao_phieu.html&province=${province}&ma_nv='+suggestion.data,
			success: function(data){ 
				$('#data-list').html(data); 
			}
		});
	}
});
function giao_phieu(){
	var s="";
	$('input[name="nnts_rad"]:checked').each(function(){
		s+=$(this).attr('id')+",";
	})
	$('#result').html('${n.i18n.crud_process_message}');
	$.ajax({
		url: 'crud_exec.jsp?crud_type=nnts/giao_phieu_exec.html&ma_nv='+ma_nv+'&msts='+s.substring(0,s.length-1),
		success: function(data){ 
			$('#result').html('Đã thực hiện giao <b>'+$("#tong_phieu").text()+'</b> phiếu, tổng tiền <b>'+$("#tong_tien").text()+'</b>!');
		}
	});
}
</script>