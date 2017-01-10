function new_provinces(
	pid varchar2,
	pprovince_name varchar2,
	pcountry_id varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.provinces|NEW',pid||'|'||pprovince_name||'|'||pcountry_id);
	s:='insert into tax.provinces(id,province_name,country_id)
	 values (:id,:province_name,:country_id)';
	execute immediate s using pid,pprovince_name,pcountry_id;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_provinces(
	pid varchar2,
	pprovince_name varchar2,
	pcountry_id varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.provinces|SEARCH',pid||'|'||pprovince_name||'|'||pcountry_id);
	s:='select * from tax.provinces where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if pprovince_name is not null then s:=s||' and province_name like '''||replace(pprovince_name,'*','%')||''''; end if;
	if pcountry_id is not null then s:=s||' and country_id like '''||replace(pcountry_id,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_provinces(
	pid varchar2,
	pprovince_name varchar2,
	pcountry_id varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.provinces|EDIT',pid||'|'||pprovince_name||'|'||pcountry_id);
	s:='update tax.provinces set  id=:id,province_name=:province_name,country_id=:country_id where id=:id';
	execute immediate s using pid,pprovince_name,pcountry_id,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_provinces(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.provinces|DEL',pId);
	s:='delete from tax.provinces where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;