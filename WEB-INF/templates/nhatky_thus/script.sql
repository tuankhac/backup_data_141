function new_nhatky_thus(
	pmst varchar2,
	plydos varchar2,
	pngayhen_tt varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nhatky_thus|NEW',pmst||'|'||plydos||'|'||pngayhen_tt);
	s:='insert into tax.nhatky_thus(mst,lydos,ngayhen_tt)
	 values (:mst,:lydos,:ngayhen_tt)';
	execute immediate s using pmst,plydos,to_date(pngayhen_tt,'dd/mm/yyyy');
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_nhatky_thus(
	pmst varchar2,
	plydos varchar2,
	pngayhen_tt varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.nhatky_thus|SEARCH',pmst||'|'||plydos||'|'||pngayhen_tt);
	s:='select * from tax.nhatky_thus where 1=1';
 	if pmst is not null then s:=s||' and mst like '''||replace(pmst,'*','%')||''''; end if;
	if plydos is not null then s:=s||' and lydos like '''||replace(plydos,'*','%')||''''; end if;
	if pngayhen_tt is not null then s:=s||' and ngayhen_tt=to_date('''||pngayhen_tt||''',''dd/mm/yyyy'')'; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_nhatky_thus(
	pmst varchar2,
	plydos varchar2,
	pngayhen_tt varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nhatky_thus|EDIT',pmst||'|'||plydos||'|'||pngayhen_tt);
	s:='update tax.nhatky_thus set  mst=:mst,lydos=:lydos,ngayhen_tt=:ngayhen_tt where id=:id';
	execute immediate s using pmst,plydos,to_date(pngayhen_tt,'dd/mm/yyyy'),pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_nhatky_thus(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nhatky_thus|DEL',pId);
	s:='delete from tax.nhatky_thus where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;