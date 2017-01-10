<%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:setProperty name="n" property="language" value="${not empty param.language ? param.language : 'vi_VN'}"/>
<jsp:useBean id="n" class="neo.velocity.common.NeoContext" scope="application"/>
<%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>

<% 	
	String useridUNT =request.getUserPrincipal().getName();	
	String useripUNT =request.getRemoteAddr();
	session.setAttribute("useridUNT",useridUNT);
	request.setAttribute("useripUNT",useripUNT);
%>

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
                  <h3 class="box-title">${n.i18n.curd_report_ban_ke_unc}</h3>
                  <div class="box-tools">
                  </div>
                </div><!-- /.box-header -->
                <div class="box-body no-padding">
                    
                    <table id="nnts" class='table table-condensed'>
                    <tr>
                        <td width="20%">${n.i18n.curd_report_ngay_tt}</td>
                        <td width="25%"><input  type="text" class="form-control" name="ngay_tt" id="ngay_tt"></td>
                        <td>${n.i18n.curd_report_kho_bac}</td>
                        <td>							
                        	<select class="form-control" name="kho_bac" id="kho_bac" onChange="selectTown()">															
                                <n:option service="danh_sach_kho_bac" serviceType="query" paramSize="1" p1="${province}"/>
                            </select>
 
                        </td>
                     </tr>
					 
					<tr>
						<td title="Loại thuế">Nhân viên thu</td>
						<td>
							<div id="nhanvien_tt"></div>
						</td>
						<td title="Loại thuế">Nộp NSNN</td>
						<td>
							<select class="form-control" name="nsnn_id" id="nsnn_id">
								<option value="1">Kho bạc</option>
								<option value="2">Ngân hàng</option>
							</select>
						</td>
					</tr>					
                </table>
                 </div><!-- /.box-body -->
              </div><!-- /.box -->
            </div><!-- /.col -->   
            <div class="col-md-12" align="center"><span id="result"></span>			
                <button onClick="ds_uynhiem()" class="btn btn-primary" id="btDSKB"><i class="fa fa-search"></i> Danh sách nộp thuế - kho bạc</button>&nbsp;
                			
				<div class="btn-group">											
					<button id="btnPrintBK" type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" aria-expanded="false"><i class="fa fa-print"></i> In bản kê <span class="fa fa-caret-down"></span></button>
					<ul class="dropdown-menu">
						<li><a href="javascript:banke_phuongxa()">In bản kê</a></li>
						<!--li class="divider"></li>
						<li><a href="javascript:banke_th()">In bản kê chi tiết </a></li>
						<li class="divider"></li>
						<li><a href="javascript:banke_th_xls()">In bản kê chi tiết - excel</a></li-->						
						
					</ul>
                </div>   
				
				<!--div class="btn-group">											
					<button id="btnPrint" disabled type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" aria-expanded="false"><i class="fa fa-print"></i> In Ủy nhiệm chi <span class="fa fa-caret-down"></span></button>
					<ul class="dropdown-menu">
						<li><a href="javascript:print_unc()">In bản kê</a></li>					
						<li class="divider"></li>
						<li><a href="javascript:print_unc_deatail()">In phụ lục</a></li>
						<li class="divider"></li>
						<li><a href="javascript:print_unc_deatail_excel()">In phụ lục - excel</a></li>	
						<li class="divider"></li>
						<li><a href="javascript:print_unc_all_excel()">In phụ lục tổng hợp - excel</a></li>	
					</ul>
                </div-->   
                <button id="btnUNT" onClick="ban_ke_UNT()" class="btn btn-primary" data-toggle="modal" data-target="#ban_ke_UNT_modal"><i class="fa fa-search"></i> GIP - Bản kê UNT</button>&nbsp;
                <p style="height:11px"></p>
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
          	<div class="modal fade" id="ban_ke_UNT_modal" role="dialog" tabindex="-1" >
				<div class="modal-dialog modal-lg">
					<div class="modal-content">
						<div class = "modal-header">
							<button type = "button" class = "close" data-dismiss = "modal" aria-hidden = "true">
							   ×
							</button>
							<h4 class = "modal-title">
							   Bản kê UNT
							</h4>
						</div>
						
						<div class="modal-body">
							<form class="form-horizontal" role="form">
								<div class="form-group">
									<label  class="col-sm-3 control-label" for="modal_ngay_tt">Ngày thanh toán</label>
									<div class="col-sm-9">
										<input type="text" class="form-control" id="modal_ngay_tt" disabled placeholder="Ngày thanh toán"/>
									</div>
								</div>
								<div class="form-group">
									<label class="col-sm-3 control-label" for="modal_kho_bac" >Kho bạc</label>
									<div class="col-sm-9">
										<select class="form-control" name="modal_kho_bac" id="modal_kho_bac" disabled>								
											<n:option service="danh_sach_kho_bac" serviceType="query" paramSize="1" p1="${province}"/>
										</select>							
									</div>

								</div>
								<div class="form-group">
									<label class="col-sm-3 control-label" for="modal_nv">Nhân viên</label>
									<div class="col-sm-9">
										<select class="form-control" name="modal_nv" id="modal_nv" disabled>								
											<n:option service="crud_report_info_staff" serviceType="query" paramSize="1" p1="${province}"/>
										</select>								
									</div>
								</div>
								
							
								
								<div class="form-group">
									<label class="col-sm-3 control-label" for="modal_so_chung_tu_kb">Số chứng từ kho bạc</label>
									<div class="col-sm-9">
										<input type="text" class="form-control" id="modal_so_chung_tu_kb" placeholder="Số chứng từ kho bạc"/>
									</div>
								</div>
								<div class="form-group">
									<label class="col-sm-3 control-label" for="modal_ngay_chung_tu_kb">Ngày chứng từ kho bạc</label>
									<div class="col-sm-9">
										<input type="text" class="form-control" id="modal_ngay_chung_tu_kb" placeholder="Ngày chứng từ kho bạc"/>
									</div>
								</div>
								<div class="form-group">
									<label class="col-sm-3 control-label" for="modal_ky_hieu">Ký hiệu ngân hàng</label>
									<div class="col-sm-9">
										<input type="text" class="form-control" id="modal_ky_hieu" placeholder="Ký hiệu chứng từ ngân hàng"/>
									</div>
								</div>
								<div class="form-group">
									<label class="col-sm-3 control-label" for="modal_so_chung_tu_nh">Số chứng từ ngân hàng</label>
									<div class="col-sm-9">
										<input type="text" class="form-control" id="modal_so_chung_tu_nh" placeholder="Số chứng từ ngân hàng"/>
									</div>
								</div>
								<div class="form-group">
									<label class="col-sm-3 control-label" for="modal_ngay_chung_tu_nh">Ngày chứng từ ngân hàng</label>
									<div class="col-sm-9">
										<input type="text" class="form-control" id="modal_ngay_chung_tu_nh" placeholder="Ngày chứng từ ngân hàng"/>
									</div>
								</div>
								<div class="form-group">
									<label class="col-sm-3 control-label" for="modal_tien_nop">Số tiền nộp kho bạc</label>
									<div class="col-sm-9">
										<input type="text" class="form-control" id="modal_tien_nop" placeholder="Số tiền nộp kho bạc"/>
									</div>
								</div>	
								<!--<div class="form-group">
									<div class="col-sm-offset-2 col-sm-10">
										<button type="submit" class="btn btn-default">Sign in</button>
									</div>
								</div> -->
							</form>
						</div>
 						<div class = "modal-footer">
							<span id="result1"></span>&nbsp;&nbsp;&nbsp;
							<button type ="button" class = "btn btn-primary" onClick="new_UNT()" id="btn_new_UNT">Tạo dữ liệu UNT</button>
							<button type ="button" class = "btn btn-primary" onClick="send_UNT()" disabled="true" id="btn_send_UNT">Gửi dữ liệu UNT</button>
						</div>
 					</div>
				</div>
			</div>
        </section>
      </div><!-- /.content-wrapper -->
    </div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script>
