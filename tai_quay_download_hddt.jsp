<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*,oracle.sql.*,neo.velocity.common.*,java.sql.*,javax.xml.parsers.*, javax.xml.soap.*,org.apache.commons.io.IOUtils, org.apache.http.client.methods.HttpPost, org.apache.http.entity.StringEntity, org.apache.http.impl.client.DefaultHttpClient, org.w3c.dom.*,org.w3c.dom.Node, org.xml.sax.InputSource, neo.gate.util.mis.Base64" %>
<%
	final String url_services = "https://dnservicetest.vnpt-invoice.com.vn/portalservice.asmx?WSDL";
	HashMap<String, String> map_data = new HashMap<String, String>();
	HashMap<String, String> map = new HashMap<String, String>();
	Base64 base = new Base64();
	map.put("username", request.getParameter("username"));
	map.put("pass", request.getParameter("pass"));
	map.put("key", request.getParameter("key"));
	map.put("fromDate", request.getParameter("fromDate"));
	map.put("toDate", request.getParameter("toDate"));

	String respons_msg = soapCall(url_services, getEntitySoap(map));
	String listInv="";
	String values = "1";

	try {
	    DocumentBuilderFactory dbf =
	        DocumentBuilderFactory.newInstance();
	    DocumentBuilder db = dbf.newDocumentBuilder();
	    InputSource is = new InputSource();
	    is.setCharacterStream(new StringReader(respons_msg));
	    Document doc = db.parse(is);
	    NodeList nodes = doc.getElementsByTagName("downloadInvPDFFkeyResult");
		Node nNode = nodes.item(0);
		if (nNode.getNodeType() == Node.ELEMENT_NODE) {
			Element element = (Element) nodes.item(0);
		    values = base.decode(element.getTextContent().trim());
		}
	   	out.print(values);
	}
	catch (Exception e) {
	    out.print("Err: "+e);
	}
%>
<%!
public String getEntitySoap(HashMap<String, String> map) {
	String body = "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
			+ "<soap:Body>"
			+ " <downloadInvPDFFkey xmlns=\"http://tempuri.org/\">"
			+ " <fkey>"+map.get("key")+"</fkey>"
			+ "  <userName>"+map.get("username")+"</userName>"
			+ "  <userPass>"+map.get("pass")+"</userPass>"
			+ "  </downloadInvPDFFkey >"
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