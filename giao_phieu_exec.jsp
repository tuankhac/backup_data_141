<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*,oracle.sql.*,neo.velocity.common.*,java.sql.*" %>
<%
	
	Utility u = new Utility();
	Connection conn = u.getConnection("crud");
	CallableStatement cstmt=conn.prepareCall("begin ?:=crud.giao_phieu_clob(?,?,?); end;");
	cstmt.registerOutParameter(1, 12);
	cstmt.setObject(2,request.getParameter("ma_nv"));
	StringReader content = new StringReader(request.getParameter("msts"));
	cstmt.setCharacterStream(3, content ,request.getParameter("msts").length());
	cstmt.setObject(4,request.getParameter("userid"));

	cstmt.execute();	
	conn.commit();
	StringBuffer _stringResult = new StringBuffer().append(cstmt.getString(1));
	cstmt.close();
	conn.close();

	out.clear();
	out.print(_stringResult.toString());
%>