<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*,oracle.sql.*,neo.velocity.common.*,java.sql.*,neo.gate.util.mis.Base64,oracle.jdbc.OracleTypes,java.text.*,java.nio.*, java.util.Date, org.apache.commons.net.ftp.FTP, org.apache.commons.net.ftp.FTPClient, java.sql.ResultSetMetaData, java.util.zip.ZipEntry, java.util.zip.ZipInputStream, java.util.zip.ZipOutputStream, java.io.FileOutputStream, java.io.FileInputStream, com.svcon.jdbf.*" %>
<jsp:useBean id="n" class="neo.velocity.common.NeoContext" scope="application"/>
<%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>${n.i18n.app_title}</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <link href="/assets/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="/assets/bootstrap/lte/css/AdminLTE.min.css" rel="stylesheet" type="text/css" />
    <link href="/assets/bootstrap/lte/css/skins/skin-blue-light.min.css" rel="stylesheet" type="text/css" />
    <link href="/assets/bootstrap/plugins/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
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
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->	
	<link rel="stylesheet" href="/assets/bootstrap/plugins/icomoon/style.css"></head>
	<script src="/assets/bootstrap/plugins/jQuery/jQuery-2.1.4.min.js"></script>
    <script src="/assets/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
	<script src="/assets/bootstrap/plugins/chartjs/Chart.min.js" type="text/javascript"></script>
  </head>
  <body>
    <div class="layout-boxed">
	<section class="content">
	<!-- Content Header (Page header) -->	        
		<div class="row">
			<div class="col-md-12">
				<!-- Custom Tabs -->
				<div class="box box-primary">   
				<div class="box-header with-border">
                  <h3 class="box-title">${n.i18n.crud_info_ls_no_tra}</h3>
                  <div class="box-tools">
                  </div>
                </div><!-- /.box-header -->
				<div class="box-body no-padding">	
					
					<table class="table table-striped">
					<tbody>
						<tr>
							<td width="10%" style="font-weight:bold;color:#039">${n.i18n.crud_info_mst}*</td>
							<td><input  type="text" class="form-control" name="mst" id="mst" value="0102604201" onKeyUp="loadInfo()"></td>
							<td>${n.i18n.crud_info_ten}</td>
							<td><input  type="text" class="form-control" name="ten_nnt" id="ten_nnt"  ></td>
						 </tr>									 									 
						 <tr>
							<td>${n.i18n.crud_info_diachi}</td>
							<td colspan="3"><input  type="text" class="form-control" name="mota_diachi" id="mota_diachi"  ></td>
						 </tr>									 
					</tbody></table>														
					<div id="data-list"></div>	
					<div id="data-list2"></div>
 
				</div><!-- /.box-body -->	
				<!--
				<div class="box-footer text-center">
					<button onClick="InBienNhan()" class="btn btn-primary" id="btInBienNhan" disabled><i class="fa fa-print"></i>View HDDT</button>
				</div>box-footer -->									
				</div>
            </div>						
		</div><!-- /. row -->  
<!-- 		<div class="col-md-12" style="text-align:center">
		<div><button onClick="InBienNhan()" class="btn btn-primary" id="btInBienNhan" disabled><i class="fa fa-print"></i>View HDDT</button>&nbsp;</div>
		</div> -->
		<div class="modal" style="display: none">
		    <div class="center">
		        <img alt="" src="style/img/loading.gif" />
		    </div>
		</div>
	</section>
</div><!-- ./wrapper -->

    <!-- jQuery 2.1.4 -->
    <script src="/assets/bootstrap/plugins/jQuery/jQuery-2.1.4.min.js"></script>
    <!-- Bootstrap 3.3.2 JS -->
    <script src="/assets/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
    <!-- iCheck -->
    <script src="/assets/bootstrap/plugins/iCheck/icheck.min.js" type="text/javascript"></script>
<script>
var ma_tinh = "";
function loadInfo(){
	if(event.keyCode != 13){
        return;
    }
	$("#ten_nnt").val("");	
	$("#mota_diachi").val("");
	if ($("#mst").val()==""){
		document.getElementById('data-list').style.display = 'none';
		document.getElementById('data-list2').style.display = 'none';
		$("#ten_nnt").val("");	
		$("#mota_diachi").val("");
		alert("Yêu cầu nhập thông tin MST tra cứu");
		return;
	}else{
		document.getElementById('data-list').style.display = 'inline';
		document.getElementById('data-list2').style.display = 'inline';
	}

	var obj = new Object();
	obj.mst = $('#mst').val();
	obj.ma_tinh = "";
	
	$.ajax({
		data:obj,
		type:'POST',
		cache: false,
		url: 'view_bldt/ajax_nnts_info.jsp',async: false,
		success: function(data){
			eval('data='+data);
			$("#ten_nnt").val(data.TEN_NNT);
			$("#mota_diachi").val(data.MOTA_DIACHI);
			obj.ma_tinh =(data.MA_TINH);
			ma_tinh = (data.MA_TINH);
		}, error:function() {
                alert("Error");
        }
	});


	
	$.ajax({
		type:"POST",
		data:obj,
 		datatype:'html',
 		url: 'view_bldt/ajax_index_no.jsp',async: false,
		success: function(data){ 
			$('#data-list').html(data);
		}, error:function() {
                alert("Error");
            }
	});

	$.ajax({
		type:"POST",
		data:obj,
 		datatype:'html',
		cache: false,
		url: 'view_bldt/ajax_index_tra.jsp',
		success: function(data){ 
			$('#data-list2').html(data);
		}
	});
	
	$("#btInBienNhan").attr('disabled' , false);
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
  </body>
</html>
