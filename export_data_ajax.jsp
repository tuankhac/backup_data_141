<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*,oracle.sql.*,neo.velocity.common.*,java.sql.*,neo.gate.util.mis.Base64,oracle.jdbc.OracleTypes,java.text.*,java.nio.*, java.util.Date, org.apache.commons.net.ftp.FTP, org.apache.commons.net.ftp.FTPClient, java.sql.ResultSetMetaData, java.util.zip.ZipEntry, java.util.zip.ZipInputStream, java.util.zip.ZipOutputStream, java.io.FileOutputStream, java.io.FileInputStream, com.linuxense.javadbf.*" %>
<%@ page import="jxl.Workbook"%>
<%@ page import="jxl.WorkbookSettings"%>
<%@ page import="jxl.write.Label"%>
<%@ page import="jxl.write.WritableCell"%>
<%@ page import="jxl.write.WritableSheet"%>
<%@ page import="jxl.write.WritableWorkbook"%>
<%@ page import="jxl.write.WritableFont"%>
<%@ page import="jxl.write.WritableCellFormat"%>
<%@ page import="jxl.format.*"%>
<%@ page import="org.xBaseJ.*"%>
<%@ page import="org.xBaseJ.fields.CharField"%>
<%@ page import="org.xBaseJ.fields.LogicalField"%>
<%@ page import="org.xBaseJ.fields.NumField"%>

