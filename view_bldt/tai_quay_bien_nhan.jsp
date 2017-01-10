<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*,oracle.sql.*,neo.velocity.common.*,java.sql.*,javax.xml.parsers.*, javax.xml.soap.*,org.apache.commons.io.IOUtils, org.apache.http.client.methods.HttpPost, org.apache.http.entity.StringEntity, org.apache.http.impl.client.DefaultHttpClient, org.w3c.dom.*, org.xml.sax.InputSource" %>
<%
	String matinh = request.getParameter("matinh");
	String url_services="";
	if(matinh.equals("79TTT")){
		url_services = "https://unttadmin.vnpt-invoice.com.vn/PortalService.asmx?WSDL";
	} else{
		url_services = "https://vnptthuhoadmin.vnpt-invoice.com.vn/PortalService.asmx?WSDL";
	}
	
	
	String username = request.getParameter("username");
	String pass = request.getParameter("pass");
	String fkey = request.getParameter("fkey");
	String respons_msg = soapCall(url_services, getEntitySoap(username,pass,fkey));
	String values = "1";
	try {
	    DocumentBuilderFactory dbf =
	        DocumentBuilderFactory.newInstance();
	    DocumentBuilder db = dbf.newDocumentBuilder();
	    InputSource is = new InputSource();
	    is.setCharacterStream(new StringReader(respons_msg));
	    Document doc = db.parse(is);
	    NodeList nodes = doc.getElementsByTagName("getInvViewFkeyResult");
	    Element element = (Element) nodes.item(0);
	    values = element.getTextContent().trim();
	    if(values.equals("ERR:1")){
			values = "Tài khoản đăng nhập sai.";
	    }else if(values.equals("ERR:6")){
			values = "Chuỗi FKEY không chính xác.";
	    }else if(values.equals("ERR:7")){
			values = "Công ty không tồn tại.";
	    }else if(values.equals("ERR:11")){
			values = "Hóa đơn chưa được thanh toán.";
	    }
	   	out.print(values);
	}
	catch (Exception e) {
	    out.print("Err: "+e);
	}
%>
<%!
public String getEntitySoap(String username, String pass, String fkey) {
	String body = "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
			+ "<soap:Body>"
			+ " <getInvViewFkey xmlns=\"http://tempuri.org/\">"
			+ " <fkey>"+fkey+"</fkey>"
			+ " <userName>"+username+"</userName>"
			+ "  <userPass>"+pass+"</userPass>"
			+ "  </getInvViewFkey>"
			+ "  </soap:Body>" + " </soap:Envelope>";
	return body;
}
public String soapCall(String url, String body) {
	DefaultHttpClient httpclient = new DefaultHttpClient();
	String out = "";
	try {
		HttpPost post = new HttpPost(url);
		post.setEntity(new StringEntity(body));
		post.setHeader("Content-Type", "text/xml; charset=UTF-8");
		// post.setParams(params);
		out = IOUtils.toString(httpclient.execute(post).getEntity()
				.getContent(), "UTF-8");
	} catch (Exception e) {
		e.printStackTrace();
		return e.getMessage();
	} finally {
		httpclient.getConnectionManager().shutdown();
	}
	return out;
}

%>