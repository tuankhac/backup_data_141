<%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:setProperty name="n" property="language" value="${not empty param.language ? param.language : 'vi_VN'}"/>
<html>
<%@include file="header.jsp"%>
<link href="/assets/bootstrap/plugins/iCheck/all.css" rel="stylesheet" type="text/css" />
<script src="/assets/bootstrap/plugins/iCheck/icheck.min.js" type="text/javascript"></script>
<script src="/assets/bootstrap/plugins/autocomplete/jquery.autocomplete.min.js" type="text/javascript"></script>
<link href="/assets/bootstrap/plugins/autocomplete/styles.css" rel="stylesheet" type="text/css" />
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
 					Export dữ liệu
 				</div>
 				<div class="box-body">
					
 					<form  class="form-horizontal" id="myForm">
						<div class="form-group">
							<label for="from_date" class="col-md-3 control-label">Từ ngày</label>
							<div class="col-md-3">
								<input type="text" class="form-control" id="from_date">
							</div>
							<label for="to_date" class="col-md-2 control-label">Đến ngày</label>
							<div class="col-md-3">
								<input type="text" class="form-control" id="to_date">
							</div>
						</div>
						<div class="form-group">
							<label for="kho_bac" class="col-md-3 control-label">${n.i18n.curd_report_kho_bac}</label>
							<div class="col-md-3">
								<select class="form-control" name="kho_bac" id="kho_bac">		
									<option value="">${n.i18n.curd_info_khong_chon}</option>
									<n:option service="danh_sach_kho_bac" serviceType="query" paramSize="1" p1="${province}"/>
								</select>
							</div>
							<label for="kythu" class="col-md-2 control-label">${n.i18n.tinhhinh_thuthue_kythue}</label>
							<div class="col-md-3">
								<select class="form-control" name="ky_thu" id="ky_thu">									
									<option value="">${n.i18n.curd_info_khong_chon}</option>
									<n:option service="crud_report_info_cycle" serviceType="query" paramSize="0"/>
								</select>
							</div>
						</div>
                        <div class="form-group">
                        	<label for="nhan_vien" class="col-md-3 control-label">${n.i18n.export_data_nvtt}</label>
							<div class="col-md-3">
								<select class="form-control" name="nhan_vien" id="nhan_vien">		
									<option value="">${n.i18n.curd_info_khong_chon}</option>
                                    <n:velocity>
									#foreach ($i in $u.ref("export_get_staff","default",["${province}","$!{request.UserPrincipal.name}","$!{request.RemoteAddr}"],3) )
					               		<option value="$!i['ID']">$!i['ID'] - $!i['NAME']</option>
					                #end
									</n:velocity>
									
								</select>
							</div>
                        </div>
						<div class="form-group">
							<label for="" class="col-md-3 control-label">Kiểu dữ liệu</label>
		                	<div class="col-md-3">
		                		<label for="rad_dbf">
		                			<input type="radio" name="rad_file_type" checked="true" id="rad_dbf" value="0">&nbsp;DBF&nbsp;&nbsp;
		                		</label>
		                		<label for="rad_excel">
		                			<input type="radio" name="rad_file_type" id="rad_excel" value="1">&nbsp;Excel&nbsp;&nbsp;
		                		</label>
		                		<label for="rad_text">
		                			<input type="radio" name="rad_file_type" id="rad_text" value="2">&nbsp;TEXT&nbsp;&nbsp;
		                		</label>
		                		<label for="rad_xml">
		                			<input type="radio" name="rad_file_type" id="rad_xml" value="3">&nbsp;XML
		                		</label>
		                	</div>
							<label for="" class="col-md-3 control-label">Tải file</label>
		                	<div class="col-md-3">
		                		<label for="rad_ftp_dbf">
		                			<input type="radio" name="rad_down_type" checked="true" id="rad_ftp_dbf" value="0">&nbsp;FTP&nbsp;&nbsp;
		                		</label>
		                		<label for="rad_down_dbf">
		                			<input type="radio" name="rad_down_type" id="rad_down_dbf" value="1">&nbsp;Download&nbsp;&nbsp;
		                		</label>

		                	</div>

		                </div>
						<div class="form-group">
							<label for="" class="col-md-3 control-label">Xuất dữ liệu</label>
							<div class="col-md-9">
								<n:velocity>
								#foreach ($i in $u.qry("crud_search_data_exports_service","default",["${province}","1"],2) )
									<div class="radio">
										<label class="control-label">
									 		<input name="rad_export_type" id="rad$i['SQL_ID']" value="$!i['SQL_ID']" type="radio">$!i['SQL_ID'] . $!i['SQL_NAME']
										</label>
									</div>
				                #end
								</n:velocity>
							</div>

		                </div>
					</form>
 				</div>
 				<div class="box-footer">
 					<label id="result" class="control-label "></label>
 					<button type="button" onClick="doExport()" class="btn btn-primary pull-right" id="btnExport" >Export</button>
 				</div>
 			</div>
        </section>
      </div><!-- /.content-wrapper -->
    </div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script>
	$(document).ready(function(){
		$('#rad1').attr("checked", "checked");
 		$('#from_date').datepicker({format:"dd/mm/yyyy"});
 		$('#to_date').datepicker({format:"dd/mm/yyyy"});
 	})
	function doExport(){
		if( !confirm('${n.i18n.crud_confirm_message}') ){return;}
			
		var file_type = "";
		var export_type = "";
		var download_type = $('input[name=rad_down_type]:checked').val();
		if ($('input[name=rad_file_type]:checked').val() != null) {           
		   file_type = $('input[name=rad_file_type]:checked').val();
		}
		if ($('input[name=rad_export_type]:checked').val() != null) {           
		   export_type = ($('input[name=rad_export_type]:checked').val());
		}
		$('#result').html('${n.i18n.crud_process_message}');
		
		//alert(file_type);
		//alert($("#kho_bac").val());

		var obj = new Object();
		obj.from_date = $("#from_date").val();
		obj.to_date = $("#to_date").val();
		obj.kho_bac = $("#kho_bac").val();
		obj.ky_thu = $("#ky_thu").val();
		obj.file_type = file_type;
		obj.export_type = export_type;
		obj.province_id = "${province}";
		obj.userid ="${pageContext.request.userPrincipal.name}";
		obj.userip ="${pageContext.request.remoteAddr}";
		obj.download_type = download_type;
		obj.nguoigachno = $("#nhan_vien").val();
		
		$.ajax({
			type:"POST",
			data:obj,
			url: "export_data_ajax.jsp",
			datatype:'html',
			cache: false,
			success : function(data){
				eval('data='+data);
				if(data.RESULT == "1"){
					window.location.href = data.VALUE;
				}else {
					alert(data.VALUE);
				}
				$('#result').html('');
				//$("#btnExport").attr('disabled' , false);	
			},
			error: function (jqXHR, textStatus, errorThrown) {
        		alert(jqXHR.responseText);
    		}
		});
	}

</script>