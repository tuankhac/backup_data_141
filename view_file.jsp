<%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:setProperty name="n" property="language" value="${not empty param.language ? param.language : 'vi_VN'}"/>
<style type="text/css">
.modal {
    display:	none;
    position:   fixed;
    z-index:    1000;
    top:        0;
    left:       0;
 
}
.center{
        z-index: 1000;
        margin: 200px auto;
        width: 140px;
        border-radius: 10px;
        filter: alpha(opacity=100);
        opacity: 1;
        -moz-opacity: 1;
}
.center img {
	height: 100px;
	width: 100px;
}
 
body.loading {
    overflow: hidden;   
}
 
body.loading .modal {
    display: block;
}

</style>
<%@include file="/header.jsp"%>
<link href="/assets/bootstrap/plugins/iCheck/all.css" rel="stylesheet" type="text/css" />
<script src="/assets/bootstrap/plugins/iCheck/icheck.min.js" type="text/javascript"></script>
<script type="text/javascript" src="style/base64.js"></script>
<div class="content-wrapper">
   <section class="content-header">
      <h1>
      </h1>
   </section>
   <section class="content">
      <div class="nav-tabs-custom">
         <div class="box box-primary">
            <div class="tab-content">
               <div class="box-body no-padding">
                  <div class="box-header with-border">
                     <h3 class="box-title" style="font-weight:bold;color:#039">DANH SÁCH FILE</h3>
                     <div class="box-tools"></div>
                  </div>
                  <!-- /.box-header -->
                  <div class="box-body no-padding">
                     <table id="nnts" class='table table-condensed'>
                        <tr>
                           <td width=8% title="${n.i18n.crud_valid_length_prefix} 30 ${n.i18n.crud_valid_length_postfix}">${n.i18n.curd_report_start_date}</td>
                           <td>
                              <input  type="text" class="form-control" name="tu_ngay" id="tu_ngay"><span id="tungay_msg"></span>
                           </td>
                           <td width=12% title="${n.i18n.crud_valid_length_prefix} 22 ${n.i18n.crud_valid_length_postfix}">${n.i18n.curd_report_end_date}</td>
                           <td>
                              <input  type="text" class="form-control" name="den_ngay" id="den_ngay"><span id="denngay_msg"></span>
                           </td>
                        </tr>
                        <tr>
                           <td width ="12%" title="${n.i18n.crud_valid_length_prefix} 30 ${n.i18n.crud_valid_length_postfix}">Tên kho bạc</td>
                           <td>
                              <select class="form-control" name="chi_cuc_thue" id="chi_cuc_thue">
							  <option value = "">Không chọn</option>
							  <n:velocity>
							  #foreach ($i in $u.qry("lay_kho_bac","default",[${province}],1))
							  <option value = "$i['ID']">$i["TEN_KHO_BAC"] </option>
							  #end
							  </n:velocity>
							  </select><span id="chi_cuc_thue_msg"></span>
                           </td>
						   
                        </tr>
						<tr><td colspan="4" align='center'><button type="button" onclick="viewFile()" class="btn btn-primary" id="upload_btn">View File</button></td></tr>
                     </table>
                  </div>
				 <section class="content-header">
				   <h1>
				   </h1>
				</section>
				<div class="box box box-primary">
					<div id="result_data">
						
					</div>
				</div>
			   </div>
            </div>
         </div>
      </div>
   </section>
   <div class="modal" style="display: none">
      <div class="center">
         <img alt="" src="style/img/loading_2.gif" />
      </div>
   </div>
</div>
<%@include file="/footer.jsp"%> 
<script type="text/javascript">
	
	var today = new Date();
   $('#tu_ngay').datepicker({format:"dd/mm/yyyy"});
   $('#den_ngay').datepicker({format:"dd/mm/yyyy"});
   $("#tu_ngay").datepicker().datepicker("setDate", new Date(today.getTime() - 120*24*60*60*1000));
   $("#den_ngay").datepicker().datepicker("setDate", today);
   
   var param = new Object();
   function viewFile(){
		
		param.tu_ngay = $("#tu_ngay").val();
		param.den_ngay = $("#den_ngay").val();
		if($("#chi_cuc_thue").val() == ""){
			alert("Vui lòng chọn tên kho bạc");
			return;
		}
		$(".modal").show();
		console.log("show");
		$.ajax({
			type : "GET",
   			url: 'crud_exec.jsp?crud_type=download_gip/get_id_filter.html&chi_cuc_thue='+$("#chi_cuc_thue").val()+'&ma_tinh=${province}',
   			success: function(data){ 
				//alert(data);
   				param.id_filter = data;
				param.id_filter.trim().replace("\n","");
		
				$.ajax({
					type : "POST",
					url: 'download_gip/filter_result.jsp',
					cache : false,
					async:false,
					data : param,
					success: function(data){
						$(".modal").hide();
						console.log("hide");
						$("#result_data").html(data);
					}
				});
   			}
   		});
		//
		
   }
</script>