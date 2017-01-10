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
                        <td width="40%">
                            <input  type="text"  class="form-control" name="ma_nv" id="ma_nv"><span id="ma_nv_msg"></span></td>
						<td><input type="text" name="Objmst" id="Objmst" onKeyUp="search_mst()" class="form-control" placeholder="Search MST..."/></td>
                        <td colspan="2">Tổng phiếu: <small class="label label-success"><i class="fa fa-dashcube"></i> <font id="tong_phieu">0</font></small> - Tổng tiền <small class="label label-danger"><i class="fa fa-usd"></i> <font id="tong_tien">0</font></small>
                        </td>
                     </tr>
                </table>
                    <section class="content"><div class="box box-primary box-body no-padding" id='data-list' style="height:300px;overflow:auto;margin:auto"></div>
						</section>                    
                 </div><!-- /.box-body -->
              </div><!-- /.box -->
            </div><!-- /.col -->   
            <div class="col-md-12" style="text-align:center"><span id="result"></span>
                <button onClick="giao_phieu()" class="btn btn-primary" id="btnGiaoPhieu"><i class="fa fa-caret-square-o-right"></i> Giao phiếu</button>&nbsp;
                <button onClick="print()" class="btn btn-primary" id="btInPhieu" disabled ><i class="fa fa-print"></i> In bản kê</button>&nbsp;
				<button onClick="print2()" class="btn btn-primary" id="btInPhieu2" disabled ><i class="fa fa-print"></i> In bản kê XLS</button>&nbsp;
				<button onClick="openWindow('crud_popup.jsp?crud_type=phieu_giao/index.html','phieu_da_giao',920,540,'')" class="btn btn-primary"><i class="fa fa-list-ol"></i> Danh sách phiếu giao</button>
            </div><!-- /.col -->            
          </div><!-- /. row -->
        </section>
      </div><!-- /.content-wrapper -->
    </div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script>
var Objphieu;

function tong_tien(){
	var c=0,s=0;
	$('input[name="nnts_rad"]:checked').each(function(){
		c+=1;
		s+=$("#st"+$(this).attr('id')).val().replace(/,/g,"")*1;
		
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
			url: 'crud_exec.jsp?crud_type=nnts/ajax_giao_phieu.html&province=${province}&ma_nv='+ma_nv,
			cache:false,
			success: function(data){ 				
				$('#result').html('');
				$("#tong_phieu").text("0");
				$("#tong_tien").text("0");
				$('#data-list').html(data); 			
			}
		});
	}
});

	
function giao_phieu(){
	var s="";
	$('input[name="nnts_rad"]:checked').each(function(){
		s+=$("#k"+$(this).attr('id')).val()+",";
	})
	//alert(s);
	$('#result').html('${n.i18n.crud_process_message}');
	$('#btnGiaoPhieu').attr("disabled","true");
	var item = {};
	item["msts"] =s.substring(0,s.length-1);
	item["ma_nv"] =ma_nv;
	item["userid"] ="${pageContext.request.userPrincipal.name}";
	if (s.length > 5000) {
		//alert('222');
		$.ajax({
			url: 'giao_phieu_exec.jsp',
			type: 'POST',
			data: item,
			datatype:'html',
			cache: false,
			success: function(data){
				if(data==data*1){
					Objphieu = data*1;
					//alert(Objphieu);
					$("#btInPhieu,#btInPhieu2").attr('disabled' , false);
					$('#result').html('Đã thực hiện giao <b>'+$("#tong_phieu").text()+'</b> phiếu, tổng tiền <b>'+$("#tong_tien").text()+'</b>!');
					reload_phieu(ma_nv);
				}else{
					$("#result").text("Lỗi giao phiếu: "+data+"!");
				}
			}
		});
	}
	else {
	
		$.ajax({
			url: 'crud_exec.jsp?crud_type=nnts/giao_phieu_exec.html&ma_nv='+ma_nv,
			data: item,
			success: function(data){
				if(data==data*1){
					Objphieu = data*1;
					$("#btInPhieu,#btInPhieu2").attr('disabled' , false);
					$('#result').html('Đã thực hiện giao <b>'+$("#tong_phieu").text()+'</b> phiếu, tổng tiền <b>'+$("#tong_tien").text()+'</b>!');
					reload_phieu(ma_nv);
				}else{
					$("#result").text("Lỗi giao phiếu: "+data+"!");
				}						
			}
		});
	}
	$('#btnGiaoPhieu').removeAttr("disabled");
}

function reload_phieu(obj){
	$.ajax({
			url: 'crud_exec.jsp?crud_type=nnts/ajax_giao_phieu.html&province=${province}&ma_nv='+obj,
			success: function(data){ 
				$('#data-list').html(data); 	
				$("#tong_phieu").text("0");
				$("#tong_tien").text("0");
			}
		});
}

function search_mst(){
	setTimeout(function(){
		var mstsearch = $('#Objmst').val();	
		$(":checkbox").filter(function() {				
			return this.value ==  mstsearch.substring(0,mstsearch.indexOf("/")).trim();
		}).prop("checked","true");
		
		$('input[name="nnts_rad"]').each(function(){
			if ($(this).is(':checked')){
				$(this).parent().parent().css('background-color','#FC3');
			}else{
				$(this).parent().parent().css("background","#fff");}
			}
		);
		tong_tien();
		$('#Objmst').val("");
		}, 500);	
}

function print(){	 		
	var jpPath = '${pathroot}' + "WEB-INF/templates/jasper/";
		s_ = window.location.protocol+"//"+window.location.host
			+"/report/?jasperFile=jasper/list_staff_invoice_retail&jasperExportType=pdf&AGENT=${province}&IMAGE_PATH="+jpPath+"&PHIEU="+Objphieu;
	window.open(s_);
}

function print2(){	 		
	var jpPath = '${pathroot}' + "WEB-INF/templates/jasper/";
		s_ = window.location.protocol+"//"+window.location.host
			+"/report/?jasperFile=jasper/list_staff_invoice_retail_xls&jasperExportType=xls&AGENT=${province}&IMAGE_PATH="+jpPath+"&PHIEU="+Objphieu;
	window.open(s_);
}
</script>