<%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:setProperty name="n" property="language" value="${not empty param.language ? param.language : 'vi_VN'}"/>
<html>
<%@include file="header.jsp"%>
<link href="/assets/bootstrap/plugins/iCheck/all.css" rel="stylesheet" type="text/css" />
<script src="/assets/bootstrap/plugins/iCheck/icheck.min.js" type="text/javascript"></script>
<script type="text/javascript" src="style/base64.js"></script>
<!-- Content Wrapper. Contains page content -->
      <div class="content-wrapper">
        <!-- Content Header (Page header) -->
        <section class="content-header">
          <h1>
            
          </h1>
        </section>
        <section class="content">
 			<div class="box box-primary">
 				<div class="box-header with-border">
 					<h4>Import dữ liệu.</h4>
 				</div>
 				<div class="box-body">
 					<form id="myForm">
	              	<div class="box-body no-padding" style="overflow:auto;margin:auto">
		                <div class="form-group">
		                  	<label for="ds_stb">Tệp thông tin các hóa đơn</label>
		                  	<input type="file" id="hddt" name="so_thue_bao"  accept="application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" data-input="false" data-icon="false" data-buttonName="btn-primary" data-buttonText="${i18n.l.file_upload}"  onchange="javascript:if(this.value!='') {$('#upload_btn').removeAttr('disabled');} else {$('#upload_btn').attr('disabled','true');}" />
		                  	<p class="help-block">Import file *.xls, *.xlsx</p>
		                </div>
	              	</div>
					</form>
 				</div>
 				<div class="box-footer">
 					<label id="result" class="control-label "></label>
 					<button type="button" onclick="doImportHDDT()" class="btn btn-primary" id="upload_btn" disabled>Import</button>
 				</div>
 			</div>
        </section>
      </div><!-- /.content-wrapper -->
    </div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script>

function doImportHDDT(){
	if($('#hddt').val()=='') {
		alert('Vui lòng chọn file danh sách!');
		return;
	}
	
	$("#upload_btn").attr('disabled' , true);	
	var form = document.getElementById('myForm');
	var formData = new FormData(form);
	var u = 'import_data_process.jsp';
	$.ajax({
		type : "POST",
		url : u,
		cache : false,
		async : false,
		enctype : 'multipart/form-data',
		data : formData,
		processData : false,
		contentType : false,	
		success : function(data) {
			alert(data.trim());	
			$("#upload_btn").attr('disabled' , false);	
		},
		error: function (jqXHR, textStatus, errorThrown) {
			alert(jqXHR.responseText);
		}
	});
} 
</script>