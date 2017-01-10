function new_ct_tra_yyyy(
	pmst varchar2,
	pten_nnt varchar2,
	pmota_diachi varchar2,
	pma_cq_thu varchar2,
	pkythue varchar2,
	pchuky varchar2,
	pma_chuong varchar2,
	pma_tmuc varchar2,
	ptientra varchar2,
	pnguoigachno_id varchar2,
	pid varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.ct_tra_yyyy|NEW',pmst||'|'||pten_nnt||'|'||pmota_diachi||'|'||pma_cq_thu||'|'||pkythue||'|'||pchuky||'|'||pma_chuong||'|'||pma_tmuc||'|'||ptientra||'|'||pnguoigachno_id||'|'||pid);
	s:='insert into tax.ct_tra_yyyy(mst,ten_nnt,mota_diachi,ma_cq_thu,kythue,chuky,ma_chuong,ma_tmuc,tientra,nguoigachno_id,id)
	 values (:mst,:ten_nnt,:mota_diachi,:ma_cq_thu,:kythue,:chuky,:ma_chuong,:ma_tmuc,:tientra,:nguoigachno_id,:id)';
	execute immediate s using pmst,pten_nnt,pmota_diachi,pma_cq_thu,pkythue,pchuky,pma_chuong,pma_tmuc,ptientra,pnguoigachno_id,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_ct_tra_yyyy(
	pmst varchar2,
	pten_nnt varchar2,
	pmota_diachi varchar2,
	pma_cq_thu varchar2,
	pkythue varchar2,
	pchuky varchar2,
	pma_chuong varchar2,
	pma_tmuc varchar2,
	ptientra varchar2,
	pnguoigachno_id varchar2,
	pid varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.ct_tra_yyyy|SEARCH',pmst||'|'||pten_nnt||'|'||pmota_diachi||'|'||pma_cq_thu||'|'||pkythue||'|'||pchuky||'|'||pma_chuong||'|'||pma_tmuc||'|'||ptientra||'|'||pnguoigachno_id||'|'||pid);
	s:='select * from tax.ct_tra_yyyy where 1=1';
 	if pmst is not null then s:=s||' and mst like '''||replace(pmst,'*','%')||''''; end if;
	if pten_nnt is not null then s:=s||' and ten_nnt like '''||replace(pten_nnt,'*','%')||''''; end if;
	if pmota_diachi is not null then s:=s||' and mota_diachi like '''||replace(pmota_diachi,'*','%')||''''; end if;
	if pma_cq_thu is not null then s:=s||' and ma_cq_thu like '''||replace(pma_cq_thu,'*','%')||''''; end if;
	if pkythue is not null then s:=s||' and kythue like '''||replace(pkythue,'*','%')||''''; end if;
	if pchuky is not null then s:=s||' and chuky like '''||replace(pchuky,'*','%')||''''; end if;
	if pma_chuong is not null then s:=s||' and ma_chuong like '''||replace(pma_chuong,'*','%')||''''; end if;
	if pma_tmuc is not null then s:=s||' and ma_tmuc like '''||replace(pma_tmuc,'*','%')||''''; end if;
	if ptientra is not null then s:=s||' and tientra like '''||replace(ptientra,'*','%')||''''; end if;
	if pnguoigachno_id is not null then s:=s||' and nguoigachno_id like '''||replace(pnguoigachno_id,'*','%')||''''; end if;
	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_ct_tra_yyyy(
	pmst varchar2,
	pten_nnt varchar2,
	pmota_diachi varchar2,
	pma_cq_thu varchar2,
	pkythue varchar2,
	pchuky varchar2,
	pma_chuong varchar2,
	pma_tmuc varchar2,
	ptientra varchar2,
	pnguoigachno_id varchar2,
	pid varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.ct_tra_yyyy|EDIT',pmst||'|'||pten_nnt||'|'||pmota_diachi||'|'||pma_cq_thu||'|'||pkythue||'|'||pchuky||'|'||pma_chuong||'|'||pma_tmuc||'|'||ptientra||'|'||pnguoigachno_id||'|'||pid);
	s:='update tax.ct_tra_yyyy set  mst=:mst,ten_nnt=:ten_nnt,mota_diachi=:mota_diachi,ma_cq_thu=:ma_cq_thu,kythue=:kythue,chuky=:chuky,ma_chuong=:ma_chuong,ma_tmuc=:ma_tmuc,tientra=:tientra,nguoigachno_id=:nguoigachno_id,id=:id where id=:id';
	execute immediate s using pmst,pten_nnt,pmota_diachi,pma_cq_thu,pkythue,pchuky,pma_chuong,pma_tmuc,ptientra,pnguoigachno_id,pid,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_ct_tra_yyyy(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.ct_tra_yyyy|DEL',pId);
	s:='delete from tax.ct_tra_yyyy where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;