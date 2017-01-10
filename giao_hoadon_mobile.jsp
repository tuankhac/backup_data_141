<%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:setProperty name="n" property="language" value="${not empty param.language ? param.language : 'vi_VN'}"/>
<html>
<%@include file="header.jsp"%>
<link href="/assets/bootstrap/plugins/iCheck/all.css" rel="stylesheet" type="text/css" />
<script src="/assets/bootstrap/plugins/iCheck/icheck.min.js" type="text/javascript"></script>
<script src="/assets/bootstrap/plugins/autocomplete/jquery.autocomplete.min.js" type="text/javascript"></script>
<link href="/assets/bootstrap/plugins/autocomplete/styles.css" rel="stylesheet" type="text/css" />
<!-- style auto complete textbox -->

 <!-- end style auto complete textbox -->
<!-- Content Wrapper. Contains page content -->
	<div class="content-wrapper">
		<section class="content">
        <!-- Content Header (Page header) -->	        
			<div class="row-fluid">				
				<div class="box box-info box-solid">
					<div class="box-header with-border ">
						<n:value id="head" service="crud_search_users_info_staff" serviceType="query" paramSize="1" p1="${pageContext.request.userPrincipal.name}">
						<div class="row">
							<div class="col-md-8">
								<icon class="fa fa-list"></icon>
								<b>${n.i18n.info_giao_hd_m_label1}</b>
							</div>
							<div class="col-md-4">
								<div class="input-group ">
                                    <input type="text" id="search_key" name="table_search" class="form-control" placeholder="${n.i18n.crud_search_button_message}">
                                    <div class="input-group-btn">
                                        <button id="btn_search_ntt" class="btn btn-sm btn-default form-control"><i class="fa fa-search"></i></button>
                                    </div>
                                </div>
							</div>							
						</div>
						</n:value>
					</div><!-- /.box-header -->
  					<div class="box-body">
						<div class="box-body no-padding" id='data-list' style="overflow:auto;margin:auto"></div>
 						<div id="div_page_section2" class=""></div>
					</div><!-- /.box-body -->
				</div><!-- /.box -->					                            
			</div><!-- /. row -->   
		</section>
    </div><!-- ./wrapper -->
<%@include file="footer.jsp"%> 
<script  type="text/javascript">
	var record_per_page=10;
	var page=1;
	var nop, nor = 0;
	//Khoi tao doi tuong quan ly phan trang:
	var objPage;
	objPage=new pageTemplates('div_page_section1','div_page_section2','pClick','onGetData');
 
	var manv_ = '${head.list.get(0).STAFF}';	
	$(document).ready(function(){			
		doSearch();
	});
	function doSearch(){
		// record_per_page=$('#numb_rec :selected').text();
		objPage.setRecPerPage(record_per_page);
		objPage.setTypeTemplate('BOOTSTRAP'); //News Template page with bootstrap:
		$.ajax({
			url: 'crud_exec.jsp?crud_type=nnts/ajax_get_nop_nor.html'+getParams(page,record_per_page),
			success: function(data){ 
				$('#data-list').html(data);
				$('#show_result').html('');
				onStartSearch();
			}
		});
	}
	function tong_tien(){
		var c=0,s=0;
		$('input[name="nnts_rad"]:checked').each(function(){
			c+=1;
			s+=$("#so_tien"+$(this).attr('id')).text().replace(/,/g,"")*1;
		});
		$("#tong_phieu").text(c);
		$("#tong_tien").text(fnumber(s+""));
	}
	$("#btn_search_ntt").click(function(){
		$.ajax({
			url: 'crud_exec.jsp?crud_type=nnts/ajax_get_nop_nor.html'+getParams(page,record_per_page),
			timeout: 1000,
			success: function(data){ 
				$('#data-list').html(data);
				$('#show_result').html('');
				onStartSearch();
			}
		});
	})
	// $( "#search_key" ).on('input', function(){
	// 	$.ajax({
	// 		url: 'crud_exec.jsp?crud_type=nnts/ajax_get_nop_nor.html'+getParams(page,record_per_page),
	// 		timeout: 1000,
	// 		success: function(data){ 
	// 			$('#data-list').html(data);
	// 			$('#show_result').html('');
	// 			onStartSearch();
	// 		}
	// 	});
 //    });
	//phan trang:
		//Ham nay duoc goi khi Click vao cac so tren trang...
	function pClick(ps_page_id,ps_rec_per_page) {
		objPage.setCurrentPage(ps_page_id);
		objPage.setRecPerPage(ps_rec_per_page);
		objPage.returnDataCount(objPage.getTotalRec());
	}
	//Ham nay tu dong duoc goi sau khi click vao cac so...:
	function onGetData(page, size){
		$.ajax({
			url: 'crud_exec.jsp?crud_type=nnts/ajax_giao_phieu_mobile.html'+getParams(page,record_per_page),
			timeout: 1000,
			success: function(data){ 
				if(data!=''){
					$('#data-list').html(data);
					$('#show_result').html('');
				}
				if(nor==0 && data!=''){
					$('#show_result').attr('style',' color:red; font-weight:bold;');
					$('#show_result').html('Không có dữ liệu!');
				}
			}
		});
	}
	//Ham tra ve chuoi parameters, truyen vao ajax de lay nop, nor va du lieu hien thi
	function getParams(page,record_per_page){
		var exec='&record_per_page='+record_per_page+'&page_index='+page+'&search_key='+$("#search_key").val()+'&province=${province}&ma_nv=${manv_}';
		return exec;
	}
	function onStartSearch(){
		//Khi search noi dung thi hien thi lai tu trang 1:
		objPage.setCurrentPage(1);
		//Get Total rows:
		var total = nor;
		// alert(total);
		//Truyen tong so ban ghi vao den hien thi phan trang va tu dong goi ham:onGetData
		objPage.returnDataCount(total);
	}

</script>