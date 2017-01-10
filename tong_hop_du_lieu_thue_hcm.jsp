<%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:setProperty name="n" property="language" value="${not empty param.language ? param.language : 'vi_VN'}"/>
<html>
<style type="text/css">
.modal {
    display:	none;
    position:   fixed;
    z-index:    1000;
    top:        0;
    left:       0;
 
}
.center{
        z-index: 1000;
        margin: 200px auto;
        width: 140px;
        border-radius: 10px;
        filter: alpha(opacity=100);
        opacity: 1;
        -moz-opacity: 1;
}
.center img {
	height: 100px;
	width: 100px;
}
 
body.loading {
    overflow: hidden;   
}
 
body.loading .modal {
    display: block;
}

</style>
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
			<div class="nav-tabs-custom">
            <ul class="nav nav-tabs">
              <li class="active"><a href="#tab_1" data-toggle="tab" aria-expanded="true">Dữ liệu thuế</a></li>
              <li class=""><a href="#tab_2" data-toggle="tab" aria-expanded="false">Dữ liệu thanh toán</a></li>
            </ul>
            <div class="tab-content">
				<div class="tab-pane active" id="tab_1">
					<div class="box-body no-padding">
						<div class="row">
						<div class="col-md-8">
							<div class="box box box-primary">
								<div class="box-header">
								  <h3 class="box-title">Upload dữ liệu thuế</h3>
								</div><!-- /.box-header -->
								<div class="box-body">
									<form id="form_tab1">
 										<div class="form-group">
											<label for="ds_stb">Tải dữ liệu thuế</label>
											<input type="file" id="hddt" name="hddt"  accept="application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" data-input="false" data-icon="false" data-buttonName="btn-primary" data-buttonText="${i18n.l.file_upload}"  onchange="javascript:if(this.value!='') {$('#upload_btn').removeAttr('disabled');} else {$('#upload_btn').attr('disabled','true');}" />
											<p class="help-block">Hỗ trợ định dạng Excel: *.xls,*.xlsx</p>
											<p id="pFileSize" style="color: red;"></p>
										</div>
										<div class="form-group">
											<label for="ds_stb">Sheet dữ liệu trong Excel:</label>
											<input type="text" id="sheet_dl"  value=""  />
										</div>
										<div class="form-group" style="display:none;">
											<div class="radio">
												<label>
												  <input type="radio" name="radGroup1" id="filted_rad" value="true" checked="true">
												  Lọc dữ liệu
												</label>
											</div>
											<div class="radio">
												<label>
												  <input type="radio" name="radGroup1" id="not_filted_rad" value="false">
												  Không lọc 
												</label>
											</div>
										</div>
 									</form>
									<button type="button" onClick="doImportHDDT()" class="btn btn-primary" id="upload_btn" disabled>Upload file</button>
									<div class="btn-group">											
										<button id="download_btn" type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" aria-expanded="false" disabled><i class="fa fa-print"></i> Download file<span class="fa fa-caret-down"></span></button>
										<ul class="dropdown-menu">
											<li><a onClick="doDownloadFile('DBF')">DBF</a></li>				
											<li class="divider"></li>
											<li><a onClick="doDownloadFile('EXCEL')">EXCEL</a></li>
										</ul>
									</div>
									<button type="button" onClick="doUploadData()" class="btn btn-primary" id="upload_data_btn" disabled >Upload data</button>
									<label id="result" class="control-label "></label>
								</div>
 
							</div><!-- /.box -->
						</div>
						 
						<div class="col-md-4">
							<div class="box box-primary">
							<div class="box-header with-border">
							  <h3 class="box-title">Thông tin dữ liệu thuế</h3>
 							</div>
							<!-- /.box-header -->
							<div class="box-body" style="display: block;">
							  <div class="table-responsive">
								<table class="table no-margin">
								  <thead>
								  <tr>
									<th> </th><th> </th>
								  </tr>
								  </thead>
								  <tbody>
								  <tr>
									<td>Lượt upload</td>
 									<td><span class="label label-success" name="info_upload">0</span></td>
 								  </tr>
								 <tr>
									<td>Số UNT</td>
 									<td><span class="label label-success" name="info_upload">0</span></td>
 								  </tr>
								  <tr>
									<td>Số tiền còn phải thu</td>
 									<td><span class="label label-success" name="info_upload">0</span></td>
 								  </tr>
								  </tbody>
								</table>
							  </div>
							  <!-- /.table-responsive -->
							</div>
							<!-- /.box-body -->
 
							</div>
						</div>
					</div>
					</div>
					<div id="div_page_section1" class=""></div>
					<div class="box-body no-padding" id='data-list' style="overflow:auto;margin:auto"></div>
					<div id="div_page_section2" class=""></div>

				</div>
              <!-- /.tab-pane -->
				<div class="tab-pane" id="tab_2">
					<div class="box-body no-padding"  >
						<div class="row">
						<div class="col-md-8">
							<div class="box box box-primary">
								<div class="box-header">
								  <h3 class="box-title">Upload dữ liệu thanh toán</h3>
								</div><!-- /.box-header -->
								<div class="box-body">
									<div class="box-body no-padding" style="overflow:auto;margin:auto">
										<form  id="form_file_tt">
										<div class="form-group">
											<label for="file_tt1">Chọn tệp dữ liệu thanh toán</label>
											<input type="file" id="file_tt" name="file_tt"  accept="application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" data-input="false" data-icon="false" data-buttonName="btn-primary" data-buttonText="${i18n.l.file_upload}"   />
											<p class="help-block">Hỗ trợ định dạng Excel: *.xls</p>
											<p id="pFileSize" style="color: red;"></p>
										</div>
										<div class="form-group">
											<label for="ds_stb">Sheet dữ liệu trong Excel:</label>
											<input type="text" id="sheet_tt"  value=""/>
										</div>
										<!--
										<div class="form-group" >
											<div class="radio">
												<label>
												  <input type="radio" name="radGroup2" id="map_manual_rad" value="1" checked="true">
												  Tự ghép cột
												</label>
											</div>
											<div class="radio">
												<label>
												  <input type="radio" name="radGroup2" id="map_auto_rad" value="2">
												  Tệp dữ liệu chuẩn, không cần tự ghép cột
												</label>
											</div>
										</div>
										 -->
										<button type="button" onClick="doUploadFileTT();" class="btn btn-primary" id="upload_file_tt_btn" >Upload file thanh toán</button>
										</form>
									</div>
								</div>
							</div><!-- /.box -->
						</div>
						<div class="col-md-4">
							<div class="box box-primary">
							<div class="box-header with-border">
							  <h3 class="box-title">Thông tin dữ liệu thanh toán</h3>
 							</div>
							<!-- /.box-header -->
							<div class="box-body" style="display: block;">
							  <div class="table-responsive">
								<table class="table no-margin">
								  <thead>
								  <tr>
									<th> </th><th> </th>
								  </tr>
								  </thead>
								  <tbody>
								  <tr>
									<td>Lượt upload</td>
 									<td><span class="label label-success" name="tt_upload">0</span></td>
 								  </tr>
								 <tr>
									<td>Số MST</td>
 									<td><span class="label label-success" name="tt_upload">0</span></td>
 								  </tr>
								  
								  <tr>
									<td>Số tiền</td>
 									<td><span class="label label-success" name="tt_upload">0</span></td>
 								  </tr>
								  
								  </tbody>
								</table>
							  </div>
							  <!-- /.table-responsive -->
							</div>
							<!-- /.box-body -->
							</div>
						</div>
						</div>
						<div id="map_column" class="row">
							<div class="col-md-12 hidden" id="map_column_1">
								<div class="box box-primary">
									<div class="box-header with-border">
									  <h3 class="box-title">Ghép cột từ Excel</h3>
										<div class="box-tools pull-right">
											<button type="button" class="btn btn-box-tool" id="collapse_1" data-widget="collapse" data-toggle="tooltip" title="" data-original-title="Ẩn">
											<i class="fa fa-minus"></i></button>
										</div>
									</div>
									<div class="box-body" style="display: block;">
									  <div class="table-responsive">
										<table class="table no-margin">
										  <tbody id="map_column_body"></tbody>
										</table>
									  </div>
									</div>
									<div class="box-footer">
										<button type="button" onClick="doStepUpTT();" class="btn btn-primary">${n.i18n.gui_sms_thu_thue_btn_gui}</button>
										<font id="result2"></font>
									</div>
								</div>
							</div>
						</div>
					</div>
					<div class="box box-primary hidden" id="map_column_2">
						<div class="box-header with-border">
						  <h3 class="box-title">Dữ liệu upload</h3>
							<div class="box-tools pull-right">
								<button type="button" class="btn btn-box-tool" data-widget="collapse" data-toggle="tooltip" title="" data-original-title="Ẩn">
								<i class="fa fa-minus"></i></button>
							</div>
						</div>
						<div class="box-body no-padding"  style="overflow:auto;margin:auto">
							<div class ="row">
								<div class="box-body">
									<div class="col-md-6">
										<div class="form-group">
											<label>Lọc dữ liệu</label>
											<select class="form-control" id="upload_tt_filter">
												<option value="NOT_VALID">Dữ liệu không hợp lệ</option>
												<option value="FILTED">Tự loại bỏ dữ liệu không hợp lệ</option>
												<option value="ALL" selected>Lấy toàn bộ dữ liệu</option>
											</select>
										</div>
										
										<div class="btn-group">											
											<button id="download_tt_btn" type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" aria-expanded="false"  ><i class="fa fa-print"></i> Download file<span class="fa fa-caret-down"></span></button>
											<ul class="dropdown-menu">
												<li><a onClick="doDownloadTT('DBF')">DBF</a></li>				
												<li class="divider"></li>
												<li><a onClick="doDownloadTT('EXCEL')">EXCEL</a></li>
											</ul>
										</div>
										<button type="button" onClick="doUploadTT()" class="btn btn-primary" id="upload_tt_btn" >Upload data</button>
									
									</div>
									<div class="col-md-6" id="div_page2_1"></div>
								</div>
							</div>
 							<div  id='map_column_2_body'></div> 
							<div class ="row"><div class="col-md-6"></div><div class="col-md-6" id="div_page2_2"></div></div>
						</div>
					</div>
						
				</div>
            </div>
            <!-- /.tab-content -->
          </div>

        </section> 
		<div class="modal" style="display: none">
		    <div class="center">
		        <img alt="" src="style/img/loading_2.gif" />
		    </div>
		</div>
      </div><!-- /.content-wrapper -->
    </div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script>
 $(document).on('change',"select",function(){
	//var v = $(this).val();
	 
 	//$('.'+v).attr('disabled',true);
 });
 
