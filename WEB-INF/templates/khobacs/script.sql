function new_khobacs(
	pid varchar2,
	pten_kho_bac varchar2,
	pma_tructiep varchar2,
	phieu_luc_tu varchar2,
	phieu_luc_den varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.khobacs|NEW',pid||'|'||pten_kho_bac||'|'||pma_tructiep||'|'||phieu_luc_tu||'|'||phieu_luc_den);
	s:='insert into tax.khobacs(id,ten_kho_bac,ma_tructiep,hieu_luc_tu,hieu_luc_den)
	 values (:id,:ten_kho_bac,:ma_tructiep,:hieu_luc_tu,:hieu_luc_den)';
	execute immediate s using pid,pten_kho_bac,pma_tructiep,phieu_luc_tu,phieu_luc_den;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_khobacs(
	pid varchar2,
	pten_kho_bac varchar2,
	pma_tructiep varchar2,
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
	logger.access('tax.khobacs|SEARCH',pid||'|'||pten_kho_bac||'|'||pma_tructiep||'|'||phieu_luc_tu||'|'||phieu_luc_den);
	s:='select * from tax.khobacs where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if pten_kho_bac is not null then s:=s||' and ten_kho_bac like '''||replace(pten_kho_bac,'*','%')||''''; end if;
	if pma_tructiep is not null then s:=s||' and ma_tructiep like '''||replace(pma_tructiep,'*','%')||''''; end if;
	if phieu_luc_tu is not null then s:=s||' and hieu_luc_tu like '''||replace(phieu_luc_tu,'*','%')||''''; end if;
	if phieu_luc_den is not null then s:=s||' and hieu_luc_den like '''||replace(phieu_luc_den,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_khobacs(
	pid varchar2,
	pten_kho_bac varchar2,
	pma_tructiep varchar2,
	phieu_luc_tu varchar2,
	phieu_luc_den varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.khobacs|EDIT',pid||'|'||pten_kho_bac||'|'||pma_tructiep||'|'||phieu_luc_tu||'|'||phieu_luc_den);
	s:='update tax.khobacs set  id=:id,ten_kho_bac=:ten_kho_bac,ma_tructiep=:ma_tructiep,hieu_luc_tu=:hieu_luc_tu,hieu_luc_den=:hieu_luc_den where id=:id';
	execute immediate s using pid,pten_kho_bac,pma_tructiep,phieu_luc_tu,phieu_luc_den,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_khobacs(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.khobacs|DEL',pId);
	s:='delete from tax.khobacs where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;