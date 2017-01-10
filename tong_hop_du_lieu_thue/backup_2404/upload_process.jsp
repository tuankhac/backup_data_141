<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@ page contentType="text/html; charset=utf-8" language="java"%>
<%@ page
	import="org.apache.commons.fileupload.util.Streams,java.io.*,java.util.*,javax.servlet.*,neo.*,com.aspose.cells.*, com.lowagie.text.pdf.codec.Base64,  org.apache.commons.fileupload.servlet.*, org.apache.commons.fileupload.*, org.apache.commons.fileupload.disk.DiskFileItemFactory, org.apache.commons.fileupload.servlet.ServletFileUpload, java.sql.PreparedStatement"%>
<%@ page
	import="com.jspsmart.upload.*,com.jspsmart.file.*,com.neo.utils.*,  java.io.BufferedReader,  java.io.File,java.sql.Statement, java.io.FileInputStream,  java.io.FileOutputStream,  java.io.IOException,  java.io.InputStreamReader,  java.sql.CallableStatement,  java.sql.Connection,  java.sql.ResultSet,  java.sql.SQLException,  java.util.zip.ZipEntry,  java.util.zip.ZipInputStream,  java.util.zip.ZipOutputStream, neo.velocity.common.Utility,  oracle.jdbc.OracleTypes,  com.github.junrar.exception.RarException, com.github.junrar.impl.FileVolumeManager, com.github.junrar.rarfile.FileHeader, com.github.junrar.Archive, org.apache.poi.xssf.usermodel.XSSFCell, org.apache.poi.xssf.usermodel.XSSFRow, org.apache.poi.xssf.usermodel.XSSFSheet, org.apache.poi.xssf.usermodel.XSSFWorkbook, org.apache.poi.hssf.usermodel.HSSFCell, org.apache.poi.hssf.usermodel.HSSFRow, org.apache.poi.hssf.usermodel.HSSFSheet, org.apache.poi.hssf.usermodel.HSSFWorkbook, org.apache.poi.poifs.filesystem.POIFSFileSystem,  org.apache.poi.hssf.usermodel.HSSFCell, org.apache.poi.hssf.usermodel.HSSFRow, org.apache.poi.hssf.usermodel.HSSFSheet, org.apache.poi.hssf.usermodel.HSSFWorkbook, org.apache.poi.poifs.filesystem.POIFSFileSystem, com.linuxense.javadbf.DBFField, com.linuxense.javadbf.DBFWriter "%>

<%
	int MAXSIZE = 1024 * 1024 * 50; //15MB
	boolean isMultipart = ServletFileUpload.isMultipartContent(request);
	HashMap<String, String> mParams = new HashMap<String, String>();
	String result = "";
	String rootFolder = getServletContext().getRealPath("/")
			+ "/tong_hop_du_lieu_thue";
	String duLieuThueFolder = "/du_lieu_thue/";
	String duLieuThanhToanFolder = "/du_lieu_thanh_toan/";
	int UPLOAD_FILE_TYPE = 0;
	int SHEET_NUMB = 0;
	if (isMultipart) {
		// Create a factory for disk-based file items
		DiskFileItemFactory factory = new DiskFileItemFactory();
 		ServletFileUpload upload = new ServletFileUpload(factory);
		upload.setHeaderEncoding("UTF-8");
		try {
			// Parse the request
			FileItemIterator iter = upload.getItemIterator(request);
			while (iter.hasNext()) {
				FileItemStream item = iter.next();
				String keyName = item.getFieldName();
				InputStream stream = item.openStream();
				if (item.isFormField()) {
					if(!mParams.containsKey(keyName)){
						mParams.put(keyName, Streams.asString(stream));
					}
					//out.println("Key= " + (keyName) + ", value= "+ Streams.asString(stream));
				} else {
					//ghi 1 file
					String fileName = getEnStringFromVnString(
							item.getName()).replaceAll(" +", "");
					String orgFileName = fileName.substring(0, fileName.lastIndexOf("."));
					String extFileName = fileName.substring(orgFileName.length()).toLowerCase();	
					UPLOAD_FILE_TYPE = Integer.parseInt(mParams.get("UPLOAD_FILE_TYPE"));
 					SHEET_NUMB = Integer.parseInt(mParams.get("sheet_numb")) -1;
 					String resultWriteFile = ghiFile(stream, fileName, UPLOAD_FILE_TYPE); 
					if(resultWriteFile.length() > 0){
						if(extFileName.equals(".xls") && UPLOAD_FILE_TYPE == 0){
 							Map<Integer, String[]>  dataXls = readXLS(rootFolder+duLieuThueFolder + resultWriteFile,SHEET_NUMB);
							if(dataXls == null || dataXls.size() <= 0){
 								result = "{RESULT:'FAIL',VALUE:'Lỗi ko có dữ liệu hoặc sheet ko tồn tại'}";
							}else{
								result = insertXlsData(dataXls, mParams);
							}
  						}
						if(extFileName.equals(".xls") && UPLOAD_FILE_TYPE == 1){
 							result = getNumbXlsColumn(rootFolder+duLieuThanhToanFolder + resultWriteFile,SHEET_NUMB);
						}
						if(!extFileName.equals(".xls")){
							File file = new File(rootFolder+duLieuThanhToanFolder + resultWriteFile);
							file.delete();
							result = "{RESULT:'FAIL',VALUE:'Định dạng file ko đúng.'}";
						}
					}else{
						result = "{RESULT:'FAIL',VALUE:'Ghi file không thành công'}";
					}
				}
			}
		}catch(NumberFormatException e){
			result = "{RESULT:'FAIL',VALUE:'Sheet nhập ở dạng số'}";
		}catch (Exception e) {
 			result = "{RESULT:'FAIL',VALUE:'"+e.getMessage()+"'}";
		}
	}
	out.print(result);