var curr_id ="";
var record_per_page=100, page=1, nor=0;
var objPage=new pageTemplates('div_page_section1','div_page_section2','pClick','onGetData');
objPage.setRecPerPage(record_per_page);
objPage.setTypeTemplate('BOOTSTRAP');
function getFilter(){
	var filter = $('input[name="radGroup1"]:checked').val();
	return (filter);
}
function doImportHDDT(){
	if($('#hddt').val()=='') {
		alert('Vui lòng chọn tệp!');
		return;
	}
 	var formData = new FormData();
	var file = $('#hddt')[0].files[0];
	var fullPath = document.getElementById('hddt').value;
	formData.append("UPLOAD_FILE_TYPE","0");
	formData.append("sheet_numb",$("#sheet_dl").val());
 	formData.append("ma_tinh", "${province}");
	formData.append("user", "${pageContext.request.userPrincipal.name}");
	formData.append("user_ip", "<%=request.getRemoteAddr()%>");
	formData.append("file_attach", file);
	var u = 'tong_hop_du_lieu_thue/upload_process.jsp';
	$.ajax({
		type : "POST",
		url : u,
		cache : false,
 		enctype : 'multipart/form-data',
		data : formData,
		processData : false,
		contentType : false,	
		success : function(data) {
			eval('data='+data);
			if(data.RESULT=="OK"){
				curr_id = data.VALUE;
				viewData();
				viewInfoNntsUploads();
				$('input[name="radGroup1"]').each(function(){
					$(this).attr("disabled",false);
				});
				$("#download_btn").attr('disabled' , false);	
				$("#upload_data_btn").attr('disabled' , false);	
			}else{
				alert(data.VALUE);
				$("#download_btn").attr('disabled' , true);	
			}
			$("#upload_btn").attr('disabled' , false);
		},
		error: function (jqXHR, textStatus, errorThrown) {
			alert(jqXHR.responseText);
		}
	});
} 
function viewData(){
	$("#showFileDownload").html("");
	$.ajax({
		url: encodeURI('crud_exec.jsp?crud_type=nnts_uploads_temp/ajax_get_nop_nor.html'+getParams(-1,record_per_page)),
		success: function(data){ 
			eval('data='+data);
			nor = data.NOR*1;
			$('#data-list').html(data);
			onStartSearch(data.NOR);
		},
		error: function (jqXHR, textStatus, errorThrown) {
			alert(jqXHR.responseText);
		}
	});
}
function viewInfoNntsUploads(){
 	$.ajax({
		url: encodeURI('crud_exec.jsp?crud_type=nnts_uploads_temp/ajax_get_info_nnts_uploads.html&log_ip=<%=request.getRemoteAddr()%>&curr_id='+curr_id),
		success: function(data){ 
			eval('data='+data);
			$("span[name='info_upload']").each(function(i){
 				$(this).html(data[i].KEY);
			});
			
		},
		error: function (jqXHR, textStatus, errorThrown) {
			alert(jqXHR.responseText);
		}
	});
}
function doDownloadFile(type) {
	var filter = $('input:radio[name="radGroup1"]:checked').val();
	var obj = {download_type : type, filter_val:filter, curr_id:curr_id};
	$.ajax({
		type: 'POST',
		data: obj,
		url: "tong_hop_du_lieu_thue/download_process.jsp",
		success: function(data){
			var err = data.trim().substring(0,5);
			if(err == ("ERROR")){
				alert(data);
				return;
			}else{
				window.location.href = 'tong_hop_du_lieu_thue/du_lieu_thue_download/'+data.trim();
			}
		}
	});
}
function doUploadData(){
	var filter = $('input:radio[name="radGroup1"]:checked').val();
	var obj = {filter_val:filter,curr_id:curr_id};
 	$.ajax({
		type: 'POST',
		data: obj,
 		url: "tong_hop_du_lieu_thue/upload_data_process.jsp",
		success: function(data){
			eval('data='+data);
			if(data.RESULT == "OK" && data.VALUE == "1"){
				alert("Upload dữ liệu thành công.");
				$("#upload_data_btn").attr('disabled' , true);
			}else {
				alert(data.VALUE);
			}
		}
	});
}
 
