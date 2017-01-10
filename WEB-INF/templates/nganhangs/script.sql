function new_nganhangs(
	pid varchar2,
	pmaso varchar2,
	pten varchar2,
	pdiachi varchar2,
	ptaikhoan varchar2,
	pdienthoai varchar2,
	psofax varchar2,
	planhdao varchar2,
	pma_tinh varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nganhangs|NEW',pid||'|'||pmaso||'|'||pten||'|'||pdiachi||'|'||ptaikhoan||'|'||pdienthoai||'|'||psofax||'|'||planhdao||'|'||pma_tinh);
	s:='insert into tax.nganhangs(id,maso,ten,diachi,taikhoan,dienthoai,sofax,lanhdao,ma_tinh)
	 values (:id,:maso,:ten,:diachi,:taikhoan,:dienthoai,:sofax,:lanhdao,:ma_tinh)';
	execute immediate s using pid,pmaso,pten,pdiachi,ptaikhoan,pdienthoai,psofax,planhdao,pma_tinh;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_nganhangs(
	pid varchar2,
	pmaso varchar2,
	pten varchar2,
	pdiachi varchar2,
	ptaikhoan varchar2,
	pdienthoai varchar2,
	psofax varchar2,
	planhdao varchar2,
	pma_tinh varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.nganhangs|SEARCH',pid||'|'||pmaso||'|'||pten||'|'||pdiachi||'|'||ptaikhoan||'|'||pdienthoai||'|'||psofax||'|'||planhdao||'|'||pma_tinh);
	s:='select * from tax.nganhangs where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if pmaso is not null then s:=s||' and maso like '''||replace(pmaso,'*','%')||''''; end if;
	if pten is not null then s:=s||' and ten like '''||replace(pten,'*','%')||''''; end if;
	if pdiachi is not null then s:=s||' and diachi like '''||replace(pdiachi,'*','%')||''''; end if;
	if ptaikhoan is not null then s:=s||' and taikhoan like '''||replace(ptaikhoan,'*','%')||''''; end if;
	if pdienthoai is not null then s:=s||' and dienthoai like '''||replace(pdienthoai,'*','%')||''''; end if;
	if psofax is not null then s:=s||' and sofax like '''||replace(psofax,'*','%')||''''; end if;
	if planhdao is not null then s:=s||' and lanhdao like '''||replace(planhdao,'*','%')||''''; end if;
	if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_nganhangs(
	pid varchar2,
	pmaso varchar2,
	pten varchar2,
	pdiachi varchar2,
	ptaikhoan varchar2,
	pdienthoai varchar2,
	psofax varchar2,
	planhdao varchar2,
	pma_tinh varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nganhangs|EDIT',pid||'|'||pmaso||'|'||pten||'|'||pdiachi||'|'||ptaikhoan||'|'||pdienthoai||'|'||psofax||'|'||planhdao||'|'||pma_tinh);
	s:='update tax.nganhangs set  id=:id,maso=:maso,ten=:ten,diachi=:diachi,taikhoan=:taikhoan,dienthoai=:dienthoai,sofax=:sofax,lanhdao=:lanhdao,ma_tinh=:ma_tinh where id=:id';
	execute immediate s using pid,pmaso,pten,pdiachi,ptaikhoan,pdienthoai,psofax,planhdao,pma_tinh,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_nganhangs(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nganhangs|DEL',pId);
	s:='delete from tax.nganhangs where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;