<%
	Utility u = new Utility();
	Connection conn = null;
	ResultSet rs = null;
	String values = "0";
	String from_date = request.getParameter("from_date");
	String to_date = request.getParameter("to_date");
	String kho_bac = request.getParameter("kho_bac");
	String ky_thu = request.getParameter("ky_thu");
	String file_type = request.getParameter("file_type");
	String export_type = request.getParameter("export_type");
	String province_id = request.getParameter("province_id");
	String userid = request.getParameter("userid");
	String userip = request.getParameter("userip");
	String download_type = request.getParameter("download_type");
	String nguoi_gach = request.getParameter("nguoigachno");
	HashMap<String, String> data = new HashMap<String, String>(); 
	String[] s = null;
	String result_test = "";
	//File
	SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
	Date date = new Date();
	String currentDate = sdf.format(date);
    String name = "";
	String exp_path = "/data_exports/";
	String path = application.getRealPath("/") + exp_path;
	File file =null;
	try{
		conn = u.getConnection("crud");
		Statement stmt = conn.createStatement();
		rs = stmt.executeQuery("select * from tax.data_exports where sql_id="+Integer.parseInt(export_type));
		if(rs.next()){
			data.put("SQL_ID",rs.getString("SQL_ID"));
			data.put("SQL_NAME",rs.getString("SQL_NAME"));
			data.put("SQL_EXPORT",rs.getString("SQL_EXPORT"));
			data.put("SQL_PARAM", rs.getString("SQL_PARAM"));
			if(rs.getString("SQL_PARAM") != null){
				data.put("SQL_PARAM", rs.getString("SQL_PARAM"));
			}else{
				data.put("SQL_PARAM","");
			}
			data.put("AGENT",rs.getString("AGENT"));
			data.put("STATUS",rs.getString("STATUS"));
			data.put("FILE_NAME",rs.getString("FILE_NAME"));
			if(rs.getString("FTP_SERVER") != null){
				data.put("FTP_SERVER", rs.getString("FTP_SERVER"));
			}else{
				data.put("FTP_SERVER","");
			}
			data.put("FTP_PORT",rs.getString("FTP_PORT"));
			if(rs.getString("FTP_PORT") != null){
				data.put("FTP_PORT", rs.getString("FTP_PORT"));
			}else{
				data.put("FTP_PORT","-1");
			}
			data.put("USERNAME",rs.getString("USERNAME"));
			data.put("PASS",rs.getString("PASS"));
		}
		CallableStatement cstm=conn.prepareCall(data.get("SQL_EXPORT"));
		cstm.registerOutParameter(1, OracleTypes.CURSOR);

		if (data.get("SQL_PARAM").equals("")) {
			from_date = "";
			to_date = "";
			userid = "";
			userip = "";
			province_id = "79TTT";
			int total_param = data.get("SQL_EXPORT").replaceAll("[^?]", "").length();
			if(total_param > 1){
				for (int i = 2; i <= s.length; i++) {
					cstm.setString(i, "");
				}
			}
		} else {
			s = data.get("SQL_PARAM").split(",");
			int count = 2;
			if (s.length <= 8) {
				for (int i = 0; i < s.length; i++) {
					if (s[i].equals("TUNGAY")) {
						cstm.setString(count, from_date);
						result_test+="("+count+"-"+from_date+")";
						count++;
						continue;
					} else if (s[i].equals("DENNGAY")) {
						cstm.setString(count, to_date);
						result_test+="("+count+"-"+to_date+")";
						count++;
						continue;
					} else if (s[i].equals("KHOBAC")) {
						cstm.setString(count, kho_bac);
						result_test+="("+count+"-"+kho_bac+")";
						count++;
						continue;
					} else if (s[i].equals("KYTHU")) {
						cstm.setString(count, ky_thu);
						result_test+="("+count+"-"+ky_thu+")";
						count++;
						continue;
					} else if (s[i].equals("NGUOIGACHNO")) {
						cstm.setString(count, nguoi_gach);
						result_test+="("+count+"-"+nguoi_gach+")";
						count++;
						continue;
					} else if (s[i].equals("MATINH")) {
						cstm.setString(count, province_id);
						result_test+="("+count+"-"+province_id+")";
						count++;
						continue;
					} else if (s[i].equals("USER")) {
						cstm.setString(count, userid);
						result_test+="("+count+"-"+userid+")";
						count++;
						continue;
					} else if (s[i].equals("IP")) {
						cstm.setString(count, userip);
						result_test+="("+count+"-"+userip+")";
						count++;
						continue;
					} else {
						out.println("Err: tham so ko phu hop");
						return;
					}
				}
			}else{
				out.println("Err: tham so ko phu hop");
			}
		}
		cstm.execute();
		rs = (ResultSet) cstm.getObject(1);
		ResultSetMetaData rsMeta = rs.getMetaData();
		int total_column = rsMeta.getColumnCount();

		File theDir = new File(path);
		if (!theDir.exists()) {
			theDir.mkdir();
		}
		name =  data.get("FILE_NAME")+"_"+currentDate;
 
		if(file_type.equals("2")){
			name += ".txt";
			file = new File(path + name);
			Writer writer = new BufferedWriter(new OutputStreamWriter(
					new FileOutputStream(file), "UTF8"));
			String rsetRow = "";
			for (int i = 1; i <= total_column; i++) {
				String columnName = rsMeta.getColumnName(i);
				rsetRow += columnName + ",";
				if (i == total_column) {
					rsetRow = rsetRow.substring(0, rsetRow.length() - 1);
				}
			}
			writer.write(rsetRow);
			writer.write("\n");
			while (rs.next()) {
				rsetRow = "";
				for (int i = 1; i <= total_column; i++) {
					if (rs.getString(i) != null)
						rsetRow += rs.getString(i).replaceAll(",", "") + ",";
					else
						rsetRow += "" + ",";
					if (i == total_column) {
						rsetRow = rsetRow.substring(0, rsetRow.length() - 1);
					}
				}
				writer.write(rsetRow);
				writer.write("\n");
			}
			writer.flush();
			writer.close();
			if(download_type.equals("0")){
				out.print(doFTP(data, path, name));
			}else if(download_type.equals("1")){				
				doFTP(data, path, name);
				name = name.replaceAll("txt", "zip");
				out.print("{RESULT:'1',VALUE:'"+exp_path+name+"'}");
			}
		}else if(file_type.equals("1")){
			name += ".xls";
			file = new File(path+name);
			file.createNewFile();
			WorkbookSettings wss = new WorkbookSettings();
			wss.setEncoding("UTF-8");
			WritableWorkbook wb = Workbook.createWorkbook(file, wss);
			WritableSheet ws = wb.createSheet("SHEET1", 1);

		WritableFont cellFontTitle = new WritableFont(WritableFont.TIMES, 16);
		cellFontTitle.setBoldStyle(WritableFont.BOLD);

		WritableCellFormat cellFormatTitle = new WritableCellFormat(
				cellFontTitle);
		cellFormatTitle.setBackground(Colour.ORANGE);

		WritableFont cellFont1 = new WritableFont(WritableFont.TIMES, 12,
				WritableFont.NO_BOLD);
		WritableCellFormat cellFormat1 = new WritableCellFormat(cellFont1);
		cellFormat1.setVerticalAlignment(VerticalAlignment.CENTRE);
		cellFormat1.setWrap(true);
		for (int i = 0; i < 20; i++) {
			ws.setColumnView(i, 20);
		}
		int row =0;
 		for (int i = 1; i <= total_column; i++) {
			ws.addCell(new Label(i-1, row, rsMeta.getColumnName(i), cellFormat1));
		}
		row++;
		while(rs.next()){
 			for (int i = 1; i <= total_column; i++) {
				ws.addCell(new Label(i-1, row, rs.getString(i), cellFormat1));
			}
			row++;
		}
		wb.write();
		wb.close();
			if(download_type.equals("0")){
				out.print(doFTP(data, path, name));
			}else if(download_type.equals("1")){				
				doFTP(data, path, name);
				name = name.replaceAll("xls", "zip");
				out.print("{RESULT:'1',VALUE:'"+exp_path+name+"'}");
			}
	}else if(file_type.equals("0")){
		name += ".DBF";
		try{							
        	DBFField fields[] = new DBFField[rsMeta.getColumnCount()];
    		for (int j = 0; j < rsMeta.getColumnCount(); j++) {
    			fields[j] = new DBFField();
    			fields[j].setName(rsMeta.getColumnName(j+1));
    		    fields[j].setDataType( DBFField.FIELD_TYPE_C);
    		    fields[j].setFieldLength(255);
    		}
    		DBFWriter writer = new DBFWriter();
    	    writer.setFields( fields);
    	    
        	while (rs.next()) {
        		Object rowData[] = new Object[rsMeta.getColumnCount()];
        		for (int j = 0; j < rsMeta.getColumnCount(); j++) {
        			rowData[j] = rs.getObject(j+1);
        		}
        		writer.addRecord(rowData);
        	}
        	        	
    	    FileOutputStream fos = new FileOutputStream(path+ name);
    	    writer.write( fos);
    	    fos.close();
			
			if(download_type.equals("0")){
				out.print(doFTP(data, path, name));
			}else if(download_type.equals("1")){
				doFTP(data, path, name);
				name = name.replaceAll("DBF", "zip");
				out.print("{RESULT:'1',VALUE:'"+exp_path+name+"'}");
			}
			
		} catch (Exception e) {
			out.println("{RESULT:'0',VALUE:'Truong du lieu qua 254 ky tu. Vui long kiem tra lai.'}");
		}

	}else if(file_type.equals("3")){
			name += ".xml";
			file = new File(path + name);
			Writer writer = new BufferedWriter(new OutputStreamWriter(
					new FileOutputStream(file), "UTF8"));
			String rsetRow = "";
 
			while (rs.next()) {
				rsetRow = "";
				for (int i = 1; i <= total_column; i++) {
					if (rs.getString(i) != null)
						rsetRow += rs.getString(i).replaceAll(",", "") + ",";
					else
						rsetRow += "" + ",";
					if (i == total_column) {
						rsetRow = rsetRow.substring(0, rsetRow.length() - 1);
					}
				}
				writer.write(rsetRow);
				writer.write("\n");
			}
			writer.flush();
			writer.close();
			if(download_type.equals("0")){
				out.print(doFTP(data, path, name));
			}else if(download_type.equals("1")){	
				doFTP(data, path, name);
				name = name.replaceAll("xml", "zip");
				out.print("{RESULT:'1',VALUE:'"+exp_path+name+"'}");
			}
		}
	//out.print(name);
}catch(SQLException e){
	out.print("Err 2: "+ e);
}finally{
 	rs.close();
	conn.close();
}


