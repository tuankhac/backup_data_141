<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@ page contentType="text/html; charset=utf-8" language="java"%>
<%@ page
	import="org.apache.commons.fileupload.util.Streams,java.io.*,java.util.*,javax.servlet.*,neo.*,com.aspose.cells.*, com.lowagie.text.pdf.codec.Base64,  org.apache.commons.fileupload.servlet.*, org.apache.commons.fileupload.*, org.apache.commons.fileupload.disk.DiskFileItemFactory, org.apache.commons.fileupload.servlet.ServletFileUpload, java.sql.PreparedStatement"%>
<%@ page
	import="com.jspsmart.upload.*,com.jspsmart.file.*,com.neo.utils.*,  java.io.BufferedReader,  java.io.File,java.sql.Statement, java.io.FileInputStream,  java.io.FileOutputStream,  java.io.IOException,  java.io.InputStreamReader,  java.sql.CallableStatement,  java.sql.Connection,  java.sql.ResultSet,  java.sql.SQLException,  java.util.zip.ZipEntry,  java.util.zip.ZipInputStream,  java.util.zip.ZipOutputStream, neo.velocity.common.Utility,  oracle.jdbc.OracleTypes,  com.github.junrar.exception.RarException, com.github.junrar.impl.FileVolumeManager, com.github.junrar.rarfile.FileHeader, com.github.junrar.Archive, org.apache.poi.xssf.usermodel.XSSFCell, org.apache.poi.xssf.usermodel.XSSFRow, org.apache.poi.xssf.usermodel.XSSFSheet, org.apache.poi.xssf.usermodel.XSSFWorkbook, org.apache.poi.hssf.usermodel.HSSFCell, org.apache.poi.hssf.usermodel.HSSFRow, org.apache.poi.hssf.usermodel.HSSFSheet, org.apache.poi.hssf.usermodel.HSSFWorkbook, org.apache.poi.poifs.filesystem.POIFSFileSystem,  org.apache.poi.hssf.usermodel.HSSFCell, org.apache.poi.hssf.usermodel.HSSFRow, org.apache.poi.hssf.usermodel.HSSFSheet, org.apache.poi.hssf.usermodel.HSSFWorkbook, org.apache.poi.poifs.filesystem.POIFSFileSystem, org.apache.poi.ss.usermodel.DateUtil"%>

<%
 	HashMap<String, String> mParams = new HashMap<String, String>();
	String[] mXlsColumnName = null;
	String result = "";
	String file_name = request.getParameter("PATH");
	String rootFolder = getServletContext().getRealPath("/") + "/tong_hop_du_lieu_thue";
 	String duLieuThanhToanFolder = "/du_lieu_thanh_toan/";
	String log_user = request.getUserPrincipal().getName();
	String log_ip = request.getRemoteAddr();
	String list_column = request.getParameter("LIST_COLUMN");
	int SHEET_NUMB = 0;
	try {
		mParams.put("log_user",log_user);
		mParams.put("log_ip",log_ip);
		if(list_column!=null || list_column.length() > 0 ){
			mXlsColumnName = list_column.split(",");
		}
		if(file_name == null || file_name.length() == 0){
			result = "{RESULT:'FAIL',VALUE:'File không tồn tại.'}";
			return;
		}else{
			SHEET_NUMB = Integer.parseInt(request.getParameter("sheet_numb")) -1;
			Map<Integer, HashMap<Integer, String>> dataXls = readXLS(rootFolder+duLieuThanhToanFolder + file_name,mXlsColumnName,SHEET_NUMB);
			if(dataXls == null  ){
				result = "{RESULT:'FAIL',VALUE:'Lỗi file excel hoặc ko có dữ liệu'}";
			}else{
				result = insertXlsData(dataXls, mParams);
			}
 		}
	}catch(NumberFormatException e){
			result = "{RESULT:'FAIL',VALUE:'Sheet nhập ở dạng số'}";
 	} catch (Exception e) {
		result = "{RESULT:'FAIL',VALUE:'"+e.getMessage()+"'}";
	}
	out.print(result);
	//1,5,6,7,4,18,20,22,2,16,8,19,9,10,12,13,14,21,15,17,3,23,
	//5,6,7,4,18,20,22,2,16,8,19,9,10,12,13,14,21,15,17,3,23,

