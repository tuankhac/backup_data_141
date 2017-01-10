function new_phieu_q42015(
	pid varchar2,
	pmst varchar2,
	ptien_giao varchar2,
	pma_nv varchar2,
	pngay_giao varchar2,
	pnguoi_giao varchar2,
	ptrangthai_tt varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.phieu_q42015|NEW',pid||'|'||pmst||'|'||ptien_giao||'|'||pma_nv||'|'||pngay_giao||'|'||pnguoi_giao||'|'||ptrangthai_tt);
	s:='insert into tax.phieu_q42015(id,mst,tien_giao,ma_nv,ngay_giao,nguoi_giao,trangthai_tt)
	 values (:id,:mst,:tien_giao,:ma_nv,:ngay_giao,:nguoi_giao,:trangthai_tt)';
	execute immediate s using pid,pmst,ptien_giao,pma_nv,to_date(pngay_giao,'dd/mm/yyyy'),pnguoi_giao,ptrangthai_tt;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_phieu_q42015(
	pid varchar2,
	pmst varchar2,
	ptien_giao varchar2,
	pma_nv varchar2,
	pngay_giao varchar2,
	pnguoi_giao varchar2,
	ptrangthai_tt varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.phieu_q42015|SEARCH',pid||'|'||pmst||'|'||ptien_giao||'|'||pma_nv||'|'||pngay_giao||'|'||pnguoi_giao||'|'||ptrangthai_tt);
	s:='select * from tax.phieu_q42015 where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if pmst is not null then s:=s||' and mst like '''||replace(pmst,'*','%')||''''; end if;
	if ptien_giao is not null then s:=s||' and tien_giao like '''||replace(ptien_giao,'*','%')||''''; end if;
	if pma_nv is not null then s:=s||' and ma_nv like '''||replace(pma_nv,'*','%')||''''; end if;
	if pngay_giao is not null then s:=s||' and ngay_giao=to_date('''||pngay_giao||''',''dd/mm/yyyy'')'; end if;
	if pnguoi_giao is not null then s:=s||' and nguoi_giao like '''||replace(pnguoi_giao,'*','%')||''''; end if;
	if ptrangthai_tt is not null then s:=s||' and trangthai_tt like '''||replace(ptrangthai_tt,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_phieu_q42015(
	pid varchar2,
	pmst varchar2,
	ptien_giao varchar2,
	pma_nv varchar2,
	pngay_giao varchar2,
	pnguoi_giao varchar2,
	ptrangthai_tt varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.phieu_q42015|EDIT',pid||'|'||pmst||'|'||ptien_giao||'|'||pma_nv||'|'||pngay_giao||'|'||pnguoi_giao||'|'||ptrangthai_tt);
	s:='update tax.phieu_q42015 set  id=:id,mst=:mst,tien_giao=:tien_giao,ma_nv=:ma_nv,ngay_giao=:ngay_giao,nguoi_giao=:nguoi_giao,trangthai_tt=:trangthai_tt where id=:id';
	execute immediate s using pid,pmst,ptien_giao,pma_nv,to_date(pngay_giao,'dd/mm/yyyy'),pnguoi_giao,ptrangthai_tt,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_phieu_q42015(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.phieu_q42015|DEL',pId);
	s:='delete from tax.phieu_q42015 where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;