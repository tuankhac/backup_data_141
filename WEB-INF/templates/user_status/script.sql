function new_user_status(
	pid varchar2,
	pstatus_name varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('admin.user_status|NEW',pid||'|'||pstatus_name);
	s:='insert into admin.user_status(id,status_name)
	 values (:id,:status_name)';
	execute immediate s using pid,pstatus_name;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_user_status(
	pid varchar2,
	pstatus_name varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('admin.user_status|SEARCH',pid||'|'||pstatus_name);
	s:='select * from admin.user_status where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if pstatus_name is not null then s:=s||' and status_name like '''||replace(pstatus_name,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_user_status(
	pid varchar2,
	pstatus_name varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('admin.user_status|EDIT',pid||'|'||pstatus_name);
	s:='update admin.user_status set  id=:id,status_name=:status_name where id=:id';
	execute immediate s using pid,pstatus_name,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_user_status(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('admin.user_status|DEL',pId);
	s:='delete from admin.user_status where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;