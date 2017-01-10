function new_tieu_mucs(
	pid varchar2,
	ptentieumuc varchar2,
	pma_muc varchar2,
	phieu_luc_tu varchar2,
	phieu_luc_den varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.tieu_mucs|NEW',pid||'|'||ptentieumuc||'|'||pma_muc||'|'||phieu_luc_tu||'|'||phieu_luc_den);
	s:='insert into tax.tieu_mucs(id,tentieumuc,ma_muc,hieu_luc_tu,hieu_luc_den)
	 values (:id,:tentieumuc,:ma_muc,:hieu_luc_tu,:hieu_luc_den)';
	execute immediate s using pid,ptentieumuc,pma_muc,phieu_luc_tu,phieu_luc_den;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_tieu_mucs(
	pid varchar2,
	ptentieumuc varchar2,
	pma_muc varchar2,
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
	logger.access('tax.tieu_mucs|SEARCH',pid||'|'||ptentieumuc||'|'||pma_muc||'|'||phieu_luc_tu||'|'||phieu_luc_den);
	s:='select * from tax.tieu_mucs where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if ptentieumuc is not null then s:=s||' and tentieumuc like '''||replace(ptentieumuc,'*','%')||''''; end if;
	if pma_muc is not null then s:=s||' and ma_muc like '''||replace(pma_muc,'*','%')||''''; end if;
	if phieu_luc_tu is not null then s:=s||' and hieu_luc_tu like '''||replace(phieu_luc_tu,'*','%')||''''; end if;
	if phieu_luc_den is not null then s:=s||' and hieu_luc_den like '''||replace(phieu_luc_den,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_tieu_mucs(
	pid varchar2,
	ptentieumuc varchar2,
	pma_muc varchar2,
	phieu_luc_tu varchar2,
	phieu_luc_den varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.tieu_mucs|EDIT',pid||'|'||ptentieumuc||'|'||pma_muc||'|'||phieu_luc_tu||'|'||phieu_luc_den);
	s:='update tax.tieu_mucs set  id=:id,tentieumuc=:tentieumuc,ma_muc=:ma_muc,hieu_luc_tu=:hieu_luc_tu,hieu_luc_den=:hieu_luc_den where id=:id';
	execute immediate s using pid,ptentieumuc,pma_muc,phieu_luc_tu,phieu_luc_den,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_tieu_mucs(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.tieu_mucs|DEL',pId);
	s:='delete from tax.tieu_mucs where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;