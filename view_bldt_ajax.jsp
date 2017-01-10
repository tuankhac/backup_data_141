<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*,oracle.sql.*,neo.velocity.common.*,java.sql.*,neo.gate.util.mis.Base64,oracle.jdbc.OracleTypes,java.text.*,java.nio.*, java.util.Date, org.apache.commons.net.ftp.FTP, org.apache.commons.net.ftp.FTPClient, java.sql.ResultSetMetaData, java.util.zip.ZipEntry, java.util.zip.ZipInputStream, java.util.zip.ZipOutputStream, java.io.FileOutputStream, java.io.FileInputStream, com.svcon.jdbf.*" %>
<jsp:useBean id="n" class="neo.velocity.common.NeoContext" scope="application"/>

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
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
	
	<link rel="stylesheet" href="/assets/bootstrap/plugins/icomoon/style.css"></head>
	
	<script src="/assets/bootstrap/plugins/jQuery/jQuery-2.1.4.min.js"></script>
    <script src="/assets/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
	<script src="/assets/bootstrap/plugins/chartjs/Chart.min.js" type="text/javascript"></script>
  </head>
  <body class="login-page">
    <div class="content-wrapper">
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
							<td><input  type="text" class="form-control" name="mst" id="mst" value="" onKeyUp="loadInfo()"></td>
							<td>${n.i18n.crud_info_ten}</td>
							<td><input  type="text" class="form-control" name="ten_nnt" id="ten_nnt"></td>
						 </tr>									 									 
						 <tr>
							<td>${n.i18n.crud_info_diachi}</td>
							<td colspan="3"><input  type="text" class="form-control" name="mota_diachi" id="mota_diachi"></td>
						 </tr>									 
					</tbody></table>														
					<div id="data-list"></div>	
					<div id="data-list2"></div>
					<%
						
						Utility u = new Utility();
						Connection conn = null;
						ResultSet rs = null;
						try{
							conn = u.getConnection("crud");
							CallableStatement cstm=conn.prepareCall("begin ?:=crud.search_info_bill_his(?,?); end;");
							cstm.registerOutParameter(1, OracleTypes.CURSOR);
							cstm.setString(2, "0100133878");
							cstm.setString(3, "");
							cstm.execute();
							rs = (ResultSet) cstm.getObject(1);
							out.print("<div class='row'> <div class='col-sm-12 table-responsive'> <table class='table table-striped'> <thead> <tr><th colspan='5' style='font-weight:bold;color:#039'><b>");%>${n.i18n.crud_info_ls_tra.toUpperCase()}<%out.print("</b></th></tr> <tr> <th>");%>${n.i18n.print_phieu}<%out.print("</th> <th>");%>${n.i18n.print_tien_tra}<%out.print("</th> <th>");%>${n.i18n.print_chuong}<%out.print("</th> <th>");%>${n.i18n.print_muc}<%out.print("</th> <th>");%>${n.i18n.print_ngay_tra}<%out.print("</th> </tr> </thead> <tbody> ");
							while(rs.next()){
								out.print("<tr><td align=left name='sophieu'>"); %>
								<%=rs.getString("PHIEU_ID")!=null ? rs.getString("PHIEU_ID") : ""%>
								<%out.print("</td>");
								out.print("<td align=left name='da_tra'>"); %>
								<%=rs.getString("TIENTRA")!=null ? rs.getString("TIENTRA") : ""%>
								<%out.print("</td>");

								out.print("<td align=left name='ma_chuong'>"); %>
								<%=rs.getString("TEN_CHUONG")!=null ? rs.getString("TEN_CHUONG") : ""%>
								<%out.print("</td>");

								out.print("<td align=left name='ma_tmuc'>"); %>
								<%=rs.getString("TEN_MUC")!=null ? rs.getString("TEN_MUC") : ""%>
								<%out.print("</td>");

								out.print("<td align=left name='ngay_tt'>"); %>
								<%=rs.getString("NGAY_TT")!=null ? rs.getString("NGAY_TT") : ""%>
								<%out.print("</td></tr>");
							}			
							out.print(" </tbody> </table> </div> </div>");	
						}catch(SQLException e){
							out.print("Err 2: "+ e);
						}finally{
						 	rs.close();
							conn.close();
						}
					%>
				</div><!-- /.box-body -->												
				</div>
            </div>						
		</div><!-- /. row -->  
		<div class="col-md-12" style="text-align:center">
		<div><button onClick="InBienNhan()" class="btn btn-primary" id="btInBienNhan" disabled><i class="fa fa-print"></i>View HDDT</button>&nbsp;</div>
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
	$('#result').text('Dang lay du lieu ...');
	// $.ajax({
	// 	url: 'crud_exec.jsp?crud_type=nnts/tai_quay_info_exec.html&mst='+$("#mst").val(),async: false,
	// 	success: function(data){ 
	// 		eval('data='+data);
	// 		$("#ten_nnt").val(data.TEN_NNT);	
	// 		$("#loai_nnt").val(data.LOAI_NNT);
	// 		$("#so").val(data.SO);
	// 		$("#chuong").val(data.CHUONG);
	// 		$("#ma_cqt_ql").val(data.MA_CQT_QL);
	// 		$("#mota_diachi").val(data.MOTA_DIACHI);
	// 		$("#mobile").val(data.EMAL+"/"+data.MOBILE);
	// 		$("#ma_nv").val(data.MA_NV);
	// 		$("#tong_tien").text(data.SOTIEN);
	// 		$("#da_tra_f").text(data.TIEN_TRA);
	// 	}
	// });
	
	// $.ajax({

	// 	url: 'view_bldt/ajax_index_no.html&mst='+$('#mst').val()+'&ma_tinh=',async: false,
	// 	success: function(data){ 
	// 		$('#data-list').html(data);
	// 	}
	// });
	
	// $.ajax({
	// 	url: 'view_bldt/ajax_index_tra.html&mst='+$('#mst').val()+'&ma_tinh=${province}',async: false,
	// 	success: function(data){ 
	// 		$('#data-list2').html(data);
	// 	}
	// });
	
	$("#btInBienNhan").attr('disabled' , false);
}
function InBienNhan(){
	if ($("#mst").val()==""){
		alert("Yêu cầu nhập thông tin MST tra cứu");
		return;
	}
	var isContinue= true ;
	$.ajax({
		url: 'crud_exec.jsp?crud_type=ct_no/check_info_dept_exec.html&mst='+$("#mst").val(),
		async: false,
		success: function(data){ 
			if(data==0){
				isContinue = false;
				alert("Bạn vui lòng thanh toán tiền thuế trước khi xem BLDT");	
			}
		}
	});

	if (isContinue) {	
		var obj = new Object();
		obj.username = "vnptthuhoservice";
		obj.pass = "Thuho@2015";
		obj.fkey = $("#mst").val();
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
    </script>
  </body>
</html>
