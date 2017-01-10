<%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="n" class="neo.velocity.common.NeoContext" scope="application"/>
<jsp:setProperty name="n" property="language" value="${not empty param.language ? param.language : 'vi_VN'}"/>
<n:check value="${param.crud_type}" minLength="3" maxLength="200" type="string" exp="[0-9a-zA-Z_/.]+">Tham số không chính xác, vui lòng kiểm tra lại!</n:check>

<jsp:useBean id="u" class="neo.velocity.common.ServiceUtility" scope="application"/>

<%@ page import="java.util.ArrayList" %>
<% 
	ArrayList<String> listUser = new ArrayList<String>(); 
	listUser.add(request.getUserPrincipal().getName());
	String prov = u.val("crud_value_get_agent_map_user","crud",listUser,1);
	session.setAttribute("province",prov);
	request.setAttribute("province",prov);
%>

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
    <link href="/assets/bootstrap/plugins/datepicker/datepicker3.css" rel="stylesheet" type="text/css" />
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
	
	<link rel="stylesheet" href="/assets/bootstrap/plugins/icomoon/style.css"></head>
	
	<script src="/assets/bootstrap/plugins/jQuery/jQuery-2.1.4.min.js"></script>
    <script src="/assets/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
	<script src="/assets/bootstrap/lte/js/app.min.js" type="text/javascript"></script>
	<script src="/assets/bootstrap/plugins/chartjs/Chart.min.js" type="text/javascript"></script>
    <script src="/assets/bootstrap/plugins/datepicker/bootstrap-datepicker.js" type="text/javascript"></script>
    
    <script type="text/javascript" src="/assets/bootstrap/plugins/ckeditor/ckeditor.js"></script>
    <script>
	function Go(l){
		document.location.href=l;
	}
	</script>
  </head>
  <body class="skin-blue-light">
    <div class="wrapper">
        <!-- Content Header (Page header) -->
        <section class="content">
		  <div class="row">
            <div class="col-md-12">
              <!-- Block buttons -->
              <div class="box box-primary">
                <div class="box-body no-padding">
                    <n:velocity>
                        #parse ("${param.crud_type}")
                    </n:velocity>
                 </div><!-- /.box-body -->
              </div><!-- /.box -->
            </div><!-- /.col -->            
          </div><!-- /. row -->
        </section>
    </div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 