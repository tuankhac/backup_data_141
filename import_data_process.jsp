<%@ page contentType="text/html; charset=utf-8" language="java"%>
<%@ page import="java.io.*,java.util.*,javax.servlet.*,neo.*,com.aspose.cells.*, com.lowagie.text.pdf.codec.Base64" %>
<%@ page import="com.jspsmart.upload.*,com.jspsmart.file.*,com.neo.utils.*,  java.io.BufferedReader,  java.io.File,  java.io.FileInputStream,  java.io.FileOutputStream,  java.io.IOException,  java.io.InputStreamReader,  java.sql.CallableStatement,  java.sql.Connection,  java.sql.ResultSet,  java.sql.SQLException,  java.util.zip.ZipEntry,  java.util.zip.ZipInputStream,  java.util.zip.ZipOutputStream, neo.velocity.common.Utility,  oracle.jdbc.OracleTypes,  com.github.junrar.exception.RarException, com.github.junrar.impl.FileVolumeManager, com.github.junrar.rarfile.FileHeader, com.github.junrar.Archive, org.apache.poi.xssf.usermodel.XSSFCell, org.apache.poi.xssf.usermodel.XSSFRow, org.apache.poi.xssf.usermodel.XSSFSheet, org.apache.poi.xssf.usermodel.XSSFWorkbook, org.apache.poi.hssf.usermodel.HSSFCell, org.apache.poi.hssf.usermodel.HSSFRow, org.apache.poi.hssf.usermodel.HSSFSheet, org.apache.poi.hssf.usermodel.HSSFWorkbook, org.apache.poi.poifs.filesystem.POIFSFileSystem"%>
<%
	int  MAXSIZE  =  1024*1024*100; //5MB
	String path = application.getRealPath("/") + "import_data";
	SmartUpload mySmartUpload=new SmartUpload();
	mySmartUpload.initialize(pageContext);
	mySmartUpload.setAllowedFilesList("xls,XLS,xlsx,XLSX");
	String values = "1";
 	StringBuffer strContent = new StringBuffer("");
 	Archive archive = null;
	try{
		mySmartUpload.upload();
		java.io.File theDir = new java.io.File(path);
		if (!theDir.exists()) {
	  		theDir.mkdir();
		}
 		for (int i=0;i< mySmartUpload.getFiles().getCount();i++){
			com.jspsmart.upload.File myFile = mySmartUpload.getFiles().getFile(i);	
			if (!myFile.isMissing() ) {
				if(myFile.getSize() > MAXSIZE){
					values = "Lỗi: File max size = 5MB";
					out.print(values);
					return;
				}
				String filename = myFile.getFileName();
				filename = filename.replaceAll(" ","");
				String orgFileName = filename.substring(0,filename.lastIndexOf("."));
				String extFileName = filename.substring(orgFileName.length()).toLowerCase();
				filename = orgFileName;
				File f = null;
				int j=0;
					while (true) {
						f = new File(path + "/" + filename + extFileName);
						if (f.exists())
							filename = orgFileName + "" + j;
						else
							break;
						j++;
					}
				filename += extFileName;
				myFile.saveAs(path + "/" + filename);
				if(extFileName.equals(".xlsx")){
					String result_unzip = readXLSX(path + "/" + filename); 
					if(result_unzip.equals("1"))
						values = "Import file success.";
					else 
						values = "Import file error.";
				}else {
					String result_unzip = readXLS(path + "/" + filename); 
					if(result_unzip.equals("1"))
						values = "Import file success.";
					else 
						values = "Import file error.";

				}
 			}
		}
	}catch(Exception e){
		values = "0|ERR: " + e.toString();
	}
	out.print(values);
