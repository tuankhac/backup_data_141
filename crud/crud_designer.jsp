<%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>
<%@ page contentType="text/html; charset=utf-8" language="java" %>
<jsp:useBean id="n" class="neo.velocity.common.NeoContext" scope="session"/>
<jsp:setProperty name="n" property="language" value="${not empty param.language ? param.language : 'vi_VN'}"/>
<n:check value="${param.owner}" minLength="3" maxLength="200" type="string" exp="[0-9a-zA-Z_,]+">Cần truyền Schema</n:check>
<html>

<head>
 	<title>${n.i18n.header_pages}</title>
    <script src="/assets/bootstrap/plugins/jQuery/jQuery-2.1.4.min.js"></script>
</head>
<style>
body, table{font-family:Arial, Helvetica, sans-serif;font-size:10pt}
</style>
<body>
<strong>Chọn bảng để thực hiện CRUD:</strong> <select id="combo" style="width:400px"><n:option src="crud" serviceType="query" service="crud_designer_tables_service" paramSize="1" p1="${param.owner}"/></select>
<input type="button" onClick="viewStruct()" value="View Struct"/>
<div id="struct"></div>
<input id="path" type="text" style="width:530px" value="<%= new java.io.File(org.apache.commons.configuration.ConfigurationUtils.locate("velocity.properties").getPath()).getParent() %>\..\templates\"/><input type="button" onClick="makeParam()" value="Tạo Create-Read-Update-Delete Form"/>
<div id="result" style="height:300px;width:100$"></div>
</body>
<script>
var seq;
function viewStruct(){
	var i = $("#combo").val().split(".");
	$("#struct").html("Dang lay du lieu ...");
	$.ajax({
		url: 'crud_designer_struct.jsp?owner='+i[0]+'&table='+i[1],
		cache: false,
		success: function(data){
			$("#struct").html(data); 
		}
	});
}
function makeParam(){
	var out = "";
	var i = $("#combo").val().split(".");
	$("#result").html("Begin: Tạo tham số ...");
	$("#structDetail tr").each(function(index, element) {
		if ($(this).find("th").size()==0){
			out+="insert into crud_detail values ('"+seq+"'";
			$(this).find("td").each(function(index, element) {
				if ($(this).find("input").size()==0){
					out+=",'"+$(this).text()+"'";
				}else{
					out+=",'"+$(this).find("input:first").val()+"'";
				}
			});
			out+=",'"+i[0]+"','"+i[1]+"');\n";
		}
    });
	$.ajax({
		url: 'crud_designer_make_param.jsp',type: "POST",cache: false,data: {"p":out},
		success: function(d){
			if (d=="1.0"){
				$("#result").html($("#result").html()+"OK");
				$.ajax({
					url: 'crud_designer_make.jsp',type: "POST",cache: false,data: {"id":seq,"table":i[1].toLowerCase(),"owner":i[0].toLowerCase(),"path":$("#path").val()},
					success: function(d1){
						$("#result").html($("#result").html()+"<br>"+d1);
					}
				});
			}else{ 
				$("#result").html($("#result").html()+d); 
			}
		}
	});
};
</script>
</html>
