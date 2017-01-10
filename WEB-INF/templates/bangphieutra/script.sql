function new_bangphieutra_q42015(
	pid varchar2,
	pma_tinh varchar2,
	pmst varchar2,
	pma_bc varchar2,
	phttt_id varchar2,
	pnguoigachno_id varchar2,
	pngay_tt varchar2,
	pngay_thuc varchar2,
	pquaythu_id varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.bangphieutra_q42015|NEW',pid||'|'||pma_tinh||'|'||pmst||'|'||pma_bc||'|'||phttt_id||'|'||pnguoigachno_id||'|'||pngay_tt||'|'||pngay_thuc||'|'||pquaythu_id);
	s:='insert into tax.bangphieutra_q42015(id,ma_tinh,mst,ma_bc,httt_id,nguoigachno_id,ngay_tt,ngay_thuc,quaythu_id)
	 values (:id,:ma_tinh,:mst,:ma_bc,:httt_id,:nguoigachno_id,:ngay_tt,:ngay_thuc,:quaythu_id)';
	execute immediate s using pid,pma_tinh,pmst,pma_bc,phttt_id,pnguoigachno_id,to_date(pngay_tt,'dd/mm/yyyy'),to_date(pngay_thuc,'dd/mm/yyyy'),pquaythu_id;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_bangphieutra_q42015(
	pid varchar2,
	pma_tinh varchar2,
	pmst varchar2,
	pma_bc varchar2,
	phttt_id varchar2,
	pnguoigachno_id varchar2,
	pngay_tt varchar2,
	pngay_thuc varchar2,
	pquaythu_id varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.bangphieutra_q42015|SEARCH',pid||'|'||pma_tinh||'|'||pmst||'|'||pma_bc||'|'||phttt_id||'|'||pnguoigachno_id||'|'||pngay_tt||'|'||pngay_thuc||'|'||pquaythu_id);
	s:='select * from tax.bangphieutra_q42015 where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
	if pmst is not null then s:=s||' and mst like '''||replace(pmst,'*','%')||''''; end if;
	if pma_bc is not null then s:=s||' and ma_bc like '''||replace(pma_bc,'*','%')||''''; end if;
	if phttt_id is not null then s:=s||' and httt_id like '''||replace(phttt_id,'*','%')||''''; end if;
	if pnguoigachno_id is not null then s:=s||' and nguoigachno_id like '''||replace(pnguoigachno_id,'*','%')||''''; end if;
	if pngay_tt is not null then s:=s||' and ngay_tt=to_date('''||pngay_tt||''',''dd/mm/yyyy'')'; end if;
	if pngay_thuc is not null then s:=s||' and ngay_thuc=to_date('''||pngay_thuc||''',''dd/mm/yyyy'')'; end if;
	if pquaythu_id is not null then s:=s||' and quaythu_id like '''||replace(pquaythu_id,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_bangphieutra_q42015(
	pid varchar2,
	pma_tinh varchar2,
	pmst varchar2,
	pma_bc varchar2,
	phttt_id varchar2,
	pnguoigachno_id varchar2,
	pngay_tt varchar2,
	pngay_thuc varchar2,
	pquaythu_id varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.bangphieutra_q42015|EDIT',pid||'|'||pma_tinh||'|'||pmst||'|'||pma_bc||'|'||phttt_id||'|'||pnguoigachno_id||'|'||pngay_tt||'|'||pngay_thuc||'|'||pquaythu_id);
	s:='update tax.bangphieutra_q42015 set  id=:id,ma_tinh=:ma_tinh,mst=:mst,ma_bc=:ma_bc,httt_id=:httt_id,nguoigachno_id=:nguoigachno_id,ngay_tt=:ngay_tt,ngay_thuc=:ngay_thuc,quaythu_id=:quaythu_id where id=:id';
	execute immediate s using pid,pma_tinh,pmst,pma_bc,phttt_id,pnguoigachno_id,to_date(pngay_tt,'dd/mm/yyyy'),to_date(pngay_thuc,'dd/mm/yyyy'),pquaythu_id,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_bangphieutra_q42015(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.bangphieutra_q42015|DEL',pId);
	s:='delete from tax.bangphieutra_q42015 where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;