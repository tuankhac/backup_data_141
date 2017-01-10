<%@ page contentType="text/html; charset=utf-8" language="java"%>
<%@ page import="java.io.*,java.util.*,javax.servlet.*,neo.*,com.aspose.cells.*, com.lowagie.text.pdf.codec.Base64" %>
<%@ page import="com.jspsmart.upload.*,com.jspsmart.file.*,com.neo.utils.*, mortennobel.imagescaling.*"%>
<%
	int  MAXSIZE  =  250*1024; //25KB
	String path = application.getRealPath("/") + "nhanvien_tcs/images";

	String img_path="";
	SmartUpload mySmartUpload=new SmartUpload();
	
	mySmartUpload.initialize(pageContext);
	mySmartUpload.setAllowedFilesList("JPEG,JPG,PNG,jpeg,jpg,png");
	//mySmartUpload.setTotalMaxFileSize(MAXSIZE);
	String values = "1";
 
	try{
		mySmartUpload.upload();
		java.io.File theDir = new java.io.File(path);
		if (!theDir.exists()) {
	  		theDir.mkdir();
		}
		//System.out.println("--------------count: "+mySmartUpload.getFiles().getCount());
		String regex = "\\d+";
		for (int i=0;i< mySmartUpload.getFiles().getCount();i++){
			// Retreive the current file
			com.jspsmart.upload.File myFile = mySmartUpload.getFiles().getFile(i);	
			//com.jspsmart.upload.Request jsprequest = mySmartUpload.getRequest();
			if (!myFile.isMissing() ) {
				String filename = myFile.getFileName();
				filename = filename.replaceAll(" ","");
				String orgFileName = filename.substring(0,filename.lastIndexOf("."));
				String extFileName = filename.substring(orgFileName.length()).toLowerCase();
				filename = orgFileName;
				int j=0;
					while (true) {
						java.io.File f = new java.io.File(path + "/" + filename + extFileName);
						if (f.exists())
							filename = orgFileName + "" + j;
						else
							break;
						j++;
					}
				filename += extFileName;
				myFile.saveAs(path + "/" + filename);
				if(myFile.getSize() > MAXSIZE){
					ScaleJPG.scale(path + "/" + filename, 500, path + "/" + filename);
				}
				values +="|"+filename+'|'+path.replace('\\','/') + "/"+ filename;
 			}
		}
		
	}catch(Exception e){
		//System.out.print(e.toString());
		values = "0|ERR: " + e.toString();
		e.printStackTrace();
	}
	System.out.println(values);
	out.print(values);
%>