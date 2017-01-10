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
        <section class="content">
		  <div class="row">
            <div class="col-md-12">
                
              <!-- Block buttons -->
              <div class="box box-primary">
              	<div class="box-header with-border">
                  <h3 class="box-title">Phân tuyến thu thuế khoán cho nhân viên</h3>
                  <div class="box-tools">
                  </div>
                </div><!-- /.box-header -->
                <div class="box-body" style="background:#fcfcfc">
                    
                    <!-- The time line -->
                      <ul class="timeline">
                        <!-- timeline time label -->
                        <li class="time-label">
                          <span class="bg-aqua">
                            Chọn nhân viên
                          </span>
                        </li>
                        <li>
                          <div class="timeline-item">
                            <div class="box box-body box-info" >
                            	<!--select class="form-control" name="ma_nv_g" id="ma_nv_g">
                                    <n:option service="danh_sach_nv_tc_theo_tinh" serviceType="query" paramSize="1" p1="${province}"/>
                                </select-->
								<div class="row">
								<div  class="col-md-7">
									<input  type="text" class="form-control" name="ma_nv_g" id="ma_nv_g">
								</div>
								<div class="col-md-5">
									<th>STT</th>
									<th><input  type="text" name="ma_tuyen" id="ma_tuyen"></th>
								</div>
								</div>
                            </div>
                          </div>
                        </li>
                        <li class="time-label">
                          <span class="bg-green">
                            Tìm kiếm và chọn những NNT
                          </span>
                        </li>
                        <li>
                          <div class="timeline-item">
                          	<div class="box box-success box-body no-padding">
                                <jsp:include page="velocity.jsp" >
                                  <jsp:param name="crud_type" value="nnts/phan_tuyen.html" />
                                  <jsp:param name="id" value="" />
                                  <jsp:param name="record_per_page" value="100" />
                                  <jsp:param name="page_index" value="1" />
                                </jsp:include>
                            </div>
                          </div>
                        </li>
                        <li class="time-label">
                          <span class="bg-red">
                            Phân những người nộp thuế đã chọn cho Nhân viên thu
                          </span>
                        </li>
                        <li>
                          <div class="timeline-item">
                          	<div class="box box-danger box-body">
                                <span id="result"></span><button class="btn btn-danger" onClick="phan_tuyen()"><i class="fa fa-edit"></i> Thực hiện</button>
                            </div>
                          </div>
                        </li>
                        <!-- END timeline item -->
                        <li>
                          <i class="fa fa-usd bg-aqua"></i>
                        </li>
                      </ul>                                        
                 </div><!-- /.box-body -->
              </div><!-- /.box -->
            </div><!-- /.col -->   
            <div class="col-md-4">
                
            </div><!-- /.col -->            
          </div><!-- /. row -->
        </section>
      </div><!-- /.content-wrapper -->
    </div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script>

function phan_tuyen(){
	var s="";
	$('input[name="nnts_rad"]:checked').each(function(){
		s+=$("#mst"+$(this).attr('id')).text()+",";
	})
	$('#result').html('${n.i18n.crud_process_message}');

	$.ajax({
		url: 'crud_exec.jsp?crud_type=nnts/phan_tuyen_kythue_exec.html&ma_nv='+ma_nv_g+'&ma_t='+$('#ma_tuyen').val()+'&msts='+s.substring(0,s.length-1),
		success: function(data){ 
			if (data*1==1)
			{
				$('#doSearch').click();
				$('#result').html('Đã cập nhật các mã <b>['+s.substring(0,s.length-1)+']</b> cho tuyến <b>'+$('#ma_nv_g').val()+'</b>!');
			}
			else if (data*1==2) $('#result').html('Không được phép phân tuyến cho NNT không thuộc đơn vị mình quản lý');
			else $('#result').html('Lỗi thực hiện :'+data);
		}
	});
}

var ma_nv_g="";
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
$('#ma_nv_g').autocomplete({
	lookup: tasksArray,
	onSelect: function (suggestion) {
		ma_nv_g = suggestion.data;		
	}
});
</script>