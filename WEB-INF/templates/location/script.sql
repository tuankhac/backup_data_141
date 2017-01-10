function new_location(
	pid varchar2,
	platitude varchar2,
	plongitude varchar2,
	plocation varchar2,
	pstaff varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.location|NEW',pid||'|'||platitude||'|'||plongitude||'|'||plocation||'|'||pstaff);
	s:='insert into tax.location(id,latitude,longitude,location,staff)
	 values (:id,:latitude,:longitude,:location,:staff)';
	execute immediate s using pid,platitude,plongitude,plocation,pstaff;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_location(
	pid varchar2,
	platitude varchar2,
	plongitude varchar2,
	plocation varchar2,
	pstaff varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.location|SEARCH',pid||'|'||platitude||'|'||plongitude||'|'||plocation||'|'||pstaff);
	s:='select * from tax.location where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if platitude is not null then s:=s||' and latitude like '''||replace(platitude,'*','%')||''''; end if;
	if plongitude is not null then s:=s||' and longitude like '''||replace(plongitude,'*','%')||''''; end if;
	if plocation is not null then s:=s||' and location like '''||replace(plocation,'*','%')||''''; end if;
	if pstaff is not null then s:=s||' and staff like '''||replace(pstaff,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_location(
	pid varchar2,
	platitude varchar2,
	plongitude varchar2,
	plocation varchar2,
	pstaff varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.location|EDIT',pid||'|'||platitude||'|'||plongitude||'|'||plocation||'|'||pstaff);
	s:='update tax.location set  id=:id,latitude=:latitude,longitude=:longitude,location=:location,staff=:staff where id=:id';
	execute immediate s using pid,platitude,plongitude,plocation,pstaff,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_location(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.location|DEL',pId);
	s:='delete from tax.location where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;