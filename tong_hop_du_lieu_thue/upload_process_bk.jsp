<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@ page contentType="text/html; charset=utf-8" language="java"%>
<%@ page
	import="org.apache.commons.fileupload.util.Streams,java.io.*,java.util.*,javax.servlet.*,neo.*, com.lowagie.text.pdf.codec.Base64,  org.apache.commons.fileupload.servlet.*, org.apache.commons.fileupload.*, org.apache.commons.fileupload.disk.DiskFileItemFactory, org.apache.commons.fileupload.servlet.ServletFileUpload, java.sql.PreparedStatement"%>
<%@ page
	import="com.jspsmart.upload.*,com.jspsmart.file.*,  java.io.BufferedReader,  java.io.File,java.sql.Statement, java.io.FileInputStream,  java.io.FileOutputStream,  java.io.IOException,  java.io.InputStreamReader,  java.sql.Statement,  java.sql.Connection,  java.sql.ResultSet,  java.sql.SQLException,  java.util.zip.ZipEntry,  java.util.zip.ZipInputStream,  java.util.zip.ZipOutputStream, neo.velocity.common.Utility,  oracle.jdbc.OracleTypes,  com.github.junrar.exception.RarException, com.github.junrar.impl.FileVolumeManager, com.github.junrar.rarfile.FileHeader, com.github.junrar.Archive, org.apache.poi.xssf.usermodel.XSSFCell, org.apache.poi.xssf.usermodel.XSSFRow, org.apache.poi.xssf.usermodel.XSSFSheet, org.apache.poi.xssf.usermodel.XSSFWorkbook, org.apache.poi.poifs.filesystem.POIFSFileSystem,  org.apache.poi.hssf.usermodel.HSSFCell, org.apache.poi.hssf.usermodel.HSSFRow, org.apache.poi.hssf.usermodel.HSSFSheet, org.apache.poi.hssf.usermodel.HSSFWorkbook, com.linuxense.javadbf.DBFField, com.linuxense.javadbf.DBFWriter "%>

<%@page
	import="javax.xml.parsers.SAXParser,javax.xml.parsers.SAXParserFactory,javax.xml.parsers.SAXParser,
	org.apache.poi.openxml4j.opc.OPCPackage,org.apache.poi.ss.usermodel.DataFormatter,org.apache.poi.xssf.eventusermodel.ReadOnlySharedStringsTable,
	org.apache.poi.xssf.eventusermodel.XSSFReader,org.apache.poi.xssf.eventusermodel.XSSFSheetXMLHandler,
	org.apache.poi.xssf.eventusermodel.XSSFSheetXMLHandler.SheetContentsHandler,org.apache.poi.xssf.model.StylesTable,
	org.xml.sax.ContentHandler,org.xml.sax.InputSource,org.xml.sax.SAXException,org.xml.sax.XMLReader"%>
<%@page
	import="org.apache.poi.openxml4j.exceptions.OpenXML4JException,org.apache.poi.openxml4j.exceptions.InvalidFormatException,
		org.apache.poi.ss.usermodel.Row,org.apache.poi.ss.usermodel.Cell,javax.xml.parsers.ParserConfigurationException"%>
<%@page import="java.util.HashMap"%>
<%!int sumRow = 0;
	long mySEQ = 0;
	int batchSize = 10000;

	Utility u = new Utility();
	SimpleDateFormat dateParse = new SimpleDateFormat("dd/MM/yyyy");
	SimpleDateFormat datetimeParse = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
	SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
	DataFormatter df = new DataFormatter();
	PreparedStatement ps = null;
	Statement stm = null;
	Connection conn = null;%>
