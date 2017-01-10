function new_user_role(
	pid varchar2,
	prole_id varchar2,
	puser_id varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('admin.user_role|NEW',pid||'|'||prole_id||'|'||puser_id);
	s:='insert into admin.user_role(id,role_id,user_id)
	 values (:id,:role_id,:user_id)';
	execute immediate s using pid,prole_id,puser_id;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_user_role(
	pid varchar2,
	prole_id varchar2,
	puser_id varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('admin.user_role|SEARCH',pid||'|'||prole_id||'|'||puser_id);
	s:='select * from admin.user_role where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if prole_id is not null then s:=s||' and role_id like '''||replace(prole_id,'*','%')||''''; end if;
	if puser_id is not null then s:=s||' and user_id like '''||replace(puser_id,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_user_role(
	pid varchar2,
	prole_id varchar2,
	puser_id varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('admin.user_role|EDIT',pid||'|'||prole_id||'|'||puser_id);
	s:='update admin.user_role set  id=:id,role_id=:role_id,user_id=:user_id where id=:id';
	execute immediate s using pid,prole_id,puser_id,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_user_role(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('admin.user_role|DEL',pId);
	s:='delete from admin.user_role where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;