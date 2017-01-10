function new_ketquaphats(
	pid varchar2,
	pmst varchar2,
	pchungtu_id varchar2,
	pma_nv varchar2,
	pbill varchar2,
	pngay_phat varchar2,
	pngay_nhap varchar2,
	pnguoi_nhan varchar2,
	plan_phat varchar2,
	plan_thu varchar2,
	ptrang_thai varchar2,
	pma_daily varchar2,
	pdiem_thu varchar2,
	pghichu varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.ketquaphats|NEW',pid||'|'||pmst||'|'||pchungtu_id||'|'||pma_nv||'|'||pbill||'|'||pngay_phat||'|'||pngay_nhap||'|'||pnguoi_nhan||'|'||plan_phat||'|'||plan_thu||'|'||ptrang_thai||'|'||pma_daily||'|'||pdiem_thu||'|'||pghichu);
	s:='insert into tax.ketquaphats(id,mst,chungtu_id,ma_nv,bill,ngay_phat,ngay_nhap,nguoi_nhan,lan_phat,lan_thu,trang_thai,ma_daily,diem_thu,ghichu)
	 values (:id,:mst,:chungtu_id,:ma_nv,:bill,:ngay_phat,:ngay_nhap,:nguoi_nhan,:lan_phat,:lan_thu,:trang_thai,:ma_daily,:diem_thu,:ghichu)';
	execute immediate s using pid,pmst,pchungtu_id,pma_nv,pbill,to_date(pngay_phat,'dd/mm/yyyy'),to_date(pngay_nhap,'dd/mm/yyyy'),pnguoi_nhan,plan_phat,plan_thu,ptrang_thai,pma_daily,pdiem_thu,pghichu;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_ketquaphats(
	pid varchar2,
	pmst varchar2,
	pchungtu_id varchar2,
	pma_nv varchar2,
	pbill varchar2,
	pngay_phat varchar2,
	pngay_nhap varchar2,
	pnguoi_nhan varchar2,
	plan_phat varchar2,
	plan_thu varchar2,
	ptrang_thai varchar2,
	pma_daily varchar2,
	pdiem_thu varchar2,
	pghichu varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.ketquaphats|SEARCH',pid||'|'||pmst||'|'||pchungtu_id||'|'||pma_nv||'|'||pbill||'|'||pngay_phat||'|'||pngay_nhap||'|'||pnguoi_nhan||'|'||plan_phat||'|'||plan_thu||'|'||ptrang_thai||'|'||pma_daily||'|'||pdiem_thu||'|'||pghichu);
	s:='select * from tax.ketquaphats where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if pmst is not null then s:=s||' and mst like '''||replace(pmst,'*','%')||''''; end if;
	if pchungtu_id is not null then s:=s||' and chungtu_id like '''||replace(pchungtu_id,'*','%')||''''; end if;
	if pma_nv is not null then s:=s||' and ma_nv like '''||replace(pma_nv,'*','%')||''''; end if;
	if pbill is not null then s:=s||' and bill like '''||replace(pbill,'*','%')||''''; end if;
	if pngay_phat is not null then s:=s||' and ngay_phat=to_date('''||pngay_phat||''',''dd/mm/yyyy'')'; end if;
	if pngay_nhap is not null then s:=s||' and ngay_nhap=to_date('''||pngay_nhap||''',''dd/mm/yyyy'')'; end if;
	if pnguoi_nhan is not null then s:=s||' and nguoi_nhan like '''||replace(pnguoi_nhan,'*','%')||''''; end if;
	if plan_phat is not null then s:=s||' and lan_phat like '''||replace(plan_phat,'*','%')||''''; end if;
	if plan_thu is not null then s:=s||' and lan_thu like '''||replace(plan_thu,'*','%')||''''; end if;
	if ptrang_thai is not null then s:=s||' and trang_thai like '''||replace(ptrang_thai,'*','%')||''''; end if;
	if pma_daily is not null then s:=s||' and ma_daily like '''||replace(pma_daily,'*','%')||''''; end if;
	if pdiem_thu is not null then s:=s||' and diem_thu like '''||replace(pdiem_thu,'*','%')||''''; end if;
	if pghichu is not null then s:=s||' and ghichu like '''||replace(pghichu,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_ketquaphats(
	pid varchar2,
	pmst varchar2,
	pchungtu_id varchar2,
	pma_nv varchar2,
	pbill varchar2,
	pngay_phat varchar2,
	pngay_nhap varchar2,
	pnguoi_nhan varchar2,
	plan_phat varchar2,
	plan_thu varchar2,
	ptrang_thai varchar2,
	pma_daily varchar2,
	pdiem_thu varchar2,
	pghichu varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.ketquaphats|EDIT',pid||'|'||pmst||'|'||pchungtu_id||'|'||pma_nv||'|'||pbill||'|'||pngay_phat||'|'||pngay_nhap||'|'||pnguoi_nhan||'|'||plan_phat||'|'||plan_thu||'|'||ptrang_thai||'|'||pma_daily||'|'||pdiem_thu||'|'||pghichu);
	s:='update tax.ketquaphats set  id=:id,mst=:mst,chungtu_id=:chungtu_id,ma_nv=:ma_nv,bill=:bill,ngay_phat=:ngay_phat,ngay_nhap=:ngay_nhap,nguoi_nhan=:nguoi_nhan,lan_phat=:lan_phat,lan_thu=:lan_thu,trang_thai=:trang_thai,ma_daily=:ma_daily,diem_thu=:diem_thu,ghichu=:ghichu where id=:id';
	execute immediate s using pid,pmst,pchungtu_id,pma_nv,pbill,to_date(pngay_phat,'dd/mm/yyyy'),to_date(pngay_nhap,'dd/mm/yyyy'),pnguoi_nhan,plan_phat,plan_thu,ptrang_thai,pma_daily,pdiem_thu,pghichu,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_ketquaphats(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.ketquaphats|DEL',pId);
	s:='delete from tax.ketquaphats where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;