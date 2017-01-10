function new_chukynos(
	pid varchar2,
	pten_chukyno varchar2,
	pis_active varchar2,
	pstatus varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.chukynos|NEW',pid||'|'||pten_chukyno||'|'||pis_active||'|'||pstatus);
	s:='insert into tax.chukynos(id,ten_chukyno,is_active,status)
	 values (:id,:ten_chukyno,:is_active,:status)';
	execute immediate s using pid,pten_chukyno,pis_active,pstatus;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_chukynos(
	pid varchar2,
	pten_chukyno varchar2,
	pis_active varchar2,
	pstatus varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.chukynos|SEARCH',pid||'|'||pten_chukyno||'|'||pis_active||'|'||pstatus);
	s:='select * from tax.chukynos where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if pten_chukyno is not null then s:=s||' and ten_chukyno like '''||replace(pten_chukyno,'*','%')||''''; end if;
	if pis_active is not null then s:=s||' and is_active like '''||replace(pis_active,'*','%')||''''; end if;
	if pstatus is not null then s:=s||' and status like '''||replace(pstatus,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_chukynos(
	pid varchar2,
	pten_chukyno varchar2,
	pis_active varchar2,
	pstatus varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.chukynos|EDIT',pid||'|'||pten_chukyno||'|'||pis_active||'|'||pstatus);
	s:='update tax.chukynos set  id=:id,ten_chukyno=:ten_chukyno,is_active=:is_active,status=:status where id=:id';
	execute immediate s using pid,pten_chukyno,pis_active,pstatus,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_chukynos(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.chukynos|DEL',pId);
	s:='delete from tax.chukynos where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;