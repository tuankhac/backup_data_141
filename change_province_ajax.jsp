
 <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="topmenu" class="neo.smartui.taglib.TreeView" scope="session"/>
<%@ page import="java.util.ArrayList, neo.velocity.common.Utility,java.sql.Connection,  java.sql.ResultSet,  java.sql.SQLException, java.sql.CallableStatement, oracle.jdbc.OracleTypes" %>
<% 
	String province_id = request.getParameter("id_province");
	session.setAttribute("province",province_id);
	request.setAttribute("province",province_id);
	
	Utility u = new Utility();
	Connection conn = null;
	CallableStatement cstm = null;
	String result = "0";
	String user_id = request.getUserPrincipal().getName();
	try{
		conn = u.getConnection("crud");
		cstm = conn
			.prepareCall("begin ?:=tax.upload.edit_chuyen_tinh(?,?); end;");
		cstm.registerOutParameter(1, OracleTypes.VARCHAR);
		cstm.setString(2,user_id);
		cstm.setString(3,province_id);
 
		cstm.execute();
 		result = "{RESULT:'OK',VALUE:'"+cstm.getString(1)+"'}";
 	}catch(Exception e){
		result = "{RESULT:'FAIL',VALUE:'"+e.getMessage()+"'}";
	}finally {
		try {
			if (cstm != null) {
				cstm.close();
			}
			if (conn != null) {
				conn.close();
			}
		} catch (Exception ex) {
			//ex.printStackTrace();
			 result = "{RESULT:'FAIL',VALUE:'"+ex.getMessage()+"'}";
		}
	}
	
	out.print(result);
	

%>
 