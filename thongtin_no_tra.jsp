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
							<td width="15%" style="font-weight:bold;color:#039">${n.i18n.crud_info_mst}*</td>
							<td><input  type="text" class="form-control" name="mst" id="mst" value="" onKeyUp="loadInfo()"></td>
							<td>${n.i18n.crud_info_ten}</td>
							<td><input  type="text" class="form-control" name="ten_nnt" id="ten_nnt" readonly></td>
						 </tr>									 									 
						 <tr>
							<td>${n.i18n.crud_info_diachi}</td>
							<td colspan="3"><input  type="text" class="form-control" name="mota_diachi" id="mota_diachi" readonly></td>
						 </tr>	
						<tr>
							<td width="15%">Nhân viên</td>
							<td><input  type="text" class="form-control" name="ma_nv" id="ma_nv" readonly></td>
							<td>Số điện thoại/Email</td>
							<td><input  type="text" class="form-control" name="mobile" id="mobile" readonly>
							</td>
						</tr>
						<tr>
							<td width="15%">Tổng phải nộp</td>
							<td><input  type="text" class="form-control" name="tong_tien" id="tong_tien" readonly></td>
							<td>Tổng trả</td>
							<td><input  type="text" class="form-control" name="da_tra_f" id="da_tra_f" readonly>
							</td>
						</tr>

					</tbody></table>														
					<div id="data-list"></div>	
					<div id="data-list2"></div>
					
				</div><!-- /.box-body -->												
				</div>
            </div>						
		</div>
	</section>
</div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 

<script type="text/javascript">

	function loadInfo(objmst){
		
		$("#ten_nnt").val("");	
		$("#mota_diachi").val("");
		$("#ma_nv").val("");
		$("#mobile").val("");
		$("#ma_tinh").val("");
		$('#result').text('Dang lay du lieu ...');
		var url ='crud_exec.jsp?crud_type=code/tai_quay_info_exec.html&mst='+objmst+'&ma_tinh=${province}';
		 $.ajax({
			url: url,
			async: false,
			success: function(data){ 
				eval('data='+data);			
				$("#ten_nnt").val(data.TEN_NNT);	
				$("#mota_diachi").val(data.MOTA_DIACHI);
				$("#ma_nv").val(data.ID_NV +" - "+ data.TEN_NV +" - "+ data.DT_NV );
				$("#mobile").val(data.MOBILE +" - "+ data.EMAIL);
				$("#ma_tinh").val(data.MA_TINH);
				$("#tong_tien").val(data.SOTIEN);
				$("#da_tra_f").val(data.TIEN_TRA);				
			}
		 });
		
		$.ajax({
			url: 'crud_exec.jsp?crud_type=code/ajax_index_no_kythue_tc.html&mst='+objmst+'&ma_tinh=${province}',async: false,
			success: function(data){ 
				$('#data-list').html(data);
			}
		});
		
		$.ajax({
			url: 'crud_exec.jsp?crud_type=code/ajax_index_tra_kythue_tc.html&mst='+objmst+'&ma_tinh=${province}',async: false,
			success: function(data){ 
				$('#data-list2').html(data);
			}
		});
		
				
	}	

	var mst="";
	var tasks = {
		<n:value service="get_mst" serviceType="ref" paramSize="1" p1="${province}">
		#set ($k = 0 )
		#foreach ($i in $list )
			#if ($k!=0),#end"$!i['ID']":"$!i['NAME']"
			#set ($k=$k+1)
		#end
		</n:value>
	};
	var tasksArray = $.map(tasks, function (value, key) { return { value: value, data: key }; });
	$('#mst').autocomplete({
		lookup: tasksArray,
		onSelect: function (suggestion) {
			mst = suggestion.data;			
			loadInfo(mst);
		}
	});


</script>