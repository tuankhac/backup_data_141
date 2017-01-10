<%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:setProperty name="n" property="language" value="${not empty param.language ? param.language : 'vi_VN'}"/>
<html>
<%@include file="header.jsp"%>
<link href="/assets/bootstrap/plugins/iCheck/all.css" rel="stylesheet" type="text/css" />
<script src="/assets/bootstrap/plugins/iCheck/icheck.min.js" type="text/javascript"></script>
<script src="/assets/bootstrap/plugins/autocomplete/jquery.autocomplete.min.js" type="text/javascript"></script>
<link href="/assets/bootstrap/plugins/autocomplete/styles.css" rel="stylesheet" type="text/css" />
<!-- Content Wrapper. Contains page content -->
      <div class="content-wrapper">
        <!-- Content Header (Page header) -->
        <section class="content-header">
          <h1>
            ${n.i18n.crud_content_gachno_chuyenkhoan}
          </h1>
        </section>
        <section class="content">
		  <div class="row">
            <div class="col-md-12">
                
              <!-- Block buttons -->
              <div class="box box-primary">
              	<div class="box-header with-border">
                  <n:value id="head" service="tai_quay_thong_tin_nguoi_gach_no" serviceType="query" paramSize="1" p1="${pageContext.request.userPrincipal.name}">
                  	Kỳ thuế: <small class="label label-success">$list.get(0).CKN</small> - Người gạch: <small class="label label-success">$list.get(0).HOVATEN</small> - Quầy: <small class="label label-danger">$list.get(0).TENQUAY</small> - Bưu cục: <small class="label label-danger">$list.get(0).TENBUUCUC</small>	
                  	</n:value>
                  <div class="box-tools">
                  </div>
                </div><!-- /.box-header -->
                <div class="box-body no-padding">
                    
                    <table id="nnts" class='table table-condensed'>
                    <tr>
                        <td width="10%" style="font-weight:bold;color:#039" title="${n.i18n.crud_valid_length_prefix} 100 ${n.i18n.crud_valid_length_postfix}" id="ma_nh_label">${n.i18n.chuyenkhoans_nganhang}*</td>
                        <td><input placeholder='Type ${n.i18n.chuyenkhoans_nganhang}'  type="text" class="form-control" name="nganhang_id" id="nganhang_id"><span id="nganhang_id_msg"></span></td>                        
                     </tr>
                </table>
                    
                 </div><!-- /.box-body -->
              </div><!-- /.box -->
            </div><!-- /.col -->   
            
                     
          </div><!-- /. row -->
          <div class="row">
          	<div class="col-md-12">
                <div class="box box-primary no-padding">
                	<div class="box-body no-padding" id="data-list">
                    </div>
                </div>
            </div>
          </div> 
           <div class="col-md-12" style="text-align:center"><span id="result"></span>
                <button onClick="thanh_toan()" class="btn btn-primary"><i class="fa fa-caret-square-o-right"></i> Thanh toán</button>&nbsp;
                <button onClick="print()" class="btn btn-primary" id="btInPhieu" disabled><i class="fa fa-print"></i> In bản kê</button>&nbsp;
                <button onClick="openWindow('crud_popup.jsp?crud_type=bangphieutra/index.html','phieu_da_gach_no',920,540,'')" class="btn btn-primary"><i class="fa fa-list-ol"></i> Danh sách phiếu thanh toán</button>&nbsp;
            </div><!-- /.col -->  
        </section>
      </div><!-- /.content-wrapper -->
    </div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script>
var Objphieu;
var nganhang_id="";
var tasks = {
	<n:value service="danh_sach_nganhang_theo_tinh" serviceType="query" paramSize="1" p1="${province}">
	#set ($k = 0 )
	#foreach ($i in $list )
		#if ($k!=0),#end"$!i['ID']":"$!i['NAME']"
		#set ($k=$k+1)
	#end
	</n:value>
};
var tasksArray = $.map(tasks, function (value, key) { return { value: value, data: key }; });
$('#nganhang_id').autocomplete({
	lookup: tasksArray,
	onSelect: function (suggestion) {
		$('#data-list').html('${n.i18n.crud_process_message}');
		nganhang_id = suggestion.data;
		$.ajax({
			url: 'crud_exec.jsp?crud_type=ct_no/ajax_ngan_hang.html&province=${province}&nganhang_id='+suggestion.data,
			success: function(data){ 
				$('#data-list').html(data); 
			}
		});
	}
});
function thanh_toan(){
	var Objmst = $(':radio:checked').parent().parent().children("[name='mst']").text();		
	var text="";
	var flag;
	$('input[name^="tien_tra"]').each(function(){
		var tien=$(this).val().replace(/,/g,"")*1;
		if (tien==0){ alert('${n.i18n.crud_confirm_value_money}'); flag=0;}
		var t=$("#f"+$(this).attr("id")).val();
		text+=t.replace("{TIEN_TRA}",tien)+"|";
	});	
	if (flag==0) {return;}
	$.ajax({
		url: 'crud_exec.jsp?crud_type=ct_no/thanh_toan_ngan_hang_exec.html&mst='+Objmst+'&ma_tinh=${province}&ma_bc=${head.list.get(0).MABC_ID}&quaythu=${head.list.get(0).QUAYTHU_ID}&httt=4&tra='+text.substring(0,text.length-1),
		async: false,
		success: function(data){ 			
			if(data==data*1){
				Objphieu = data*1;
				$("#btInPhieu").attr('disabled' , false);
				$("#result").text("Gạch nợ thành công, số phiếu "+data*1+"!");
			}else{
				$("#result").text("Gạch nợ lỗi: "+data+"!");
			}
		}
	});
}

function CalTra(o){		
	$(o).val(fnumber($(o).val()));		
}

function print(){
	var Pmst = $(':radio:checked').parent().parent().children("[name='mst']").text();
	var Pten = $(':radio:checked').parent().parent().children("[name='ten_nnt']").text();
	var Pdiachi = $(':radio:checked').parent().parent().children("[name='diachi']").text();
	//openWindow('crud_popup.jsp?crud_type=hoadon/index.html&phieu='+Objphieu+'&ma_tinh=${province}&mst='+Pmst+'&ten='+Pten+'&diachi='+Pdiachi);  

	var jpPath = '${pathroot}' + "WEB-INF/templates/jasper/";	
		s_ = window.location.protocol+"//"+window.location.host
			+"/report/?jasperFile=jasper/receipts&jasperExportType=pdf&AGENT=${province}&IMAGE_PATH="+jpPath+"&MST_NNT="+Pmst+"&TEN_NNT="+Pten+"&DIACHI="+Pdiachi+"&PHIEU_ID="+Objphieu;
	window.open(s_);

}

</script>