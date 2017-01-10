function new_quaythus(
	pid varchar2,
	pma_tinh varchar2,
	ptenquay varchar2,
	pdiachi varchar2,
	ptel varchar2,
	pfax varchar2,
	ptruongquay varchar2,
	pmabc_id varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.quaythus|NEW',pid||'|'||pma_tinh||'|'||ptenquay||'|'||pdiachi||'|'||ptel||'|'||pfax||'|'||ptruongquay||'|'||pmabc_id);
	s:='insert into tax.quaythus(id,ma_tinh,tenquay,diachi,tel,fax,truongquay,mabc_id)
	 values (:id,:ma_tinh,:tenquay,:diachi,:tel,:fax,:truongquay,:mabc_id)';
	execute immediate s using pid,pma_tinh,ptenquay,pdiachi,ptel,pfax,ptruongquay,pmabc_id;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_quaythus(
	pid varchar2,
	pma_tinh varchar2,
	ptenquay varchar2,
	pdiachi varchar2,
	ptel varchar2,
	pfax varchar2,
	ptruongquay varchar2,
	pmabc_id varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.quaythus|SEARCH',pid||'|'||pma_tinh||'|'||ptenquay||'|'||pdiachi||'|'||ptel||'|'||pfax||'|'||ptruongquay||'|'||pmabc_id);
	s:='select * from tax.quaythus where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
	if ptenquay is not null then s:=s||' and tenquay like '''||replace(ptenquay,'*','%')||''''; end if;
	if pdiachi is not null then s:=s||' and diachi like '''||replace(pdiachi,'*','%')||''''; end if;
	if ptel is not null then s:=s||' and tel like '''||replace(ptel,'*','%')||''''; end if;
	if pfax is not null then s:=s||' and fax like '''||replace(pfax,'*','%')||''''; end if;
	if ptruongquay is not null then s:=s||' and truongquay like '''||replace(ptruongquay,'*','%')||''''; end if;
	if pmabc_id is not null then s:=s||' and mabc_id like '''||replace(pmabc_id,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_quaythus(
	pid varchar2,
	pma_tinh varchar2,
	ptenquay varchar2,
	pdiachi varchar2,
	ptel varchar2,
	pfax varchar2,
	ptruongquay varchar2,
	pmabc_id varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.quaythus|EDIT',pid||'|'||pma_tinh||'|'||ptenquay||'|'||pdiachi||'|'||ptel||'|'||pfax||'|'||ptruongquay||'|'||pmabc_id);
	s:='update tax.quaythus set  id=:id,ma_tinh=:ma_tinh,tenquay=:tenquay,diachi=:diachi,tel=:tel,fax=:fax,truongquay=:truongquay,mabc_id=:mabc_id where id=:id';
	execute immediate s using pid,pma_tinh,ptenquay,pdiachi,ptel,pfax,ptruongquay,pmabc_id,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_quaythus(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.quaythus|DEL',pId);
	s:='delete from tax.quaythus where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;