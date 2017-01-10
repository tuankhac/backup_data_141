<%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>
<div class="row">
  <div class="col-sm-12 table-responsive">
    <table class="table table-striped">
      <thead>
      	<tr><th colspan='5' style="font-weight:bold;color:#039"><b>${n.i18n.crud_info_ls_no.toUpperCase()}</b></th></tr>
        <tr>
          <th>${n.i18n.crud_info_no_cuoi_ky}</th>
          <th>${n.i18n.crud_info_chuong}</th>
          <th>${n.i18n.crud_info_muc}</th>
          <th>${n.i18n.crud_info_da_tra}</th>     
          <!--th>${n.i18n.crud_info_tien_tra}</th--> 
        </tr>
      </thead>
      <tbody>
      <n:velocity>
		#set ($list = $u.ref("crud_search_ct_no_service","default",["$!{mst}","$!{ma_tinh}"],2) )
		<!--#set( $a = $list.size() )
		$a-->
			#if($list.size() > 0)

		#foreach ($i in $list)	
			<tr>
				<td align=left name='no_cuoi_ky'>$!i["NO_CUOI_KY"]<input type="hidden" id="fn_$!i["MA_CHUONG"]_$!i["MA_TMUC"]" value="$!{mst},$!{ma_tinh},{TIEN_TRA},$!i["MA_CHUONG"],$!i["MA_CQ_THU"],$!i["MA_TMUC"],$!i["SO_TAIKHOAN_CO"],$!i["SO_QDINH"],$!i["NGAY_QDINH"],$!i["LOAI_TIEN"],$!i["TI_GIA"],$!i["LOAI_THUE"]" ></td>
				<td align=left name='ma_chuong'>$!i["TEN_CHUONG"]</td>
				<td align=left name='ma_tmuc'>$!i["TENTIEUMUC"]</td>
				<td align=left name='da_tra'>$!i["TIEN_TRA"]</td>
				<!--td align=left name='ngay_qdinh'>$!i["SOTIEN"]</td-->
			</tr>

		#end
			#else
				<tr><td colspan="4" style="text-align:center">Không có dữ liệu</td></tr>
			#end
    </n:velocity>
      </tbody>
    </table>
  </div><!-- /.col -->
</div><!-- /.row -->

