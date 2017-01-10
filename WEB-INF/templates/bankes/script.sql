function new_bankes(
	pid varchar2,
	pkbnn varchar2,
	pct_kbnn varchar2,
	pkh_ct_nh varchar2,
	pso_ct_nh varchar2,
	psotien varchar2,
	ptrang_thai varchar2,
	pngay_unt varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.bankes|NEW',pid||'|'||pkbnn||'|'||pct_kbnn||'|'||pkh_ct_nh||'|'||pso_ct_nh||'|'||psotien||'|'||ptrang_thai||'|'||pngay_unt);
	s:='insert into tax.bankes(id,kbnn,ct_kbnn,kh_ct_nh,so_ct_nh,sotien,trang_thai,ngay_unt)
	 values (:id,:kbnn,:ct_kbnn,:kh_ct_nh,:so_ct_nh,:sotien,:trang_thai,:ngay_unt)';
	execute immediate s using pid,pkbnn,pct_kbnn,pkh_ct_nh,pso_ct_nh,psotien,ptrang_thai,to_date(pngay_unt,'dd/mm/yyyy');
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_bankes(
	pid varchar2,
	pkbnn varchar2,
	pct_kbnn varchar2,
	pkh_ct_nh varchar2,
	pso_ct_nh varchar2,
	psotien varchar2,
	ptrang_thai varchar2,
	pngay_unt varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.bankes|SEARCH',pid||'|'||pkbnn||'|'||pct_kbnn||'|'||pkh_ct_nh||'|'||pso_ct_nh||'|'||psotien||'|'||ptrang_thai||'|'||pngay_unt);
	s:='select * from tax.bankes where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if pkbnn is not null then s:=s||' and kbnn like '''||replace(pkbnn,'*','%')||''''; end if;
	if pct_kbnn is not null then s:=s||' and ct_kbnn like '''||replace(pct_kbnn,'*','%')||''''; end if;
	if pkh_ct_nh is not null then s:=s||' and kh_ct_nh like '''||replace(pkh_ct_nh,'*','%')||''''; end if;
	if pso_ct_nh is not null then s:=s||' and so_ct_nh like '''||replace(pso_ct_nh,'*','%')||''''; end if;
	if psotien is not null then s:=s||' and sotien like '''||replace(psotien,'*','%')||''''; end if;
	if ptrang_thai is not null then s:=s||' and trang_thai like '''||replace(ptrang_thai,'*','%')||''''; end if;
	if pngay_unt is not null then s:=s||' and ngay_unt=to_date('''||pngay_unt||''',''dd/mm/yyyy'')'; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_bankes(
	pid varchar2,
	pkbnn varchar2,
	pct_kbnn varchar2,
	pkh_ct_nh varchar2,
	pso_ct_nh varchar2,
	psotien varchar2,
	ptrang_thai varchar2,
	pngay_unt varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.bankes|EDIT',pid||'|'||pkbnn||'|'||pct_kbnn||'|'||pkh_ct_nh||'|'||pso_ct_nh||'|'||psotien||'|'||ptrang_thai||'|'||pngay_unt);
	s:='update tax.bankes set  id=:id,kbnn=:kbnn,ct_kbnn=:ct_kbnn,kh_ct_nh=:kh_ct_nh,so_ct_nh=:so_ct_nh,sotien=:sotien,trang_thai=:trang_thai,ngay_unt=:ngay_unt where id=:id';
	execute immediate s using pid,pkbnn,pct_kbnn,pkh_ct_nh,pso_ct_nh,psotien,ptrang_thai,to_date(pngay_unt,'dd/mm/yyyy'),pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_bankes(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.bankes|DEL',pId);
	s:='delete from tax.bankes where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;