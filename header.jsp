<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="topmenu" class="neo.smartui.taglib.TreeView" scope="session"/>
<jsp:useBean id="u" class="neo.velocity.common.ServiceUtility" scope="application"/>

<%@ page import="java.util.ArrayList" %>
<% 
	ArrayList<String> listUser = new ArrayList<String>(); 
	listUser.add(request.getUserPrincipal().getName());
	String prov = u.val("crud_value_get_agent_map_user","crud",listUser,1);
	session.setAttribute("province",prov);
	request.setAttribute("province",prov);
	
	String path = application.getRealPath("/").replace('\\', '/');
	session.setAttribute("pathroot",path);
	request.setAttribute("pathroot",path);
%>

<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=8" />

    <title>${n.i18n.app_title}</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <link href="/assets/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="/assets/bootstrap/lte/css/AdminLTE.min.css" rel="stylesheet" type="text/css" />
    <link href="/assets/bootstrap/lte/css/skins/skin-blue-light.min.css" rel="stylesheet" type="text/css" />
    <link href="/assets/bootstrap/plugins/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <link href="/assets/bootstrap/plugins/datepicker/datepicker3.css" rel="stylesheet" type="text/css" />
  <link rel="stylesheet" href="/assets/bootstrap/plugins/icomoon/style.css"></head>
  <link rel="stylesheet" href="style/chosen.min.css">

    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
    <!--[if lt IE 8]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
 
	<script src="/assets/bootstrap/plugins/jQuery/jQuery-2.1.4.min.js"></script>
    <script src="/assets/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
	<script src="/assets/bootstrap/lte/js/app.min.js" type="text/javascript"></script>
	<script src="/assets/bootstrap/plugins/chartjs/Chart.min.js" type="text/javascript"></script>
    <script src="/assets/bootstrap/plugins/datepicker/bootstrap-datepicker.js" type="text/javascript"></script>
    
    <script type="text/javascript" src="/assets/bootstrap/plugins/ckeditor/ckeditor.js"></script>
	<!-- phan trang -->
	<link rel="stylesheet" type="text/css" media="screen" href="style/page_template/page_templates.css"/>
	<script type="text/javascript" src="style/page_template/page_templates.js"></script>
	<script src="style/chosen.jquery.min.js"></script>
    <script>
	function Go(l){
		document.location.href=l;
	}
	</script>
  </head>  
  <body class="skin-blue-light sidebar-mini">		
	<div class="wrapper">	

      <header class="main-header">
        <!-- Logo -->
        <a href="index.jsp" class="logo">
          <!-- mini logo for sidebar mini 50x50 pixels -->
          <span class="logo-mini"><b>${n.i18n.app_name_small}</b></span>
          <!-- logo for regular state and mobile devices -->
          <span class="logo-lg">${n.i18n.app_name_large}</span>
        </a>
        <!-- Header Navbar: style can be found in header.less -->
        <nav class="navbar navbar-static-top" role="navigation">
          <!-- Sidebar toggle button-->
          <a href="#" class="sidebar-toggle" data-toggle="offcanvas" role="button">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </a>
          <div class="navbar-custom-menu">
		  	<ul class="nav navbar-nav">
              <!-- User Account: style can be found in dropdown.less -->
              <li class="dropdown user user-menu">
                <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                  <img src="/assets/bootstrap/user.png" class="user-image" alt="User Image"/>
                  <span class="hidden-xs"><%=request.getUserPrincipal().getName() %></span>
                </a>
                <ul class="dropdown-menu">
                  <!-- User image -->
                  <li class="user-header">
                    <img src="/assets/bootstrap/user.png" class="img-circle" alt="User Image" />
                    <p>
                      <%=request.getUserPrincipal().getName() %> - Java Developer
                      <small>NEO Member</small>
                    </p>
                  </li>
				  <li class="user-footer">
				  	<div class="pull-left">
                      <a href="help.jsp" class="btn btn-default btn-flat">Help</a>
                    </div>
                    <div class="pull-right">
                      <a href="logout" class="btn btn-default btn-flat">Sign out</a>
                    </div>
                  </li>
                </ul>
              </li>
            </ul>
          </div>
        </nav>
      </header>
	</form>
	<!-- Left side column. contains the logo and sidebar -->
      <aside class="main-sidebar">
        <!-- sidebar: style can be found in sidebar.less -->
        <section class="sidebar">
  <!-- search form -->
  <form action="#" method="GET" class="sidebar-form" name="frmAgent">
	<div class="input-group">
	  <input type="text" name="q" class="form-control" placeholder="Search..."/>
	  <span class="input-group-btn">
		<button type='submit' name='search' id='search-btn' class="btn btn-flat"><i class="fa fa-search"></i></button>
	  </span>
	</div>
  </form>
  <!-- /.search form -->
  <!-- sidebar menu: : style can be found in sidebar.less -->
  <ul class="sidebar-menu">
	${topmenu.getBootstrapMenu("top",pageContext.request.userPrincipal.name,"crud",pageContext.request.contextPath) }
  </ul>
</section>
        <!-- /.sidebar -->
</aside>



