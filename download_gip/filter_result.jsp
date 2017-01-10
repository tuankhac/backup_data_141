<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page
	import="java.io.File, java.text.SimpleDateFormat,java.util.Map,java.util.TreeMap,java.util.Date"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<style type="text/css">
ul li ul {
  display: none;
}
a:hover {
	cursor : pointer;
}

</style>
</head>

<body>
	<%
		String tu_ngay = request.getParameter("tu_ngay");
		String den_ngay = request.getParameter("den_ngay");
		
		String id_filter = request.getParameter("id_filter");
		String dir = getServletContext().getRealPath("/") + "WEB-INF/gip/req";
		result = getString(tu_ngay, den_ngay, dir, id_filter);
		
	%>
	<div class="box-body no-padding" id='data-list'
		style="overflow: auto; margin: auto">
		<div id="r_parent" style="overflow: hidden;">
			<div style="width: 47%; float: left;">
				<section class="content-header">
				<h1></h1>
				</section>
				<div class="box-header with-border">
					<h3 class="box-title" style="font-weight: bold; color: #039">DANH
						SÁCH REQUEST FILE</h3>
					<div class="box-tools"></div>
				</div>
				<div class="box box box-primary">
					<div id="pageinfoL"></div>
					<div class ="div_data" id="left">
						<section class="content-header">
						<h1></h1>
						</section>
						<%
				   		out.println(result);
				   	
					  %>
					</div>
				</div>
			</div>
			<div style="width: 47%; float: right;">
				<section class="content-header">
				<h1></h1>
				</section>
				<div class="box-header with-border">
					<h3 class="box-title" style="font-weight: bold; color: #039">DANH
						SÁCH RESPONSE FILE</h3>
					<div class="box-tools"></div>
				</div>
				<div class="box box box-primary">
					<div id="pageinfoR"></div>
					<div class ="div_data" id="right">
						<section class="content-header">
						<h1></h1>
						</section>
						<%
					   		out.println(result);
					  %>
					</div>
				</div>
			</div>
		</div>
	</div>
</body>
<script type="text/javascript">
	function downloadFile(name,obj) {
		var path ="";
		if($(obj).parents("div.div_data").get(0).id == "left"){
			path =  "1,"+name;
		}
		else{
			path = "2,"+name;
		}
		window.open("/downloadFile?path="+path);
		//$.ajax({
		//	type : "GET",
		//	url : path,
		//	dataType : "xml",
		//	async : false,
		//	success : function(xml) {
		//		console.log(xml);
		//		var text = new XMLSerializer().serializeToString(xml);
		//		a = document.createElement('a');
		//		a.setAttribute("href", "data:application/xml;charset=utf-8,"
		//				+ text);
		//		a.setAttribute("download", name);
		//		a.click();
		//	}
		//});
	}
	$(function(){
		$('.expand').click(function() {
		  $('ul', $(this).parent()).toggle();
		});
	});
