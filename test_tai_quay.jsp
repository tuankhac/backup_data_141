
<html>
<%@include file="header.jsp"%>
<link href="/assets/bootstrap/plugins/iCheck/all.css" rel="stylesheet" type="text/css" />
<script src="/assets/bootstrap/plugins/iCheck/icheck.min.js" type="text/javascript"></script>
<script src="/assets/bootstrap/plugins/autocomplete/jquery.autocomplete.min.js" type="text/javascript"></script>
<link href="/assets/bootstrap/plugins/autocomplete/styles.css" rel="stylesheet" type="text/css" />

    </div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script>
alert("${pathroot}  ${province}");
function print(){
	var Pmst = $("#mst").val();
	var Pten = $("#ten_nnt").val();
	var Pdiachi = $("#mota_diachi").val();	
	var jpPath = '${pathroot}' + "WEB-INF/templates/jasper/";	
	var fname;
	var matinh = "${province}";
	
	if(matinh=="01TTT"){
		fname = "receipts";
	}else if (matinh=="79TTT"){
		fname = "receipts_hcm";
	}
	else {
		//alert(matinh);
		fname = "receipts_blu";
	}
	
	s_ = window.location.protocol+"//"+window.location.host
			+"/report/?jasperFile=jasper/"+fname+"&jasperExportType=pdf&AGENT=${province}&IMAGE_PATH="+jpPath+"&MST_NNT="+Pmst+"&TEN_NNT="+Pten+"&DIACHI="+Pdiachi+"&PHIEU_ID="+		Objphieu+"&INVOICE="+Inv_no+"&SERIAL="+Serial_no;
	window.open(s_);
}
print();
</script>