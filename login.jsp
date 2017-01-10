<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="n" class="neo.velocity.common.NeoContext" scope="application"/>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
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
    <div class="login-box">
	<font style="color:#F00"><b >Từ 01/01/2017 hệ thống chuyển về địa chỉ https://unt.vnptsoftware.vn</b></font>
      <div class="login-logo">
        <a href="index.jsp"><b>${n.i18n.app_name_large}</b></a>		
      </div><!-- /.login-logo -->
      <div class="login-box-body">
        <p class="login-box-msg">Sign in to System</p>
        <form action="" method="post">
          <div class="form-group has-feedback">
            <input type="text" class="form-control input-lg" placeholder="User name" name="username" id="username"/>
            <span class="glyphicon glyphicon-user form-control-feedback"></span>
			<a href="javascript:sendotp()">
				<font style="font-size:9px;font-color:darkblue;text-decoration:none">${n.i18n.app_name_get_otp}</font></a>
          </div>
          <div class="form-group has-feedback">
            <input type="password" class="form-control input-lg" placeholder="Password" name="password"/>			
            <span class="glyphicon glyphicon-lock form-control-feedback"></span>
			<font style="font-size:10px;font-color:darkblue;text-decoration:none">M&#7853;t kh&#7849;u: &lt;M&#7853;t kh&#7849;u&gt;&lt;Mã OTP&gt;</font>
          </div>
          <div class="row">
            <div class="col-xs-8">   
				<c:choose>
					<c:when test="${not empty requestScope.loginResult}">
						<c:if test="${fn:contains(requestScope.loginResult, 'IncorrectCredentialsException')}">					
							<div class="social-auth-links text-center">
							  <p>${n.i18n.app_name_check_login}</p>
							</div><!-- /.social-auth-links -->
						</c:if>
					</c:when>
					<c:otherwise></c:otherwise>
				</c:choose>
            </div><!-- /.col -->
            <div class="col-xs-4">
              <button type="submit" class="btn btn-success btn-block btn-flat">Sign In</button>
            </div><!-- /.col -->
          </div>
        </form>
			  
      </div><!-- /.login-box-body -->
    </div><!-- /.login-box -->

    <!-- jQuery 2.1.4 -->
    <script src="/assets/bootstrap/plugins/jQuery/jQuery-2.1.4.min.js"></script>
    <!-- Bootstrap 3.3.2 JS -->
    <script src="/assets/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
    <!-- iCheck -->
    <script src="/assets/bootstrap/plugins/iCheck/icheck.min.js" type="text/javascript"></script>
    <script>
      $(function () {
        $('input').iCheck({
          checkboxClass: 'icheckbox_square-blue',
          radioClass: 'iradio_square-blue',
          increaseArea: '20%' // optional
        });
      });
	  
	  function sendotp(){	
		var obj = new Object();
		obj.userid = $("#username").val();
		$.ajax({
			type:"POST",
			data:obj,
			datatype:'html',
			url: "send_otp.jsp",
			cache: false,
			success : function(data){	
				alert(data);
			},
			error: function (jqXHR, textStatus, errorThrown) {
				alert("ERROR");
			}
		});
	 }
    </script>
  </body>
</html>
	  