<%
	int MAX_MEMORY_SIZE = 1024 * 1024 * 60; //60MB
	boolean isMultipart = ServletFileUpload.isMultipartContent(request);
	String result = "";
	String rootFolder = getServletContext().getRealPath("/") + "/tong_hop_du_lieu_thue";
	String duLieuThueFolder = "/du_lieu_thue/";
	String duLieuThanhToanFolder = "/du_lieu_thanh_toan/";

	HashMap<String, String> mParams = new HashMap<String, String>();
	int UPLOAD_FILE_TYPE = 0;
	// UPLOAD_FILE_TYPE = 0 : Upload dữ liệu thuế
	int SHEET_NUMB = 0;
	if (isMultipart) {
		// Create a factory for disk-based file items
		DiskFileItemFactory factory = new DiskFileItemFactory();
		factory.setSizeThreshold(MAX_MEMORY_SIZE);
		// Create a new file upload handler
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
					if (!mParams.containsKey(keyName)) {
						mParams.put(keyName, Streams.asString(stream));
					}
				} else {
					//ghi 1 file
					String fileName = getEnStringFromVnString(item.getName()).replaceAll(" +", "");
					String orgFileName = fileName.substring(0, fileName.lastIndexOf("."));
					String extFileName = fileName.substring(orgFileName.length()).toLowerCase();
					UPLOAD_FILE_TYPE = Integer.parseInt(mParams.get("UPLOAD_FILE_TYPE"));
					SHEET_NUMB = Integer.parseInt(mParams.get("sheet_numb"));
					String resultWriteFile = ghiFile(stream, fileName, UPLOAD_FILE_TYPE);
					if (resultWriteFile.length() > 0) {
						//Upload dữ liệu thuế
						int excelType = 0;
						if (extFileName.equals(".xls") && UPLOAD_FILE_TYPE == 0) {
							//thuc hien insert
							result = insertXlsData(rootFolder + duLieuThueFolder + resultWriteFile,
									SHEET_NUMB - 1, excelType, mParams);
						} else if (extFileName.equals(".xlsx") && UPLOAD_FILE_TYPE == 0) {
							excelType = 1;
							result = insertXlsData(rootFolder + duLieuThueFolder + resultWriteFile, SHEET_NUMB,
									excelType, mParams);
						}
						//Upload dữ liệu thanh toán
						if (extFileName.equals(".xls") && UPLOAD_FILE_TYPE == 1) {
							result = getNumbXlsColumn(rootFolder + duLieuThanhToanFolder + resultWriteFile,
									SHEET_NUMB - 1);
						}
						if (!extFileName.equals(".xls") && !extFileName.equals(".xlsx")) {
							File file = new File(rootFolder + duLieuThanhToanFolder + resultWriteFile);
							file.delete();
							result = "{RESULT:'FAIL',VALUE:'Định dạng file ko đúng.'}";
						}
					} else {
						result = "{RESULT:'FAIL',VALUE:'Ghi file không thành công'}";
					}
				}
			}
		} catch (NumberFormatException e) {
			result = "{RESULT:'FAIL',VALUE:'Sheet nhập ở dạng số'}";
		} catch (Exception e) {
			result = "{RESULT:'FAIL',VALUE:'" + e.getMessage() + "'}";
		}
	}
	out.print(result);
