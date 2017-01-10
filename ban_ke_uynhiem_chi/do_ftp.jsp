<%@ page contentType="text/html; charset=utf-8" language="java"%>
<%@ page import="java.io.ByteArrayOutputStream , java.io.File , java.io.FileInputStream , java.io.FileOutputStream , java.io.IOException , java.io.InputStream , java.sql.Connection , java.util.HashMap , java.util.Map ,neo.velocity.common.Utility , net.sf.jasperreports.engine.JRException , net.sf.jasperreports.engine.JasperExportManager , net.sf.jasperreports.engine.JasperFillManager , net.sf.jasperreports.engine.JasperPrint , net.sf.jasperreports.engine.JasperReport , net.sf.jasperreports.engine.export.JRHtmlExporter , net.sf.jasperreports.engine.export.JRHtmlExporterParameter , net.sf.jasperreports.engine.export.JRXlsExporter , net.sf.jasperreports.engine.export.JRXlsExporterParameter , net.sf.jasperreports.engine.query.JRQueryExecuterFactory , net.sf.jasperreports.engine.util.JRLoader , net.sf.jasperreports.engine.util.JRProperties , org.apache.commons.net.ftp.FTP , org.apache.commons.net.ftp.FTPClient , org.apache.http.client.ClientProtocolException, com.neo.utils.*, java.text.SimpleDateFormat, java.text.DateFormat, java.util.Calendar" %>
<%
	Connection conn = null;
	Utility u = new Utility();
	Map params = new HashMap<String, String>();
	String result = "";
	String jasperPath = "E:/tax/Server/webapps/ROOT/WEB-INF/templates/jasper/";
	String exportType = request.getParameter("jasperExportType");
	String downloadDir = "E:/tax/Server/webapps/ROOT/ban_ke_uynhiem_chi/file_download/";
	String fileNames = request.getParameter("jasperFile");
	params.put("jasperFile", jasperPath+fileNames+".jasper");
	params.put("jasperExportType", exportType);
	params.put("AGENT", request.getParameter("AGENT"));
	params.put("IMAGE_PATH", request.getParameter("IMAGE_PATH"));
	params.put("NGAY_TT", request.getParameter("NGAY_TT"));
	params.put("KHO_BAC", request.getParameter("KHO_BAC"));
	params.put("MA_KHOBAC", request.getParameter("MA_KHOBAC"));
	params.put("PHUONG", request.getParameter("PHUONG"));
	params.put("LOAITHUE", request.getParameter("LOAITHUE"));
 
	try {
		conn = u.getConnection("crud");
		if(exportType.equals("PDF")){
			fileNames = downloadDir+ fileNames+ getCurrentTime()+".pdf";
		}else {
			fileNames = downloadDir+ fileNames+ getCurrentTime()+".xls";
		}
 		FileOutputStream fileOuputStream =  new FileOutputStream(fileNames); 
		fileOuputStream.write(makeJasperReport(params, conn));
		fileOuputStream.close();
		String doFtp = doFTP(fileNames);
		
		if(doFtp.equals("1")){
			result = "{RESULT:'OK',VALUE:'1'}";
		}else{
			result = "{RESULT:'FAIL',VALUE:'FTP file ko thanh cong.'}";
		}
		
	} catch (Exception e) {
		//result = "{RESULT:'FAIL',VALUE:'"+e.getMessage()+"'}";
 		e.printStackTrace();
	}
 	out.print(result);