%>
<%!
public String readXLSX(String path ){
	String result = "";
	Utility u = new Utility();
	Connection conn = null;
	CallableStatement cstm = null;
	HashMap<String, String> data = new HashMap<String, String>();
	String[] record = null;
	try{
		conn = u.getConnection("crud");
		InputStream ExcelFileToRead = new FileInputStream(path);
		XSSFWorkbook wb = new XSSFWorkbook(ExcelFileToRead);
		XSSFSheet sheet = wb.getSheetAt(0);
		XSSFRow row;
		XSSFCell cell;
		Iterator rows = sheet.rowIterator();
		rows.next();rows.next();//bo 2 dong tieu de
 		while (rows.hasNext()) {
			row = (XSSFRow) rows.next();
			Iterator cells = row.cellIterator();
			int i = 2;
			cstm = conn.prepareCall("begin ?:= tax.report.new_nnts_temp(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);end;");
			cstm.registerOutParameter(1, OracleTypes.VARCHAR);
			record = new String[42];
			while (cells.hasNext()) {
				cell = (XSSFCell) cells.next();
				record[i-2] = getCellValue(cell);
 				cstm.setString(i,  record[i-2]);
				i++;
			}
			cstm.executeUpdate();
			result =cstm.getString(1);//get String in registerOutParameter when OracleTypes.VARCHAR
			if (result.equals("1"))
				cstm.close();conn.commit();
		}
	}catch(Exception e){
		result=("Err xlsx: "+e);
	}finally {
		try {
			if (cstm != null) {
				cstm.close();
			}
			if (conn != null) {
				conn.close();
			}
		} catch (Exception ex) {
			result = ex.getMessage();
		}
	}
	return result;
}
public String readXLS(String path ){
	String result = "";
	Utility u = new Utility();
	Connection conn = null;
	CallableStatement cstm = null;
	HashMap<String, String> data = new HashMap<String, String>();
	String[] record = null;
	try {
		conn = u.getConnection("crud");
		FileInputStream input = new FileInputStream(path);
		POIFSFileSystem fs = new POIFSFileSystem(input);
		HSSFWorkbook wb = new HSSFWorkbook(fs);
		HSSFSheet sheet = wb.getSheetAt(0);
		Iterator rows = sheet.rowIterator();
		rows.next();
		rows.next();
		while (rows.hasNext()) {
			HSSFRow row = (HSSFRow) rows.next();
			Iterator cells = row.cellIterator();
			int i = 2;
			cstm = conn
					.prepareCall("begin ?:= tax.report.new_nnts_temp(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);end;");
			cstm.registerOutParameter(1, OracleTypes.VARCHAR);
			record = new String[42];

			while (cells.hasNext()) {
				HSSFCell cell = (HSSFCell) cells.next();
				record[i - 2] = getCellValue(cell);
				cstm.setString(i, record[i - 2]);
				i++;

			}
			cstm.executeUpdate();
			result = cstm.getString(1);
			if (result.equals("1"))				
			cstm.close();conn.commit();
		}

	} catch (Exception e) {
		result = ("Err xls: " + e.getMessage());
	} finally {
		try {
			if (cstm != null) {
				cstm.close();
			}
			if (conn != null) {
				conn.close();
			}
		} catch (Exception ex) {
			result = ex.getMessage();
		}
	}
	return result;
}
public String getCellValue(XSSFCell cell) {
    if (cell == null) {
        return null;
    }
    if (cell.getCellType() == XSSFCell.CELL_TYPE_STRING) {
        return cell.getStringCellValue();
    } else if (cell.getCellType() == XSSFCell.CELL_TYPE_NUMERIC) {
        return cell.getNumericCellValue() + "";
    } else if (cell.getCellType() == XSSFCell.CELL_TYPE_BOOLEAN) {
        return cell.getBooleanCellValue() + "";
    }else if(cell.getCellType() == XSSFCell.CELL_TYPE_BLANK){
        return cell.getStringCellValue();
    }else if(cell.getCellType() == XSSFCell.CELL_TYPE_ERROR){
        return cell.getErrorCellValue() + "";
    } 
    else {
        return null;
    }
}

public String getCellValue(HSSFCell cell) {
    if (cell == null) {
        return null;
    }
    if (cell.getCellType() == HSSFCell.CELL_TYPE_STRING) {
        return cell.getStringCellValue();
    } else if (cell.getCellType() == HSSFCell.CELL_TYPE_NUMERIC) {
        return cell.getNumericCellValue() + "";
    } else if (cell.getCellType() == HSSFCell.CELL_TYPE_BOOLEAN) {
        return cell.getBooleanCellValue() + "";
    }else if(cell.getCellType() == HSSFCell.CELL_TYPE_BLANK){
        return cell.getStringCellValue();
    }else if(cell.getCellType() == HSSFCell.CELL_TYPE_ERROR){
        return cell.getErrorCellValue() + "";
    } 
    else {
        return null;
    }
}
%>