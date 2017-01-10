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
				<div class="col-md-6">
						<div class="box box-info box-solid direct-chat direct-chat-info">
							<div class="box-header">
								<n:value id="head" service="crud_search_users_info_staff" serviceType="query" paramSize="1" p1="${pageContext.request.userPrincipal.name}">
								<b>${n.i18n.info_giao_hd_m_label1} : $list.get(0).NAME</b>										
								</n:value>						
							<div class="box-tools pull-right">
								<!--span data-toggle="tooltip" class="badge bg-green">3</span>
								<button class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i></button-->								
								<button class="btn btn-box-tool" data-widget="remove"><i class="fa fa-times"></i></button>
							  </div>
							</div><!-- /.box-header -->
							<div class="box-body">
							<!-- Conversations are loaded here -->
							  <div class="direct-chat-messages">
								<!-- Message. Default to the left -->
								<div class="direct-chat-msg">
									<div class="box-body no-padding">                                        
										<div class="box-body" id='data-list' style="overflow:auto;margin:auto"></div>                   
									</div>
								</div><!-- /.direct-chat-msg -->														
							</div><!-- /.box-body -->							
						  </div>	              
				</div><!-- /.col -->                               
			</div><!-- /. row -->   
		</section>
    </div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script>
	var manv_ = '${head.list.get(0).STAFF}';	
	$(document).ready(function(){			
		$.ajax({
			url: 'crud_exec.jsp?crud_type=nnts/ajax_giao_phieu_m.html&province=${province}&ma_nv=${manv_}',
			success: function(data){ 				
				$('#data-list').html(data); 
			}
		});	
	});
	function tong_tien(){
		var c=0,s=0;
		$('input[name="nnts_rad"]:checked').each(function(){
			c+=1;
			s+=$("#so_tien"+$(this).attr('id')).text().replace(/,/g,"")*1;
		});
		$("#tong_phieu").text(c);
		$("#tong_tien").text(fnumber(s+""));
	}	
</script>