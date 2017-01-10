<%@ page contentType="text/html; charset=utf-8" language="java"%>
<%@ page import="java.io.File, java.nio.file.Paths"%>
<%
		String folder = "news_info/images";
		String currentFolder = application.getRealPath("/")+ folder;
		File f = new File(currentFolder);
		File[] fl = f.listFiles();
		//out.println(fl.length);
		String json = "";
		for (int i = 0; i < fl.length; i++) {
			if(!fl[i].getName().equals("Thumbs.db")){
				json += ",{";
				json += "\"image\":\"" + request.getContextPath() + "/" + folder + "/" + fl[i].getName() + "\",";
				json += "\"thumb\":\"" + request.getContextPath() + "/" + folder + "/" + fl[i].getName() + "\",";
				json += "\"folder\":\"news_info/images/\"";
				json += "}";
			}
		}
		json = json.substring(1);
		json = "[" + json + "]";
		out.println(json);
%>