%>
<%!
public String doFTP(HashMap<String, String> map, String file_path, String file_name){
	String result = "1";
	FTPClient ftpClient = new FTPClient();
	String server = map.get("FTP_SERVER");
	if(server.equals("")){
		return("{RESULT:'0',VALUE:'Server is not available.'}");
	}
	int port = Integer.parseInt(map.get("FTP_PORT"));
	if(port == -1){
		return("{RESULT:'0',VALUE:'Port is not available.'}");
	}
	String user_name = map.get("USERNAME");
	String pass = map.get("PASS");
	try {
		ftpClient.connect(server, port);
		ftpClient.login(user_name, pass);
		ftpClient.enterLocalPassiveMode();

		ftpClient.setFileType(FTP.BINARY_FILE_TYPE);
		String filename = doZipFile(file_path, file_name);
 		File firstLocalFile = new File(file_path+filename);

		InputStream inputStream = new FileInputStream(firstLocalFile);

		//System.out.println("Start uploading first file");
		boolean done = ftpClient.storeFile(filename, inputStream);
		inputStream.close();
		if (done) {
			result = "{RESULT:'0',VALUE:'FTP file thành công.'}";
		}

	} catch (IOException ex) {
		result = "{RESULT:'0',VALUE:'File not found: "+ex+"'}";
	} finally {
		try {
			if (ftpClient.isConnected()) {
				ftpClient.logout();
				ftpClient.disconnect();
			}
		} catch (IOException ex) {
			result = "Err: "+ex;
		}
	}
	return result;
}
public String doZipFile(String path, String file_name){
	String filename =file_name;
	byte[] buffer = new byte[1024];
	try{
		if (filename.indexOf(".") > 0) {
		    filename = filename.substring(0, filename.lastIndexOf("."));
		}
		FileOutputStream fos = new FileOutputStream(path + filename + ".zip");
		ZipOutputStream zos = new ZipOutputStream(fos);
		ZipEntry ze= new ZipEntry(file_name);
		zos.putNextEntry(ze);
		FileInputStream in = new FileInputStream(path + file_name);
	   
		int len;
		while ((len = in.read(buffer)) > 0) {
			zos.write(buffer, 0, len);
		}

		in.close();
		zos.closeEntry();
       
		//remember close it
		zos.close();
      
		return  filename + ".zip";

	}catch(IOException ex){
	   ex.printStackTrace();
	}
	return filename;
}
public static char GetType(String types) {
	char return_value = 'C';
	if (types == "VARCHAR2")
		return_value = 'C';
	else if (types == "NUMBER")
		return_value = 'N';
	else if (types == "DATE")
		return_value = 'D';
	else
		return_value = 'C';
	return return_value;
}
%>