%>
<%!public String insertXlsData(String fileName, int sheetNum, int excelType, HashMap<String, String> mParams) {
		String result = "";
		String sql = "insert into tax.nnts_uploads_temp(mcq,ma_unt,ten_unt,cbk_unt,ngay_unt,ma_nnt,ten_nnt,sac_thue,chuong,tieu_muc,dia_ban,kbnn,kythue,loaitk_nsnn,han_nop,magiao_unt,loai_tien,tien_giao,tien_con,tien_thuduoc,tien_quyettoan,so_bl,ngay_bl,sobl_unt,ngaybl_unt,ngay_banke,sonha_ct,matinh_ct,tentinh_ct,maquan_ct,tenquan_ct,maxa_ct,tenxa_ct,mobile,email,sonha_tt,matinh_tt,tentinh_tt,maquan_tt,tenquan_tt,maxa_tt,tenxa_tt,id,ma_tinh,log_user,log_ip,log_date) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,'"
				+ mParams.get("ma_tinh") + "','" + mParams.get("user") + "','" + mParams.get("user_ip") + "',sysdate)";
		String sqlSEQ = "select NNTS_UPLOADS_TEMP_SEQ.NEXTVAL from dual";

		try {
			conn = u.getConnection("crud");

			stm = conn.createStatement();
			ResultSet rs = stm.executeQuery(sqlSEQ);
			if (rs.next())
				mySEQ = rs.getLong(1);

			conn.setAutoCommit(false);
			ps = conn.prepareStatement(sql);
			if (excelType == 1) {
				result = readFileExcelXLSX(fileName, sheetNum, mySEQ);
			} else {
				result = readXLS(fileName, sheetNum, mySEQ);
			}

		} catch (Exception e) {
			result = ("Err xls: " + e.getMessage());
		} finally {
			try {
				if (ps != null) {
					ps.close();
				}
				if (conn != null) {
					conn.close();
				}
				if (stm != null) {
					stm.close();
				}
			} catch (Exception ex) {
				ex.printStackTrace();
			}
		}
		return result;
	}

	public String readFileExcelXLSX(String fileName, int numSheet, long mySEQ) throws IOException {
		String result = "";
		File file = new File(fileName);
		if (!file.exists()) {
			System.out.println("");
			return "File not found";
		}
		OPCPackage container = null;
		try {
			container = OPCPackage.open(file);
			ReadOnlySharedStringsTable strings = new ReadOnlySharedStringsTable(container);
			XSSFReader xssfReader = new XSSFReader(container);
			StylesTable styles = xssfReader.getStylesTable();
			InputStream stream = xssfReader.getSheet("rId" + numSheet);
			if (stream != null) {
				result = processSheet(styles, strings, stream);

				ps.executeBatch();
				conn.commit();
				stream.close();
				result = "{RESULT:'OK',VALUE:'" + mySEQ + "'}";
			} else {
				result = "{RESULT:'FAIL',VALUE:'Lỗi ko có dữ liệu hoặc sheet ko tồn tại'}";
			}
		} catch (SAXException e) {
			return e.getMessage();
		} catch (SQLException e) {
			return e.getMessage();
		} catch (InvalidFormatException e) {
			e.printStackTrace();
		} catch (OpenXML4JException e) {
			return e.getMessage();
		} finally {
			if (container != null) {
				container.close();
			}
		}
		return result;
	}

	private String processSheet(StylesTable styles, ReadOnlySharedStringsTable strings, InputStream sheetInputStream)
			throws IOException, SAXException {

		InputSource sheetSource = new InputSource(sheetInputStream);
		SAXParserFactory saxFactory = SAXParserFactory.newInstance();
		String result = "OK";
		try {
			SAXParser saxParser = saxFactory.newSAXParser();
			XMLReader sheetParser = saxParser.getXMLReader();
			ContentHandler handler = new XSSFSheetXMLHandler(styles, strings, new SheetContentsHandler() {
				List<String> list = new ArrayList<String>();

				@Override
				public void startRow(int rowNum) {
					sumRow = rowNum;
				}

				@Override
				public void endRow() {
					if (sumRow > 1) {
						try {
							//sau moi dong thuc hien insert vao bang temp
							updateDB(list);
							if (sumRow % batchSize == 0) {
								try {
									ps.executeBatch();
								} catch (Exception e) {
									System.out.println(e.toString());
								}
								ps.clearBatch();
								conn.commit();
							}

						} catch (SQLException e) {
							e.printStackTrace();
						}
					}
					list.clear();
				}

				@Override
				public void cell(String cellReference, String value) {
					if(cellReference.matches("(E|O|W|Y|Z)\\d+")){
						if("".equals(value)){
							list.add(value);
						}else{
							try {
								Date out_date = datetimeParse.parse(value);
								list.add(dateFormat.format(out_date));
							} catch (Exception e) {
								try {
									Date out_date = dateParse.parse(value);
									list.add(dateFormat.format(out_date));
								} catch (Exception ce) {
									list.add(value);
								}
							}
						}
					}else{
						list.add(value);
					}
				}

				@Override
				public void headerFooter(String text, boolean isHeader, String tagName) {
				}

			}, false);
			sheetParser.setContentHandler(handler);
			sheetParser.parse(sheetSource);
		} catch (ParserConfigurationException e) {
			throw new RuntimeException("SAX parser appears to be broken - " + e.getMessage());
		}
		return result;
	}

	public String readXLS(String path, int numbOfSheet, long mySEQ) {
		List<String> list = null;
		String result = "";
		try {
			FileInputStream input = new FileInputStream(path);
			POIFSFileSystem fs = new POIFSFileSystem(input);
			HSSFWorkbook wb = new HSSFWorkbook(fs);
			int totalSheet = wb.getNumberOfSheets();
			if (numbOfSheet > totalSheet - 1) {
				return "Sheet không tồn tại";
			}
			HSSFSheet sheet = wb.getSheetAt(numbOfSheet);
			Iterator<Row> rows = sheet.rowIterator();
			for (int i = 0; i < 2; i++)
				rows.next();

			int count = 0;
			while (rows.hasNext()) {
				HSSFRow row = (HSSFRow) rows.next();
				Iterator<Cell> cells = row.cellIterator();
				int i = 1;
				list = new ArrayList<String>();
				while (cells.hasNext() && i < 43) {
					HSSFCell cell = (HSSFCell) cells.next();
					list.add(getCellValue(cell));
					i++;
				}
				updateDB(list);
				if (++count % batchSize == 0) {
					try {
						ps.executeBatch();
						ps.clearBatch();
						conn.commit();
					} catch (Exception e) {
						System.out.println(e.toString());
					}
					count = 0;
				}
			}
			ps.executeBatch();
			ps.clearBatch();
			conn.commit();
			result = "{RESULT:'OK',VALUE:'" + mySEQ + "'}";
		} catch (SQLException e) {
			return "{RESULT:'FAIL',VALUE:'Lỗi ko có dữ liệu hoặc file ko tồn tại'}";
		} catch (IOException e) {
			return "{RESULT:'FAIL',VALUE:'Đọc file bị lỗi'}";
		}
		return result;
	}

	private void updateDB(List<String> list) {
		if (conn == null) {
			System.out.println("Connect fail");
			return;
		}
		try {
			String value = "";
			for (int i = 0; i < 42; i++) {
				value = i < list.size() ? list.get(i) : null;
				ps.setString(i + 1, value);
			}
			// ID
			ps.setLong(43, mySEQ);
			ps.addBatch();

			ps.clearParameters();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public static String getNumbXlsColumn(String path, int numbOfSheet) {
		String result = "";
		String s = "";
		try {
			FileInputStream input = new FileInputStream(path);
			POIFSFileSystem fs = new POIFSFileSystem(input);
			HSSFWorkbook wb = new HSSFWorkbook(fs);
			int totalSheet = wb.getNumberOfSheets();
			if (numbOfSheet > totalSheet - 1) {
				return result = "{RESULT:'FAIL',VALUE:'Lỗi ko có dữ liệu hoặc sheet ko tồn tại'}";
			}
			HSSFSheet sheet = wb.getSheetAt(numbOfSheet);
			Iterator<Row> rows = sheet.rowIterator();
			// rows.next();
			HSSFRow row = (HSSFRow) rows.next();
			Iterator<Cell> cells = row.cellIterator();
			int count = 0;
			while (cells.hasNext()) {
				HSSFCell cell = (HSSFCell) cells.next();
				String cellVal = getCellValue(cell);
				if (cellVal != "") {
					s = s + ",{'COLUMN_NAME':'" + cellVal + "'}";
					count++;
				}
			}

			input.close();
			result = "{'RESULT':'OK','VALUE':[" + s.substring(1) + "],'FILE_PATH':'"
					+ path.substring(path.lastIndexOf("/")) + "'}";
		} catch (Exception e) {
			result = "{RESULT:'FAIL',VALUE:'Sheet ko có dữ liệu hoặc: " + e.getMessage() + "'}";
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

	public static String getCellXSSFValue(XSSFCell cell) {
		if (cell == null) {
			return null;
		}
		if (cell.getCellType() == XSSFCell.CELL_TYPE_STRING) {
			return cell.getStringCellValue();
		} else if (cell.getCellType() == XSSFCell.CELL_TYPE_NUMERIC) {
			return cell.getNumericCellValue() + "";
		} else if (cell.getCellType() == XSSFCell.CELL_TYPE_BOOLEAN) {
			return cell.getBooleanCellValue() + "";
		} else if (cell.getCellType() == XSSFCell.CELL_TYPE_BLANK) {
			return cell.getStringCellValue();
		} else if (cell.getCellType() == XSSFCell.CELL_TYPE_ERROR) {
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
		String extFileName = fileName.substring(orgFileName.length()).toLowerCase();
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
		String rootFolder = getServletContext().getRealPath("/") + "tong_hop_du_lieu_thue";
		String duLieuThueFolder = "/du_lieu_thue/";
		String duLieuThanhToanFolder = "/du_lieu_thanh_toan/";
		String path = "";
		try {
			String orgFileName = fileName.substring(0, fileName.lastIndexOf("."));
			String extFileName = fileName.substring(orgFileName.length()).toLowerCase();
			String finalFileName = orgFileName + getCurrentTime() + extFileName;
			if (type == 0) {
				path = rootFolder + duLieuThueFolder + finalFileName;
			} else if (type == 1) {
				path = rootFolder + duLieuThanhToanFolder + finalFileName;
			}
			int j = 0;
			while (true) {
				fileUploaded = new File(path);
				if (fileUploaded.exists())
					finalFileName = orgFileName + getCurrentTime() + "_" + j + extFileName;
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
			result = "{RESULT:'FAIL',VALUE:'" + e.getMessage() + "'}";
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