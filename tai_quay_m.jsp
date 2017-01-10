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
            <div class="col-md-6">
				<div class="box box-info box-solid direct-chat direct-chat-info">
					<div class="box-header">
						<n:value id="head" service="tai_quay_thong_tin_nguoi_gach_no" serviceType="query" paramSize="1" p1="${pageContext.request.userPrincipal.name}">
						<b>Chu kỳ [$list.get(0).CKN] $list.get(0).HOVATEN</b>										
						</n:value>
						<div class="box-tools pull-right">									
							<b>Tiền trả</b> <span data-toggle="tooltip"  class="badge bg-green" id="tien_tra"></span>								
							<button class="btn btn-box-tool" data-widget="remove"><i class="fa fa-times"></i></button>
						</div>
					</div><!-- /.box-header -->  					
		
					<div class="box-body table-bordered">							
						<div class="col-xs-3"><b>MST</b></div>
						<div class="col-xs-6"><span class="pull-left" name="mst" id="mst" style="padding-left:5px"></span></div>
					</div>
					<div class="box-body table-bordered">							
						<div class="col-xs-3"><b>Người NT</b></div>
						<div class="col-xs-6"><span class="pull-left" name="ten_nnt" id="ten_nnt" style="padding-left:5px"></div>
					</div>
					<!--div class="box-body">							
						<div class="col-xs-2"><b>Số</b></div>
						<div class="col-xs-6"><span class="pull-left" name="so" id="so" style="padding-left:5px"></span></div>
					</div-->
					<!--div class="box-body">							
						<div class="col-xs-3"><b>Cơ quan thu</b></div>
						<div class="col-xs-6"><span class="pull-left" name="ma_cqt_ql" id="ma_cqt_ql" style="padding-left:5px"></span></div>
					</div-->
					<div class="box-body table-bordered">						
						<div class="col-xs-3"><b>Địa chỉ</b></div>
						<div class="col-xs-6"><span class="pull-left" name="mota_diachi" id="mota_diachi" style="padding-left:5px"></div>
					</div>
					<div class="box-body table-bordered">							
						<div class="col-xs-3"><b>Email/mobile</b></div>
						<div class="col-xs-6"><span class="pull-left" name="email_mobile" id="email_mobile" style="padding-left:5px"></div>
					</div>

					<div class="box-footer">					
						<div class="col-md-12">							
							<div class="box-body" id="data-list"></div>
						</div>
						<div class="col-md-12" style="text-align:center"><span id="result"></span>
							<button onClick="thanh_toan()" class="btn btn-primary btn-xs"><i class="fa fa-money"></i> Gạch nợ</button>&nbsp;
							<button onClick="print()" class="btn btn-primary btn-xs"><i class="fa fa-print"></i> In phiếu thu</button>&nbsp;                
						</div>
					</div><!-- /.box-footer-->
				</div><!--/.direct-chat -->
            </div><!-- /.col -->                               
			</div><!-- /. row -->   			          
        </section>
    </div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script type="text/javascript">

function getQueryVariable(variable)
{
       var query = window.location.search.substring(1);
       var vars = query.split("&");
       for (var i=0;i<vars.length;i++) {
               var pair = vars[i].split("=");
               if(pair[0] == variable){return pair[1];}
       }
       return(false);
}
var mst_= getQueryVariable("mst");

function CalTra(o){
	$(o).val(fnumber($(o).val()));
	var tien_tra=0;
	$('input[name="tien_tra"]').each(function(){
		tien_tra+=$(this).val().replace(/,/g,"")*1;
	});
	$("#tien_tra").text(fnumber(tien_tra+""));
}
function thanh_toan(){
	var text="";
	$('input[name="tien_tra"]').each(function(){
		var tien=$(this).val().replace(/,/g,"")*1;
		var t=$("#f"+$(this).attr("id")).val();
		text+=t.replace("{TIEN_TRA}",tien)+"|";
	});
	$.ajax({
		url: 'crud_exec.jsp?crud_type=ct_no/thanh_toan_exec.html&mst='+mst_+'&ma_tinh=${province}&ma_bc=${head.list.get(0).MABC_ID}&quaythu=${head.list.get(0).QUAYTHU_ID}&httt=1&tra='+text.substring(0,text.length-1),
		async: false,
		success: function(data){ 
			if(data==data*1){
				$("#result").text("Gạch nợ thành công, số phiếu "+data*1+"!");
			}else{
				$("#result").text("Gạch nợ lỗi: "+data+"!");
			}
		}
	});
}
$(document).ready(function loadInfo(){
	$.ajax({
		url: 'crud_exec.jsp?crud_type=nnts/tai_quay_info_exec.html&mst='+mst_,async: false,
		success: function(data){ 
			eval('data='+data);	
			$("#ten_nnt").html(data.TEN_NNT);		
			$("#mst").html(data.MST);
			$("#loai_nnt").html(data.LOAI_NNT);
			$("#so").html(data.SO);
			$("#chuong").html(data.CHUONG);
			$("#ma_cqt_ql").html(data.MA_CQT_QL);
			$("#mota_diachi").html(data.MOTA_DIACHI);
			$("#mobile").html(data.EMAL+"/"+data.MOBILE);
			$("#ma_nv").html(data.MA_NV);
			$("#tong_tien").html(data.SOTIEN);
			$("#da_tra_f").html(data.TIEN_TRA);					
		}
	});	
	
	$.ajax({
		url: 'crud_exec.jsp?crud_type=ct_no/ajax_index_m.html&mst='+mst_+'&ma_tinh=${province}',async: false,
		success: function(data){ 
			$('#data-list').html(data);
			$('#result').html('');
		}
	});
	var tien_tra=0;
	$('input[name="tien_tra"]').each(function(){
		tien_tra+=$(this).val().replace(/,/g,"")*1;
	});
	$("#tien_tra").text(fnumber(tien_tra+""));
});
</script>