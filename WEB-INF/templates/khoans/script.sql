function new_khoans(
	pid varchar2,
	ptenkhoan varchar2,
	pma_loai varchar2,
	phieu_luc_tu varchar2,
	phieu_luc_den varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.khoans|NEW',pid||'|'||ptenkhoan||'|'||pma_loai||'|'||phieu_luc_tu||'|'||phieu_luc_den);
	s:='insert into tax.khoans(id,tenkhoan,ma_loai,hieu_luc_tu,hieu_luc_den)
	 values (:id,:tenkhoan,:ma_loai,:hieu_luc_tu,:hieu_luc_den)';
	execute immediate s using pid,ptenkhoan,pma_loai,phieu_luc_tu,phieu_luc_den;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_khoans(
	pid varchar2,
	ptenkhoan varchar2,
	pma_loai varchar2,
	phieu_luc_tu varchar2,
	phieu_luc_den varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.khoans|SEARCH',pid||'|'||ptenkhoan||'|'||pma_loai||'|'||phieu_luc_tu||'|'||phieu_luc_den);
	s:='select * from tax.khoans where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if ptenkhoan is not null then s:=s||' and tenkhoan like '''||replace(ptenkhoan,'*','%')||''''; end if;
	if pma_loai is not null then s:=s||' and ma_loai like '''||replace(pma_loai,'*','%')||''''; end if;
	if phieu_luc_tu is not null then s:=s||' and hieu_luc_tu like '''||replace(phieu_luc_tu,'*','%')||''''; end if;
	if phieu_luc_den is not null then s:=s||' and hieu_luc_den like '''||replace(phieu_luc_den,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_khoans(
	pid varchar2,
	ptenkhoan varchar2,
	pma_loai varchar2,
	phieu_luc_tu varchar2,
	phieu_luc_den varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.khoans|EDIT',pid||'|'||ptenkhoan||'|'||pma_loai||'|'||phieu_luc_tu||'|'||phieu_luc_den);
	s:='update tax.khoans set  id=:id,tenkhoan=:tenkhoan,ma_loai=:ma_loai,hieu_luc_tu=:hieu_luc_tu,hieu_luc_den=:hieu_luc_den where id=:id';
	execute immediate s using pid,ptenkhoan,pma_loai,phieu_luc_tu,phieu_luc_den,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_khoans(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.khoans|DEL',pId);
	s:='delete from tax.khoans where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;