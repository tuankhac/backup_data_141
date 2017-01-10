function new_image(
	pid varchar2,
	ptitle varchar2,
	psource varchar2,
	pdescription varchar2,
	pcreated_date varchar2,
	pmodified_date varchar2,
	pcreated_user varchar2,
	pmodified_user varchar2,
	pnhanvien_tcs_id varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.image|NEW',pid||'|'||ptitle||'|'||psource||'|'||pdescription||'|'||pcreated_date||'|'||pmodified_date||'|'||pcreated_user||'|'||pmodified_user||'|'||pnhanvien_tcs_id);
	s:='insert into tax.image(id,title,source,description,created_date,modified_date,created_user,modified_user,nhanvien_tcs_id)
	 values (:id,:title,:source,:description,:created_date,:modified_date,:created_user,:modified_user,:nhanvien_tcs_id)';
	execute immediate s using pid,ptitle,psource,pdescription,to_date(pcreated_date,'dd/mm/yyyy'),to_date(pmodified_date,'dd/mm/yyyy'),pcreated_user,pmodified_user,pnhanvien_tcs_id;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_image(
	pid varchar2,
	ptitle varchar2,
	psource varchar2,
	pdescription varchar2,
	pcreated_date varchar2,
	pmodified_date varchar2,
	pcreated_user varchar2,
	pmodified_user varchar2,
	pnhanvien_tcs_id varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.image|SEARCH',pid||'|'||ptitle||'|'||psource||'|'||pdescription||'|'||pcreated_date||'|'||pmodified_date||'|'||pcreated_user||'|'||pmodified_user||'|'||pnhanvien_tcs_id);
	s:='select * from tax.image where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if ptitle is not null then s:=s||' and title like '''||replace(ptitle,'*','%')||''''; end if;
	if psource is not null then s:=s||' and source like '''||replace(psource,'*','%')||''''; end if;
	if pdescription is not null then s:=s||' and description like '''||replace(pdescription,'*','%')||''''; end if;
	if pcreated_date is not null then s:=s||' and created_date=to_date('''||pcreated_date||''',''dd/mm/yyyy'')'; end if;
	if pmodified_date is not null then s:=s||' and modified_date=to_date('''||pmodified_date||''',''dd/mm/yyyy'')'; end if;
	if pcreated_user is not null then s:=s||' and created_user like '''||replace(pcreated_user,'*','%')||''''; end if;
	if pmodified_user is not null then s:=s||' and modified_user like '''||replace(pmodified_user,'*','%')||''''; end if;
	if pnhanvien_tcs_id is not null then s:=s||' and nhanvien_tcs_id like '''||replace(pnhanvien_tcs_id,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_image(
	pid varchar2,
	ptitle varchar2,
	psource varchar2,
	pdescription varchar2,
	pcreated_date varchar2,
	pmodified_date varchar2,
	pcreated_user varchar2,
	pmodified_user varchar2,
	pnhanvien_tcs_id varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.image|EDIT',pid||'|'||ptitle||'|'||psource||'|'||pdescription||'|'||pcreated_date||'|'||pmodified_date||'|'||pcreated_user||'|'||pmodified_user||'|'||pnhanvien_tcs_id);
	s:='update tax.image set  id=:id,title=:title,source=:source,description=:description,created_date=:created_date,modified_date=:modified_date,created_user=:created_user,modified_user=:modified_user,nhanvien_tcs_id=:nhanvien_tcs_id where id=:id';
	execute immediate s using pid,ptitle,psource,pdescription,to_date(pcreated_date,'dd/mm/yyyy'),to_date(pmodified_date,'dd/mm/yyyy'),pcreated_user,pmodified_user,pnhanvien_tcs_id,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_image(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.image|DEL',pId);
	s:='delete from tax.image where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;