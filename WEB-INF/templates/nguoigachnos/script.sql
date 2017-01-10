function new_nguoigachnos(
	pid varchar2,
	pma_tinh varchar2,
	phovaten varchar2,
	pmabc_id varchar2,
	pquaythu_id varchar2,
	pgn_luingay varchar2,
	pxp_luingay varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nguoigachnos|NEW',pid||'|'||pma_tinh||'|'||phovaten||'|'||pmabc_id||'|'||pquaythu_id||'|'||pgn_luingay||'|'||pxp_luingay);
	s:='insert into tax.nguoigachnos(id,ma_tinh,hovaten,mabc_id,quaythu_id,gn_luingay,xp_luingay)
	 values (:id,:ma_tinh,:hovaten,:mabc_id,:quaythu_id,:gn_luingay,:xp_luingay)';
	execute immediate s using pid,pma_tinh,phovaten,pmabc_id,pquaythu_id,pgn_luingay,pxp_luingay;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_nguoigachnos(
	pid varchar2,
	pma_tinh varchar2,
	phovaten varchar2,
	pmabc_id varchar2,
	pquaythu_id varchar2,
	pgn_luingay varchar2,
	pxp_luingay varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.nguoigachnos|SEARCH',pid||'|'||pma_tinh||'|'||phovaten||'|'||pmabc_id||'|'||pquaythu_id||'|'||pgn_luingay||'|'||pxp_luingay);
	s:='select * from tax.nguoigachnos where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
	if phovaten is not null then s:=s||' and hovaten like '''||replace(phovaten,'*','%')||''''; end if;
	if pmabc_id is not null then s:=s||' and mabc_id like '''||replace(pmabc_id,'*','%')||''''; end if;
	if pquaythu_id is not null then s:=s||' and quaythu_id like '''||replace(pquaythu_id,'*','%')||''''; end if;
	if pgn_luingay is not null then s:=s||' and gn_luingay like '''||replace(pgn_luingay,'*','%')||''''; end if;
	if pxp_luingay is not null then s:=s||' and xp_luingay like '''||replace(pxp_luingay,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_nguoigachnos(
	pid varchar2,
	pma_tinh varchar2,
	phovaten varchar2,
	pmabc_id varchar2,
	pquaythu_id varchar2,
	pgn_luingay varchar2,
	pxp_luingay varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nguoigachnos|EDIT',pid||'|'||pma_tinh||'|'||phovaten||'|'||pmabc_id||'|'||pquaythu_id||'|'||pgn_luingay||'|'||pxp_luingay);
	s:='update tax.nguoigachnos set  id=:id,ma_tinh=:ma_tinh,hovaten=:hovaten,mabc_id=:mabc_id,quaythu_id=:quaythu_id,gn_luingay=:gn_luingay,xp_luingay=:xp_luingay where id=:id';
	execute immediate s using pid,pma_tinh,phovaten,pmabc_id,pquaythu_id,pgn_luingay,pxp_luingay,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_nguoigachnos(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nguoigachnos|DEL',pId);
	s:='delete from tax.nguoigachnos where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;