%>
<%!
	public static Map<Integer, HashMap<Integer, String>> readXLS(String path,
			String[] mXlsColumnName, int numbOfSheet) {
		Map<Integer, HashMap<Integer, String>> myMap = new HashMap<Integer, HashMap<Integer, String>>();
		HashMap<Integer, String> record = null;
		try {
			FileInputStream input = new FileInputStream(path);
			POIFSFileSystem fs = new POIFSFileSystem(input);
			HSSFWorkbook wb = new HSSFWorkbook(fs);
			int totalSheet = wb.getNumberOfSheets();
			if(numbOfSheet > totalSheet-1){
				return null;
 			}
			HSSFSheet sheet = wb.getSheetAt(numbOfSheet);
			Iterator rows = sheet.rowIterator();
			rows.next();
			int key = 1;
			while (rows.hasNext()) {
				HSSFRow row = (HSSFRow) rows.next();
				record = new HashMap<Integer, String>();
				for (int j = 1; j <= mXlsColumnName.length; j++) {
					HSSFCell cell = row.getCell(j-1);
					String val = mXlsColumnName[j - 1];
					int objKey= 0;
					if(!val.equals("")){
						objKey = Integer.parseInt(val);
					}
 					if (cell == null) {
						cell = row.createCell(j-1, HSSFCell.CELL_TYPE_BLANK);
						record.put(objKey, "");
					} else {
						record.put(objKey, getCellValue(cell));
					}
				}
				myMap.put(key, record);
				key++;
			}
			/*
			 * Set<String[]> mySet = new HashSet<String[]>(); for (Iterator itr
			 * = myMap.entrySet().iterator(); itr.hasNext();) {
			 * Map.Entry<Integer, String[]> entrySet = (Map.Entry) itr.next();
			 * String[] value = entrySet.getValue(); if (!mySet.add(value)) {
			 * itr.remove(); } }
			 */
		} catch (Exception e) {
			myMap = null;
			//result = "{RESULT:'FAIL',VALUE:'"+e.getMessage()+"'}";
			//result = ("Err xls: " + e.getMessage());
		}
		return myMap;
	}

	public static String insertXlsData(
			Map<Integer, HashMap<Integer, String>> myMap,
			HashMap<String, String> mParams) {
		String result = "";
		String sql = "insert into tax.thanhtoan_upload_temp(ma_cqt,ma_goi_tin,ma_kho_bac,ngay_kho_bac,mst,ten_nnt,diachi_nnt,so_qd,so_lenh_hoan,ngay_lenh_hoan,mcq,tk_no,tk_co,tien_te,ty_gia,so_chung_tu,nien_do,chuong,khoan,tieu_muc,ky_thue,so_tien,upload_id,log_user,log_ip) "
				+ " values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
		String sqlSEQ = "select UPLOADS_THANHTOAN_TEMP_SEQ.NEXTVAL from dual";
		long mySEQ = 0;
		PreparedStatement ps = null;
		Connection conn = null;
		Utility u = new Utility();
		int batchSize = 1000;
		int count = 0;
		try {
			conn = u.getConnection("crud");
			conn.setAutoCommit(false);
			ps = conn.prepareStatement(sqlSEQ);
			ResultSet rs = ps.executeQuery();
			if (rs.next())
				mySEQ = rs.getLong(1);
			ps = conn.prepareStatement(sql);
			for (Iterator itr = myMap.entrySet().iterator(); itr.hasNext();) {
				Map.Entry<Integer, HashMap<Integer, String>> entrySet = (Map.Entry) itr
						.next();
				HashMap<Integer, String> record = entrySet.getValue();
				for (int key = 1; key < 23; key++) {
					if (key == 4 || key == 10) {
						String dateInput = record.get(key);
 
						if(dateInput == "" || dateInput == null){
							ps.setDate( key,   null );
						}else{
							Date myDate = null;
							try{
								Double dateNumb = (double) Double.parseDouble(dateInput);
								  myDate = DateUtil.getJavaDate(dateNumb);
							}catch(NumberFormatException e){
								SimpleDateFormat format = new SimpleDateFormat("mm/dd/yyyy");
								  myDate = format.parse(dateInput);
							}
							java.sql.Date mySqlDate = new java.sql.Date(myDate.getTime());
							ps.setDate( key, (record.containsKey(key) ? mySqlDate : null));
						}
						continue;
					} else if (key == 0) {

					} else {
						ps.setString(key, (record.containsKey(key) ? record.get(key) : null));
					}
				}
				
				ps.setLong(23, mySEQ);
				ps.setString(24, mParams.get("log_user"));
 				ps.setString(25, mParams.get("log_ip"));
				ps.addBatch();
				count++;
				if (count >= batchSize) {
					count = 0;
					ps.executeBatch();
				}
			}
			ps.executeBatch();
			conn.commit();
			result = "{RESULT:'OK',VALUE:'" + mySEQ + "'}";
		}  catch(NumberFormatException e){
			result = "{RESULT:'FAIL',VALUE:'Sai định dạng ngày (mm/dd/yyyy)'}";
		} catch (Exception e) {
			//e.printStackTrace();
			result = "{RESULT:'FAIL',VALUE:'"+e.getMessage()+"'}";
		} finally {
			try {
				if (ps != null) {
					ps.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch (Exception ex) {
				//ex.printStackTrace();
				result = "{RESULT:'FAIL',VALUE:'"+ex.getMessage()+"'}";
			}
		}
		return result;
	}
	
	public static String getCellValue(HSSFCell cell) {
		if (cell == null) {
			return null;
		}
		if (cell.getCellType() == HSSFCell.CELL_TYPE_STRING) {
			return cell.getStringCellValue().trim();
		} else if (cell.getCellType() == HSSFCell.CELL_TYPE_NUMERIC) {
			return cell.getNumericCellValue() + "";
		} else if (cell.getCellType() == HSSFCell.CELL_TYPE_BOOLEAN) {
			return cell.getBooleanCellValue() + "";
		} else if (cell.getCellType() == HSSFCell.CELL_TYPE_BLANK) {
			return cell.getStringCellValue();
		} else if (cell.getCellType() == HSSFCell.CELL_TYPE_ERROR) {
			return cell.getErrorCellValue() + "";
		} else {
			return null;
		}
	}

%>