$('#ngay_tt').datepicker({format:"dd/mm/yyyy"});
$('#modal_ngay_tt').datepicker({format:"dd/mm/yyyy"});
$('#modal_ngay_chung_tu_kb').datepicker({format:"dd/mm/yyyy"});
$('#modal_ngay_chung_tu_nh').datepicker({format:"dd/mm/yyyy"});

$("#ngay_tt").datepicker().datepicker("setDate", new Date());
$("#modal_ngay_tt").datepicker().datepicker("setDate", new Date());
var SEQ = "";
var loaithue;

function selectTown(){
	if ($("#kho_bac").val()==""){
		$("#nhanvien_tt").html("");
		return;
	}
	$.ajax({
		url: 'crud_exec.jsp?crud_type=nnts/ajax_staff_by_district_id.html&ma_tinh=${province}&kho_bac='+$("#kho_bac").val(),
		success: function(data){ 
			$("#nhanvien_tt").html(data);
		}
	});
}
function ds_uynhiem(){

	$("#data-list").html("Đang lấy dữ liệu ...");
	$.ajax({
		url: 'crud_exec.jsp?crud_type=ct_no/ajax_uynhiem_nv.html&kho_bac='+$("#kho_bac").val()+'&ma_tinh=${province}&ngay_tt='+$("#ngay_tt").val()+'&phuong='+$("#ma_xa").val(),
		async: false,
		success: function(data){ 
			$("#data-list").html(data);
		}
	});
}

