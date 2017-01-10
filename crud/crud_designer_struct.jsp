<%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>
<%@ page contentType="text/html; charset=utf-8" language="java" %>
<jsp:useBean id="n" class="neo.velocity.common.NeoContext" scope="session"/>
<jsp:setProperty name="n" property="language" value="${not empty param.language ? param.language : 'vi_VN'}"/>
<style>
#structDetail th{
	height:30px;padding:1px 3px;background:#fcfcfc;border-right:1px solid #ddd;border-bottom:1px solid #ddd;
}
#structDetail td{
	background:#fefefe;border-right:1px solid #ddd;border-bottom:1px solid #ddd;padding:1px 3px;
}
</style>
<table id="structDetail" border="0" cellpadding="0" cellspacing="0" style="border:1px solid #999" width="100%">
	<tr>
    	 <th width="4%">ID</th>
        <th width="15%">Column Name</th>
        <th width="10%">Data Type</th>
        <th width="6%">Data Length</th>
        <th width="5%">Check Null</th>
        <th width="30%">Label</th>
        <th width="30%">Select Query</th>
	</tr>
    <n:value id="a1" src="crud" service="crud_get_table_struct_service" serviceType="ref" p1="${param.owner}" p2="${param.table}" paramSize="2">
    #foreach ($i in $list)
    	<tr>
        	<td align="center">$i["COLUMN_ID"]</td>
            <td>$i["COLUMN_NAME"]</td>
            <td>$i["DATA_TYPE"]</td>
            <td><input type="text" style="width:100%" value='$i["DATA_LENGTH"]'></td>
            <td><input type="text" style="width:100%" value='$i["CHECK_NULLABLE"]'></td>
            <td><input type="text" style="width:100%" value='$i["COLUMN_NAME"]'></td>
            <td><input type="text" style="width:100%" value='$!i["RELATED"]'></td>
        </tr>
    #end
    </n:value>
</table>
<script>
<n:value id="seq2" src="crud" service="crud_designer_get_seq_service" paramSize="0" serviceType="query"/>
seq='${seq2.list[0].SEQ}';
</script>