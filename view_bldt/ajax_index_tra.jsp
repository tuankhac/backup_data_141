 <%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>

<div class="row">
  <div class="col-sm-12 table-responsive">
    <table class="table table-striped">
      <thead>
      	<tr><th colspan='5' style="font-weight:bold;color:#039"><b>${n.i18n.crud_info_ls_tra.toUpperCase()}</b></th></tr>
        <tr>
          <th>${n.i18n.print_phieu}</th>
		  <th>${n.i18n.print_ky_thue}</th>
          <th>${n.i18n.print_tien_tra}</th>
          <th>${n.i18n.print_chuong}</th>
          <th>${n.i18n.print_muc}</th>     
          <th>${n.i18n.print_ngay_tra}</th> 
		  <th>${n.i18n.print_tra_cuu}</th> 
        </tr>
      </thead>
      <tbody>
      <n:velocity>
		#set ($list = $u.ref("crud_info_history_service","default",["$!{mst}","$!{ma_tinh}"],2) )
		<!--
		#set( $a = $list.size() )
		$a
		-->
		#if($list.size() > 0)
			#foreach ($i in $list)
				#if($i.size() >1)
				<tr>
					<td align=left name='sophieu'>$!i["PHIEU_ID"]</td>
					<td align=left name='so_ky'>$!i["KYTHUE"]</td>
					<td align=left name='da_tra'>$!i["TIENTRA"]</td>
					<td align=left name='ma_chuong'>$!i["TEN_CHUONG"]</td>
					<td align=left name='ma_tmuc'>$!i["TEN_MUC"]</td>
					<td align=left name='ngay_tt'>$!i["NGAY_TT"]</td>
					<td align=left name='ngay_tt'><center><button onClick="InBienNhan('$!i['KYTHUE']', '$!i['PHIEU_ID']');" class="btn btn-primary" id="btInBienNhan"><i class="fa fa-print"></i></button></center></td>
				</tr>
				#else
					<tr><td colspan="7" style="text-align:center">Không có dữ liệu</td></tr>
				#end
			#end
		#else
				<tr><td colspan="7" style="text-align:center">Không có dữ liệu</td></tr>
		#end
    </n:velocity>
      </tbody>
    </table>
  </div><!-- /.col -->
</div><!-- /.row -->
<script>

function InBienNhan(ky_thue,phieu_id){
	var mst = $("#mst").val();
	var isContinue= true ;
	var obj = new Object();
	obj.mst = mst;
	$.ajax({
		type:"POST",
		data:obj,
 		datatype:'html',
		cache: false,
		url: 'view_bldt/ajax_check_info_dept.html',
		async: false,
		success: function(data){ 
 			if(data==0){
				isContinue = false;
				alert("Bạn vui lòng thanh toán tiền thuế trước khi xem BLDT");	
			}
		}
	});

	if (isContinue) {	
 		var obj = new Object();
		
		if(ma_tinh =="79TTT"){
			obj.username = "unttservice";
			obj.pass = "Untt@1234";
			obj.fkey = mst+ky_thue+phieu_id;
			obj.matinh = ma_tinh;
		} else{
			obj.username = "vnptthuhoservice";
			obj.pass = "Thuho@2015";
			obj.fkey = mst+ky_thue;
			obj.matinh = ma_tinh;
		}
		console.log(obj.fkey);
		$.ajax({
			type:"POST",
			data:obj,
			url: "view_bldt/tai_quay_bien_nhan.jsp",
			datatype:'html',
			cache: false,
			success : function(data){
				var x=window.open();
				x.document.open();
				x.document.write(data);
				x.document.close();
			},
			error: function (jqXHR, textStatus, errorThrown) {
				alert(jqXHR.responseText);
			}
		});
	}else{
		alert("failed");
		return;
	}
}
</script>
