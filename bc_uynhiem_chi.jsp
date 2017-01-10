<%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:setProperty name="n" property="language" value="${not empty param.language ? param.language : 'vi_VN'}"/>
<jsp:useBean id="n" class="neo.velocity.common.NeoContext" scope="application"/>
<%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>


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
                  <h3 class="box-title">Báo cáo bản kê ủy nhiệm chi</h3>
                  <div class="box-tools">
                  </div>
                </div><!-- /.box-header -->
                <div class="box-body no-padding">
                    
                    <table id="nnts" class='table table-condensed'>
                    <tr>
                        <td width="20%">Từ ngày</td>
                        <td width="25%"><input  type="text" class="form-control" name="ngay_tt1" id="ngay_tt1"></td>
                        <td>Đến ngày</td>
                        <td><input  type="text" class="form-control" name="ngay_tt2" id="ngay_tt2">                        	
                        </td>
                     </tr>
					 <tr>
						<td>${n.i18n.curd_report_kho_bac}</td>
                        <td colspan="3">							
                        	<select class="form-control" name="kho_bac" id="kho_bac">															
                                <n:option service="danh_sach_kho_bac" serviceType="query" paramSize="1" p1="${province}"/>
                            </select>
 
                        </td>
					</tr>					
                </table>
                 </div><!-- /.box-body -->
              </div><!-- /.box -->
            </div><!-- /.col -->   
            <div class="col-md-12" style="text-align:center"><span id="result"></span>			
				<div class="btn-group">											
					<button onclick="print_unc_deatail()" class="btn btn-primary btn-sm"><i class="fa fa-print"></i> ${n.i18n.curd_report_print}</button>&nbsp;&nbsp;&nbsp;
					<input type="radio" id="pdf" name="loaibc" value="1" checked> PDF&nbsp;&nbsp;&nbsp;
						<input type="radio" id="excel" name="loaibc" value="2"> EXCEL
				</div>   				
				<p style="height:11px"></p>
			</div><!-- /.col -->              
          </div><!-- /. row -->
        </section>
      </div><!-- /.content-wrapper -->
    </div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script>
$('#ngay_tt1,#ngay_tt2').datepicker({format:"dd/mm/yyyy"});
$("#ngay_tt1,#ngay_tt2").datepicker().datepicker("setDate", new Date());

function print_unc_deatail(){
	var tungay = $("#ngay_tt1").val();
	var dengay = $("#ngay_tt2").val();
	var ma_khobac =  $("#kho_bac").val();
	var ten_khobac =  $("#kho_bac option:selected").text();	
	
	var jpFile;	
	var jpPath = "E:/tax/Server/webapps/ROOT/WEB-INF/templates/jasper/";
	
	if ($("#pdf").is(":checked")) {
		s_ = window.location.protocol+"//"+window.location.host
		+"/report/?jasperFile=jasper/payment_unc_towns&jasperExportType=pdf&AGENT=${province}&IMAGE_PATH="+jpPath+"&TUNGAY="+tungay+"&DENNGAY="+dengay+"&KHO_BAC="+ten_khobac+"&MA_KHOBAC="+ma_khobac;
	}else{
		s_ = window.location.protocol+"//"+window.location.host
		+"/report/?jasperFile=jasper/payment_unc_towns_xls&jasperExportType=xls&AGENT=${province}&IMAGE_PATH="+jpPath+"&TUNGAY="+tungay+"&DENNGAY="+dengay+"&KHO_BAC="+ten_khobac+"&MA_KHOBAC="+ma_khobac;
	}
	window.open(s_);
}
</script>