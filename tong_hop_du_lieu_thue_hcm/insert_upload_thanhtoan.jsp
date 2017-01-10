<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@ page contentType="text/html; charset=utf-8" language="java"%>
<%@ page
	import="org.apache.commons.fileupload.util.Streams,java.io.*,java.util.*,javax.servlet.*,neo.*,com.aspose.cells.*, com.lowagie.text.pdf.codec.Base64,  org.apache.commons.fileupload.servlet.*, org.apache.commons.fileupload.*, org.apache.commons.fileupload.disk.DiskFileItemFactory, org.apache.commons.fileupload.servlet.ServletFileUpload, java.sql.ResultSetMetaData,java.sql.PreparedStatement"%>
<%@ page
	import="com.jspsmart.upload.*,com.jspsmart.file.*,com.neo.utils.*,  java.io.BufferedReader,  java.io.File,  java.io.FileInputStream,  java.io.FileOutputStream,  java.io.IOException,  java.io.InputStreamReader,  java.sql.CallableStatement,  java.sql.Connection,  java.sql.ResultSet,  java.sql.SQLException,  java.util.zip.ZipEntry,  java.util.zip.ZipInputStream,  java.util.zip.ZipOutputStream, neo.velocity.common.Utility,  oracle.jdbc.OracleTypes,  com.github.junrar.exception.RarException, com.github.junrar.impl.FileVolumeManager, com.github.junrar.rarfile.FileHeader, com.github.junrar.Archive, org.apache.poi.xssf.usermodel.XSSFCell, org.apache.poi.xssf.usermodel.XSSFRow, org.apache.poi.xssf.usermodel.XSSFSheet, org.apache.poi.xssf.usermodel.XSSFWorkbook, org.apache.poi.hssf.usermodel.HSSFCell, org.apache.poi.hssf.usermodel.HSSFRow, org.apache.poi.hssf.usermodel.HSSFSheet, org.apache.poi.hssf.usermodel.HSSFWorkbook, org.apache.poi.poifs.filesystem.POIFSFileSystem"%>
 <%
	Utility u = new Utility();
	Connection conn = null;
	CallableStatement cstm = null;
	String result = "0";
 	String filter = request.getParameter("filter_val");
	String user_id = request.getUserPrincipal().getName();
	String user_ip = request.getRemoteAddr();
	String curr_id = request.getParameter("curr_id");
	try{
		conn = u.getConnection("crud");
		cstm = conn
			.prepareCall("begin ?:= upload.insert_uploads_thanhtoan_hcm(?,?,?,? ) ;end;");
		cstm.registerOutParameter(1, OracleTypes.VARCHAR);
		cstm.setString(2,filter);
		cstm.setString(3,user_id);
		cstm.setString(4,user_ip);
		cstm.setString(5,curr_id);
 
		cstm.execute();
 		result = "{RESULT:'OK',VALUE:'"+cstm.getString(1)+"'}";
 	}catch(Exception e){
		//e.printStackTrace();
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
	out.println(result);
%>
 