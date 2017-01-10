function new_coquanthus(
	pid varchar2,
	pcqt_qlt varchar2,
	pcqt_tms varchar2,
	pten_cqt varchar2,
	pma_tinh varchar2,
	pma_huyen varchar2,
	pma_quoc_gia varchar2,
	phieu_luc_tu varchar2,
	phieu_luc_den varchar2,
	pshkb varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.coquanthus|NEW',pid||'|'||pcqt_qlt||'|'||pcqt_tms||'|'||pten_cqt||'|'||pma_tinh||'|'||pma_huyen||'|'||pma_quoc_gia||'|'||phieu_luc_tu||'|'||phieu_luc_den||'|'||pshkb);
	s:='insert into tax.coquanthus(id,cqt_qlt,cqt_tms,ten_cqt,ma_tinh,ma_huyen,ma_quoc_gia,hieu_luc_tu,hieu_luc_den,shkb)
	 values (:id,:cqt_qlt,:cqt_tms,:ten_cqt,:ma_tinh,:ma_huyen,:ma_quoc_gia,:hieu_luc_tu,:hieu_luc_den,:shkb)';
	execute immediate s using pid,pcqt_qlt,pcqt_tms,pten_cqt,pma_tinh,pma_huyen,pma_quoc_gia,phieu_luc_tu,phieu_luc_den,pshkb;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_coquanthus(
	pid varchar2,
	pcqt_qlt varchar2,
	pcqt_tms varchar2,
	pten_cqt varchar2,
	pma_tinh varchar2,
	pma_huyen varchar2,
	pma_quoc_gia varchar2,
	phieu_luc_tu varchar2,
	phieu_luc_den varchar2,
	pshkb varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.coquanthus|SEARCH',pid||'|'||pcqt_qlt||'|'||pcqt_tms||'|'||pten_cqt||'|'||pma_tinh||'|'||pma_huyen||'|'||pma_quoc_gia||'|'||phieu_luc_tu||'|'||phieu_luc_den||'|'||pshkb);
	s:='select * from tax.coquanthus where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if pcqt_qlt is not null then s:=s||' and cqt_qlt like '''||replace(pcqt_qlt,'*','%')||''''; end if;
	if pcqt_tms is not null then s:=s||' and cqt_tms like '''||replace(pcqt_tms,'*','%')||''''; end if;
	if pten_cqt is not null then s:=s||' and ten_cqt like '''||replace(pten_cqt,'*','%')||''''; end if;
	if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
	if pma_huyen is not null then s:=s||' and ma_huyen like '''||replace(pma_huyen,'*','%')||''''; end if;
	if pma_quoc_gia is not null then s:=s||' and ma_quoc_gia like '''||replace(pma_quoc_gia,'*','%')||''''; end if;
	if phieu_luc_tu is not null then s:=s||' and hieu_luc_tu like '''||replace(phieu_luc_tu,'*','%')||''''; end if;
	if phieu_luc_den is not null then s:=s||' and hieu_luc_den like '''||replace(phieu_luc_den,'*','%')||''''; end if;
	if pshkb is not null then s:=s||' and shkb like '''||replace(pshkb,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_coquanthus(
	pid varchar2,
	pcqt_qlt varchar2,
	pcqt_tms varchar2,
	pten_cqt varchar2,
	pma_tinh varchar2,
	pma_huyen varchar2,
	pma_quoc_gia varchar2,
	phieu_luc_tu varchar2,
	phieu_luc_den varchar2,
	pshkb varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.coquanthus|EDIT',pid||'|'||pcqt_qlt||'|'||pcqt_tms||'|'||pten_cqt||'|'||pma_tinh||'|'||pma_huyen||'|'||pma_quoc_gia||'|'||phieu_luc_tu||'|'||phieu_luc_den||'|'||pshkb);
	s:='update tax.coquanthus set  id=:id,cqt_qlt=:cqt_qlt,cqt_tms=:cqt_tms,ten_cqt=:ten_cqt,ma_tinh=:ma_tinh,ma_huyen=:ma_huyen,ma_quoc_gia=:ma_quoc_gia,hieu_luc_tu=:hieu_luc_tu,hieu_luc_den=:hieu_luc_den,shkb=:shkb where id=:id';
	execute immediate s using pid,pcqt_qlt,pcqt_tms,pten_cqt,pma_tinh,pma_huyen,pma_quoc_gia,phieu_luc_tu,phieu_luc_den,pshkb,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_coquanthus(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.coquanthus|DEL',pId);
	s:='delete from tax.coquanthus where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;