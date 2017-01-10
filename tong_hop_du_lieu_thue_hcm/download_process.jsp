<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@ page contentType="text/html; charset=utf-8" language="java"%>
<%@ page
	import="org.apache.commons.fileupload.util.Streams,java.io.*,java.util.*,javax.servlet.*,neo.*,com.aspose.cells.*, com.lowagie.text.pdf.codec.Base64,  org.apache.commons.fileupload.servlet.*, org.apache.commons.fileupload.*, org.apache.commons.fileupload.disk.DiskFileItemFactory, org.apache.commons.fileupload.servlet.ServletFileUpload, java.sql.ResultSetMetaData"%>
<%@ page
	import="com.jspsmart.upload.*,com.jspsmart.file.*,com.neo.utils.*,  java.io.BufferedReader,  java.io.File,  java.io.FileInputStream,  java.io.FileOutputStream,  java.io.IOException,  java.io.InputStreamReader,  java.sql.CallableStatement,  java.sql.Connection,  java.sql.ResultSet,  java.sql.SQLException,  java.util.zip.ZipEntry,  java.util.zip.ZipInputStream,  java.util.zip.ZipOutputStream, neo.velocity.common.Utility,  oracle.jdbc.OracleTypes,  com.github.junrar.exception.RarException, com.github.junrar.impl.FileVolumeManager, com.github.junrar.rarfile.FileHeader, com.github.junrar.Archive, org.apache.poi.xssf.usermodel.XSSFCell, org.apache.poi.xssf.usermodel.XSSFRow, org.apache.poi.xssf.usermodel.XSSFSheet, org.apache.poi.xssf.usermodel.XSSFWorkbook, org.apache.poi.hssf.usermodel.HSSFCell, org.apache.poi.hssf.usermodel.HSSFRow, org.apache.poi.hssf.usermodel.HSSFSheet, org.apache.poi.hssf.usermodel.HSSFWorkbook, org.apache.poi.poifs.filesystem.POIFSFileSystem"%>
<%@page import="com.linuxense.javadbf.*"%>
<%
	Utility u = new Utility();
	Connection conn = null;
	ResultSet rs = null;
	CallableStatement cstm = null;
	String result = "1";
	List listData = new ArrayList<String[]>();
	String realPath = "tong_hop_du_lieu_thue" +"/du_lieu_thue_download/";
	String rootPath = application.getRealPath("/")+ realPath;
	String fileName = "dulieuthue";
	String outputType = request.getParameter("download_type");
	String filter = request.getParameter("filter_val");
	String currId = request.getParameter("curr_id");
	try{
		conn = u.getConnection("crud");
		cstm = conn
			.prepareCall("begin ?:= upload.search_nnts_uploads_temp(?,?,?,?,?) ;end;");
		cstm.registerOutParameter(1, OracleTypes.CURSOR);
		cstm.setString(2,filter);
		cstm.setString(3,request.getRemoteAddr());
		cstm.setString(4,currId);
		cstm.setString(5,"1");
		cstm.setString(6,"-2");
		cstm.execute();
		rs = (ResultSet) cstm.getObject(1);
		ResultSetMetaData rsMeta = rs.getMetaData();
		int totalColumn = rsMeta.getColumnCount();
		result = totalColumn + "";
		String[] columnNames = null;
		if (totalColumn > 0) {
			columnNames = new String[47];
			for (int i = 0; i < totalColumn; i++) {
				columnNames[i] = rsMeta.getColumnName(i + 1);
			}
		}
		String[] rowValues = null;
		while (rs.next()) {
			rowValues = new String[47];
			for (int i = 0; i < totalColumn; i++) {
				String columnType = rsMeta.getColumnTypeName(i + 1);
				if (columnType.equals("NUMBER")) {
					rowValues[i] = rs.getDouble(i + 1) + "";
				} else if (columnType.equals("DATE")) {
					rowValues[i] = rs.getDate(i + 1) + "";
				} else {
					rowValues[i] = rs.getString(i + 1);
				}
			}
			listData.add(rowValues);
		}
		String fullName = fileName + getCurrentTime();
		if (outputType.equals("EXCEL")) {
			result = doWriteExcel(listData, rootPath, fullName + ".xls", totalColumn, columnNames);
 		} else {
			result = doWriteDBF(listData, rootPath, fullName + ".dbf", totalColumn, columnNames);
		}
	}catch(Exception e){
		//e.printStackTrace();
		out.println(e.getMessage());
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
			 result = ex.getMessage();
		}
	}
	out.println(result);

%>
<%!
	public static String doWriteExcel(List<String[]> listData, String path,
			String orgFileName, int totalColumn, String[] columnNames) {
		if (listData.isEmpty())
			return "ERROR:Không có dữ liệu";
		String result = "";
		try {
			HSSFWorkbook wb = new HSSFWorkbook();
			HSSFSheet sheet = wb.createSheet("SHEET1");
			double sizeData = listData.size();
			for (int r = 0; r <= sizeData; r++) {
				HSSFRow row = sheet.createRow(r);
				for (int c = 0; c < totalColumn; c++) {
					HSSFCell cell = row.createCell(c);
					if (r == 0) {
						cell.setCellValue(columnNames[c]);
					} else {
						cell.setCellValue(listData.get(r - 1)[c]);
					}
				}
			}
			FileOutputStream fileOut = new FileOutputStream(path + orgFileName);
			wb.write(fileOut);
			File fileUpload = new File(path + orgFileName);
			if (fileUpload.exists()) {
				result = orgFileName;
			}
			fileOut.flush();
			fileOut.close();
		} catch (Exception e) {
			// e.printStackTrace();
			result = "ERROR:" + e.getMessage();
		}
		return result;
	}

	public static String doWriteDBF(List<String[]> listData, String path,
			String orgFileName, int totalColumn, String[] columnNames) {
		if (listData.isEmpty() || columnNames == null)
			return "ERROR:Không có dữ liệu";
		String result = "";
		try {
			DBFField fields[] = new DBFField[totalColumn];
			for (int j = 0; j < totalColumn; j++) {
				fields[j] = new DBFField();
				fields[j].setName(subColumnName(columnNames[j]));
				fields[j].setDataType(DBFField.FIELD_TYPE_C);
				fields[j].setFieldLength(255);
			}
			DBFWriter writer = new DBFWriter();
			writer.setFields(fields);

			for (int r = 0; r < listData.size(); r++) {
				Object rowData[] = new Object[totalColumn];
				for (int c = 0; c < totalColumn; c++) {
					rowData[c] = listData.get(r)[c];
				}
				writer.addRecord(rowData);
			}
			FileOutputStream fos = new FileOutputStream(path + orgFileName);
			writer.write(fos);
			File fileUpload = new File(path + orgFileName);
			if (fileUpload.exists()) {
				result = orgFileName;
			}
			fos.close();

		} catch (Exception e) {
			// e.printStackTrace();
			result = "ERROR:" + e.getMessage();
			// out.println("ERROR:Truong du lieu qua 254 ky tu. Vui long kiem tra lai.");
		}
		return result;
	}

	public static String subColumnName(String columnName) {
		int length = columnName.length();
		if (length > 10) {
			columnName = columnName.substring(0, 9);
		}
		return columnName;
	}

	public static String getCurrentTime() {
		Calendar cal = Calendar.getInstance();
		String format = "_yyyyMMddHHmmss";
		DateFormat dateFormat = new SimpleDateFormat(format);
		return dateFormat.format(cal.getTime());
	}
%>