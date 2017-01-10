<%@ page contentType="text/html; charset=utf-8" language="java"%>
<%@ page import="java.io.*,java.lang.*,java.util.*, javax.servlet.*,oracle.sql.*,neo.velocity.common.*,java.sql.*,neo.gate.util.mis.Base64,oracle.jdbc.OracleTypes,java.text.*,java.nio.*, java.util.Date, org.apache.commons.net.ftp.FTP, org.apache.commons.net.ftp.FTPClient, java.sql.ResultSetMetaData, java.util.zip.ZipEntry, java.util.zip.ZipInputStream, java.util.zip.ZipOutputStream, java.io.FileOutputStream, java.io.FileInputStream, com.svcon.jdbf.*" %>
<%
	String result = "";
	String seq = "";
  	HashMap<Integer, String> data = new HashMap<Integer, String>();

 	data.put(0, request.getParameter("ma_tinh"));	
	data.put(1, request.getParameter("kho_bac"));
 	data.put(2, request.getParameter("so_chung_tu_kb"));
	data.put(3, request.getParameter("ngay_chung_tu_kb"));
 	data.put(4, request.getParameter("ky_hieu"));
 	data.put(5, request.getParameter("so_chung_tu_nh"));
	data.put(6, request.getParameter("ngay_chung_tu_nh"));
 	data.put(7, request.getParameter("tien_nop").trim());
 	data.put(8, request.getParameter("user_ip"));
 	data.put(9, request.getParameter("user_id"));
	data.put(10, request.getParameter("ngay"));	
	data.put(11, request.getParameter("phuong"));
	data.put(12, request.getParameter("loaithue"));	
  	data.put(13, request.getParameter("tong_tien").trim());
	
	Utility u = new Utility();
	Connection conn = null;
	CallableStatement cstm = null;
  	if (data.get(7).equals(data.get(13))) {
 		try {
			conn = u.getConnection("crud");
			cstm = conn
					.prepareCall("begin ?:= REPORT.ACCEPT_SEQ_UNT(?,?,?,?,?,?,?,?,?,?,?,?,?) ;end;");
			cstm.registerOutParameter(1, OracleTypes.VARCHAR);
			for (int i = 0; i <= 12; i++) {
				cstm.setString(i + 2, (String) data.get(i));
			}
			cstm.execute();
			seq = cstm.getString(1);
			
			try
			{
				Integer.parseInt(seq);
				result = "{'SEQ':'"+seq+"','TEXT':'Tạo dữ liệu UNT thành công : "+seq+"'}";
			} catch (Exception e)
			{
				result = "{'SEQ':'"+seq+"','TEXT':'Tạo dữ liệu UNT không thành công : "+seq+"'}";
			}					
			
		} catch (Exception e) {
			e.printStackTrace();	
			result = "{'SEQ':'"+e+"','TEXT':'Tạo dữ liệu UNT không thành công : "+e.getMessage()+"'}";
		}
	}else{
		result = "{'SEQ':'"+seq+"','TEXT':'Tạo dữ liệu UNT không thành công -> yêu cầu kiểm tra lại thông tin tiền "+data.get(7)+"'}";
	}
 	out.print(result);
%>