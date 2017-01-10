<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
    
  </body>
</html>
<script>
$(".treeview-menu").each(function(idx,el){
	$(el).find("a").each(function(idx1,el1){
		if (document.location.href.indexOf($(el1).attr("href"))>0){
			$(el1).parent().addClass("active");
			$(el).addClass("menu-open");
			$(el).parent().addClass("active");
		}
	});
});
function patternValidate(fldName,type) {
    return true
}
function emailValidate(fldName,fldLabel) {
	return true;
}
function fnumber(o){
	var n = o.replace(/,/g,"");
	return n.split('').reverse().join('').replace(/(\d{3})(?=\d)/g,'$1,').split('').reverse().join('');
}
function openWindow(baseURL,winName,width,height,features){
	var top=(window.screen.height - height)/2 - 30;
	var left=(window.screen.width - width )/2;
	
	features="width="+width+",height="+height+",top="+top+",left="+left+";"+features
	return window.open(baseURL,winName,features);
}
</script>