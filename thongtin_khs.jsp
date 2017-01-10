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
                  <h3 class="box-title">${n.i18n.crud_content_tracuu_kh}</h3>
                  <div class="box-tools">
                  </div>
                </div><!-- /.box-header -->
                <div class="box-body no-padding">                    
                    <table id="nnts" class='table table-condensed'>
                    <tr>
                        <td width="10%" style="font-weight:bold;color:#039">${n.i18n.crud_info_mst}*</td>
                        <td><input  type="text" class="form-control" name="mst" id="mst" value="" onKeyUp="loadInfo()"></td>
                        <td>${n.i18n.crud_info_ten}</td>
                        <td><input  type="text" class="form-control" name="ten_nnt" id="ten_nnt"></td>
                     </tr>
                     <tr>
                        <td>${n.i18n.crud_info_loai}</td>
                        <td><input  type="text" class="form-control" name="loai_nnt" id="loai_nnt"></td>
                        <td>${n.i18n.crud_info_so}</td>
                        <td><input  type="text" class="form-control" name="so" id="so"></td>
                     </tr>
                     <tr>
                        <td>${n.i18n.crud_info_chuong}</td>
                        <td><input  type="text" class="form-control" name="chuong" id="chuong"></td>
                        <td>${n.i18n.crud_info_cqt}</td>
                        <td><input  type="text" class="form-control" name="ma_cqt_ql" id="ma_cqt_ql"></td>
                     </tr>
                     <tr>
                        <td>${n.i18n.crud_info_diachi}</td>
                        <td colspan="3"><input  type="text" class="form-control" name="mota_diachi" id="mota_diachi"></td>
                     </tr>
                     <tr>
                        <td>${n.i18n.crud_info_email_mobile}</td><td><input  type="text" class="form-control" name="email_mobile" id="email_mobile"></td>
                        <td>${n.i18n.crud_info_mnv}</td><td><input  type="text" class="form-control" name="ma_nv" id="ma_nv"></td>
                     </tr>
                     
                    
                </table>
                 </div><!-- /.box-body -->
              </div><!-- /.box -->
            </div><!-- /.col -->                                  
          </div><!-- /. row -->
          
        </section>
      </div><!-- /.content-wrapper -->
    </div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script>

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
	$('#result').text('${n.i18n.crud_process_message}');
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
	
}

</script>