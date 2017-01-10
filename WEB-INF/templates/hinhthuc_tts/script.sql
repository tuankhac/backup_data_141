function new_hinhthuc_tts(
	pid varchar2,
	pname varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.hinhthuc_tts|NEW',pid||'|'||pname);
	s:='insert into tax.hinhthuc_tts(id,name)
	 values (:id,:name)';
	execute immediate s using pid,pname;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_hinhthuc_tts(
	pid varchar2,
	pname varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.hinhthuc_tts|SEARCH',pid||'|'||pname);
	s:='select * from tax.hinhthuc_tts where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if pname is not null then s:=s||' and name like '''||replace(pname,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_hinhthuc_tts(
	pid varchar2,
	pname varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.hinhthuc_tts|EDIT',pid||'|'||pname);
	s:='update tax.hinhthuc_tts set  id=:id,name=:name where id=:id';
	execute immediate s using pid,pname,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_hinhthuc_tts(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.hinhthuc_tts|DEL',pId);
	s:='delete from tax.hinhthuc_tts where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;