function new_tien_nop(
	pma_bc varchar2,
	pma_nv varchar2,
	pngay_nop varchar2,
	ptien varchar2,
	pnguoi_cn varchar2,
	pngay_cn varchar2,
	pip_cn varchar2,
	pid varchar2,
	pnoi_dung varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.tien_nop|NEW',pma_bc||'|'||pma_nv||'|'||pngay_nop||'|'||ptien||'|'||pnguoi_cn||'|'||pngay_cn||'|'||pip_cn||'|'||pid||'|'||pnoi_dung);
	s:='insert into tax.tien_nop(ma_bc,ma_nv,ngay_nop,tien,nguoi_cn,ngay_cn,ip_cn,id,noi_dung)
	 values (:ma_bc,:ma_nv,:ngay_nop,:tien,:nguoi_cn,:ngay_cn,:ip_cn,:id,:noi_dung)';
	execute immediate s using pma_bc,pma_nv,to_date(pngay_nop,'dd/mm/yyyy'),ptien,pnguoi_cn,to_date(pngay_cn,'dd/mm/yyyy'),pip_cn,pid,pnoi_dung;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_tien_nop(
	pma_bc varchar2,
	pma_nv varchar2,
	pngay_nop varchar2,
	ptien varchar2,
	pnguoi_cn varchar2,
	pngay_cn varchar2,
	pip_cn varchar2,
	pid varchar2,
	pnoi_dung varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.tien_nop|SEARCH',pma_bc||'|'||pma_nv||'|'||pngay_nop||'|'||ptien||'|'||pnguoi_cn||'|'||pngay_cn||'|'||pip_cn||'|'||pid||'|'||pnoi_dung);
	s:='select * from tax.tien_nop where 1=1';
 	if pma_bc is not null then s:=s||' and ma_bc like '''||replace(pma_bc,'*','%')||''''; end if;
	if pma_nv is not null then s:=s||' and ma_nv like '''||replace(pma_nv,'*','%')||''''; end if;
	if pngay_nop is not null then s:=s||' and ngay_nop=to_date('''||pngay_nop||''',''dd/mm/yyyy'')'; end if;
	if ptien is not null then s:=s||' and tien like '''||replace(ptien,'*','%')||''''; end if;
	if pnguoi_cn is not null then s:=s||' and nguoi_cn like '''||replace(pnguoi_cn,'*','%')||''''; end if;
	if pngay_cn is not null then s:=s||' and ngay_cn=to_date('''||pngay_cn||''',''dd/mm/yyyy'')'; end if;
	if pip_cn is not null then s:=s||' and ip_cn like '''||replace(pip_cn,'*','%')||''''; end if;
	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if pnoi_dung is not null then s:=s||' and noi_dung like '''||replace(pnoi_dung,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_tien_nop(
	pma_bc varchar2,
	pma_nv varchar2,
	pngay_nop varchar2,
	ptien varchar2,
	pnguoi_cn varchar2,
	pngay_cn varchar2,
	pip_cn varchar2,
	pid varchar2,
	pnoi_dung varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.tien_nop|EDIT',pma_bc||'|'||pma_nv||'|'||pngay_nop||'|'||ptien||'|'||pnguoi_cn||'|'||pngay_cn||'|'||pip_cn||'|'||pid||'|'||pnoi_dung);
	s:='update tax.tien_nop set  ma_bc=:ma_bc,ma_nv=:ma_nv,ngay_nop=:ngay_nop,tien=:tien,nguoi_cn=:nguoi_cn,ngay_cn=:ngay_cn,ip_cn=:ip_cn,id=:id,noi_dung=:noi_dung where id=:id';
	execute immediate s using pma_bc,pma_nv,to_date(pngay_nop,'dd/mm/yyyy'),ptien,pnguoi_cn,to_date(pngay_cn,'dd/mm/yyyy'),pip_cn,pid,pnoi_dung,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_tien_nop(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.tien_nop|DEL',pId);
	s:='delete from tax.tien_nop where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;