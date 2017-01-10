function new_chuyenkhoans(
	pmst varchar2,
	pso_bl varchar2,
	pso_ct varchar2,
	ptien varchar2,
	pthue varchar2,
	ploaitien_id varchar2,
	pchukyno varchar2,
	pphieu_id varchar2,
	phinhthuctt_id varchar2,
	pnganhang_ph varchar2,
	pnganhang_dvh varchar2,
	pngaynhan varchar2,
	pngay_tt varchar2,
	pnguoi_th varchar2,
	pmay_th varchar2,
	pngay_th varchar2,
	ptamthu varchar2,
	ptrangthai varchar2,
	pphat varchar2,
	plephinganhang varchar2,
	pghichu varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.chuyenkhoans|NEW',pmst||'|'||pso_bl||'|'||pso_ct||'|'||ptien||'|'||pthue||'|'||ploaitien_id||'|'||pchukyno||'|'||pphieu_id||'|'||phinhthuctt_id||'|'||pnganhang_ph||'|'||pnganhang_dvh||'|'||pngaynhan||'|'||pngay_tt||'|'||pnguoi_th||'|'||pmay_th||'|'||pngay_th||'|'||ptamthu||'|'||ptrangthai||'|'||pphat||'|'||plephinganhang||'|'||pghichu);
	s:='insert into tax.chuyenkhoans(mst,so_bl,so_ct,tien,thue,loaitien_id,chukyno,phieu_id,hinhthuctt_id,nganhang_ph,nganhang_dvh,ngaynhan,ngay_tt,nguoi_th,may_th,ngay_th,tamthu,trangthai,phat,lephinganhang,ghichu)
	 values (:mst,:so_bl,:so_ct,:tien,:thue,:loaitien_id,:chukyno,:phieu_id,:hinhthuctt_id,:nganhang_ph,:nganhang_dvh,:ngaynhan,:ngay_tt,:nguoi_th,:may_th,:ngay_th,:tamthu,:trangthai,:phat,:lephinganhang,:ghichu)';
	execute immediate s using pmst,pso_bl,pso_ct,ptien,pthue,ploaitien_id,pchukyno,pphieu_id,phinhthuctt_id,pnganhang_ph,pnganhang_dvh,to_date(pngaynhan,'dd/mm/yyyy'),to_date(pngay_tt,'dd/mm/yyyy'),pnguoi_th,pmay_th,to_date(pngay_th,'dd/mm/yyyy'),ptamthu,ptrangthai,pphat,plephinganhang,pghichu;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_chuyenkhoans(
	pmst varchar2,
	pso_bl varchar2,
	pso_ct varchar2,
	ptien varchar2,
	pthue varchar2,
	ploaitien_id varchar2,
	pchukyno varchar2,
	pphieu_id varchar2,
	phinhthuctt_id varchar2,
	pnganhang_ph varchar2,
	pnganhang_dvh varchar2,
	pngaynhan varchar2,
	pngay_tt varchar2,
	pnguoi_th varchar2,
	pmay_th varchar2,
	pngay_th varchar2,
	ptamthu varchar2,
	ptrangthai varchar2,
	pphat varchar2,
	plephinganhang varchar2,
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
	logger.access('tax.chuyenkhoans|SEARCH',pmst||'|'||pso_bl||'|'||pso_ct||'|'||ptien||'|'||pthue||'|'||ploaitien_id||'|'||pchukyno||'|'||pphieu_id||'|'||phinhthuctt_id||'|'||pnganhang_ph||'|'||pnganhang_dvh||'|'||pngaynhan||'|'||pngay_tt||'|'||pnguoi_th||'|'||pmay_th||'|'||pngay_th||'|'||ptamthu||'|'||ptrangthai||'|'||pphat||'|'||plephinganhang||'|'||pghichu);
	s:='select * from tax.chuyenkhoans where 1=1';
 	if pmst is not null then s:=s||' and mst like '''||replace(pmst,'*','%')||''''; end if;
	if pso_bl is not null then s:=s||' and so_bl like '''||replace(pso_bl,'*','%')||''''; end if;
	if pso_ct is not null then s:=s||' and so_ct like '''||replace(pso_ct,'*','%')||''''; end if;
	if ptien is not null then s:=s||' and tien like '''||replace(ptien,'*','%')||''''; end if;
	if pthue is not null then s:=s||' and thue like '''||replace(pthue,'*','%')||''''; end if;
	if ploaitien_id is not null then s:=s||' and loaitien_id like '''||replace(ploaitien_id,'*','%')||''''; end if;
	if pchukyno is not null then s:=s||' and chukyno like '''||replace(pchukyno,'*','%')||''''; end if;
	if pphieu_id is not null then s:=s||' and phieu_id like '''||replace(pphieu_id,'*','%')||''''; end if;
	if phinhthuctt_id is not null then s:=s||' and hinhthuctt_id like '''||replace(phinhthuctt_id,'*','%')||''''; end if;
	if pnganhang_ph is not null then s:=s||' and nganhang_ph like '''||replace(pnganhang_ph,'*','%')||''''; end if;
	if pnganhang_dvh is not null then s:=s||' and nganhang_dvh like '''||replace(pnganhang_dvh,'*','%')||''''; end if;
	if pngaynhan is not null then s:=s||' and ngaynhan=to_date('''||pngaynhan||''',''dd/mm/yyyy'')'; end if;
	if pngay_tt is not null then s:=s||' and ngay_tt=to_date('''||pngay_tt||''',''dd/mm/yyyy'')'; end if;
	if pnguoi_th is not null then s:=s||' and nguoi_th like '''||replace(pnguoi_th,'*','%')||''''; end if;
	if pmay_th is not null then s:=s||' and may_th like '''||replace(pmay_th,'*','%')||''''; end if;
	if pngay_th is not null then s:=s||' and ngay_th=to_date('''||pngay_th||''',''dd/mm/yyyy'')'; end if;
	if ptamthu is not null then s:=s||' and tamthu like '''||replace(ptamthu,'*','%')||''''; end if;
	if ptrangthai is not null then s:=s||' and trangthai like '''||replace(ptrangthai,'*','%')||''''; end if;
	if pphat is not null then s:=s||' and phat like '''||replace(pphat,'*','%')||''''; end if;
	if plephinganhang is not null then s:=s||' and lephinganhang like '''||replace(plephinganhang,'*','%')||''''; end if;
	if pghichu is not null then s:=s||' and ghichu like '''||replace(pghichu,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_chuyenkhoans(
	pmst varchar2,
	pso_bl varchar2,
	pso_ct varchar2,
	ptien varchar2,
	pthue varchar2,
	ploaitien_id varchar2,
	pchukyno varchar2,
	pphieu_id varchar2,
	phinhthuctt_id varchar2,
	pnganhang_ph varchar2,
	pnganhang_dvh varchar2,
	pngaynhan varchar2,
	pngay_tt varchar2,
	pnguoi_th varchar2,
	pmay_th varchar2,
	pngay_th varchar2,
	ptamthu varchar2,
	ptrangthai varchar2,
	pphat varchar2,
	plephinganhang varchar2,
	pghichu varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.chuyenkhoans|EDIT',pmst||'|'||pso_bl||'|'||pso_ct||'|'||ptien||'|'||pthue||'|'||ploaitien_id||'|'||pchukyno||'|'||pphieu_id||'|'||phinhthuctt_id||'|'||pnganhang_ph||'|'||pnganhang_dvh||'|'||pngaynhan||'|'||pngay_tt||'|'||pnguoi_th||'|'||pmay_th||'|'||pngay_th||'|'||ptamthu||'|'||ptrangthai||'|'||pphat||'|'||plephinganhang||'|'||pghichu);
	s:='update tax.chuyenkhoans set  mst=:mst,so_bl=:so_bl,so_ct=:so_ct,tien=:tien,thue=:thue,loaitien_id=:loaitien_id,chukyno=:chukyno,phieu_id=:phieu_id,hinhthuctt_id=:hinhthuctt_id,nganhang_ph=:nganhang_ph,nganhang_dvh=:nganhang_dvh,ngaynhan=:ngaynhan,ngay_tt=:ngay_tt,nguoi_th=:nguoi_th,may_th=:may_th,ngay_th=:ngay_th,tamthu=:tamthu,trangthai=:trangthai,phat=:phat,lephinganhang=:lephinganhang,ghichu=:ghichu where id=:id';
	execute immediate s using pmst,pso_bl,pso_ct,ptien,pthue,ploaitien_id,pchukyno,pphieu_id,phinhthuctt_id,pnganhang_ph,pnganhang_dvh,to_date(pngaynhan,'dd/mm/yyyy'),to_date(pngay_tt,'dd/mm/yyyy'),pnguoi_th,pmay_th,to_date(pngay_th,'dd/mm/yyyy'),ptamthu,ptrangthai,pphat,plephinganhang,pghichu,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_chuyenkhoans(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.chuyenkhoans|DEL',pId);
	s:='delete from tax.chuyenkhoans where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;