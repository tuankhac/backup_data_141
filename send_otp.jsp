<%@ page contentType="text/html; charset=utf-8" language="java"%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*,oracle.sql.*,neo.velocity.common.*,java.sql.*,oracle.jdbc.OracleTypes" %>
<%
	String result = "";
  	HashMap<Integer, String> data = new HashMap<Integer, String>();
 	data.put(0, request.getParameter("userid"));

 	Utility u = new Utility();
	Connection conn = null;
	CallableStatement cstm = null;
  	try {
		conn = u.getConnection("crud");
		cstm = conn.prepareCall("begin ?:= tax.get_authentication(?) ;end;");
		cstm.registerOutParameter(1, OracleTypes.VARCHAR);
		cstm.setString(2, (String) data.get(0));
		boolean check = cstm.execute();
		result = cstm.getString(1);		
	} catch (Exception e) {
		e.printStackTrace();
 	}
	
	if(result.equals("1")){
		out.print("Mã OTP đã được gửi đến số điện thoại của user "+(String) data.get(0));
 	}else{
		out.print(result);
	}
  	
%>