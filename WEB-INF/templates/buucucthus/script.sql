function new_buucucthus(
	pid varchar2,
	pma_tinh varchar2,
	ptenbuucuc varchar2,
	pdiachi varchar2,
	ptel varchar2,
	pfax varchar2,
	pdonviql_id varchar2,
	pnotes varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.buucucthus|NEW',pid||'|'||pma_tinh||'|'||ptenbuucuc||'|'||pdiachi||'|'||ptel||'|'||pfax||'|'||pdonviql_id||'|'||pnotes);
	s:='insert into tax.buucucthus(id,ma_tinh,tenbuucuc,diachi,tel,fax,donviql_id,notes)
	 values (:id,:ma_tinh,:tenbuucuc,:diachi,:tel,:fax,:donviql_id,:notes)';
	execute immediate s using pid,pma_tinh,ptenbuucuc,pdiachi,ptel,pfax,pdonviql_id,pnotes;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_buucucthus(
	pid varchar2,
	pma_tinh varchar2,
	ptenbuucuc varchar2,
	pdiachi varchar2,
	ptel varchar2,
	pfax varchar2,
	pdonviql_id varchar2,
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
	logger.access('tax.buucucthus|SEARCH',pid||'|'||pma_tinh||'|'||ptenbuucuc||'|'||pdiachi||'|'||ptel||'|'||pfax||'|'||pdonviql_id||'|'||pnotes);
	s:='select * from tax.buucucthus where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
	if ptenbuucuc is not null then s:=s||' and tenbuucuc like '''||replace(ptenbuucuc,'*','%')||''''; end if;
	if pdiachi is not null then s:=s||' and diachi like '''||replace(pdiachi,'*','%')||''''; end if;
	if ptel is not null then s:=s||' and tel like '''||replace(ptel,'*','%')||''''; end if;
	if pfax is not null then s:=s||' and fax like '''||replace(pfax,'*','%')||''''; end if;
	if pdonviql_id is not null then s:=s||' and donviql_id like '''||replace(pdonviql_id,'*','%')||''''; end if;
	if pnotes is not null then s:=s||' and notes like '''||replace(pnotes,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_buucucthus(
	pid varchar2,
	pma_tinh varchar2,
	ptenbuucuc varchar2,
	pdiachi varchar2,
	ptel varchar2,
	pfax varchar2,
	pdonviql_id varchar2,
	pnotes varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.buucucthus|EDIT',pid||'|'||pma_tinh||'|'||ptenbuucuc||'|'||pdiachi||'|'||ptel||'|'||pfax||'|'||pdonviql_id||'|'||pnotes);
	s:='update tax.buucucthus set  id=:id,ma_tinh=:ma_tinh,tenbuucuc=:tenbuucuc,diachi=:diachi,tel=:tel,fax=:fax,donviql_id=:donviql_id,notes=:notes where id=:id';
	execute immediate s using pid,pma_tinh,ptenbuucuc,pdiachi,ptel,pfax,pdonviql_id,pnotes,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_buucucthus(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.buucucthus|DEL',pId);
	s:='delete from tax.buucucthus where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;