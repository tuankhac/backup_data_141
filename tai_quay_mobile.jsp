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
		<div class="row">
			<div class="col-md-12">
				<!-- Custom Tabs -->
				<div class="nav-tabs-custom" id="exTab1">
					<ul class="nav nav-pills">
						<li class="active" style="font-weight:bold"><a href="#tab_1" data-toggle="tab"><icon class="fa fa-dollar"></icon> Thanh toán</a></li>
						<li style="font-weight:bold"><a href="#tab_2" data-toggle="tab"><icon class="fa fa-history"></icon> Lịch sử</a>
						</li>                           
					</ul>
					<div class="tab-content">
						<div class="tab-pane active" id="tab_1">
							<div class="box-body no-padding">												
								<table class="table table-striped">
								<tbody><tr>
									<div>
										<n:value id="head" service="tai_quay_thong_tin_nguoi_gach_no" serviceType="query" paramSize="1" p1="${pageContext.request.userPrincipal.name}">																				
										<th colspan=2>
											<span style="font-weight:bold;color:#039">MST </span>
											<span data-toggle="tooltip" style="padding-right:5px" class="badge bg-red" id="mst"></span>
											<span style="font-weight:bold;color:#039">&nbsp;Chu kỳ </span>
											<span data-toggle="tooltip" style="padding-right:5px" class="badge bg-red">$list.get(0).CKN</span> 											
										</th>
										</n:value>									
									</div>
									<th></th>									
								</tr>		
								<tr>			
									<td style="font-weight:bold;">Tên</td>
									<td>
										<span class="pull-left" name="ten_nnt" id="ten_nnt" style="padding-left:5px">
									</td>								  
								</tr>
								<tr>			
									<td style="font-weight:bold;">Địa chỉ</td>
									<td>
										<span class="pull-left" name="mota_diachi" id="mota_diachi" style="padding-left:5px">
									</td>								  
								</tr>
								<tr>
									<td colspan=2 align="center">
									<b>Tổng nợ </b><span data-toggle="tooltip" style="padding-right:5px" class="badge bg-red" id="tong_tien"></span>&nbsp;&nbsp;&nbsp;
									<b>Đã trả </b><span data-toggle="tooltip" title="" class="badge bg-blue" name="da_tra_f" id="da_tra_f">0</span>
									</td>										
								</tr>																							
								</tbody></table>														
								<div id="data-list"></div>								
								
							</div><!-- /.box-body -->
							<div class="box-footer">							
								<div class="col-md-12" style="text-align:center">
									<button onClick="thanh_toan()" class="btn btn-primary btn-sm"><i class="fa fa-money"></i> Gạch nợ</button>&nbsp;
									<button disabled onClick="in_biennhan()" class="btn btn-primary btn-sm" id="btInPhieu"><i class="fa fa-print"></i> In phiếu</button>&nbsp;									
								</div>
								<div style="text-align:center"><span id="result" style="font-weight:bold;color:#039"></span></div>
							</div><!-- /.box-footer-->
					
						</div><!-- /.tab-pane -->
						<div class="tab-pane" id="tab_2"> 
							<div class="box-body no-padding">	
								<div id="tab-data-list"></div>	
							</div>	
						</div><!-- /.tab-pane -->                  
					</div><!-- /.tab-content -->
				</div><!-- nav-tabs-custom -->
            </div>						
		</div><!-- /. row -->   			          

</div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script type="text/javascript">

function getDateTime() {
    var now     = new Date(); 
    var year    = now.getFullYear();
    var month   = now.getMonth()+1; 
    var day     = now.getDate();
    var hour    = now.getHours();
    var minute  = now.getMinutes();
    var second  = now.getSeconds(); 
    if(month.toString().length == 1) {
        var month = '0'+month;
    }
    if(day.toString().length == 1) {
        var day = '0'+day;
    }   
    if(hour.toString().length == 1) {
        var hour = '0'+hour;
    }
    if(minute.toString().length == 1) {
        var minute = '0'+minute;
    }
    if(second.toString().length == 1) {
        var second = '0'+second;
    }   
    var dateTime = year+'/'+month+'/'+day+' '+hour+':'+minute+':'+second;   
     return dateTime;
}

function CalTra(o){
	$(o).val(fnumber($(o).val()));
	var tien_tra=0;
	$('input[name="tien_tra"]').each(function(){
		tien_tra+=$(this).val().replace(/,/g,"")*1;
	});
	$("#tien_tra").text(fnumber(tien_tra+""));
}