%>
<%!
 public byte[] makeJasperReport(Map Parameters, Connection conn) throws IllegalStateException, ClientProtocolException, IOException {
	ByteArrayOutputStream o = new ByteArrayOutputStream();
	try {
 	   JasperReport jasperReport = (JasperReport) JRLoader.loadObject(new FileInputStream(new File(Parameters.get("jasperFile").toString())));
	   jasperReport.setProperty( "net.sf.jasperreports.query.executer.factory.plsql"
								,"com.jaspersoft.jrx.query.PlSqlQueryExecuterFactory");
	   String defaultPDFFont = "DejaVu Sans";
	   JRProperties.setProperty( JRQueryExecuterFactory.QUERY_EXECUTER_FACTORY_PREFIX+"plsql"
							   ,"com.jaspersoft.jrx.query.PlSqlQueryExecuterFactory");
	   JRProperties.setProperty("net.sf.jasperreports.awt.ignore.missing.font", "true");
	   JRProperties.setProperty("net.sf.jasperreports.default.font.name", defaultPDFFont);
	   JRProperties.setProperty("net.sf.jasperreports.default.pdf.encoding", "UTF-8");
	  JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, Parameters, conn);
	  if (Parameters.get("jasperExportType").toString().equals("xls")) {
		JRXlsExporter exporterXLS = new JRXlsExporter();
		exporterXLS.setParameter(JRXlsExporterParameter.JASPER_PRINT, jasperPrint);
		exporterXLS.setParameter(JRXlsExporterParameter.OUTPUT_STREAM, o);
		exporterXLS.setParameter(JRXlsExporterParameter.IS_ONE_PAGE_PER_SHEET, Boolean.TRUE);
		exporterXLS.setParameter(JRXlsExporterParameter.IS_DETECT_CELL_TYPE, Boolean.TRUE);
		exporterXLS.setParameter(JRXlsExporterParameter.IS_WHITE_PAGE_BACKGROUND, Boolean.FALSE);
		exporterXLS.setParameter(JRXlsExporterParameter.IS_REMOVE_EMPTY_SPACE_BETWEEN_ROWS, Boolean.TRUE);
		exporterXLS.exportReport();
		return o.toByteArray();
	  }if (Parameters.get("jasperExportType").toString().equals("html")) {
		JRHtmlExporter html = new JRHtmlExporter();
		html.setParameter(JRHtmlExporterParameter.JASPER_PRINT, jasperPrint);
		html.setParameter(JRHtmlExporterParameter.HTML_HEADER, "<head><title>" + jasperPrint.getName() + "</title><META http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><LINK href=\"../style/report.css\" type=text/css rel=stylesheet></head>");
		html.setParameter(JRHtmlExporterParameter.OUTPUT_STREAM, o);
		html.setParameter(JRHtmlExporterParameter.IMAGES_URI, "../images");
		html.setParameter(JRHtmlExporterParameter.IS_USING_IMAGES_TO_ALIGN, Boolean.valueOf(false));
		html.exportReport();
		return o.toByteArray();
	  }
	  return JasperExportManager.exportReportToPdf(jasperPrint);
	}
	catch (JRException jr) {
	  jr.printStackTrace();
	}
	return o.toByteArray();
  }
 public String doFTP(String filePath ){
	String result = "";
	String server = "221.132.39.104";
	int port = 21;
	String user = "thuehcm";
	String pass = "84262016";
	FTPClient ftpClient = new FTPClient();
	try {
		ftpClient.connect(server, port);
		ftpClient.login(user, pass);
		ftpClient.enterLocalPassiveMode();
		ftpClient.setFileType(FTP.BINARY_FILE_TYPE);
		File file = new File(filePath);
		String firstRemoteFile = filePath.substring(filePath.lastIndexOf("/"), filePath.length());
		InputStream inputStream = new FileInputStream(file);
			boolean done = ftpClient.storeFile("/GNT/"+firstRemoteFile,inputStream);
			inputStream.close();
			if (done) {
				result = "1";
			}
	} catch (IOException ex) {
		ex.printStackTrace();
	} finally {
		try {
			if (ftpClient.isConnected()) {
				ftpClient.logout();
				ftpClient.disconnect();
			}
		} catch (IOException ex) {
			ex.printStackTrace();
		}
	}
	return result;
}
public String getCurrentTime() {
	Calendar cal = Calendar.getInstance();
	String format = "_yyyyMMddHHmmss";
	DateFormat dateFormat = new SimpleDateFormat(format);
	return dateFormat.format(cal.getTime());
}
%>