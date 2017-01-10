function new_donvi_qls(
	pid varchar2,
	pma_tinh varchar2,
	pten_dv varchar2,
	ptel varchar2,
	pfax varchar2,
	pnotes varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.donvi_qls|NEW',pid||'|'||pma_tinh||'|'||pten_dv||'|'||ptel||'|'||pfax||'|'||pnotes);
	s:='insert into tax.donvi_qls(id,ma_tinh,ten_dv,tel,fax,notes)
	 values (:id,:ma_tinh,:ten_dv,:tel,:fax,:notes)';
	execute immediate s using pid,pma_tinh,pten_dv,ptel,pfax,pnotes;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_donvi_qls(
	pid varchar2,
	pma_tinh varchar2,
	pten_dv varchar2,
	ptel varchar2,
	pfax varchar2,
	pnotes varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.donvi_qls|SEARCH',pid||'|'||pma_tinh||'|'||pten_dv||'|'||ptel||'|'||pfax||'|'||pnotes);
	s:='select * from tax.donvi_qls where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
	if pten_dv is not null then s:=s||' and ten_dv like '''||replace(pten_dv,'*','%')||''''; end if;
	if ptel is not null then s:=s||' and tel like '''||replace(ptel,'*','%')||''''; end if;
	if pfax is not null then s:=s||' and fax like '''||replace(pfax,'*','%')||''''; end if;
	if pnotes is not null then s:=s||' and notes like '''||replace(pnotes,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_donvi_qls(
	pid varchar2,
	pma_tinh varchar2,
	pten_dv varchar2,
	ptel varchar2,
	pfax varchar2,
	pnotes varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.donvi_qls|EDIT',pid||'|'||pma_tinh||'|'||pten_dv||'|'||ptel||'|'||pfax||'|'||pnotes);
	s:='update tax.donvi_qls set  id=:id,ma_tinh=:ma_tinh,ten_dv=:ten_dv,tel=:tel,fax=:fax,notes=:notes where id=:id';
	execute immediate s using pid,pma_tinh,pten_dv,ptel,pfax,pnotes,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_donvi_qls(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.donvi_qls|DEL',pId);
	s:='delete from tax.donvi_qls where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;