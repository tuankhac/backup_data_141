<%@ page contentType="text/html; charset=utf-8" language="java"%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*,oracle.sql.*,neo.velocity.common.*,java.sql.*,neo.gate.util.mis.Base64,oracle.jdbc.OracleTypes,java.text.*,java.nio.*, java.util.Date, org.apache.commons.net.ftp.FTP, org.apache.commons.net.ftp.FTPClient, java.sql.ResultSetMetaData, java.util.zip.ZipEntry, java.util.zip.ZipInputStream, java.util.zip.ZipOutputStream, java.io.FileOutputStream, java.io.FileInputStream, com.svcon.jdbf.*,neo.tct.XmlSignatureBill,neo.tct.soap.GIPWS_Service" %>
<%
	String result = "";
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
	data.put(10, request.getParameter("seq"));
 	String seq = request.getParameter("seq");

	String path = "E:/tax/Server/webapps/ROOT/WEB-INF/gip/req/";
 	Utility u = new Utility();
	Connection conn = null;
	CallableStatement cstm = null;
  	try {
		conn = u.getConnection("crud");
		cstm = conn
				.prepareCall("begin ?:= REPORT.GET_XML_UNT(?,?,?,?,?,?,?,?,?,?,?) ;end;");
		cstm.registerOutParameter(1, OracleTypes.VARCHAR);
		for (int i = 0; i <= 10; i++) {
			cstm.setString(i + 2, (String) data.get(i));
		}
		boolean check = cstm.execute();//true = resultset, false = a varible
		result = cstm.getString(1);
		if(!check){
			result = writeXmlFile(path, seq, result);
 		}else{
			result = "Err: Kiểm tra REPORT.GET_XML_UNT hoặc tham số.";
		}
	} catch (Exception e) {
		e.printStackTrace();
 	}
  	out.print(result);
%>
<%!
public String writeXmlFile(String path, String seq,String value) {
	Utility u = new Utility();
	Connection conn = null;
	CallableStatement cstm = null;
	String result = "";
	File dir = new File(path);
	if (!dir.exists()) {
		dir.mkdir();
	}
 	File file = new File(path+"unt_"+seq+".xml");
	try {
		Writer writer = new BufferedWriter(new OutputStreamWriter(
				new FileOutputStream(file), "UTF8"));
		writer.write(value);
 		writer.close();
 		path = "E:/tax/Server/webapps/ROOT/WEB-INF/gip/";
		
 		neo.tct.XmlSignatureBill.callws(path,"unt",seq); 		
		
		conn = u.getConnection("crud");
		cstm = conn.prepareCall("begin ?:= REPORT.UPDATE_SEQ_UNT('"+seq+"') ;end;");
		cstm.registerOutParameter(1, OracleTypes.VARCHAR);
		boolean check = cstm.execute();
		
		if(!check){
			result = "Ghi file thành công";
 		}else{
			result = "Err: Kiểm tra REPORT.UPDATE_SEQ_UNT hoặc tham số.";
		}
				
	} catch (Exception e) {
		result = "Ghi file không thành công" + e.getMessage();
	}
	return result;
 }
%>