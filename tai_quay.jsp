<%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:setProperty name="n" property="language" value="${not empty param.language ? param.language : 'vi_VN'}"/>
<html>
<%@include file="header.jsp"%>
<link href="/assets/bootstrap/plugins/iCheck/all.css" rel="stylesheet" type="text/css" />
<script src="/assets/bootstrap/plugins/iCheck/icheck.min.js" type="text/javascript"></script>
<script src="/assets/bootstrap/plugins/autocomplete/jquery.autocomplete.min.js" type="text/javascript"></script>
<link href="/assets/bootstrap/plugins/autocomplete/styles.css" rel="stylesheet" type="text/css" />
<style type="text/css">
    body
    {
        font-family: Arial;
        font-size: 10pt;
    }
    .modal
    {
        position: fixed;
        z-index: 999;
        height: 100%;
        width: 100%;
        top: 0;
        left: 0;
        background-color: Black;
        filter: alpha(opacity=60);
        opacity: 0.6;
        -moz-opacity: 0.8;
    }
    .center
    {
        z-index: 1000;
        margin: 300px auto;
        padding: 10px;
        width: 140px;
        background-color: White;
        border-radius: 10px;
        filter: alpha(opacity=100);
        opacity: 1;
        -moz-opacity: 1;
    }
    .center img
    {
        height: 128px;
        width: 128px;
    }
</style>
<!-- Content Wrapper. Contains page content -->
      <div class="content-wrapper">
        <!-- Content Header (Page header) -->
        <section class="content-header">
        <h1>${n.i18n.crud_content_gachno_taiquay}</h1>
        </section>
        <section class="content">
		  <div class="row">
            <div class="col-md-12">                
              <!-- Block buttons -->
              <div class="box box-primary">
              	<div class="box-header with-border">                  
                  	<n:value id="head" service="tai_quay_thong_tin_nguoi_gach_no" serviceType="query" paramSize="1" p1="${pageContext.request.userPrincipal.name}">
                  	Chu kỳ: <small class="label label-success">$list.get(0).CKN</small> - Người gạch: <small class="label label-success">$list.get(0).HOVATEN</small> - Quầy: <small class="label label-danger">$list.get(0).TENQUAY</small> - Bưu cục: <small class="label label-danger">$list.get(0).TENBUUCUC</small>									
                  	</n:value>
                  <div class="box-tools">
                  </div>
                </div><!-- /.box-header -->
                <div class="box-body no-padding">                    
                    <table id="nnts" class='table table-condensed'>
                     <tr id="row6">
                     	<td colspan="4">
						Mẫu số <span data-toggle="tooltip" title="" class="badge bg-blue" id="pattern_no"></span>
                     	- Ký hiệu <span data-toggle="tooltip" title="" class="badge bg-blue" id="inv_no" name="inv_no"></span> 
						- Số hóa đơn <span data-toggle="tooltip" title="" class="badge bg-blue" id="serial_no" name="serial_no"></span> 			
                     	</td>
                     </tr>
                    <tr>
                        <td width="10%" style="font-weight:bold;color:#039" >Mã số thuế*</td>
                        <td width="40%"><input placeholder='Type ${n.i18n.crud_info_mst}'  type="text" class="form-control" name="mst" id="mst" value="" onKeyUp="loadInfo()"></td>
                        <td style="font-weight:bold;color:#039" >Kỳ thuế</td>
                        <td>	
							<div id="data-kythue"></div>
						</td>
                     </tr>
					 <tr>
						<td>Tên NNT</td>
                        <td colspan="3"><input  type="text" class="form-control" name="ten_nnt" id="ten_nnt"></td>
					 </tr>
                     <tr>
                        <td>Loại NNT</td>
                        <td><input  type="text" class="form-control" name="loai_nnt" id="loai_nnt"></td>
                        <td>Số</td>
                        <td><input  type="text" class="form-control" name="so" id="so"></td>
                     </tr>
                     <tr>
                        <td>Chương</td>
                        <td><input  type="text" class="form-control" name="chuong" id="chuong"></td>
                        <td>Cơ quan thu</td>
                        <td><input  type="text" class="form-control" name="ma_cqt_ql" id="ma_cqt_ql"></td>
                     </tr>
                     <tr>
                        <td>Địa chỉ</td>
                        <td colspan="3"><input  type="text" class="form-control" name="mota_diachi" id="mota_diachi"></td>
                     </tr>
                     <tr>
                        <td>Emai/Mobile</td><td><input  type="text" class="form-control" name="email_mobile" id="email_mobile"></td>
                        <td>Nhân viên thu</td><td><input  type="text" class="form-control" name="ma_nv" id="ma_nv"></td>
                     </tr>
                     <tr>
                     	<td>Tổng phải nộp</td><td><span data-toggle="tooltip" title="" class="badge bg-red" id="tong_tien"></span> - ${n.i18n.nnts_da_tra} <span data-toggle="tooltip" title="" class="badge bg-green" id="da_tra_f"></span></td>
                     	<td style="font-weight:bold;color:#C30">Còn phải nộp</td><td><span data-toggle="tooltip" title="" class="badge bg-blue" id="tien_tra">0</span></td>
                     </tr>
                     <tr><td colspan="4" height="8px"></td>
                </table>
                 </div><!-- /.box-body -->
              </div><!-- /.box -->
            </div><!-- /.col -->                                  
          </div><!-- /. row -->
          <div class="row">
          	<div class="col-md-12">
                <div class="box box-primary no-padding">
                	<div class="box-body" id="data-list">
                    </div>
                </div>
            </div>
          </div> 
          <div class="col-md-12" style="text-align:center"><span id="result"></span>
                <button onClick="thanh_toan()" class="btn btn-primary" id="btThanhtoan" ><i class="fa fa-money"></i> Nộp tiền</button>&nbsp;
                <button onClick="print()" class="btn btn-primary" id="btInPhieu" disabled><i class="fa fa-print"></i> In phiếu</button>&nbsp;                
                <button onClick="openWindow('crud_popup.jsp?crud_type=bangphieutra/index.html','phieu_da_gach_no',920,540,'')" class="btn btn-primary"><i class="fa fa-list-ol"></i> Xóa phiếu</button>&nbsp;
				<!--button onClick="InBienNhan()" class="btn btn-primary" id="btInBienNhan" disabled><i class="fa fa-print"></i>View HDDT</button>&nbsp;
                <button onClick="DownloadHDDT()" class="btn btn-primary" id="btDownloadHDDT" ><i class="fa fa-print"></i>Download HDDT</button-->&nbsp;
            </div><!-- /.col -->			
        </section>
      </div><!-- /.content-wrapper -->
	  <div class="modal" style="display: none">
    <div class="center">
        <img alt="" src="style/img/loading.gif" />
    </div>