%>
<%!
	public static Map<Integer, String[]> readXLS(String path, int numbOfSheet) {
		Map<Integer, String[]> myMap = new TreeMap<Integer, String[]>();
		String[] record = null;
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
			rows.next();
			int key = 1;
			while (rows.hasNext()) {
				HSSFRow row = (HSSFRow) rows.next();
				Iterator cells = row.cellIterator();
				int i = 1;
				record = new String[42];
				while (cells.hasNext() && i < 43) {
					HSSFCell cell = (HSSFCell) cells.next();
					record[i - 1] = getCellValue(cell);
					i++;
				}
				myMap.put(key, record);
				key++;
			}
			Set<String[]> mySet = new HashSet<String[]>();
			for (Iterator itr = myMap.entrySet().iterator(); itr.hasNext();) {
				Map.Entry<Integer, String[]> entrySet = (Map.Entry) itr.next();
				String[] value = entrySet.getValue();
				if (!mySet.add(value)) {
					itr.remove();
				}
			}
		} catch (Exception e) {
			myMap =null;
			//e.printStackTrace();
			// result = ("Err xls: " + e.getMessage());
		}
		return myMap;
	}

	public static String insertXlsData(Map<Integer, String[]> myMap,
			HashMap<String, String> mParams) {
		String result = "";
		String sql = "insert into tax.nnts_uploads_temp(mcq,ma_unt,ten_unt,cbk_unt,ngay_unt,ma_nnt,ten_nnt,sac_thue,chuong,tieu_muc,dia_ban,kbnn,kythue,loaitk_nsnn,han_nop,magiao_unt,loai_tien,tien_giao,tien_con,tien_thuduoc,tien_quyettoan,so_bl,ngay_bl,sobl_unt,ngaybl_unt,ngay_banke,sonha_ct,matinh_ct,tentinh_ct,maquan_ct,tenquan_ct,maxa_ct,tenxa_ct,mobile,email,sonha_tt,matinh_tt,tentinh_tt,maquan_tt,tenquan_tt,maxa_tt,tenxa_tt,id,ma_tinh,log_user,log_ip,log_date) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,sysdate)";
		//String sqlDelTable = "delete from tax.nnts_uploads_temp where log_ip='"+mParams.get("user_ip")+"'";
		String sqlSEQ = "select NNTS_UPLOADS_TEMP_SEQ.NEXTVAL from dual";
		long mySEQ = 0;
		Statement stm = null;
		PreparedStatement ps = null;
		Connection conn = null;
		Utility u = new Utility();
		int batchSize = 1000;
		int count = 0;
		try {
			conn = u.getConnection("crud");
			stm = conn.createStatement();
			//stm.executeUpdate(sqlDelTable);
			conn.setAutoCommit(false);
			ps = conn.prepareStatement(sqlSEQ);
			ResultSet rs = ps.executeQuery();
			if(rs.next())
			   mySEQ = rs.getLong(1); 
			ps = conn.prepareStatement(sql);
			for (Iterator itr = myMap.entrySet().iterator(); itr.hasNext();) {
				Map.Entry<Integer, String[]> entrySet = (Map.Entry) itr.next();
				String[] record = entrySet.getValue();
				int key = 1;
				for (String c : record) {
					ps.setString(key, c);
					key++;
				}
				// ID
				ps.setLong(43, mySEQ);
				ps.setString(44, mParams.get("ma_tinh"));
				ps.setString(45, mParams.get("user"));
				ps.setString(46, mParams.get("user_ip"));
  				//ps.setDate(47, "");
				ps.addBatch();
				count++;
				if (count >= batchSize) {
					count = 0;
					ps.executeBatch();
				}
			}
			ps.executeBatch();
			conn.commit();
			result = "{RESULT:'OK',VALUE:'"+mySEQ+"'}";
		} catch (Exception e) {
			//e.printStackTrace();
			 result = ("Err xls: " + e.getMessage());
		} finally {
			try {
				if (ps != null) {
					ps.close();
				}
				if (stm != null) {
					stm.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch (Exception ex) {
				ex.printStackTrace();
				// result = ex.getMessage();
			}
		}
		return result;
	}
	public static String getNumbXlsColumn(String path, int numbOfSheet) {
		String result = "";String s = "";
		try {
			FileInputStream input = new FileInputStream(path);
			POIFSFileSystem fs = new POIFSFileSystem(input);
			HSSFWorkbook wb = new HSSFWorkbook(fs);
			int totalSheet = wb.getNumberOfSheets();
			if(numbOfSheet > totalSheet-1){
				return result = "{RESULT:'FAIL',VALUE:'Lỗi ko có dữ liệu hoặc sheet ko tồn tại'}";
 			}
			HSSFSheet sheet = wb.getSheetAt(numbOfSheet);
			Iterator rows = sheet.rowIterator();
			// rows.next();
			HSSFRow row = (HSSFRow) rows.next();
			Iterator cells = row.cellIterator();
			int count = 0;
			while (cells.hasNext()) {
				HSSFCell cell = (HSSFCell) cells.next();
				String cellVal = getCellValue(cell);
				if (cellVal != "") {
					s=s+",{'COLUMN_NAME':'"+cellVal+"'}";			
					count++;
				}
			}
			
 			input.close();
			result = "{'RESULT':'OK','VALUE':[" + s.substring(1) + "],'FILE_PATH':'"+path.substring(path.lastIndexOf("/"))+"'}";
		} catch (Exception e) {
			//result = "{RESULT:'FAIL',VALUE:'" + e.getMessage() + "'}";
			result = "{RESULT:'FAIL',VALUE:'Sheet ko có dữ liệu hoặc: "+e.getMessage()+"'}";
			//e.printStackTrace();
		}
		return result;
	}
	public static String getCellValue(HSSFCell cell) {
		if (cell == null) {
			return null;
		}
		if (cell.getCellType() == HSSFCell.CELL_TYPE_STRING) {
			return cell.getStringCellValue().trim().replaceAll("[\n\r]", "");
		} else if (cell.getCellType() == HSSFCell.CELL_TYPE_NUMERIC) {
			return cell.getNumericCellValue() + "";
		} else if (cell.getCellType() == HSSFCell.CELL_TYPE_BOOLEAN) {
			return cell.getBooleanCellValue() + "";
		} else if (cell.getCellType() == HSSFCell.CELL_TYPE_BLANK) {
			return cell.getStringCellValue().trim().replaceAll("[\n\r]", "");
		} else if (cell.getCellType() == HSSFCell.CELL_TYPE_ERROR) {
			return cell.getErrorCellValue() + "";
		} else {
			return null;
		}
	}
 
	public String getCurrentTime() {
		Calendar cal = Calendar.getInstance();
		String format = "_yyyyMMddHHmmss";
		DateFormat dateFormat = new SimpleDateFormat(format);
		return dateFormat.format(cal.getTime());
	}

	public String doiTenFile(String fileName) {
		fileName = fileName.replaceAll(" ", "");
		String orgFileName = fileName.substring(0, fileName.lastIndexOf("."));
		String extFileName = fileName.substring(orgFileName.length())
				.toLowerCase();
		fileName = orgFileName;
		File f = null;
		int j = 0;
		while (true) {
			f = new File(fileName + "/" + fileName + extFileName);
			if (f.exists())
				fileName = orgFileName + "" + j;
			else
				break;
			j++;
		}
		return fileName += extFileName;
	}

	private String ghiFile(InputStream in, String fileName, int type) {
		String result = "";
		File fileUploaded = null;
		String rootFolder = getServletContext().getRealPath("/")
			+ "tong_hop_du_lieu_thue";
		String duLieuThueFolder = "/du_lieu_thue/";
		String duLieuThanhToanFolder = "/du_lieu_thanh_toan/";
		String path = "";
		try {
			String orgFileName = fileName.substring(0,
					fileName.lastIndexOf("."));
			String extFileName = fileName.substring(orgFileName.length())
					.toLowerCase();
			String finalFileName = orgFileName + getCurrentTime() + extFileName;
			if(type == 0){
				path = rootFolder + duLieuThueFolder + finalFileName;
			}else if(type == 1){
				path = rootFolder + duLieuThanhToanFolder + finalFileName;
			}
			int j = 0;
			while (true) {
				fileUploaded = new File(path);
				if (fileUploaded.exists())
					finalFileName = orgFileName + getCurrentTime() + "_" + j
							+ extFileName;
				else
					break;
				j++;
			}
			fileUploaded = new File(path);
			OutputStream out = new FileOutputStream(fileUploaded);
			byte[] buf = new byte[1024];
			int len;
			while ((len = in.read(buf)) > 0) {
				out.write(buf, 0, len);
			}
			if (fileUploaded.exists())
				//ghi file thanh cong, tra ve ten file
				result = finalFileName;
			out.close();
			in.close();
		} catch (Exception e) {
			result = "{RESULT:'FAIL',VALUE:'"+ e.getMessage()+"'}";
		}
		return result;
	}

	public String vn_lower = "à,á,ả,ã,ạ,â,ầ,ấ,ẩ,ẫ,ậ,ă,ằ,ắ,ẳ,ẵ,f,è,é,ẻ,ẽ,ẹ,ê,ề,ế,ể,ễ,ệ,ì,í,ỉ,ĩ,ị,ò,ó,ỏ,õ,ọ,ô,ồ,ố,ổ,ỗ,ộ,ơ,ờ,ớ,ở,ỡ,ợ,ù,ú,ủ,ũ,ụ,ư,ừ,ứ,ử,ữ,ự,ỳ,ý,ỷ,ỹ,ỵ,đ";
	String vn_upper = "À,Á,Ả,Ã,Ạ,Â,Ầ,Ấ,Ẩ,Ẫ,Ậ,Ă,Ằ,Ắ,Ẳ,Ẵ,Ặ,È,É,Ẻ,Ẽ,Ẹ,Ê,Ề,Ế,Ể,Ễ,Ệ,Ì,Í,Ỉ,Ĩ,Ị,Ò,Ó,Ỏ,Õ,Ọ,Ô,Ồ,Ố,Ổ,Ỗ,Ộ,Ơ,Ờ,Ớ,Ở,Ỡ,Ợ,Ù,Ú,Ủ,Ũ,Ụ,Ư,Ừ,Ứ,Ử,Ữ,Ự,Ỳ,Ý,Ỷ,Ỹ,Ỵ,Đ";
	String en_lower = "a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,e,e,e,e,e,e,e,e,e,e,e,i,i,i,i,i,o,o,o,o,o,o,o,o,o,o,o,o,o,o,o,o,o,u,u,u,u,u,u,u,u,u,u,u,y,y,y,y,y,d";
	String en_upper = "A,A,A,A,A,A,A,A,A,A,A,A,A,A,A,A,A,E,E,E,E,E,E,E,E,E,E,E,I,I,I,I,I,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,U,U,U,U,U,U,U,U,U,U,U,Y,Y,Y,Y,Y,D";

	String vn_char_lower = vn_lower.replaceAll(",", "");
	String vn_char_upper = vn_upper.replaceAll(",", "");
	String en_char_lower = en_lower.replaceAll(",", "");
	String en_char_upper = en_upper.replaceAll(",", "");
	String character_iso_8859_1_map = "&quot;,&apos;,&amp;,&lt;,&gt;,&nbsp;,&iexcl;,&cent;,&pound;,&curren;,&yen;,&brvbar;,&sect;,&uml;,&copy;,&ordf;,&laquo;,&not;,&shy;,&reg;,&macr;,&deg;,&plusmn;,&sup2;,&sup3;,&acute;,&micro;,&para;,&middot;,&cedil;,&sup1;,&ordm;,&raquo;,&frac14;,&frac12;,&frac34;,&iquest;,&times;,&divide;,&Agrave;,&Aacute;,&Acirc;,&Atilde;,&Auml;,&Aring;,&AElig;,&Ccedil;,&Egrave;,&Eacute;,&Ecirc;,&Euml;,&Igrave;,&Iacute;,&Icirc;,&Iuml;,&ETH;,&Ntilde;,&Ograve;,&Oacute;,&Ocirc;,&Otilde;,&Ouml;,&Oslash;,&Ugrave;,&Uacute;,&Ucirc;,&Uuml;,&Yacute;,&THORN;,&szlig;,&agrave;,&aacute;,&acirc;,&atilde;,&auml;,&aring;,&aelig;,&ccedil;,&egrave;,&eacute;,&ecirc;,&euml;,&igrave;,&iacute;,&icirc;,&iuml;,&eth;,&ntilde;,&ograve;,&oacute;,&ocirc;,&otilde;,&ouml;,&oslash;,&ugrave;,&uacute;,&ucirc;,&uuml;,&yacute;,&thorn;,&yuml;";
	String[] character_iso_8859_1_map_arr = character_iso_8859_1_map.split(",");
	String character_unicode = "\",',&,<,>, ,¡,¢,£,¤,¥,¦,§,¨,©,ª,«,¬,�­,®,¯,°,±,²,³,´,µ,¶,·,¸,¹,º,»,¼,½,¾,¿,×,÷,À,Á,Â,Ã,Ä,Å,Æ,Ç,È,É,Ê,Ë,Ì,Í,Î,Ï,Ð,Ñ,Ò,Ó,Ô,Õ,Ö,Ø,Ù,Ú,Û,Ü,Ý,Þ,ß,à,á,â,ã,ä,å,æ,ç,è,é,ê,ë,ì,í,î,ï,ð,ñ,ò,ó,ô,õ,ö,ø,ù,ú,û,ü,ý,þ,ÿ";
	String[] character_unicode_arr = character_unicode.split(",");

	public String getEnStringFromVnString(String vnUtf8String) {
		if (vnUtf8String == null)
			return "";
		if (vnUtf8String.length() == 0)
			return "";

		String a = "";
		String s = ClearISO_8859_1_From_UTF8String(vnUtf8String);

		char b;
		for (int i = 0; i < s.length(); i++) {
			b = s.charAt(i);
			for (int j = 0; j < vn_char_lower.length(); j++) {
				if (b == vn_char_lower.charAt(j)) {
					b = en_char_lower.charAt(j);
					break;
				} else if (b == vn_char_upper.charAt(j)) {
					b = en_char_upper.charAt(j);
					break;
				}
			}

			a = a + Character.toString(b);
		}
		// String a = new String(vnChar);
		return a;
	}

	public String ClearISO_8859_1_From_UTF8String(String s) {
		try {
			if (s == null)
				return "";
			if (s.length() == 0)
				return "";

			String result = s;

			for (int i = 0; i < character_iso_8859_1_map_arr.length; i++) {
				String s1 = character_iso_8859_1_map_arr[i];
				// replace iso 8859_1 string by unicode string
				result = result.replaceAll(s1, character_unicode_arr[i]);
			}

			return result;
		} catch (Exception ex) {
			ex.printStackTrace();
			return "";
		}
	}%>