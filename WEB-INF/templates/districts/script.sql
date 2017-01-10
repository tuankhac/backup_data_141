function new_districts(
	pid varchar2,
	pdistrict_name varchar2,
	pprovince_id varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.districts|NEW',pid||'|'||pdistrict_name||'|'||pprovince_id);
	s:='insert into tax.districts(id,district_name,province_id)
	 values (:id,:district_name,:province_id)';
	execute immediate s using pid,pdistrict_name,pprovince_id;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_districts(
	pid varchar2,
	pdistrict_name varchar2,
	pprovince_id varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.districts|SEARCH',pid||'|'||pdistrict_name||'|'||pprovince_id);
	s:='select * from tax.districts where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if pdistrict_name is not null then s:=s||' and district_name like '''||replace(pdistrict_name,'*','%')||''''; end if;
	if pprovince_id is not null then s:=s||' and province_id like '''||replace(pprovince_id,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_districts(
	pid varchar2,
	pdistrict_name varchar2,
	pprovince_id varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.districts|EDIT',pid||'|'||pdistrict_name||'|'||pprovince_id);
	s:='update tax.districts set  id=:id,district_name=:district_name,province_id=:province_id where id=:id';
	execute immediate s using pid,pdistrict_name,pprovince_id,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_districts(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.districts|DEL',pId);
	s:='delete from tax.districts where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;