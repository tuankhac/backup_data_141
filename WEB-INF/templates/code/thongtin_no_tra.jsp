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
	<section class="content">
	<!-- Content Header (Page header) -->	        
		<div class="row">
			<div class="col-md-12">
				<!-- Custom Tabs -->
				<div class="box box-primary">   
				<div class="box-header with-border">
                  <h3 class="box-title">${n.i18n.crud_info_ls_no_tra}</h3>
                  <div class="box-tools">
                  </div>
                </div><!-- /.box-header -->
				<div class="box-body no-padding">	
					
					<table class="table table-striped">
					<tbody>
						<tr>
							<td width="10%" style="font-weight:bold;color:#039">${n.i18n.crud_info_mst}*</td>
							<td><input  type="text" class="form-control" name="mst" id="mst" value="" onKeyUp="loadInfo()"></td>
							<td>${n.i18n.crud_info_ten}</td>
							<td><input  type="text" class="form-control" name="ten_nnt" id="ten_nnt"></td>
						 </tr>									 									 
						 <tr>
							<td>${n.i18n.crud_info_diachi}</td>
							<td colspan="3"><input  type="text" class="form-control" name="mota_diachi" id="mota_diachi"></td>
						 </tr>									 
					</tbody></table>														
					<div id="data-list"></div>	
					<div id="data-list2"></div>
					
				</div><!-- /.box-body -->												
				</div>
            </div>						
		</div><!-- /. row -->  
		<!--div class="col-md-12" style="text-align:center">
		<div><button onClick="InBienNhan()" class="btn btn-primary" id="btInBienNhan" disabled><i class="fa fa-print"></i>View HDDT</button>&nbsp;</div>
		</div-->
	</section>
</div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script type="text/javascript">

function loadInfo(){
	if(event.keyCode != 13){
        return;
    }
	$("#ten_nnt").val("");	
	$("#loai_nnt").val("");
	$("#so").val("");
	$("#chuong").val("");
	$("#ma_cqt_ql").val("");
	$("#mota_diachi").val("");
	$("#mobile").val("");
	$("#ma_nv").val("");
	$("#tong_tien").text("0");
	$("#da_tra_f").text("0");
	$('#result').text('Dang lay du lieu ...');
	 $.ajax({
	 	url: 'crud_exec.jsp?crud_type=nnts/tai_quay_info_exec.html&mst='+$("#mst").val(),async: false,
	 	success: function(data){ 
	 		eval('data='+data);
	 		$("#ten_nnt").val(data.TEN_NNT);	
	 		$("#loai_nnt").val(data.LOAI_NNT);
	 		$("#so").val(data.SO);
			$("#chuong").val(data.CHUONG);
	 		$("#ma_cqt_ql").val(data.MA_CQT_QL);
	 		$("#mota_diachi").val(data.MOTA_DIACHI);
	 		$("#mobile").val(data.EMAL+"/"+data.MOBILE);
	 		$("#ma_nv").val(data.MA_NV);
	 		$("#tong_tien").text(data.SOTIEN);
	 		$("#da_tra_f").text(data.TIEN_TRA);
	 	}
	 });
	
	$.ajax({
		url: 'crud_exec.jsp?crud_type=ct_no/ajax_index_no_kythue.html&mst='+$('#mst').val()+'&ma_tinh=${province}',async: false,
		success: function(data){ 
			$('#data-list').html(data);
		}
	});
	
	$.ajax({
		url: 'crud_exec.jsp?crud_type=ct_no/ajax_index_tra_kythue.html&mst='+$('#mst').val()+'&ma_tinh=${province}',async: false,
		success: function(data){ 
			$('#data-list2').html(data);
		}
	});
	
	$("#btInBienNhan").attr('disabled' , false);
}
function InBienNhan(){
	if ($("#mst").val()==""){
		alert("Yêu cầu nhập thông tin MST tra cứu");
		return;
	}
	var isContinue= true ;
	$.ajax({
		url: 'crud_exec.jsp?crud_type=ct_no/check_info_dept_exec.html&mst='+$("#mst").val(),
		async: false,
		success: function(data){ 
			if(data==0){
				isContinue = false;
				alert("Bạn vui lòng thanh toán tiền thuế trước khi xem BLDT");	
			}
		}
	});

	if (isContinue) {	
		var obj = new Object();
		obj.username = "vnptthuhoservice";
		obj.pass = "Thuho@2015";
		obj.fkey = $("#mst").val();
		$.ajax({
			type:"POST",
			data:obj,
			url: "tai_quay_bien_nhan.jsp",
			datatype:'html',
			cache: false,
			success : function(data){
				var x=window.open();
				x.document.open();
				x.document.write(data);
				x.document.close();
			},
			error: function (jqXHR, textStatus, errorThrown) {
				alert(jqXHR.responseText);
			}
		});
	}else{
		return;
	}
}
</script>