function pClick(ps_page_id,ps_rec_per_page) {
	objPage.setCurrentPage(ps_page_id);
	objPage.setRecPerPage(ps_rec_per_page);
	objPage.returnDataCount(objPage.getTotalRec());
}
//Ham nay tu dong duoc goi sau khi click vao cac so...:
function onGetData(page, size){
	$.ajax({
		url: 'crud_exec.jsp?crud_type=nnts_uploads_temp/ajax_index.html'+getParams(page,record_per_page),
		timeout: 1000,
		success: function(data){ 
			if(data!=''){
				$('#data-list').html(data);
				$('#result').html('');
			}
			if(nor==0 && data!=''){
				$('#result').html('Không có dữ liệu!');
			}
		}
	});
}
//Ham tra ve chuoi parameters, truyen vao ajax de lay nop, nor va du lieu hien thi
function getParams(page,record_per_page){
	var exec='&filter='+getFilter()+'&log_ip=<%=request.getRemoteAddr()%>&record_per_page='+record_per_page+'&page_index='+page+'&curr_id='+curr_id;
	return exec;
}
function onStartSearch(total){
	objPage.setCurrentPage(1);
	objPage.returnDataCount(total);
}
$.ajaxSetup({
	beforeSend: function () {
	   $(".modal").show();
	   console.log("show");
	},
	complete: function () {
		$(".modal").hide();
		console.log("hide");
	}
});
/******************** TAB 2 **********************/
var numbColumn = 0;
var file_xls_path = "";
var record_per_page=100, page2=1, nor2=0, curr_id2 = 0;
var objPage2=new pageTemplates('div_page2_1','div_page2_2','pClick2','onGetData2');
objPage2.setRecPerPage(record_per_page);
objPage2.setTypeTemplate('BOOTSTRAP');
function doUploadFileTT(){
	if($('#file_tt').val()=='') {
		alert('Vui lòng chọn tệp!');
		return;
	}
 	var formData = new FormData();
	var file = $('#file_tt')[0].files[0];
	var fullPath = document.getElementById('file_tt').value;
	//tu dong ghep cot: value =1
	var map_data_type = 1;
	//var map_data_type = $("input:radio[name='radGroup2']:checked").val();
	formData.append("UPLOAD_FILE_TYPE",map_data_type);
	formData.append("sheet_numb",$("#sheet_tt").val());
 	formData.append("ma_tinh", "${province}");
	formData.append("user", "${pageContext.request.userPrincipal.name}");
	formData.append("user_ip", "<%=request.getRemoteAddr()%>");
	formData.append("file_attach", file);
	var u = 'tong_hop_du_lieu_thue/upload_process.jsp';
	$.ajax({
		type : "POST",
		url : u,
		cache : false,
 		enctype : 'multipart/form-data',
		data : formData,
		processData : false,
		contentType : false,	
		success : function(data) {
			console.log(data);
   			eval('data='+data);
			if(data.RESULT=="OK"){
				$("#map_column_1").removeClass('hidden');
				//$("#collapse_1").click();
				var count = 1;
				if (!$('#map_column_body').is(':empty')){
					$('#map_column_body').html("");
				} 
				$.each(data.VALUE, function(key, value) {
 					/*
					$('#map_column_body').append("<tr><td>"+value.COLUMN_NAME+"</td><td><select class='form-control' name='col_tt'> <option value=''>${n.i18n.curd_info_khong_chon}</option><n:velocity>#set ($k=0) #foreach ($i in $u.qry('upload_tt_get_column_name_service','default',[],0) ) #set #if ($k==$!{count}) <option value='$!k' selected>$!i['COLUMN_NAME']</option> #else <option value='$!k'>$!i['COLUMN_NAME']</option> #end #end </n:velocity></select></td></tr>"); 
					*/
					$.ajax({
						url: 'crud_exec.jsp?crud_type=nnts_uploads_temp/ajax_map_column.html&count='+count+'&col_name=' +value.COLUMN_NAME,
						type: 'GET',
						async: false,
						timeout: 1000,
						success: function(data){ 
							$('#map_column_body').append(data);
						}
					});
					count=count+1;
				});
				 
				file_xls_path = data.FILE_PATH;
 			}else{
				alert(data.VALUE);
 			}
 		},
		error: function (jqXHR, textStatus, errorThrown) {
			alert(jqXHR.responseText);
		}
	});
}

