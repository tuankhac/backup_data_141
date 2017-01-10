function new_notification_log(
	pid varchar2,
	preceiver varchar2,
	pcontent varchar2,
	pprovince_id varchar2,
	pcreated_user varchar2,
	pcreated_date varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.notification_log|NEW',pid||'|'||preceiver||'|'||pcontent||'|'||pprovince_id||'|'||pcreated_user||'|'||pcreated_date);
	s:='insert into tax.notification_log(id,receiver,content,province_id,created_user,created_date)
	 values (:id,:receiver,:content,:province_id,:created_user,:created_date)';
	execute immediate s using pid,preceiver,pcontent,pprovince_id,pcreated_user,to_date(pcreated_date,'dd/mm/yyyy');
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_notification_log(
	pid varchar2,
	preceiver varchar2,
	pcontent varchar2,
	pprovince_id varchar2,
	pcreated_user varchar2,
	pcreated_date varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.notification_log|SEARCH',pid||'|'||preceiver||'|'||pcontent||'|'||pprovince_id||'|'||pcreated_user||'|'||pcreated_date);
	s:='select * from tax.notification_log where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if preceiver is not null then s:=s||' and receiver like '''||replace(preceiver,'*','%')||''''; end if;
	if pcontent is not null then s:=s||' and content like '''||replace(pcontent,'*','%')||''''; end if;
	if pprovince_id is not null then s:=s||' and province_id like '''||replace(pprovince_id,'*','%')||''''; end if;
	if pcreated_user is not null then s:=s||' and created_user like '''||replace(pcreated_user,'*','%')||''''; end if;
	if pcreated_date is not null then s:=s||' and created_date=to_date('''||pcreated_date||''',''dd/mm/yyyy'')'; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_notification_log(
	pid varchar2,
	preceiver varchar2,
	pcontent varchar2,
	pprovince_id varchar2,
	pcreated_user varchar2,
	pcreated_date varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.notification_log|EDIT',pid||'|'||preceiver||'|'||pcontent||'|'||pprovince_id||'|'||pcreated_user||'|'||pcreated_date);
	s:='update tax.notification_log set  id=:id,receiver=:receiver,content=:content,province_id=:province_id,created_user=:created_user,created_date=:created_date where id=:id';
	execute immediate s using pid,preceiver,pcontent,pprovince_id,pcreated_user,to_date(pcreated_date,'dd/mm/yyyy'),pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_notification_log(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.notification_log|DEL',pId);
	s:='delete from tax.notification_log where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;