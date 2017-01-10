function new_nnt_cks(
	pmst varchar2,
	pnganhang_id varchar2,
	pngay_bd varchar2,
	pngay_kt varchar2,
	ploguser varchar2,
	plogdate varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nnt_cks|NEW',pmst||'|'||pnganhang_id||'|'||pngay_bd||'|'||pngay_kt||'|'||ploguser||'|'||plogdate);
	s:='insert into tax.nnt_cks(mst,nganhang_id,ngay_bd,ngay_kt,loguser,logdate)
	 values (:mst,:nganhang_id,:ngay_bd,:ngay_kt,:loguser,:logdate)';
	execute immediate s using pmst,pnganhang_id,to_date(pngay_bd,'dd/mm/yyyy'),to_date(pngay_kt,'dd/mm/yyyy'),ploguser,to_date(plogdate,'dd/mm/yyyy');
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_nnt_cks(
	pmst varchar2,
	pnganhang_id varchar2,
	pngay_bd varchar2,
	pngay_kt varchar2,
	ploguser varchar2,
	plogdate varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.nnt_cks|SEARCH',pmst||'|'||pnganhang_id||'|'||pngay_bd||'|'||pngay_kt||'|'||ploguser||'|'||plogdate);
	s:='select * from tax.nnt_cks where 1=1';
 	if pmst is not null then s:=s||' and mst like '''||replace(pmst,'*','%')||''''; end if;
	if pnganhang_id is not null then s:=s||' and nganhang_id like '''||replace(pnganhang_id,'*','%')||''''; end if;
	if pngay_bd is not null then s:=s||' and ngay_bd=to_date('''||pngay_bd||''',''dd/mm/yyyy'')'; end if;
	if pngay_kt is not null then s:=s||' and ngay_kt=to_date('''||pngay_kt||''',''dd/mm/yyyy'')'; end if;
	if ploguser is not null then s:=s||' and loguser like '''||replace(ploguser,'*','%')||''''; end if;
	if plogdate is not null then s:=s||' and logdate=to_date('''||plogdate||''',''dd/mm/yyyy'')'; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_nnt_cks(
	pmst varchar2,
	pnganhang_id varchar2,
	pngay_bd varchar2,
	pngay_kt varchar2,
	ploguser varchar2,
	plogdate varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nnt_cks|EDIT',pmst||'|'||pnganhang_id||'|'||pngay_bd||'|'||pngay_kt||'|'||ploguser||'|'||plogdate);
	s:='update tax.nnt_cks set  mst=:mst,nganhang_id=:nganhang_id,ngay_bd=:ngay_bd,ngay_kt=:ngay_kt,loguser=:loguser,logdate=:logdate where id=:id';
	execute immediate s using pmst,pnganhang_id,to_date(pngay_bd,'dd/mm/yyyy'),to_date(pngay_kt,'dd/mm/yyyy'),ploguser,to_date(plogdate,'dd/mm/yyyy'),pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_nnt_cks(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nnt_cks|DEL',pId);
	s:='delete from tax.nnt_cks where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;