function new_chuongs(
	pid varchar2,
	pma_cap varchar2,
	pten_chuong varchar2,
	phieu_luc_tu varchar2,
	phieu_luc_den varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.chuongs|NEW',pid||'|'||pma_cap||'|'||pten_chuong||'|'||phieu_luc_tu||'|'||phieu_luc_den);
	s:='insert into tax.chuongs(id,ma_cap,ten_chuong,hieu_luc_tu,hieu_luc_den)
	 values (:id,:ma_cap,:ten_chuong,:hieu_luc_tu,:hieu_luc_den)';
	execute immediate s using pid,pma_cap,pten_chuong,phieu_luc_tu,phieu_luc_den;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_chuongs(
	pid varchar2,
	pma_cap varchar2,
	pten_chuong varchar2,
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
	logger.access('tax.chuongs|SEARCH',pid||'|'||pma_cap||'|'||pten_chuong||'|'||phieu_luc_tu||'|'||phieu_luc_den);
	s:='select * from tax.chuongs where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if pma_cap is not null then s:=s||' and ma_cap like '''||replace(pma_cap,'*','%')||''''; end if;
	if pten_chuong is not null then s:=s||' and ten_chuong like '''||replace(pten_chuong,'*','%')||''''; end if;
	if phieu_luc_tu is not null then s:=s||' and hieu_luc_tu like '''||replace(phieu_luc_tu,'*','%')||''''; end if;
	if phieu_luc_den is not null then s:=s||' and hieu_luc_den like '''||replace(phieu_luc_den,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_chuongs(
	pid varchar2,
	pma_cap varchar2,
	pten_chuong varchar2,
	phieu_luc_tu varchar2,
	phieu_luc_den varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.chuongs|EDIT',pid||'|'||pma_cap||'|'||pten_chuong||'|'||phieu_luc_tu||'|'||phieu_luc_den);
	s:='update tax.chuongs set  id=:id,ma_cap=:ma_cap,ten_chuong=:ten_chuong,hieu_luc_tu=:hieu_luc_tu,hieu_luc_den=:hieu_luc_den where id=:id';
	execute immediate s using pid,pma_cap,pten_chuong,phieu_luc_tu,phieu_luc_den,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_chuongs(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.chuongs|DEL',pId);
	s:='delete from tax.chuongs where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;