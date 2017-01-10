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
        <section class="content-header">
          <h1>
            ${n.i18n.gui_sms_thu_thue}
          </h1>
        </section>
        <section class="content">
 			<div class="nav-tabs-custom">
            <ul class="nav nav-tabs">
              <li class="active"><a href="#tab_1" data-toggle="tab" aria-expanded="true">${n.i18n.gui_sms_thu_thue_theo_lo}</a></li>
              <li class=""><a href="#tab_2" data-toggle="tab" aria-expanded="false">${n.i18n.gui_sms_thu_thue_nhan_cong}</a></li>
              <li class="pull-right"><a href="#" class="text-muted"><i class="fa fa-gear"></i></a></li>
            </ul>
            <div class="tab-content">
              <div class="tab-pane active" id="tab_1">
				<!-- <form role="form" id="form_tab1"> -->
	              <div class="box-body">
	                <div class="form-group">
	                  	<div class="form-group">
		                  <label>${n.i18n.gui_sms_thu_thue_theo_lo_ma_tinh}</label>
							<select class="form-control" name="ma_tinh" id="ma_tinh">
								<n:velocity>
									#foreach ($i in $u.qry("crud_search_donvi_qls_ma_tinh_service","default",[],0) )
					               		<option value="$!i['ID']">$!i['NAME']</option>
					                #end
								</n:velocity>
							</select>
		                </div>
	                </div>
					<input type="hidden" id="subject1" name="subject1">
	                <div class="form-group">
	                  <label for="noi_dung_sms">${n.i18n.gui_sms_thu_thue_theo_lo_noi_dung}</label>
	                  <textarea type="text" class="form-control" id="noi_dung_sms1" placeholder="${n.i18n.gui_sms_thu_thue_theo_lo_noi_dung}" rows="3" ></textarea>
	                </div>

	              </div>
	              <!-- /.box-body -->
	              <div class="box-footer">
	                <button  class="btn btn-primary" onclick="doSend1()">${n.i18n.gui_sms_thu_thue_btn_gui}</button>
	                <font id="result"></font>
	              </div>
	            <!-- </form> -->
              </div>
              <!-- /.tab-pane -->
              <div class="tab-pane" id="tab_2">
				<form  id="form_tab2">
	              	<div class="box-body no-padding" style="overflow:auto;margin:auto">
						<table class='table table-condensed table-striped table-bordered' width="100%">
							<tbody>
							<tr>
								<td width="22px" align="center">
									<input type="radio" name="optionsRadios" id="rad1" value="rad1" >
								</td>
								<td name="type" style="display:none;">1</td>
								<td>
					                <div class="form-group">
					                  	<label for="ds_stb">${n.i18n.gui_sms_thu_thue_lbl_file_sdt}</label>
					                  	<input type="file" id="ds_stb" name="so_thue_bao"  accept=".txt" data-input="false" data-icon="false" data-buttonName="btn-primary" data-buttonText="${i18n.l.file_upload}"  onchange="javascript:if(this.value!='') {$('#upload_btn').removeAttr('disabled');} else {$('#upload_btn').attr('disabled','true');}" />
					                  	<p class="help-block">Các mã số thuế cách nhau bởi dấu ",".</p>
					                </div>
								</td>
							</tr>
							<tr>
								<td width="22px" align="center">
									<input type="radio" name="optionsRadios" id="rad2" value="rad2"  >
								</td>
								<td name="type" style="display:none;">2</td>
								<td>
					                <div class="form-group">
					                  	<label for="stb">${n.i18n.crud_info_mst}</label>
		                  				<input type="text" class="form-control" id="stb" name="so_thue_bao" placeholder="${n.i18n.crud_info_mst}">
					                </div>
								</td>
							</tr>
							</tbody>
						</table>
						<input type="hidden" id="subject2" name="subject2">
		                <div class="form-group">
		                  <label for="noi_dung_sms">${n.i18n.gui_sms_thu_thue_theo_lo_noi_dung}</label>
		                  <textarea type="text" class="form-control" id="noi_dung_sms2" placeholder="${n.i18n.gui_sms_thu_thue_theo_lo_noi_dung}" rows="3"></textarea>
		                </div>
	              	</div>
	              <!-- /.box-body -->
	              <div class="box-footer">
	                <button   type="button" onClick="doSend2();" class="btn btn-primary">${n.i18n.gui_sms_thu_thue_btn_gui}</button>
	                <font id="result2"></font>
	              </div>
	            </form>
              </div>
            </div>
            <!-- /.tab-content -->
          </div>
        </section>
      </div><!-- /.content-wrapper -->
    </div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script>
	$(document).ready(function(){
		$('#rad1').attr("checked", "checked");

	})
	function doSend1(){
		if( !confirm('${n.i18n.crud_confirm_message}') ){return;}
		var exec= '&receiver='+$('#ma_tinh').val()+'&content='+$('#noi_dung_sms1').val()+'&subject='+$('#subject1').val()+'&province_id='+$('#ma_tinh').val()+'&created_user=${pageContext.request.userPrincipal.name}'+'&created_date='+'&type=SMS'+'&userid=${pageContext.request.userPrincipal.name}&userip=$!{request.RemoteAddr}';
		$('#result').html('${n.i18n.crud_process_message}');
		$.ajax({
			url: 'crud_exec.jsp?crud_type=notification_log/new_exec.html'+exec,
			success: function(data){ 
				if (data=="1.0"){
					$('#result').html("${n.i18n.gui_sms_thanh_cong}"); 
				}else{
					$('#result').html(data);
				}
			}
		});
	}
	function doSend2(){
		if($("input:radio[name='optionsRadios']").is(":checked")) {
         	var send_type = $("input:checked" ).parent().parent().children('[name="type"]').text();
         	if(send_type == 1 || send_type =="1"){
         		uploadFileAttach();
         	}else if (send_type == 2 || send_type =="2"){
         		var soThueBao = $("#stb").val();
         		doSendNhanCong(soThueBao);
         	}else{
         		alert("Err");
         	}
		}
	}
	function uploadFileAttach(){
		if($('#ds_stb').val()=='') {
			alert('Vui lòng chọn file danh sách!');
			return;
		}
		var form = document.getElementById('form_tab2');
		var formData = new FormData(form);
		var u = 'gui_sms/uploadfile.jsp';
		var dsSoThueBao="";
		//alert(u);
		// loading();
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
				doSendNhanCong(data);
			},
			error: function (jqXHR, textStatus, errorThrown) {
        		alert(jqXHR.responseText);
    		}
		});
	}
	function doSendNhanCong(stb){
		var exec= '&receiver='+stb.trim()+'&content='+$('#noi_dung_sms2').val()+'&subject='+$('#subject2').val()+'&province_id='+$('#ma_tinh').val()+'&created_user=${pageContext.request.userPrincipal.name}'+'&created_date='+'&type=SMS'+'&userid=${pageContext.request.userPrincipal.name}&userip=$!{request.RemoteAddr}';
		$('#result2').html('${n.i18n.crud_process_message}');
		$.ajax({
			url: 'crud_exec.jsp?crud_type=notification_log/new_exec.html'+exec,
			success: function(data){ 
				if (data=="1.0"){
					$('#result2').html("${n.i18n.gui_sms_thanh_cong}"); 
				}else{
					$('#result2').html(data);
				}
			}
		});
	}
</script>