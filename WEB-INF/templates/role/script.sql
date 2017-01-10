function new_role(
	pid varchar2,
	prole_name varchar2,
	pdescription varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('admin.role|NEW',pid||'|'||prole_name||'|'||pdescription);
	s:='insert into admin.role(id,role_name,description)
	 values (:id,:role_name,:description)';
	execute immediate s using pid,prole_name,pdescription;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_role(
	pid varchar2,
	prole_name varchar2,
	pdescription varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('admin.role|SEARCH',pid||'|'||prole_name||'|'||pdescription);
	s:='select * from admin.role where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if prole_name is not null then s:=s||' and role_name like '''||replace(prole_name,'*','%')||''''; end if;
	if pdescription is not null then s:=s||' and description like '''||replace(pdescription,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_role(
	pid varchar2,
	prole_name varchar2,
	pdescription varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('admin.role|EDIT',pid||'|'||prole_name||'|'||pdescription);
	s:='update admin.role set  id=:id,role_name=:role_name,description=:description where id=:id';
	execute immediate s using pid,prole_name,pdescription,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_role(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('admin.role|DEL',pId);
	s:='delete from admin.role where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;