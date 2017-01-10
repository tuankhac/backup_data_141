<%@page import="org.apache.commons.io.FileUtils"%>
<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import="org.apache.commons.configuration.reloading.FileChangedReloadingStrategy"%>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.io.output.*" %>
<jsp:useBean id="props" class="org.apache.commons.configuration.PropertiesConfiguration" scope="application"/>
<% if (props.getString("item.types")==null){
	props.setDelimiterParsingDisabled(true);
	props.setEncoding("UTF-8");
	props.setPath("wcm.properties");
	props.load();
	props.setReloadingStrategy(new FileChangedReloadingStrategy());
}%>
<%
   File file = null;
   int maxFileSize = 5000 * 1024;
   int maxMemSize = 5000 * 1024;
   ServletContext context = pageContext.getServletContext();

   String contentType = request.getContentType();
   out.clear();
   if ((contentType.indexOf("multipart/form-data") >= 0)) {

      DiskFileItemFactory factory = new DiskFileItemFactory();
      factory.setSizeThreshold(maxMemSize);

      ServletFileUpload upload = new ServletFileUpload(factory);
      upload.setSizeMax( maxFileSize );
      try{ 
         List fileItems = upload.parseRequest(request);
         Iterator i = fileItems.iterator();

         while ( i.hasNext () ) {
            FileItem fi = (FileItem)i.next();
            if ( !fi.isFormField () ){
                String fileName = fi.getName();
                if( fileName.lastIndexOf("\\") >= 0 ){
                    fileName=fileName.substring( fileName.lastIndexOf("\\")) ;
                }else{
                    fileName=fileName.substring(fileName.lastIndexOf("\\")+1) ;
                }
                String uri = System.getProperty("user.dir")+"/../webapps/ROOT/public/files/";
                FileUtils.forceMkdir(new File(uri));
                fi.write(new File(uri+fileName));
                out.println("1");
            }
         }
      }catch(Exception ex) {
         out.println(ex.getMessage());
      }
   }else{
      out.println("No file Upload"); 
   }
%>