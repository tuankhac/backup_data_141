<%@page import="java.io.ByteArrayOutputStream"%>
<%@page
	import="java.io.IOException,java.sql.Connection,java.sql.PreparedStatement"%>
<%@page
	import="java.sql.ResultSet,java.sql.ResultSetMetaData,java.sql.SQLException"%>
<%@page
	import="java.text.SimpleDateFormat,java.util.Date,java.util.concurrent.Callable"%>
<%@page
	import="javax.servlet.ServletException, javax.servlet.http.HttpServlet"%>
<%@page
	import="javax.servlet.http.HttpServletRequest,javax.servlet.http.HttpServletResponse"%>
<%@page
	import="org.apache.poi.hssf.usermodel.HSSFWorkbook,org.apache.poi.ss.usermodel.Cell"%>
<%@page
	import="org.apache.poi.ss.usermodel.CellStyle,org.apache.poi.ss.usermodel.Row"%>
<%@page
	import="org.apache.poi.ss.usermodel.Sheet,org.apache.poi.ss.usermodel.Workbook"%>
<%@page
	import="org.apache.poi.xssf.usermodel.XSSFWorkbook,neo.velocity.common.Utility"%>

<%
	String param = request.getParameter("param");
	String condition = request.getParameter("condition");
	String cW = request.getParameter("cW");
	String filter = request.getParameter("filter");

	String sqlWhere = "";
	boolean isSelectAll = false;
	if (filter != null) {
		isSelectAll = filter.equals("1");
	}
	if (condition != null) {
		if ("1".equals(condition)) {
			sqlWhere = "where ma_tinh = ? and Ma_Cqt_Ql = ?";
		} else if ("2".equals(condition)) {
			sqlWhere = "where ma_tinh = ? and Ma_Cqt_Ql = ? and ma_nv is null";
		} else if ("3".equals(condition)) {
			sqlWhere = "nnt where nnt.ma_tinh = ? and nnt.ma_cqt_ql = ? and nnt.ma_nv  = ? ";
		}
	}

	String[] arr = param.split(keySplit);
	String fileName = "DS_MST_NV";
	SimpleDateFormat spd = new SimpleDateFormat("_ddMMyyyy_HHmmss");
	Date date = new Date();
	fileName += spd.format(date);
	
	ByteArrayOutputStream result = start(param, sqlWhere, cW, isSelectAll, condition);
	byte[] data = result.toByteArray();
	
	response.setContentType("application/vnd.ms-excel");
	if (arr[arr.length - 1].equals("xls"))
		response.setHeader("Content-Disposition", "attachment; filename=" + fileName + ".xls");
	if (arr[arr.length - 1].equals("xlsx"))
		response.setHeader("Content-Disposition", "attachment; filename=" + fileName + ".xlsx");
	if (arr[arr.length - 1].equals("csv"))
		response.setHeader("Content-Disposition", "attachment; filename=" + fileName + ".csv");

	
	ServletOutputStream sos = response.getOutputStream();
	sos.write(data);
	sos.flush();
	sos.close();
