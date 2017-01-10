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
          <h1>${n.i18n.crud_content_gachno_tainha}</h1>
        </section>
        <section class="content">
		  <div class="row">
            <div class="col-md-12">
                
              <!-- Block buttons -->
              <div class="box box-primary">
              	<div class="box-header with-border">
                <n:value id="head" service="tai_quay_thong_tin_nguoi_gach_no" serviceType="query" paramSize="1" p1="${pageContext.request.userPrincipal.name}">
                  	Chu kỳ: <small class="label label-success">$list.get(0).CKN</small> - Người gạch: <small class="label label-success">$list.get(0).HOVATEN</small> - Quầy: <small class="label label-danger">$list.get(0).TENQUAY</small> - Bưu cục: <small class="label label-danger">$list.get(0).TENBUUCUC</small>				
                </n:value>												
                <div class="box-tools"></div>
                </div><!-- /.box-header -->		
                <div class="box-body no-padding">                    
                    <table id="nnts" class='table table-condensed'>
						<tr>
							<td width="7%" title="${n.i18n.crud_valid_length_prefix} 100 ${n.i18n.crud_valid_length_postfix}" id="ma_nv_label">Mã NV</td>
							<td width="40%">
								<input  type="text" class="form-control" name="ma_nv" id="ma_nv"><span id="ma_nv_msg"></span></td>
							<td><input type="text" name="Objmst" id="Objmst" onkeyup="search_mst()" class="form-control" placeholder="Search MST..."/></td>
							<td>${n.i18n.curd_info_tong_ma_tt}: <small class="label label-success"><i class="fa fa-dashcube"></i> <font id="tong_phieu">0</font></small>&nbsp;<small class="label label-primary"><i class="fa fa-dashcube"></i> <font id="tong_mst">0</font></small> - ${n.i18n.curd_info_tong_tien_tt}: <small class="label label-danger"><i class="fa fa-usd"></i> <font id="tong_tien">0</font></small>
							</td>
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
                <button onClick="thanh_toan()" class="btn btn-primary" id="btThanhtoan"><i class="fa fa-caret-square-o-right"></i> Thanh toán</button>&nbsp;
                <!--button onClick="print()" class="btn btn-primary"><i class="fa fa-print"></i> In bản kê gạch nợ</button>&nbsp; -->
                <button onClick="openWindow('crud_popup.jsp?crud_type=bangphieutra/index.html','phieu_da_gach_no',920,540,'')" class="btn btn-primary"><i class="fa fa-list-ol"></i> Danh sách phiếu thanh toán</button>&nbsp;
            </div><!-- /.col -->  
        </section>
      </div><!-- /.content-wrapper -->
    </div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script>
function CalTra(o){
	var tien_tra =0;	
	$('input[name="nnts_rad"]:checked').each(function(){
		$(o).val(fnumber($(o).val()));
		tien_tra +=$("#i"+$(this).attr("id")).val().replace(/,/g,"")*1;
	});
	
	$("#tong_tien").text(fnumber(tien_tra+""));
}
function tong_tien(){
	var c=0,s=0,r=0,ss="";
	$('input[name="nnts_rad"]:checked').each(function(){
		c+=1;
		s+=$("#i"+$(this).attr('id')).val().replace(/,/g,"")*1;		
			
		if (ss != $(this).val()) {
			r+=1; ss = $(this).val();
		};
	});
	$("#tong_mst").text(r);
	$("#tong_phieu").text(c);
	$("#tong_tien").text(fnumber(s+""));
}
var ma_nv="";
var tasks = {
	<n:value service="danh_sach_nv_tc_theo_tinh" serviceType="query" paramSize="1" p1="${province}">
	#set ($k = 0 )
	#foreach ($i in $list )
		#if ($k!=0),#end"$!i['ID']":"$!i['NAME']"
		#set ($k=$k+1)
	#end
	</n:value>
};
var tasksArray = $.map(tasks, function (value, key) { return { value: value, data: key }; });
$('#ma_nv').autocomplete({
	lookup: tasksArray,
	onSelect: function (suggestion) {
		$('#data-list').html('${n.i18n.crud_process_message}');
		ma_nv = suggestion.data;
		$.ajax({
			url: 'crud_exec.jsp?crud_type=ct_no/ajax_kythue_tai_nha.html&province=${province}&ma_nv='+suggestion.data,
			success: function(data){ 
				$('#data-list').html(data); 
			}
		});
	}
});
function thanh_toan(){
	$("#result").text("${n.i18n.crud_process_message}");	
	$("#btThanhtoan").attr('disabled' , true);
	
	var text="",msts="";
	var sum_tien=0;
	$("#result").text('${n.i18n.crud_process_message}');
	$('input[name="nnts_rad"]:checked').each(function(){
		var tien=$("#i"+$(this).attr("id")).val().replace(/,/g,"")*1;
		sum_tien = sum_tien + tien;
		var t=$("#f"+$(this).attr("id")).val();
		text+=t.replace("{TIEN_TRA}",tien)+"|";
		msts+=$("#m"+$(this).attr("id")).text()+","
	});
	
	if (sum_tien==0){ alert('${n.i18n.crud_confirm_value_money}'); return;}		
	
	if (text.length > 4300){ 
		alert('${n.i18n.crud_confirm_value_payment}'); 
		$("#result").text("");
		$("#btThanhtoan").attr('disabled' , false);
		return;
	}
	
	$.ajax({
		url: 'crud_exec.jsp?crud_type=ct_no/thanh_toan_tainha_exec.html&msts='+msts.substring(0,msts.length-1)+'&ma_tinh=${province}&ma_bc=${head.list.get(0).MABC_ID}&quaythu=${head.list.get(0).QUAYTHU_ID}&httt=2&tra='+text.substring(0,text.length-1),
		async: false,
		success: function(data){ 	
			$("#btThanhtoan").attr('disabled' , false);
			if(data==data*1){
				$("#result").text("Gạch nợ thành công, mã phiếu gom "+data*1+"!");
				reloadInfo();
			}else{
				$("#result").text("Gạch nợ lỗi: "+data+"!");
			}
		}
	});
}

function reloadInfo(){	
	var manv_ = $("#ma_nv").val().substring(1,$("#ma_nv").val().indexOf("]"));	
	$.ajax({
		url: 'crud_exec.jsp?crud_type=ct_no/ajax_kythue_tai_nha.html&province=${province}&ma_nv='+manv_,
		success: function(data){ 
			$('#data-list').html(data); 
		}
	});
}



function search_mst(){
	setTimeout(function(){
			var mstsearch = $('#Objmst').val().trim();
		$(":checkbox").filter(function() {
		  return this.value == mstsearch;	  
		}).prop("checked","true");
		
		$('input[name="nnts_rad"]').each(function(){
			if ($(this).is(':checked')){
				$(this).parent().parent().css('background-color','#FC3');
			}else{
				$(this).parent().parent().css("background","#fff");}
			}
		);
		tong_tien();
		$('#Objmst').val("");
		}, 500);	
}
</script>