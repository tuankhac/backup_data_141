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
            
          </h1>
        </section>
        <section class="content">
			<div class="tab-pane" id="tab_2">
				<div class="box box-primary">
					<div class="box-header with-border">
						<h5 style="font-weight:bold;text-transform:uppercase;">Chuyển tỉnh</h5>
					</div>
					<div class="box-body">
						<form class="form-horizontal">
						  <div class="form-group">
							<label for="inputName" class="col-sm-2 control-label">Chọn tỉnh</label>
							
							<div class="col-sm-10">                   
							<n:velocity>
								<select class="form-control" name="id_province" id="id_province"  >
									#set ($list = $u.qry("chuyen_tinh_get_all_province","default",[],0) )
									#foreach ($i in $list)
										
										<option value="$!i['ID']" #if ($!i['ID']== $!{province}) selected #end >$!i['PROVINCE_NAME']</option>
									#end
								</select>
							</n:velocity>
							</div>
						  </div>
						  
						  <div class="form-group">
							
							<div class="col-sm-offset-2 col-sm-10">		  
								<button type="button" onclick="doAccept()" class="btn btn-primary" id="btn_accept" >Submit</button>
								<div id="result"></div>		
							</div>
						  </div>
						</form>
					</div>
				</div>
			</div>
         </section>
    </div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script>
 
	function doAccept(){
//		if( !confirm('${n.i18n.crud_confirm_message}') ){return;}
		$('#result').html('${n.i18n.crud_process_message}');
		var obj = new Object();
		obj.id_user =  "${pageContext.request.userPrincipal.name}";
		obj.id_province = $("#id_province").val();
 		$.ajax({
			type:"POST",
			data:obj,
			url: "change_province_ajax.jsp",
			cache: false,
			success : function(data){
				eval('data='+data);
				if(data.RESULT == "OK"){
					alert("Chuyển tỉnh thành công");
					$('#result').html('');
				}else {
					alert(data.VALUE);
				}			
			},
			error: function (jqXHR, textStatus, errorThrown) {
        		alert(jqXHR.responseText);
    		}
		});
	}
		
</script>