function doStepUpTT(){
 	var step2_invisible = $("#map_column_2").hasClass("hidden");
	var s = "";
	var is_empty = false;
	$('input[name="cb_xls_col"]').each(function (){
		console.log("ok check");
		var select_val = $(this).parent().parent().children('[name="select_col"]').children('[name="col_tt"]').val();
		if($(this).is(":checked") && select_val != "") {
			s+= select_val+",";
		}else{
			s+= ",";
		}
	} ); 

	if(!is_empty){
		//map cot va doc tu excel
		console.log(s);
		var obj = {PATH:file_xls_path,LIST_COLUMN:s,sheet_numb:$("#sheet_tt").val()};
		$.ajax({
			type : "POST",
			url:'tong_hop_du_lieu_thue/upload_thanhtoan.jsp',
			data: obj,
			success: function(data){
				console.log(data);
				eval('data='+data);
				if(data.RESULT=="OK"){
					$("#collapse_1").click();
					$("#map_column_2").removeClass('hidden');
					curr_id2 = data.VALUE;
					viewDataTT();
					viewInfoUploadsTT();
					$("#upload_file_tt_btn").attr("disabled",true);
				}else{
					alert(data.VALUE);
				}
			},
			error: function (jqXHR, textStatus, errorThrown) {
				alert(jqXHR.responseText);
			}
		});
	}else{
		alert("Bạn chưa nhập hết cột dữ liệu tương ứng");
	}
 }
