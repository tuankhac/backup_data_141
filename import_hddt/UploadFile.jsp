<%@ page contentType="text/html; charset=utf-8" language="java"%>
<%@ page import="java.io.*,java.util.*,javax.servlet.*,neo.*,com.aspose.cells.*, com.lowagie.text.pdf.codec.Base64" %>
<%@ page import="com.jspsmart.upload.*,com.jspsmart.file.*,com.neo.utils.*,  java.io.BufferedReader,  java.io.File,  java.io.FileInputStream,  java.io.FileOutputStream,  java.io.IOException,  java.io.InputStreamReader,  java.sql.CallableStatement,  java.sql.Connection,  java.sql.ResultSet,  java.sql.SQLException,  java.util.zip.ZipEntry,  java.util.zip.ZipInputStream,  java.util.zip.ZipOutputStream, neo.velocity.common.Utility,  oracle.jdbc.OracleTypes,  com.github.junrar.exception.RarException, com.github.junrar.impl.FileVolumeManager, com.github.junrar.rarfile.FileHeader, com.github.junrar.Archive"%>
<%
	int  MAXSIZE  =  2048*1024; //25KB
	String path = application.getRealPath("/") + "import_hddt";
	SmartUpload mySmartUpload=new SmartUpload();
	mySmartUpload.initialize(pageContext);
	mySmartUpload.setAllowedFilesList("xml,XML,zip,ZIP,rar,RAR");
	//mySmartUpload.setTotalMaxFileSize(MAXSIZE);
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
			// Retreive the current file
			com.jspsmart.upload.File myFile = mySmartUpload.getFiles().getFile(i);	
			//com.jspsmart.upload.Request jsprequest = mySmartUpload.getRequest();
			if (!myFile.isMissing() ) {
				if(myFile.getSize() > MAXSIZE){
					values = "Lỗi: File max size = 2MB";
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
				if(extFileName.equals(".zip")){
					String result_unzip = unzipFunction(path, filename); 
					if(result_unzip.equals("1"))
						values = "Import file success.";
					else 
						values = result_unzip;
				}else if(extFileName.equals(".xml")){
					FileInputStream fis = new FileInputStream(path + "/" + filename);
					BufferedReader reader = new BufferedReader(
							new InputStreamReader(fis));
					String line = reader.readLine();
					while (line != null) {
 						doInsertDb(line);
						line = reader.readLine();
					}
					fis.close();
					values = "Import file success.";
				}else if(extFileName.equals(".rar")){
					String result_unzip = unrarFunction(path, filename); 
					if(result_unzip.equals("1"))
						values = "Import file success.";
					else 
						values = result_unzip;
				}
 			}
		}
	}catch(Exception e){
		//out.print(e.toString());
		values = "0|ERR: " + e.toString();
		//e.printStackTrace();
	}
	// out.println(strContent);
	out.print(values);
%>
<%!
public String unzipFunction(String destinationFolder, String zipFile) {
	String result ="0";
	File directory = new File(destinationFolder);
	// if the output directory doesn't exist, create it
	if (!directory.exists())
		directory.mkdirs();
	// buffer for read and write data to file
	byte[] buffer = new byte[2048];
	result ="12";
	try {
		FileInputStream fInput = new FileInputStream(destinationFolder+"/"+zipFile);
		ZipInputStream zipInput = new ZipInputStream(fInput);
		ZipEntry entry = zipInput.getNextEntry();
		while (entry != null) {
			// entryName: ten file
			String entryName = entry.getName();
			File file = new File(destinationFolder + File.separator
					+ entryName);
			// file.getAbsolutePath(): path + tenfile
			// create the directories of the zip directory
			result ="14";
			if (entry.isDirectory()) {
				File newDir = new File(file.getAbsolutePath());
				result ="15";
				if (!newDir.exists()) {
					boolean success = newDir.mkdirs();
					if (success == false) {
						result = ("Problem creating Folder");
					}
				}
			} else {
				result ="111";
				FileOutputStream fOutput = new FileOutputStream(file);
				int count = 0;
				while ((count = zipInput.read(buffer)) > 0) {
					// write 'count' bytes to the file output stream
					fOutput.write(buffer, 0, count);
				}
				FileInputStream fis = new FileInputStream(file);
				BufferedReader reader = new BufferedReader(
						new InputStreamReader(fis));
				String line = reader.readLine();
				while (line != null) {
					//out.println(line);
					doInsertDb(line);
					line = reader.readLine();
				}
				fOutput.close();
				fis.close();
				result = "1";
			}
			// close ZipEntry and take the next one
			zipInput.closeEntry();
			entry = zipInput.getNextEntry();
		}
		// close the last ZipEntry
		zipInput.closeEntry();
		zipInput.close();
		fInput.close();
	} catch (IOException e) {
		result = e.getMessage();
	}
	return result;
}
public String unrarFunction(String desFolder, String filename){
	String result ="0";
	//String desFolder = "E:/NEO/J2EE/workspace/TEST";
	//String filename = "longpd.rar";
	File f = new File(desFolder + "/" + filename);
	Archive a = null;
	try {
		a = new Archive(new FileVolumeManager(f));
		if (a != null) {
			a.getMainHeader().print();
			FileHeader fh = a.nextFileHeader();
			while (fh != null) {
				File out = new File(desFolder + "/"
						+ fh.getFileNameString().trim());
				System.out.println(out.getAbsolutePath());
				if (fh.isDirectory()) {
					File newDir = new File(out.getAbsolutePath());
					if (!newDir.exists()) {
						boolean success = newDir.mkdirs();
						if (success == false) {
							System.out.println("Problem creating Folder");
						}
					}
				} else {
					FileOutputStream os = new FileOutputStream(out);
					a.extractFile(fh, os);
					os.close();
					FileInputStream fis = new FileInputStream(out);
					BufferedReader reader = new BufferedReader(
							new InputStreamReader(fis));
					String line = reader.readLine();
					while (line != null) {
						//out.println(line);
						doInsertDb(line);
						line = reader.readLine();
					}
 					fis.close();
					result = "1";
				}
				fh = a.nextFileHeader();
			}
		}
	} catch (Exception e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
	return result;
}
public String doInsertDb(String input) {
	Utility u = new Utility();
	Connection conn = null;
	CallableStatement cstm = null;
	String[] parts = input.split("-");
	String status = parts[0].split(":")[0];
	//out.println("Status = " + status);
	String pattern = parts[0].split(":")[1].split(";")[0];
	//out.println("parttern = " + pattern);
	int total_hd = parts[1].split(",").length;
	String result = "0";
	try {
		conn = u.getConnection("crud");
		cstm = conn.prepareCall("begin ?:= tax.crud.new_hddts(?,?,?,?,?,?,?,?);end;");
		for (int i = 0; i < total_hd; i++) {
			//out.println(parts[1].split(",")[i]);
			cstm.registerOutParameter(1, OracleTypes.VARCHAR);
			cstm.setString(2, "");
			cstm.setString(3, status);
			cstm.setString(4, pattern);
			int total_item = parts[1].split(",")[i].split("_").length;
			for (int j = 0; j < total_item; j++) {
				cstm.setString(5 + j, parts[1].split(",")[i].split("_")[j]);
			}
			cstm.setString(9, "sysdate");
			result = String.valueOf(cstm.executeUpdate());
		}
	} catch (Exception e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
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
%>