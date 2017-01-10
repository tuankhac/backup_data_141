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
			  <h3 class="box-title" style="font-weight:bold;color:#039">${n.i18n.crud_content_tracuu_kh}</h3>
			  <div class="box-tools">
			  </div>
			</div><!-- /.box-header -->
			<div class="box-body no-padding">
				<table id="tile" class='table table-condensed'>
					<tr>						
						<td><input placeholder='Type ${n.i18n.crud_info_mst}'  type="text" class="form-control" name="mst" id="mst"></td>
						<td><input placeholder='Type ${n.i18n.crud_info_so}' type="text" class="form-control" name="so" id="so"></td>                        
						<td><button onClick="loadInfo()" class="btn btn-primary btn-sm" title="Tìm kiếm thông tin" ><i class="fa fa-caret-square-o-right"></i></button></td>
						<td><!--button onClick="InBienNhan()" class="btn btn-primary btn-sm" id="btInBienNhan" disabled title="View thông tin BLDT"><i class="fa fa-print"></i></button--></td>
					</tr>	
				</table>
				<table id="nnts" class='table table-condensed'>                    				 
				 <tr>
					<td style="font-weight:bold">${n.i18n.crud_info_ten}</b></td>
					<td colspan=4><input  style="border:none;align:right;" type="text" class="form-control" name="ten_nnt" id="ten_nnt"></td>                                         
				 </tr>
				 <tr>			
					<td style="font-weight:bold">${n.i18n.crud_info_loai}</td>
					<td colspan=4><input  style="border:none" type="text" class="form-control" name="loai_nnt" id="loai_nnt"></td>                        
				 </tr>
				 <tr>
					<td style="font-weight:bold">${n.i18n.crud_info_chuong}</td>
					<td colspan=4><input  style="border:none" type="text" class="form-control" name="chuong" id="chuong" align=right></td>                        
				 </tr>
				 <tr>                   
					<td style="font-weight:bold">${n.i18n.crud_info_cqt}</td>
					<td colspan=4><input  style="border:none" type="text" class="form-control" name="ma_cqt_ql" id="ma_cqt_ql"></td>
				 </tr>
				 <tr>
					<td style="font-weight:bold">${n.i18n.crud_info_diachi}</td>
					<td colspan="4"><input style="border:none" type="text" class="form-control" name="mota_diachi" id="mota_diachi"></td>
				 </tr>
				 <tr>
					<td style="font-weight:bold">${n.i18n.crud_info_email_mobile}</td>
					<td colspan=4><input style="border:none" type="text" class="form-control" name="email_mobile" id="email_mobile"></td>                        
				 </tr>
				 <tr>                        
					<td style="font-weight:bold">${n.i18n.crud_info_mnv}</td>
					<td colspan=4><input style="border:none" type="text" class="form-control" name="ma_nv" id="ma_nv"></td>
				 </tr>
				
				</table>
			 </div><!-- /.box-body -->
			 
			 <div class="box box-default collapsed-box">
				<div class="box-header with-border">
				  <h3 class="box-title" style="font-weight:bold;color:#039">${n.i18n.crud_info_ls_no}</h3>
				  <div class="box-tools pull-right">
					<button class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-plus"></i></button>
				  </div><!-- /.box-tools -->
				</div><!-- /.box-header -->
				<div class="box-body" style="display: none;">
					<div id="data-list"></div>
				</div><!-- /.box-body -->
			 </div><!-- /.box -->
			 
			 <div class="box box-default collapsed-box">
				<div class="box-header with-border">
				  <h3 class="box-title" style="font-weight:bold;color:#039">${n.i18n.crud_info_ls_tra}</h3>
				  <div class="box-tools pull-right">
					<button class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-plus"></i></button>
				  </div><!-- /.box-tools -->
				</div><!-- /.box-header -->
				<div class="box-body" style="display: none;">
					<div id="data-list2"></div>
				</div><!-- /.box-body -->
			 </div><!-- /.box -->
		  
		  </div><!-- /.box -->
		</div><!-- /.col --> 				
	  </div><!-- /. row -->	  	  
<%@include file="footer.jsp"%> 
	</section>
  </div><!-- /.content-wrapper -->
</div><!-- ./wrapper -->


<script>

function loadInfo(){

	$("#ten_nnt").val("");	
	$("#loai_nnt").val("");
	$("#chuong").val("");
	$("#ma_cqt_ql").val("");
	$("#mota_diachi").val("");
	$("#mobile").val("");
	$("#ma_nv").val("");
	$("#tong_tien").text("0");
	$("#da_tra_f").text("0");
	$('#result').text('${n.i18n.crud_process_message}');

	$.ajax({
		url: 'crud_exec.jsp?crud_type=nnts/tai_quay_info_search.html&mst='+$("#mst").val()+'&sogt='+$("#so").val(),async: false,
		success: function(data){ 
			eval('data='+data);
			$("#ten_nnt").val(data.TEN_NNT);	
			$("#loai_nnt").val(data.LOAI_NNT);
			$("#so").val(data.SO);
			$("#mst").val(data.MST);
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
		url: 'crud_exec.jsp?crud_type=ct_no/ajax_index_no_m.html&mst='+$('#mst').val()+'&ma_tinh=${province}',async: false,
		success: function(data){ 
			$('#data-list').html(data);
			$('#result').html('');
		}
	});
	
	$.ajax({
		url: 'crud_exec.jsp?crud_type=ct_no/ajax_index_tra_m.html&mst='+$('#mst').val()+'&ma_tinh=${province}',async: false,
		success: function(data){ 
			$('#data-list2').html(data);
			$('#result').html('');
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