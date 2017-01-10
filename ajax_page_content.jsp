<%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>
<table><tr><td></td></tr></table>
 <n:value service="crud_search_contents_service_sum" serviceType="ref" paramSize="12" p1="" p2="${param.id}" p3="" p4="" p5="" p6="" p7="" p8="3" p9="15" p10="1" p11="" p12="">                        
<tbody>
 
	<table class="paging_bg" id="Paging_1" cellpadding=0 cellspacing=0 align=center  width="100%" >
		<tr  align="center">
		   <td  align=left width=30%  ><strong>T&#7893;ng s&#7889; <span id="TotalRow">$!list[0]['PAGE']</span>  Record</strong></td>
		   <td width="12%">
				<A href="javascript:GoStartPage()" title="Danh sach san pham">
			<span style="display:inline-block;width:20px;height:13px" class="cicon ui-icon-arrowthickstop-1-w"></span> <span style="color:#000000">Trang &#273;&#7847;u</span></A></td>
			 #foreach($i in $list)
				#if( $!i['PAGE_REC'] != 0)
					<td id=page$!i['PAGE']><span id=sp$!i['PAGE'] class=paging><a href='javascript:search_information($!i['PAGE'], $!i['PAGE_REC'])' >  $!i['PAGE']&nbsp; </a></span> </td>
				#end
			#end
			<td width="50%" align="left"><A href="javascript:GoEndPage()" title="Danh sach san pham">
			<span style="color:#000000">Trang cu&#7889;i</span><span style="display:inline-block;width:20px;height:13px" class="cicon ui-icon-arrowthickstop-1-e "></span></A></td>    

		</tr>
	  </table>
 
</tbody>  
 </n:value>
<script language="javascript">
$(document).ready(function(){
  	$("#sp$!i['PAGE']").css({"background-color":"#ffffff","color":"#E87817"});
	
});
	var GloPageRec=0;
function SetPageRec(){ 
	GloPageRec=$("#cboSetPageRec").val();
	search_information(1,GloPageRec);
}

function SelectPage(){
	var GloPageRec=$("#cboSetPageRec").val();
	var GloPageNum=$("#cboselectPage").val();
	search_information(GloPageNum,GloPageRec);	
	$("#cboselectPage").val(GloPageNum);

}

function GoStartPage(){
 GloPageRec=$("#cboSetPageRec").val();
 search_information(1,GloPageRec);	
}

function GoEndPage(){
 var EndPage;
 GloPageRec=$("#cboSetPageRec").val();
 countRow=$("#TotalRow").html();
 if(GloPageRec)
 var tg=Math.ceil((countRow*1)/GloPageRec);
 else{
  var tg=Math.ceil((countRow*1)/15);
  GloPageRec=15;
  }
 EndPage=tg;

 if((countRow*1)) EndPage=EndPage; else    	 
 EndPage=EndPage+1;
 search_information(EndPage,GloPageRec);	
}
</script> 