function getQueryVariable(variable)
{
       var query = window.location.search.substring(1);
       var vars = query.split("&");
       for (var i=0;i<vars.length;i++) {
               var pair = vars[i].split("=");
               if(pair[0] == variable){return pair[1];}
       }
       return(false);
}
var mst_= getQueryVariable("mst");
var print_phieu =0;
var print_time = getDateTime();
var print_ten_ntt;
var print_dc_ntt;
var print_tientra=0;
var print_ten_nv = "${head.list.get(0).HOVATEN}";
var print_ckn = "${head.list.get(0).CKN}";

function thanh_toan(){
	if( !confirm('${n.i18n.crud_confirm_message}') ){return;}
	var text="";
	var flag;
	$('input[name="tien_tra"]').each(function(){
		var tien=$(this).val().replace(/,/g,"")*1;
		if (tien==0){ alert('${n.i18n.crud_confirm_value_money}'); flag=0;}
		print_tientra = print_tientra + tien;
		var t=$("#f"+$(this).attr("id")).val();		
		text+=t.replace("{TIEN_TRA}",tien)+"|";				
	});
	
	if (flag==0) {return;}
	
	$.ajax({
		url: 'crud_exec.jsp?crud_type=ct_no/thanh_toan_exec.html&mst='+mst_+'&ma_tinh=${province}&ma_bc=${head.list.get(0).MABC_ID}&quaythu=${head.list.get(0).QUAYTHU_ID}&httt=3&tra='+text.substring(0,text.length-1),
		async: false,
		success: function(data){ 
			if(data==data*1){
				print_phieu = data*1;
				$("#btInPhieu").attr('disabled' , false);
				onLoadLsTra(mst_);	
				$("#result").text("Gạch nợ thành công, số phiếu "+data*1+"!");
			}else{
				$("#result").text("Gạch nợ lỗi: "+data+"!");
			}
		}
	});
}

$(document).ready(function loadInfo(){
	$.ajax({
		url: 'crud_exec.jsp?crud_type=nnts/tai_quay_info_exec.html&mst='+mst_,async: false,
		success: function(data){ 
			eval('data='+data);	
			$("#ten_nnt").html(data.TEN_NNT);		
			$("#mst").html(data.MST);
			$("#loai_nnt").html(data.LOAI_NNT);
			$("#so").html(data.SO);
			$("#chuong").html(data.CHUONG);
			$("#ma_cqt_ql").html(data.MA_CQT_QL);
			$("#mota_diachi").html(data.MOTA_DIACHI);
			$("#mobile").html(data.EMAL+"/"+data.MOBILE);
			$("#ma_nv").html(data.MA_NV);
			$("#tong_tien").html(data.SOTIEN);
			$("#da_tra_f").html(data.TIEN_TRA);	
			print_ten_ntt = data.TEN_NNT;
			print_dc_ntt = data.MOTA_DIACHI;
		}
	});	
	
	//Lay thong tin no theo khoan muc
	$.ajax({
		url: 'crud_exec.jsp?crud_type=ct_no/ajax_index_mobile.html&mst='+mst_+'&ma_tinh=${province}',async: false,
		success: function(data){ 
			$('#data-list').html(data);
			$('#result').html('');
		}
	});
	
	//Lay lich su thanh toan theo MST
	onLoadLsTra(mst_);	

	var tien_tra=0;
	$('input[name="tien_tra"]').each(function(){
		tien_tra+=$(this).val().replace(/,/g,"")*1;
	});
	$("#tien_tra").text(fnumber(tien_tra+""));
});

function onLoadLsTra(Vmst){
	
	$.ajax({
		url: 'crud_exec.jsp?crud_type=nnts/tai_quay_info_exec.html&mst='+mst_,async: false,
		success: function(data){ 
			eval('data='+data);				
			$("#da_tra_f").html(data.TIEN_TRA);	
			print_ten_ntt = data.TEN_NNT;
			print_dc_ntt = data.MOTA_DIACHI;
		}
	});	
	
	$.ajax({
		url: 'crud_exec.jsp?crud_type=ct_no/ajax_index_mobile.html&mst='+Vmst+'&ma_tinh=${province}',async: false,
		success: function(data){ 
			$('#data-list').html(data);
		}
	});
	
	$.ajax({		
		url: 'crud_exec.jsp?crud_type=bangphieutra/ajax_index_mobile.html&record_per_page=500&page_index=1&mst='+Vmst,
		success: function(data){	
			$('#tab-data-list').html(data);		
		}
	});
}
function in_biennhan(){	
	openWindow('crud_popup.jsp?crud_type=ct_no/in_bien_nhan.html&phieu='+print_phieu+'&tientra='+fnumber(print_tientra+"")+'&mst='+mst_+'&ten='+print_ten_ntt+'&diachi='+print_dc_ntt+'&tennv='+print_ten_nv+'&tennv='+print_ten_nv+'&ckn='+print_ckn+'&time='+print_time,'in_bien_nhan',480,320,'');
}
</script>