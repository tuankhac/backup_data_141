function new_user_info(
	pid varchar2,
	ppassword varchar2,
	pfirst_name varchar2,
	plast_name varchar2,
	pmobile varchar2,
	pdepartment varchar2,
	pemail varchar2,
	pgender varchar2,
	pstatus_id varchar2,
	pcreated_date varchar2,
	pmodified_date varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('admin.user_info|NEW',pid||'|'||ppassword||'|'||pfirst_name||'|'||plast_name||'|'||pmobile||'|'||pdepartment||'|'||pemail||'|'||pgender||'|'||pstatus_id||'|'||pcreated_date||'|'||pmodified_date);
	s:='insert into admin.user_info(id,password,first_name,last_name,mobile,department,email,gender,status_id,created_date,modified_date)
	 values (:id,:password,:first_name,:last_name,:mobile,:department,:email,:gender,:status_id,:created_date,:modified_date)';
	execute immediate s using pid,ppassword,pfirst_name,plast_name,pmobile,pdepartment,pemail,pgender,pstatus_id,to_date(pcreated_date,'dd/mm/yyyy'),to_date(pmodified_date,'dd/mm/yyyy');
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_user_info(
	pid varchar2,
	ppassword varchar2,
	pfirst_name varchar2,
	plast_name varchar2,
	pmobile varchar2,
	pdepartment varchar2,
	pemail varchar2,
	pgender varchar2,
	pstatus_id varchar2,
	pcreated_date varchar2,
	pmodified_date varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('admin.user_info|SEARCH',pid||'|'||ppassword||'|'||pfirst_name||'|'||plast_name||'|'||pmobile||'|'||pdepartment||'|'||pemail||'|'||pgender||'|'||pstatus_id||'|'||pcreated_date||'|'||pmodified_date);
	s:='select * from admin.user_info where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if ppassword is not null then s:=s||' and password like '''||replace(ppassword,'*','%')||''''; end if;
	if pfirst_name is not null then s:=s||' and first_name like '''||replace(pfirst_name,'*','%')||''''; end if;
	if plast_name is not null then s:=s||' and last_name like '''||replace(plast_name,'*','%')||''''; end if;
	if pmobile is not null then s:=s||' and mobile like '''||replace(pmobile,'*','%')||''''; end if;
	if pdepartment is not null then s:=s||' and department like '''||replace(pdepartment,'*','%')||''''; end if;
	if pemail is not null then s:=s||' and email like '''||replace(pemail,'*','%')||''''; end if;
	if pgender is not null then s:=s||' and gender like '''||replace(pgender,'*','%')||''''; end if;
	if pstatus_id is not null then s:=s||' and status_id like '''||replace(pstatus_id,'*','%')||''''; end if;
	if pcreated_date is not null then s:=s||' and created_date=to_date('''||pcreated_date||''',''dd/mm/yyyy'')'; end if;
	if pmodified_date is not null then s:=s||' and modified_date=to_date('''||pmodified_date||''',''dd/mm/yyyy'')'; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_user_info(
	pid varchar2,
	ppassword varchar2,
	pfirst_name varchar2,
	plast_name varchar2,
	pmobile varchar2,
	pdepartment varchar2,
	pemail varchar2,
	pgender varchar2,
	pstatus_id varchar2,
	pcreated_date varchar2,
	pmodified_date varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('admin.user_info|EDIT',pid||'|'||ppassword||'|'||pfirst_name||'|'||plast_name||'|'||pmobile||'|'||pdepartment||'|'||pemail||'|'||pgender||'|'||pstatus_id||'|'||pcreated_date||'|'||pmodified_date);
	s:='update admin.user_info set  id=:id,password=:password,first_name=:first_name,last_name=:last_name,mobile=:mobile,department=:department,email=:email,gender=:gender,status_id=:status_id,created_date=:created_date,modified_date=:modified_date where id=:id';
	execute immediate s using pid,ppassword,pfirst_name,plast_name,pmobile,pdepartment,pemail,pgender,pstatus_id,to_date(pcreated_date,'dd/mm/yyyy'),to_date(pmodified_date,'dd/mm/yyyy'),pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_user_info(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('admin.user_info|DEL',pId);
	s:='delete from admin.user_info where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;