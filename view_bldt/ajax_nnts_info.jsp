<%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>
<n:velocity>
#set ($list = $u.ref("tai_quay_nnt_info","default",["$!{mst}","$!{ma_tinh}","$!{request.UserPrincipal.name}","$!{request.RemoteAddr}"],4) )
#foreach ($i in $list)
{"MST":"$!i["MST"]","TEN_NNT":"$!i["TEN_NNT"]","LOAI_NNT":"$!i["LOAI_NNT"]","SO":"$!i["SO"]","CHUONG":"$!i["CHUONG"]","MA_CQT_QL":"$!i["MA_CQT_QL"]","MOTA_DIACHI":"$!i["MOTA_DIACHI"]","MOBILE":"$!i["MOBILE"]","EMAIL":"$!i["EMAIL"]","MA_NV":"$!i["MA_NV"]","SOTIEN":"$!i["SOTIEN"]","TIEN_TRA":"$!i["TIEN_TRA"]",
"PATTERN":"$!i["PATTERN"]","NUMB_BILL":"$!i["NUMB_BILL"]", "SERIAL":"$!i["SERIAL"]", "MA_TINH":"$!i["MA_TINH"]"};
#end
</n:velocity>
 