%>
<%!private static Connection conn = null;
	public String src = "";
	public String keySplit = ",";
	private PreparedStatement pstmt;
	private ResultSet rs;

	public ByteArrayOutputStream start(String param, String sqlWhere, String cW, boolean isSelectAll,
			String condition) {
		ByteArrayOutputStream result = null;

		String openConnect = openConnection();
		if(openConnect.equals("FAIL")){
			result = new ByteArrayOutputStream(openConnect.length());
			try{
				result.write(openConnect.getBytes("UTF-8"));
				result.write(": Loi ket noi CSDL".getBytes("UTF-8"));
			}catch(IOException ie){
			}
			return result;
		}
		String[] arr_param = param.split(keySplit);

		String[] arr_cW = cW.split(keySplit);
		// lay dinh dang in ra
		String type = arr_param[arr_param.length - 1];
		// lay table can chon
		String table = arr_param[arr_param.length - 2];

		StringBuffer sql = new StringBuffer();
		if (isSelectAll) {
			sql.append("SELECT * FROM " + table);
			if (!"".equals(sqlWhere)) {
				sql.append(" " + sqlWhere);
			}
		} else {
			sql.append("SELECT ");
			for (int i = 0; i < arr_param.length - 2; i++)
				sql.append(arr_param[i] + ",");
			sql.deleteCharAt(sql.length() - 1);
			sql.append(" FROM " + table);
			if (!"".equals(sqlWhere)) {
				sql.append(" " + sqlWhere);
			}
		}
		try {
			PreparedStatement stm = conn.prepareStatement(sql.toString());
			if (condition.equals("1")) {
				stm.setString(1, arr_cW[0]);
				stm.setString(2, arr_cW[1]);
			} else if (condition.equals("2")) {
				stm.setString(1, arr_cW[0]);
				stm.setString(2, arr_cW[1]);
			} else if (condition.equals("3")) {
				stm.setString(1, arr_cW[0]);
				stm.setString(2, arr_cW[1]);
				stm.setString(3, arr_cW[2]);
			}

			rs = stm.executeQuery();
			if ("xls".equals(type) || "xlsx".equals(type)) {
				result = write2XLSX_XLS(arr_param, type, table);
			}
			if ("csv".equals(type)) {
				result = write2CSV(arr_param, type, table);
			}
		} catch (SQLException e) {
			result = null;
			e.printStackTrace();
		}
		closeConnection();
		return result;
	}

	public ByteArrayOutputStream write2XLSX_XLS(String[] arr, String type, String table) throws SQLException {

		ByteArrayOutputStream result = new ByteArrayOutputStream();
		ResultSetMetaData rsmd;
		rsmd = rs.getMetaData();
		int row_num = 1;
		Workbook wb = null;

		wb = "xls".equals(type) ? new HSSFWorkbook() : new XSSFWorkbook();
		Sheet sheet = wb.createSheet(table);

		for (int i = 1; i <= rsmd.getColumnCount(); i++)
			sheet.autoSizeColumn(i - 1);
		Row header = sheet.createRow(0);
		header.setHeight((short) 500);
		for (int i = 1; i <= rsmd.getColumnCount(); i++) {
			Cell c_header = header.createCell(i - 1);
			c_header.setCellValue(rsmd.getColumnName(i));
			c_header.setCellType(CellStyle.SOLID_FOREGROUND);
		}

		try {
			while (rs.next()) {
				Row row = sheet.createRow(row_num);
				for (int i = 1; i <= rsmd.getColumnCount(); i++)
					if ("".equals(rs.getString(i))) {
						Cell cell = row.createCell(i - 1);
						cell.setCellValue("null");
					} else {
						Cell cell = row.createCell(i - 1);
						cell.setCellValue(rs.getString(i));
					}
				row_num++;
			}
			wb.write(result);
		} catch (SQLException e) {
			result = null;
			e.printStackTrace();
		} catch (IOException io) {
			result = null;
		}
		return result;
	}

	public ByteArrayOutputStream write2CSV(String[] arr, String type, String table) {
		ByteArrayOutputStream result = new ByteArrayOutputStream();
		ResultSetMetaData rsmd;
		try {
			rs.next();
			rsmd = rs.getMetaData();
			for (int i = 1; i <= rsmd.getColumnCount(); i++) {
				result.write(rsmd.getColumnName(i).getBytes("UTF-8"));
				result.write(",".getBytes("UTF-8"));
				result.flush();
			}
			result.write("\n".getBytes("UTF-8"));
			while (rs.next()) {
				for (int i = 1; i <= rsmd.getColumnCount(); i++) {
					result.write(rs.getString(i).getBytes("UTF-8"));
					result.write(",".getBytes("UTF-8"));
					result.flush();
				}
				result.write("\n".getBytes("UTF-8"));
			}
		} catch (SQLException e) {
			result = null;
			e.printStackTrace();
		} catch (IOException e) {
			result = null;
			e.printStackTrace();
		}
		return result;
	}

	public String openConnection() {
		String result = "";
		Utility u = new Utility();
		try {
			conn = u.getConnection("crud");
			System.out.println("connect success");
			result = "OK";
		} catch (Exception e) {
			result = "FAIL";
			e.printStackTrace();
		}
		return result;
	}

	public void closeConnection() {
		try {
			if (pstmt != null)
				pstmt.close();
			if (conn != null) {
				conn.close();
				System.out.println("disconnect success");
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}%>