function viewDataTT(){
 	$.ajax({
		url: encodeURI('crud_exec.jsp?crud_type=nnts_uploads_temp/ajax_get_nop_nor_upload_tt.html'+getParams2(-1,record_per_page)),
		success: function(data){ 
			eval('data='+data);
			nor2 = data.NOR*1;
			$('#map_column_2_body').html(data);
			onStartSearch2(data.NOR);
		},
		error: function (jqXHR, textStatus, errorThrown) {
			alert(jqXHR.responseText);
		}
	});
}
function doDownloadTT(type) {
	var filter = $('#upload_tt_filter').val();
 	var obj = {download_type : type, filter_val:filter, curr_id:curr_id2};
	$.ajax({
		type: 'POST',
		data: obj,
		url: "tong_hop_du_lieu_thue/download_thanhtoan.jsp",
		success: function(data){		
			var err = data.trim().substring(0,5);
			if(err == ("ERROR")){
				alert(data);
				return;
			}else{
				window.location.href = 'tong_hop_du_lieu_thue/du_lieu_thanhtoan_download/'+data.trim();
			}
			
		}
	});
}
function doUploadTT(){
	var filter = $('#upload_tt_filter').val();
	var obj = {filter_val:filter,curr_id:curr_id2};
  	$.ajax({
		type: 'POST',
		data: obj,
 		url: "tong_hop_du_lieu_thue_hcm/insert_upload_thanhtoan.jsp",
		success: function(data){
 			eval('data='+data);
			if(data.RESULT == "OK" && data.VALUE == "1"){
				viewInfoUploadsTT();
				alert("Upload dữ liệu thành công.");
				$("#upload_tt_btn").attr("disabled",true);
 			}else {
				alert(data.VALUE);
			}
		}
	});
}
function viewInfoUploadsTT(){
 	$.ajax({
		url: encodeURI('crud_exec.jsp?crud_type=nnts_uploads_temp/ajax_get_info_uploads_tt.html&log_user=${pageContext.request.userPrincipal.name}&log_ip=<%=request.getRemoteAddr()%>&curr_id='+curr_id2),
		success: function(data){ 
			eval('data='+data);
			$("span[name='tt_upload']").each(function(i){
 				$(this).html(data[i].KEY);
			});
			
		},
		error: function (jqXHR, textStatus, errorThrown) {
			alert(jqXHR.responseText);
		}
	});
}
function pClick2(ps_page_id,ps_rec_per_page) {
	objPage2.setCurrentPage(ps_page_id);
	objPage2.setRecPerPage(ps_rec_per_page);
	objPage2.returnDataCount(objPage2.getTotalRec());
}
function onGetData2(page2, size){
	$.ajax({
		url: 'crud_exec.jsp?crud_type=nnts_uploads_temp/ajax_data_tt.html'+getParams2(page2,record_per_page),
		timeout: 1000,
		success: function(data){ 
			if(data!=''){
				$('#map_column_2_body').html(data);
				$('#result2').html('');
			}
			if(nor2==0 && data!=''){
				$('#result2').html('Không có dữ liệu!');
			}
		}
	});
}
function getParams2(page2,record_per_page){
	var filter_val = $("#upload_tt_filter").val();
	var exec='&filter='+filter_val+'&log_ip=<%=request.getRemoteAddr()%>&record_per_page='+record_per_page+'&page_index2='+page2+'&curr_id='+curr_id2+'&log_user=<%=request.getUserPrincipal().getName()%>';
	return exec;
}
function onStartSearch2(total){
	objPage2.setCurrentPage(1);
	objPage2.returnDataCount(total);
}
$(document).on("change",'#check_all',function(){
	console.log("checkssss");
    $("input:checkbox").prop('checked', $(this).prop("checked"));
});
$("document").ready(function(){
	/*
    $("#hddt").change(function() {
		var file = $('input[type=file]')[0].files[0];
		var fileSizeMb = Math.round((file.size/(1024*1024))*100)/100;
		if($('#hddt').val()!='' && fileSizeMb >= 15){
			$('#hddt').val("");
			$("#upload_btn").attr('disabled' , true);	
			alert("Tệp đính kèm phải nhỏ hơn 15Mb, ("+fileSizeMb+" Mb)");
			return;
		}
    });
	*/
	 $('#upload_tt_filter').on('change', function (e) {
		var optionSelected = $("option:selected", this);
		var valueSelected = this.value;
		viewDataTT();
 	});

	$('input[name="radGroup1"]').each(function(){
		$(this).attr("disabled",true);
	});
	$('input[name="radGroup1"]').change(function(){ 
 		viewData();
	});
	/********TAB2********/
});
</script>