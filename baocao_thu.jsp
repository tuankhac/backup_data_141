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
                  <h3 class="box-title">${n.i18n.crud_lable_report_dept}</h3>
                  <div class="box-tools">
                  </div>
                </div><!-- /.box-header -->
                <div class="box-body no-padding">
                    
                    <table id="nnts" class='table table-condensed'>
                    <tr>
                        <td width="15%">${n.i18n.curd_report_start_date}</td>
                        <td><input  type="text" class="form-control" name="tungay" id="tungay"></td>     
						<td width="20%">${n.i18n.curd_report_end_date}</td>
                        <td><input  type="text" class="form-control" name="denngay" id="denngay"></td>      
                     </tr>
					 <tr>
                        <td width="10%" title="${n.i18n.crud_valid_length_prefix} 100 ${n.i18n.crud_valid_length_postfix}" id="ma_nv_label">${n.i18n.nnts_ma_nv}</td>
                        <td><input  type="text" class="form-control" name="ma_nv" id="ma_nv"><span id="ma_nv_msg"></span></td>
					 </tr>
                </table>
                 </div><!-- /.box-body -->
              </div><!-- /.box -->
            </div><!-- /.col -->   
            <div class="col-md-12" style="text-align:center"><span id="result"></span>			
				<div class="btn-group">											
					<button id="btnPrint1" type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" aria-expanded="false"><i class="fa fa-print"></i> Báo cáo tổng hợp <span class="fa fa-caret-down"></span></button>
					<ul class="dropdown-menu">
						<li><a href="javascript:print()">PDF</a></li>				
						<li class="divider"></li>
						<li><a href="javascript:print_excel()">EXCEL</a></li>
					</ul>
                </div>   
                <div class="btn-group">											
					<button id="btnPrint2" type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" aria-expanded="false"><i class="fa fa-print"></i> Báo cáo chi tiết <span class="fa fa-caret-down"></span></button>
					<ul class="dropdown-menu">
						<li><a href="javascript:print_detail()">PDF</a></li>				
						<li class="divider"></li>
						<li><a href="javascript:print_detail_excel()">EXCEL</a></li>
					</ul>
                </div>
				<div class="btn-group">											
					<button id="btnPrint2" type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" aria-expanded="false"><i class="fa fa-print"></i> Báo cáo chi tiết chưa thu<span class="fa fa-caret-down"></span></button>
					<ul class="dropdown-menu">
						<li><a href="javascript:print_no_detail()">PDF</a></li>				
						<li class="divider"></li>
						<li><a href="javascript:print_no_detail_excel()">EXCEL</a></li>
					</ul>
                </div>
                <p style="height:11px"></p>
            </div><!-- /.col -->            
          </div><!-- /. row -->
          
        </section>
      </div><!-- /.content-wrapper -->
    </div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script>
$('#tungay').datepicker({format:"dd/mm/yyyy"});
$('#denngay').datepicker({format:"dd/mm/yyyy"});

$("#tungay").datepicker().datepicker("setDate", new Date());
$("#denngay").datepicker().datepicker("setDate", new Date());

var ma_nv="";
var tasks = {
	<n:value service="danh_sach_nv_tc_theo_tinh" serviceType="query" paramSize="1" p1="${province}">
	#set ($k = 0 )
	#foreach ($i in $list )
		#if ($k!=0),#end"$!i['ID']":"$!i['NAME']"
		#set ($k=$k+1)
	#end
	</n:value>
};
var tasksArray = $.map(tasks, function (value, key) { return { value: value, data: key }; });
$('#ma_nv').autocomplete({
	lookup: tasksArray,
	onSelect: function (suggestion) {
		$('#data-list').html('${n.i18n.crud_process_message}');
		ma_nv = suggestion.data;		
	}
});

function print(){

	var tungay = $("#tungay").val();
	var denngay = $("#denngay").val();

	var jpFile;
	var jpPath = "E:/tax/Server/webapps/ROOT/WEB-INF/templates/jasper/";
	s_ = window.location.protocol+"//"+window.location.host
		+"/report/?jasperFile=jasper/report_dept_staff&jasperExportType=pdf&AGENT=${province}&IMAGE_PATH="+jpPath+"&TUNGAY="+tungay+"&DENNGAY="+denngay+"&MA_NV="+ma_nv;	
	window.open(s_);
}

function print_excel(){
	
	var tungay = $("#tungay").val();
	var denngay = $("#denngay").val();

	var jpFile;
	var jpPath = "E:/tax/Server/webapps/ROOT/WEB-INF/templates/jasper/";
	s_ = window.location.protocol+"//"+window.location.host
		+"/report/?jasperFile=jasper/report_dept_staff&jasperExportType=xls&AGENT=${province}&IMAGE_PATH="+jpPath+"&TUNGAY="+tungay+"&DENNGAY="+denngay+"&MA_NV="+ma_nv;	
	window.open(s_);
}

function print_detail(){
	
	var tungay = $("#tungay").val();
	var denngay = $("#denngay").val();

	var jpFile;
	var jpPath = "E:/tax/Server/webapps/ROOT/WEB-INF/templates/jasper/";
	s_ = window.location.protocol+"//"+window.location.host
		+"/report/?jasperFile=jasper/report_dept_staff_detail&jasperExportType=pdf&AGENT=${province}&IMAGE_PATH="+jpPath+"&TUNGAY="+tungay+"&DENNGAY="+denngay+"&MA_NV="+ma_nv;	
	window.open(s_);
}

function print_detail_excel(){
	
	var tungay = $("#tungay").val();
	var denngay = $("#denngay").val();

	var jpFile;
	var jpPath = "E:/tax/Server/webapps/ROOT/WEB-INF/templates/jasper/";
	s_ = window.location.protocol+"//"+window.location.host
		+"/report/?jasperFile=jasper/report_dept_staff_detail&jasperExportType=xls&AGENT=${province}&IMAGE_PATH="+jpPath+"&TUNGAY="+tungay+"&DENNGAY="+denngay+"&MA_NV="+ma_nv;	
	window.open(s_);
}

function print_no_detail(){
	
	var tungay = $("#tungay").val();
	var denngay = $("#denngay").val();

	var jpFile;
	var jpPath = "E:/tax/Server/webapps/ROOT/WEB-INF/templates/jasper/";
	s_ = window.location.protocol+"//"+window.location.host
		+"/report/?jasperFile=jasper/report_dept_staff_no_detail&jasperExportType=pdf&AGENT=${province}&IMAGE_PATH="+jpPath+"&TUNGAY="+tungay+"&DENNGAY="+denngay+"&MA_NV="+ma_nv;	
	window.open(s_);
}

function print_no_detail_excel(){
	
	var tungay = $("#tungay").val();
	var denngay = $("#denngay").val();

	var jpFile;
	var jpPath = "E:/tax/Server/webapps/ROOT/WEB-INF/templates/jasper/";
	s_ = window.location.protocol+"//"+window.location.host
		+"/report/?jasperFile=jasper/report_dept_staff_no_detail&jasperExportType=xls&AGENT=${province}&IMAGE_PATH="+jpPath+"&TUNGAY="+tungay+"&DENNGAY="+denngay+"&MA_NV="+ma_nv;	
	window.open(s_);
}
</script>