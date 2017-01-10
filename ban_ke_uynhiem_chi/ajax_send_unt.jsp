<%@ page contentType="text/html; charset=utf-8" language="java"%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*,oracle.sql.*,neo.velocity.common.*,java.sql.*,neo.gate.util.mis.Base64,oracle.jdbc.OracleTypes,java.text.*,java.nio.*, java.util.Date, org.apache.commons.net.ftp.FTP, org.apache.commons.net.ftp.FTPClient, java.sql.ResultSetMetaData, java.util.zip.ZipEntry, java.util.zip.ZipInputStream, java.util.zip.ZipOutputStream, java.io.FileOutputStream, java.io.FileInputStream, com.svcon.jdbf.*,neo.tct.XmlSignatureBill,neo.tct.soap.GIPWS_Service" %>
<%
	String result = "";
	StringBuffer sb = new StringBuffer();
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
	data.put(11, request.getParameter("phuong"));
	data.put(12, request.getParameter("loaithue"));	
 	String seq = request.getParameter("seq");

	String path = "D:/NEOCompany/BK_NEW/Server/webapps/ROOT/WEB-INF/gip/req/";
 	Utility u = new Utility();
	Connection conn = null;
	CallableStatement cstm = null;
  	try {
		conn = u.getConnection("crud");
		cstm = conn.prepareCall("begin ?:= REPORT.GET_XML_UNT(?,?,?,?,?,?,?,?,?,?,?,?,?) ;end;");
		cstm.registerOutParameter(1, OracleTypes.CLOB);
		for (int i = 0; i <= 12; i++) {
			cstm.setString(i + 2, (String) data.get(i));
		}
		cstm.execute();
		Clob myClob = cstm.getClob(1);
		Reader  reader = myClob.getCharacterStream();
		BufferedReader br = new BufferedReader(reader);
	    String text;
		while ((text = br.readLine()) != null) {
			System.out.println(text);
	        sb.append(text);			
	    }		
		
	    br.close();
		cstm.close();
		conn.close();
		
		if(!sb.toString().startsWith("Loi thuc hien")){
			System.out.println(sb.toString());
			result = writeXmlFile(path, seq, sb.toString(),u);
 		}else{
			result = "Err: Kiểm tra REPORT.GET_XML_UNT hoặc tham số.";
		}
	} catch (Exception e) {
		e.printStackTrace();
 	}	
	out.clear();out.print(result);
%>
<%!
public String writeXmlFile(String path, String seq,String value,Utility u) {
	String result = "";
	File dir = new File(path);
	if (!dir.exists()) {
		dir.mkdir();
	}
 	File file = new File(path+"unt_"+seq+".xml");
	try {
		Writer writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file), "UTF8"));
		writer.write(value);
 		writer.close();
 		path = "D:/NEOCompany/BK_NEW/Server/webapps/ROOT/WEB-INF/gip/";						
		
		if(!value.equals("-1001")){
			System.out.println("vao day");
			//neo.tct.XmlSignatureBill.callws(path,"unt",seq);	
			result = u.getValue("begin ?:= REPORT.UPDATE_SEQ_UNT('"+seq+"') ;end;", new String[]{},u.getConnection("crud"));
		}				
		
		if(result.equals("1")){
			result = "Gửi file báo cáo thành công";
 		}else{
			result = "Err: Kiểm tra REPORT.UPDATE_SEQ_UNT hoặc tham số "+result;
		}			
		
	} catch (Exception e) {
		e.printStackTrace();
		result = "Gửi file báo cáo không thành công" + e.getMessage();
	}
	
	if(value.equals("-1001")){
		result = "Gửi file báo cáo không thành công -> Kiểm tra lại thông tin bản kê";
	}
	return result;
 }
%>