</div>
    </div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script>
var Objphieu, Inv_no, Serial_no;
	
$("#row6").hide();
$('#mst').on('input', function() { 
	if($(this).val() == ""){
		$("#row6").hide();
	}
});
function CalTra(o){
	$(o).val(fnumber($(o).val()));
	var tien_tra=0;
	$('input[name="tien_tra"]').each(function(){
		tien_tra+=$(this).val().replace(/,/g,"")*1;
	});
	$("#tien_tra").text(fnumber(tien_tra+""));
}
function thanh_toan(){
	var sum_tien=0;
	var text="";

	$("input:checkbox[name='ky_thue_chb']:checked").each(function(){
   		var tien=$(this).parent().parent().children().children("input:text[name='tien_tra']").val().replace(/,/g,"")*1;
		sum_tien = sum_tien + tien;
		var t=$("#f"+$(this).parent().parent().children().children("input:text[name='tien_tra']").attr("id")).val();
		text+=t.replace("{TIEN_TRA}",tien)+"|";
	});
	/*
	$('input[name="tien_tra"]').each(function(){
		var tien=$(this).val().replace(/,/g,"")*1;
		sum_tien = sum_tien + tien;
		
		var t=$("#f"+$(this).attr("id")).val();
		text+=t.replace("{TIEN_TRA}",tien)+"|";
	});*/

	$("#result").text("");	
	if (sum_tien==0){ alert('${n.i18n.crud_confirm_value_money}'); return;}
	
	$("#btThanhtoan").attr('disabled' , true);
	$.ajax({
		url: 'crud_exec.jsp?crud_type=ct_no/thanh_toan_exec.html&mst='+$("#mst").val()+'&ma_tinh=${province}&kythue='+$('#kythue').val()+'&ma_bc=${head.list.get(0).MABC_ID}&quaythu=${head.list.get(0).QUAYTHU_ID}&httt=1&tra='+text.substring(0,text.length-1),
		async: false,
		success: function(data){ 		
			if(data==data*1){
				Objphieu = data*1;
				$("#btInPhieu").attr('disabled' , false);
				$("#btInBienNhan").attr('disabled' , false);	
				$("#btThanhtoan").attr('disabled' , false);
				ReloadInfo($("#mst").val());
				$("#result").text("Gạch nợ thành công, số phiếu "+data*1+"!");
			}else{
				$("#result").text("Gạch nợ lỗi: "+data+"!");
			}
		}
	});
	
}
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
	$('#result').text('Đang lấy dữ liệu ...');
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
			
			$("#pattern_no").text(data.PATTERN);
			$("#serial_no").text(data.SERIAL);
			$("#inv_no").text(data.NUMB_BILL);
			$("#row6").show();
			
			Inv_no = data.NUMB_BILL;
			Serial_no = data.SERIAL;
			
			$("#btInPhieu").attr('disabled' , true);
			$("#btInBienNhan").attr('disabled' , true); 
		}
	});
	$.ajax({
		url: 'crud_exec.jsp?crud_type=ct_no/ajax_kythue_cqthu.html&mst='+$('#mst').val()+'&ma_tinh=${province}&ma_cqt_ql='+$('#ma_cqt_ql').val(),async: false,
		success: function(data){ 
			$('#data-kythue').html(data);
			$("#mst").attr('disabled' , true);
			$('#result').html('');
		}
	});
	
		
	GetInfodept();
	
}
function GetInfodept(){
	$.ajax({
		url: 'crud_exec.jsp?crud_type=ct_no/ajax_index_kythue.html&mst='+$('#mst').val()+'&ma_tinh=${province}&kythue='+$('#kythue').val(),async: false,
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
}

function ReloadInfo(obj){
	$.ajax({
		url: 'crud_exec.jsp?crud_type=nnts/tai_quay_info_exec.html&mst='+obj,async: false,
		success: function(data){ 
			eval('data='+data);			
			$("#da_tra_f").text(data.TIEN_TRA);
		}
	});
	
	$.ajax({
		url: 'crud_exec.jsp?crud_type=ct_no/ajax_index_kythue.html&mst='+$('#mst').val()+'&ma_tinh=${province}&kythue='+$('#kythue').val(),async: false,
		success: function(data){ 
			$('#data-list').html(data);
		}
	});
	
	var tien_tra=0;
	$('input[name="tien_tra"]').each(function(){
		tien_tra+=$(this).val().replace(/,/g,"")*1;
	});
	$("#tien_tra").text(fnumber(tien_tra+""));
}
function print(){	 
	var Pmst = $("#mst").val();
	var Pten = $("#ten_nnt").val();
	var Pdiachi = $("#mota_diachi").val();	
	var jpPath = '${pathroot}' + "WEB-INF/templates/jasper/";	
	var fname;
	var matinh = "${province}";
	
	if(matinh=="01TTT"){
		fname = "receipts";
	}else if (matinh=="79TTT"){
		fname = "receipts_hcm";
	}
	else {
		//alert(matinh);
		fname = "receipts_blu";
	}
	
	s_ = window.location.protocol+"//"+window.location.host
			+"/report/?jasperFile=jasper/"+fname+"&jasperExportType=pdf&AGENT=${province}&IMAGE_PATH="+jpPath+"&MST_NNT="+Pmst+"&TEN_NNT="+Pten+"&DIACHI="+Pdiachi+"&PHIEU_ID="+		Objphieu+"&INVOICE="+Inv_no+"&SERIAL="+Serial_no;
	window.open(s_);
}
function InBienNhan(){
	var isContinue= true ;
	$.ajax({
		url: 'crud_exec.jsp?crud_type=ct_no/check_info_dept_exec.html&mst='+$("#mst").val()+'&kythue='+$('#kythue').val(),
		async: false,
		success: function(data){ 
			if(data==0){
				isContinue = false;
				$("#result").text("Bạn vui lòng thanh toán hết nợ trước khi xem HDDT");	
			}
		}
	});

	if (isContinue) {	
		var obj = new Object();
		obj.username = "vnptthuhoservice";
		obj.pass = "Thuho@2015";
		obj.fkey = $("#mst").val()+$('#kythue').val();
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
function GetInvByCus(){
	var obj = new Object();
	obj.username = "vnptthuhoservice";
	obj.pass = "Thuho@2015";
	obj.key = $("#mst").val()+$('#kythue').val();
	obj.fromDate = "";
	obj.toDate = "";
	$.ajax({
		type:"POST",
		data:obj,
		url: "tai_quay_hoa_don.jsp",
		datatype:'html',
		cache: false,
		success : function(data){
			var obj = eval ("(" + data + ")");
			if(obj.Error[0].ERR == "0" || obj.Error[0].ERR == 0){
				$("#inv_no").text(obj.invoice[0].invNum);
				Inv_no = obj.invoice[0].invNum; 
				$("#serial_no").text(obj.invoice[0].serial);
				Serial_no = obj.invoice[0].serial;
				$("#pattern_no").text(obj.invoice[0].pattern);
				$("#row6").show();
			}else{
				alert(obj.Error[0].Loi);
			}

		},
		error: function (jqXHR, textStatus, errorThrown) {
    		alert(jqXHR.responseText);
		}
	});
}
function DownloadHDDT(){
	var obj = new Object();
	obj.username = "vnptthuhoservice";
	obj.pass = "Thuho@2015";
	obj.key = $("#mst").val()+$('#kythue').val();
	$.ajax({
		type:"POST",
		data:obj,
		url: "tai_quay_download_hddt.jsp",
 		cache: false,
		success : function(data){
			window.open("data:application/pdf," + escape(data)); 
		},
		error: function (jqXHR, textStatus, errorThrown) {
    		alert("err "+jqXHR.responseText);
		}
	});
}
$.ajaxSetup({
	beforeSend: function () {
	   $(".modal").show();
	},
	complete: function () {
		$(".modal").hide();
	}
});

</script>