</script>
</html>
<%!//lay danh sach cac file thoa man
	String result = "";
	String oldCharH = "unt_";
	String oldCharL = ".xml";

	public String getString(String from_date, String to_date, String dir, String id_filter) {
		String year = "";
		String month = "";
		String day = "";
		StringBuffer sb = new StringBuffer();
		Map<String, String> map = getList(from_date, to_date, dir, id_filter);
		if(map.size() == 0){
			sb.append("File dữ liệu không tồn tại");
		}
		else
		if(map.size() == 1){
			if(map.get("FAIL").equals("0"))
			sb.append("File dữ liệu không tồn tại");
		}
		else
		for (Map.Entry<String, String> entry : map.entrySet()) {
			String date = entry.getKey().toString();
			String year_temp = date.substring(date.lastIndexOf("/") + 1, date.lastIndexOf("/") + 5);
			String month_temp = date.substring(0, 2);
			String day_temp = date.substring(3, 5);
			String id = entry.getValue().replace(oldCharL, "");
			if ("".equals(year)) {
				year = year_temp;
				sb.append("<ul><li><a class=expand>Year " + year + "</a>");
				if ("".equals(month)) {
					month = month_temp;
					sb.append("<ul><li><a class=expand>Month " + month + "</a>");
					if ("".equals(day)) {
						day = day_temp;
						sb.append("<ul><li><a class=expand>Day " + day + "</a>");
						sb.append("<ul><div class=box-header style=overflow: hidden;><li><a class=expand id =" + id
								+ " onclick = downloadFile(&#34;" + entry.getValue() + "&#34;,this)>/../" + entry.getValue() + "</a></li></div></ul>");
					}
				}
			} else if (year.equals(year_temp) && !"".equals(year)) {
				if (month.equals(month_temp)) {
					if (day.equals(day_temp)) {
						sb.append("<ul><div class=box-header style=overflow: hidden;><li><a class=expand id =" + id
								+ " onclick = downloadFile(&#34;" + entry.getValue() + "&#34;,this)>/../" + entry.getValue() + "</a></li></div></ul>");
					} else {
						day = day_temp;
						sb.append("</li></ul><ul><li><a class=expand>Day " + day + "</a>");
						sb.append("<ul><div class=box-header style=overflow: hidden;><li><a class=expand id =" + id
								+ " onclick = downloadFile(&#34;" + entry.getValue() + "&#34;,this)>/../" + entry.getValue() + "</a></li></div></ul>");
					}
				} else {
					month = month_temp;
					day = day_temp;
					sb.append("</li></ul></li></ul><ul><li><a class=expand>Month " + month + "</a>");
					sb.append("<ul><li><a class=expand>Day " + day + "</a>");
					sb.append("<ul><div class=box-header style=overflow: hidden;><li><a class=expand id =" + id
								+ " onclick = downloadFile(&#34;" + entry.getValue() + "&#34;,this)>/../" + entry.getValue() + "</a></li></div></ul>");
				}
			} else {
				year = year_temp;
				month = month_temp;
				day = day_temp;
				sb.append("</li></ul></li></ul></li></ul><ul><li><a class=expand>Year " + year);
				sb.append("<ul><li><a class=expand>Month " + month);
				sb.append("<ul><li><a class=expand>day " + day);
				sb.append("<ul><div class=box-header style=overflow: hidden;><li><a class=expand id =" + id
								+ " onclick = downloadFile(&#34;" + entry.getValue() + "&#34;,this)>/../" + entry.getValue() + "</a></li></div></ul>");
			}
		}
		return sb.toString();
	}

	public Map<String, String> getList(String from_date, String to_date, String dir, String id_filter) {
		Map<String, String> map = new TreeMap<String, String>();
		String[] result = new String[2];

		File file = new File(dir);
		File[] files = file.listFiles();
		for (File f : files) {
			result = checkFile(f, from_date, to_date, id_filter);
			if("FAIL".equals(result[0])){
				map.put("FAIL", "0");
				return map;
			}else
			if (!"".equals(result[0]) && !"".equals(result[1]))
				map.put(result[0], result[1]);
		}
		//printMap(map);
		return map;
	}

	// kiem tra file co thoa man dieu kien ko
	private String[] checkFile(File file, String from_date, String to_date, String id_filter) {
		String[] result = new String[] { "", "" };
		SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");
		SimpleDateFormat convertDateFile = new SimpleDateFormat("MM/dd/yyyy");
		SimpleDateFormat convertDate = new SimpleDateFormat("dd/MM/yyyy");
		try {
			// chuyen ngay cua file
			String val = sdf.format(file.lastModified());
			Date dateOfFile = convertDateFile.parse(val);

			// get tu ngay va den ngay
			Date dateF = convertDate.parse(from_date);
			Date dateT = convertDate.parse(to_date);
			
			if(dateF.after(dateT)){
				result[0]= "FAIL";
				result[1] = "0";
				return result;
			}
			
			if ((dateOfFile.before(dateT)|| dateOfFile.equals(dateT)) 
					&& (dateOfFile.after(dateF)|| dateOfFile.equals(dateF))) {
				String sub_name = file.getName().replace(oldCharH, "").replace(oldCharL, "");
				if (id_filter.contains(sub_name)) {
					result[0] = val;
					result[1] = file.getName();
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		return result;
	}

	private <K, V> void printMap(Map<K, V> map) {
		for (Map.Entry<K, V> entry : map.entrySet()) {
			System.out.println("Key : " + entry.getKey() + " Value : " + entry.getValue());
		}
	}%>