function banke_phuongxa(){
	var ngaytt = $("#ngay_tt").val();
	var ma_khobac =  $("#kho_bac").val();
	var ten_khobac =  $("#kho_bac option:selected").text();
	var phuong = "";
	loaithue= $("#loaithue_id").val();
	
	var jpFile;
	var jpPath = '${pathroot}' + "WEB-INF/templates/jasper/";
	s_ = window.location.protocol+"//"+window.location.host
		+"/report/?jasperFile=jasper/payment_order_detail_towns_blu&jasperExportType=pdf&AGENT=${province}&IMAGE_PATH="+jpPath+"&NGAY_TT="+ngaytt+"&KHO_BAC="+ten_khobac+"&MA_KHOBAC="+ma_khobac+"&PHUONG="+phuong+"&LOAITHUE="+loaithue;
	window.open(s_);
}



function ban_ke_UNT(){	
	$("#modal_ngay_tt").val($('#ngay_tt').val());
	$("#modal_kho_bac").val($('#kho_bac').val());
	$("#modal_tieumuc").val($("#loaithue_id option:selected").text());
	
	if ($("#nsnn_id").val()=="1"){		
		$("#modal_so_chung_tu_kb,#modal_ngay_chung_tu_kb").attr('disabled',false);
		$("#modal_ky_hieu,#modal_so_chung_tu_nh,#modal_ngay_chung_tu_nh").attr('disabled',true);
		$("#modal_ngay_chung_tu_kb").datepicker().datepicker("setDate", new Date());
		$("#modal_ngay_chung_tu_nh").datepicker().datepicker("setDate", "");
		$("#modal_ky_hieu,#modal_so_chung_tu_nh,#modal_ngay_chung_tu_nh").val("");	
	}else{
		$("#modal_so_chung_tu_kb,#modal_ngay_chung_tu_kb").attr('disabled',true);
		$("#modal_ky_hieu,#modal_so_chung_tu_nh,#modal_ngay_chung_tu_nh").attr('disabled',false);		
		$("#modal_ngay_chung_tu_nh").datepicker().datepicker("setDate", new Date());
		$("#modal_ngay_chung_tu_kb").datepicker().datepicker("setDate", "");
		$("#modal_so_chung_tu_kb,#modal_ngay_chung_tu_kb").val("");		
	}
		
	
	$("#modal_nv").val($("#ma_xa").val());
		
	
}
function new_UNT(){
	var sum_dept;
	$('#result1').html('${n.i18n.crud_process_message}');
	loaithue= $("#loaithue_id").val();
	$.ajax({
		url: 'crud_exec.jsp?crud_type=ct_no/check_sum_dept_exec_blu.html&kho_bac='+$("#kho_bac").val()+'&ma_tinh=${province}&ngay_tt='+$("#ngay_tt").val()+'&ma_nv='+$("#ma_xa").val(),
		async: false,
		success: function(data){ 			
			sum_dept = data*1;
		}
	});	
	
	if ($("#nsnn_id").val()=="1"){
		if (($("#modal_so_chung_tu_kb").val().length ==0)||($("#modal_so_chung_tu_kb").val().trim() == "")){
			alert("Yêu cầu xác lập các thông tin số chứng từ kho bạc !");
			$('#result1').html('');
			return;
		}
		
		if (($("#modal_ngay_chung_tu_kb").val().length ==0)||($("#modal_ngay_chung_tu_kb").val().trim() == "")){
			alert("Yêu cầu xác lập các thông tin ngày chứng từ kho bạc !");
			$('#result1').html('');
			return;
		}
	}else{
		if (($("#modal_ky_hieu").val().length ==0)||($("#modal_ky_hieu").val().trim() == "")){
			alert("Yêu cầu xác lập các thông tin ký hiệu ngân hàng !");
			$('#result1').html('');
			return;
		}
		
		if (($("#modal_so_chung_tu_nh").val().length ==0)||($("#modal_so_chung_tu_nh").val().trim() == "")){
			alert("Yêu cầu xác lập các thông tin số chứng từ ngân hàng !");
			$('#result1').html('');
			return;
		}
		
		if (($("#modal_ngay_chung_tu_nh").val().length ==0)||($("#modal_ngay_chung_tu_nh").val().trim() == "")){
			alert("Yêu cầu xác lập các thông tin ngày chứng từ ngân hàng !");
			$('#result1').html('');
			return;
		}
	}
		
	
	var obj = new Object();
	obj.ma_tinh = "${province}";
	obj.ngay = $("#modal_ngay_tt").val();
	obj.kho_bac = $("#modal_kho_bac").val();
	obj.so_chung_tu_kb =  $("#modal_so_chung_tu_kb").val();
	obj.ngay_chung_tu_kb = $("#modal_ngay_chung_tu_kb").val();
	obj.ky_hieu = $("#modal_ky_hieu").val();
	obj.so_chung_tu_nh = $("#modal_so_chung_tu_nh").val();
	obj.ngay_chung_tu_nh = $("#modal_ngay_chung_tu_nh").val();
 	obj.tien_nop = $("#modal_tien_nop").val();
  	obj.tong_tien = sum_dept;
 	obj.user_ip = "${useripUNT}";
 	obj.user_id = "${useridUNT}";
	obj.ma_nv = $("#ma_xa").val();
	obj.loaithue = "";
 	$.ajax({
		type:"POST",
		data:obj,
		url: "ban_ke_uynhiem_chi_blu/ajax_new_unt.jsp",
		datatype:'html',
		cache: false,
		success : function(data){
			eval("data="+data);
						
			if(data.SEQ*1==-1001){
				alert("Bản kê UNT đã thực hiện, yêu cầu kiểm tra lại bảng kê UNT !");
				$('#result1').html('');
				return;
			}
			
			alert(data.TEXT);
			if(SEQ = data.SEQ*1)
			$("#btn_send_UNT").attr('disabled',false);
			$('#result1').html('');
		},
		error: function (jqXHR, textStatus, errorThrown) {
    		alert(jqXHR.responseText);
			$('#result1').html('');
		}
	});

}
function send_UNT(){
	$('#result1').html('${n.i18n.crud_process_message}');
	
	if ($("#nsnn_id").val()=="1"){
		if (($("#modal_so_chung_tu_kb").val().length ==0)||($("#modal_so_chung_tu_kb").val().trim() == "")){
			alert("Yêu cầu xác lập các thông tin số chứng từ kho bạc !");
			$('#result1').html('');
			return;
		}
		
		if (($("#modal_ngay_chung_tu_kb").val().length ==0)||($("#modal_ngay_chung_tu_kb").val().trim() == "")){
			alert("Yêu cầu xác lập các thông tin ngày chứng từ kho bạc !");
			$('#result1').html('');
			return;
		}
	}else{
		if (($("#modal_ky_hieu").val().length ==0)||($("#modal_ky_hieu").val().trim() == "")){
			alert("Yêu cầu xác lập các thông tin ký hiệu ngân hàng !");
			$('#result1').html('');
			return;
		}
		
		if (($("#modal_so_chung_tu_nh").val().length ==0)||($("#modal_so_chung_tu_nh").val().trim() == "")){
			alert("Yêu cầu xác lập các thông tin số chứng từ ngân hàng !");
			$('#result1').html('');
			return;
		}
		
		if (($("#modal_ngay_chung_tu_nh").val().length ==0)||($("#modal_ngay_chung_tu_nh").val().trim() == "")){
			alert("Yêu cầu xác lập các thông tin ngày chứng từ ngân hàng !");
			$('#result1').html('');
			return;
		}
	}
	
	var obj = new Object();
	obj.ma_tinh = "${province}";
	obj.ngay = $("#modal_ngay_tt").val();
	obj.kho_bac = $("#modal_kho_bac").val();
	obj.ma_nv = $("#ma_xa").val();
	obj.loaithue = "";
	obj.so_chung_tu_kb =  $("#modal_so_chung_tu_kb").val();
	obj.ngay_chung_tu_kb = $("#modal_ngay_chung_tu_kb").val();
	obj.ky_hieu = $("#modal_ky_hieu").val();
	obj.so_chung_tu_nh = $("#modal_so_chung_tu_nh").val();
	obj.ngay_chung_tu_nh = $("#modal_ngay_chung_tu_nh").val();
 	obj.tien_nop = $("#modal_tien_nop").val();
 	obj.seq = SEQ;
 	$("#btn_send_UNT").attr('disabled',true);
   	$.ajax({
		type:"POST",
		data:obj,
		url: "ban_ke_uynhiem_chi_blu/ajax_send_unt.jsp",
		datatype:'html',
		cache: false,
		success : function(data){	
			alert(data);
			$("#btn_send_UNT").attr('disabled',true);
			$('#result1').html('');
		},
		error: function (jqXHR, textStatus, errorThrown) {
    		alert(jqXHR.responseText);
			$('#result1').html('');
		}
	});
}
</script>