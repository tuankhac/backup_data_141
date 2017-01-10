<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*,oracle.sql.*,neo.velocity.common.*,java.sql.*,javax.xml.parsers.*, javax.xml.soap.*,org.apache.commons.io.IOUtils, org.apache.http.client.methods.HttpPost, org.apache.http.entity.StringEntity, org.apache.http.impl.client.DefaultHttpClient, org.w3c.dom.*,org.w3c.dom.Node, org.xml.sax.InputSource" %>
<%
	final String url_services = "https://dnservicetest.vnpt-invoice.com.vn/portalservice.asmx?WSDL";
	HashMap<String, String> map_data = new HashMap<String, String>();
	HashMap<String, String> map = new HashMap<String, String>();
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
	    NodeList nodes = doc.getElementsByTagName("listInvByCusFkeyResult");
		Node nNode = nodes.item(0);
		if (nNode.getNodeType() == Node.ELEMENT_NODE) {
			Element element = (Element) nodes.item(0);
		    values = element.getTextContent().trim();
		    if(values.equals("ERR:1")){
				values = "{'Error':[" + "{'Loi':'"+ "Tài khoản đăng nhập sai." + "'}]}";
		    }else if(values.equals("ERR:3")){
				values = "{'Error':[" + "{'Loi':'"+ "Không tồn tài khách hàng tương ứng với cusCode." + "'}]}";
		    }else if(values.equals("ERR:4")){
				values = "{'Error':[" + "{'Loi':'"+ "Công ty chưa được đăng kí mẫu hóa đơn nào." + "'}]}";
		    }else{
				is.setCharacterStream(new StringReader(element.getTextContent()));
				Document doc1 = db.parse(is);
				NodeList datas = doc1.getElementsByTagName("Data");
				Node data = datas.item(0);
				if (data.getNodeType() == Node.ELEMENT_NODE) {
					Element item_element = (Element) data;
					map_data.put("index",
							item_element.getElementsByTagName("index").item(0)
									.getTextContent());
					map_data.put("cusCode",
							item_element.getElementsByTagName("cusCode")
									.item(0).getTextContent());
					map_data.put("month",
							item_element.getElementsByTagName("month").item(0)
									.getTextContent());
					map_data.put("name",
							item_element.getElementsByTagName("name").item(0)
									.getTextContent());
					map_data.put("publishDate", item_element
							.getElementsByTagName("publishDate").item(0)
							.getTextContent());
					map_data.put("signStatus", item_element
							.getElementsByTagName("signStatus").item(0)
							.getTextContent());
					map_data.put("pattern",
							item_element.getElementsByTagName("pattern")
									.item(0).getTextContent());
					map_data.put("serial",
							item_element.getElementsByTagName("serial").item(0)
									.getTextContent());
					map_data.put("invNum",
							item_element.getElementsByTagName("invNum").item(0)
									.getTextContent());
					map_data.put("amount",
							item_element.getElementsByTagName("amount").item(0)
									.getTextContent());
					map_data.put("status",
							item_element.getElementsByTagName("status").item(0)
									.getTextContent());
					map_data.put("cusname",
							item_element.getElementsByTagName("cusname")
									.item(0).getTextContent());
					map_data.put("payment",
							item_element.getElementsByTagName("payment")
									.item(0).getTextContent());
				}
				values = "{'Error':[{'ERR':'0'}],'invoice':[" + "{'index':'"+map_data.get("index")+"','cusCode':'"+map_data.get("cusCode")+"',"
					+ "'month':'"+map_data.get("month")+"','name':'"+map_data.get("name")+"' ,"
					+ "'publishDate':'"+map_data.get("publishDate")+"','signStatus':'"+map_data.get("signStatus")+"',"
					+ "'pattern':'"+map_data.get("pattern")+"','serial':'"+map_data.get("serial")+"',"
					+ "'invNum':'"+map_data.get("invNum")+"','amount':'"+map_data.get("amount")+"',"
					+ "'status':'"+map_data.get("status")+"','cusname':'"+map_data.get("cusname")+"',"
					+ "'payment':'"+map_data.get("payment")+"'"+
					"}]}";
			}
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
			+ " <listInvByCusFkey xmlns=\"http://tempuri.org/\">"
			+ " <key>"+map.get("key")+"</key>"
			+ " <fromDate>"+map.get("fromDate")+"</fromDate>"
			+ "  <toDate>"+map.get("toDate")+"</toDate>"
			+ "  <userName>"+map.get("username")+"</userName>"
			+ "  <userPass>"+map.get("pass")+"</userPass>"
			+ "  </listInvByCusFkey>"
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