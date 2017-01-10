function new_nhanvien_tcs(
	pid varchar2,
	pma_tinh varchar2,
	pso_cmnd varchar2,
	pten_nv varchar2,
	pdiachi varchar2,
	pnguoi_bl varchar2,
	ptien_dc varchar2,
	pso_hd varchar2,
	pngay_hd varchar2,
	pmabc_id varchar2,
	pmobile varchar2,
	pemail varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nhanvien_tcs|NEW',pid||'|'||pma_tinh||'|'||pso_cmnd||'|'||pten_nv||'|'||pdiachi||'|'||pnguoi_bl||'|'||ptien_dc||'|'||pso_hd||'|'||pngay_hd||'|'||pmabc_id||'|'||pmobile||'|'||pemail);
	s:='insert into tax.nhanvien_tcs(id,ma_tinh,so_cmnd,ten_nv,diachi,nguoi_bl,tien_dc,so_hd,ngay_hd,mabc_id,mobile,email)
	 values (:id,:ma_tinh,:so_cmnd,:ten_nv,:diachi,:nguoi_bl,:tien_dc,:so_hd,:ngay_hd,:mabc_id,:mobile,:email)';
	execute immediate s using pid,pma_tinh,pso_cmnd,pten_nv,pdiachi,pnguoi_bl,ptien_dc,pso_hd,to_date(pngay_hd,'dd/mm/yyyy'),pmabc_id,pmobile,pemail;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_nhanvien_tcs(
	pid varchar2,
	pma_tinh varchar2,
	pso_cmnd varchar2,
	pten_nv varchar2,
	pdiachi varchar2,
	pnguoi_bl varchar2,
	ptien_dc varchar2,
	pso_hd varchar2,
	pngay_hd varchar2,
	pmabc_id varchar2,
	pmobile varchar2,
	pemail varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.nhanvien_tcs|SEARCH',pid||'|'||pma_tinh||'|'||pso_cmnd||'|'||pten_nv||'|'||pdiachi||'|'||pnguoi_bl||'|'||ptien_dc||'|'||pso_hd||'|'||pngay_hd||'|'||pmabc_id||'|'||pmobile||'|'||pemail);
	s:='select * from tax.nhanvien_tcs where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
	if pso_cmnd is not null then s:=s||' and so_cmnd like '''||replace(pso_cmnd,'*','%')||''''; end if;
	if pten_nv is not null then s:=s||' and ten_nv like '''||replace(pten_nv,'*','%')||''''; end if;
	if pdiachi is not null then s:=s||' and diachi like '''||replace(pdiachi,'*','%')||''''; end if;
	if pnguoi_bl is not null then s:=s||' and nguoi_bl like '''||replace(pnguoi_bl,'*','%')||''''; end if;
	if ptien_dc is not null then s:=s||' and tien_dc like '''||replace(ptien_dc,'*','%')||''''; end if;
	if pso_hd is not null then s:=s||' and so_hd like '''||replace(pso_hd,'*','%')||''''; end if;
	if pngay_hd is not null then s:=s||' and ngay_hd=to_date('''||pngay_hd||''',''dd/mm/yyyy'')'; end if;
	if pmabc_id is not null then s:=s||' and mabc_id like '''||replace(pmabc_id,'*','%')||''''; end if;
	if pmobile is not null then s:=s||' and mobile like '''||replace(pmobile,'*','%')||''''; end if;
	if pemail is not null then s:=s||' and email like '''||replace(pemail,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_nhanvien_tcs(
	pid varchar2,
	pma_tinh varchar2,
	pso_cmnd varchar2,
	pten_nv varchar2,
	pdiachi varchar2,
	pnguoi_bl varchar2,
	ptien_dc varchar2,
	pso_hd varchar2,
	pngay_hd varchar2,
	pmabc_id varchar2,
	pmobile varchar2,
	pemail varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nhanvien_tcs|EDIT',pid||'|'||pma_tinh||'|'||pso_cmnd||'|'||pten_nv||'|'||pdiachi||'|'||pnguoi_bl||'|'||ptien_dc||'|'||pso_hd||'|'||pngay_hd||'|'||pmabc_id||'|'||pmobile||'|'||pemail);
	s:='update tax.nhanvien_tcs set  id=:id,ma_tinh=:ma_tinh,so_cmnd=:so_cmnd,ten_nv=:ten_nv,diachi=:diachi,nguoi_bl=:nguoi_bl,tien_dc=:tien_dc,so_hd=:so_hd,ngay_hd=:ngay_hd,mabc_id=:mabc_id,mobile=:mobile,email=:email where id=:id';
	execute immediate s using pid,pma_tinh,pso_cmnd,pten_nv,pdiachi,pnguoi_bl,ptien_dc,pso_hd,to_date(pngay_hd,'dd/mm/yyyy'),pmabc_id,pmobile,pemail,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_nhanvien_tcs(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nhanvien_tcs|DEL',pId);
	s:='delete from tax.nhanvien_tcs where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;