function new_data_exports(
	psql_id varchar2,
	psql_name varchar2,
	psql_export varchar2,
	psql_param varchar2,
	pagent varchar2,
	pstatus varchar2,
	pfile_name varchar2,
	pftp varchar2,
	pftp_path varchar2,
	pusername varchar2,
	ppass varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.data_exports|NEW',psql_id||'|'||psql_name||'|'||psql_export||'|'||psql_param||'|'||pagent||'|'||pstatus||'|'||pfile_name||'|'||pftp||'|'||pftp_path||'|'||pusername||'|'||ppass);
	s:='insert into tax.data_exports(sql_id,sql_name,sql_export,sql_param,agent,status,file_name,ftp,ftp_path,username,pass)
	 values (:sql_id,:sql_name,:sql_export,:sql_param,:agent,:status,:file_name,:ftp,:ftp_path,:username,:pass)';
	execute immediate s using psql_id,psql_name,psql_export,psql_param,pagent,pstatus,pfile_name,pftp,pftp_path,pusername,ppass;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_data_exports(
	psql_id varchar2,
	psql_name varchar2,
	psql_export varchar2,
	psql_param varchar2,
	pagent varchar2,
	pstatus varchar2,
	pfile_name varchar2,
	pftp varchar2,
	pftp_path varchar2,
	pusername varchar2,
	ppass varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.data_exports|SEARCH',psql_id||'|'||psql_name||'|'||psql_export||'|'||psql_param||'|'||pagent||'|'||pstatus||'|'||pfile_name||'|'||pftp||'|'||pftp_path||'|'||pusername||'|'||ppass);
	s:='select * from tax.data_exports where 1=1';
 	if psql_id is not null then s:=s||' and sql_id like '''||replace(psql_id,'*','%')||''''; end if;
	if psql_name is not null then s:=s||' and sql_name like '''||replace(psql_name,'*','%')||''''; end if;
	if psql_export is not null then s:=s||' and sql_export like '''||replace(psql_export,'*','%')||''''; end if;
	if psql_param is not null then s:=s||' and sql_param like '''||replace(psql_param,'*','%')||''''; end if;
	if pagent is not null then s:=s||' and agent like '''||replace(pagent,'*','%')||''''; end if;
	if pstatus is not null then s:=s||' and status like '''||replace(pstatus,'*','%')||''''; end if;
	if pfile_name is not null then s:=s||' and file_name like '''||replace(pfile_name,'*','%')||''''; end if;
	if pftp is not null then s:=s||' and ftp like '''||replace(pftp,'*','%')||''''; end if;
	if pftp_path is not null then s:=s||' and ftp_path like '''||replace(pftp_path,'*','%')||''''; end if;
	if pusername is not null then s:=s||' and username like '''||replace(pusername,'*','%')||''''; end if;
	if ppass is not null then s:=s||' and pass like '''||replace(ppass,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_data_exports(
	psql_id varchar2,
	psql_name varchar2,
	psql_export varchar2,
	psql_param varchar2,
	pagent varchar2,
	pstatus varchar2,
	pfile_name varchar2,
	pftp varchar2,
	pftp_path varchar2,
	pusername varchar2,
	ppass varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.data_exports|EDIT',psql_id||'|'||psql_name||'|'||psql_export||'|'||psql_param||'|'||pagent||'|'||pstatus||'|'||pfile_name||'|'||pftp||'|'||pftp_path||'|'||pusername||'|'||ppass);
	s:='update tax.data_exports set  sql_id=:sql_id,sql_name=:sql_name,sql_export=:sql_export,sql_param=:sql_param,agent=:agent,status=:status,file_name=:file_name,ftp=:ftp,ftp_path=:ftp_path,username=:username,pass=:pass where id=:id';
	execute immediate s using psql_id,psql_name,psql_export,psql_param,pagent,pstatus,pfile_name,pftp,pftp_path,pusername,ppass,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_data_exports(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.data_exports|DEL',pId);
	s:='delete from tax.data_exports where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;