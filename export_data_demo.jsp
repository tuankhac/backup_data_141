<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.sql.*, com.linuxense.javadbf.*" %>

<%
	String user = "tax";
        String pass = "abc1234";
        String ip = "localhost";
        String sid = "NEO";
        
        Class.forName("oracle.jdbc.OracleDriver");
        String url = "jdbc:oracle:thin:@" + ip + ":1521:" + sid;
        Connection conn = DriverManager.getConnection(url, user, pass);
        
        String sql = "select mst, cfont_utotcvn3(ten_nnt) ten, cfont_utotcvn3(mota_diachi) diachi from nnts";
        String filename = "d:\\dbf.dbf";
        
        conn.setAutoCommit(false);
        CallableStatement stmt = conn.prepareCall(sql);
        ResultSet rset = stmt.executeQuery(sql);
        try {
            
        	ResultSetMetaData rsMeta = rset.getMetaData();
        	DBFField fields[] = new DBFField[rsMeta.getColumnCount()];
    		for (int j = 0; j < rsMeta.getColumnCount(); j++) {
    			fields[j] = new DBFField();
    			fields[j].setName(rsMeta.getColumnName(j+1));
    		    fields[j].setDataType( DBFField.FIELD_TYPE_C);
    		    fields[j].setFieldLength(255);
    		}
    		DBFWriter writer = new DBFWriter();
    	    writer.setFields( fields);
    	    
        	while (rset.next()) {
        		Object rowData[] = new Object[rsMeta.getColumnCount()];
        		for (int j = 0; j < rsMeta.getColumnCount(); j++) {
        			rowData[j] = rset.getObject(j+1);
        		}
        		writer.addRecord(rowData);
        	}
        	
        	FileOutputStream fos = new FileOutputStream(filename);
    	    writer.write( fos);
    	    fos.close();
        	
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        
        conn.commit();
        stmt.close();
%>