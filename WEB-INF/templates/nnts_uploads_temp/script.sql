function new_nnts_temp(
	pmcq varchar2,
	pma_unt varchar2,
	pten_unt varchar2,
	pcbk_unt varchar2,
	pngay_unt varchar2,
	pma_nnt varchar2,
	pten_nnt varchar2,
	psac_thue varchar2,
	pchuong varchar2,
	ptieu_muc varchar2,
	pdia_ban varchar2,
	pkbnn varchar2,
	pkythue varchar2,
	ploaitk_nsnn varchar2,
	phan_nop varchar2,
	pmagiao_unt varchar2,
	ploai_tien varchar2,
	ptien_giao varchar2,
	ptien_con varchar2,
	ptien_thuduoc varchar2,
	ptien_quyettoan varchar2,
	pso_bl varchar2,
	pngay_bl varchar2,
	psobl_unt varchar2,
	pngaybl_unt varchar2,
	pngay_banke varchar2,
	psonha_ct varchar2,
	pmatinh_ct varchar2,
	ptentinh_ct varchar2,
	pmaquan_ct varchar2,
	ptenquan_ct varchar2,
	pmaxa_ct varchar2,
	ptenxa_ct varchar2,
	pmobile varchar2,
	pemail varchar2,
	psonha_tt varchar2,
	pmatinh_tt varchar2,
	ptentinh_tt varchar2,
	pmaquan_tt varchar2,
	ptenquan_tt varchar2,
	pmaxa_tt varchar2,
	ptenxa_tt varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nnts_temp|NEW',pmcq||'|'||pma_unt||'|'||pten_unt||'|'||pcbk_unt||'|'||pngay_unt||'|'||pma_nnt||'|'||pten_nnt||'|'||psac_thue||'|'||pchuong||'|'||ptieu_muc||'|'||pdia_ban||'|'||pkbnn||'|'||pkythue||'|'||ploaitk_nsnn||'|'||phan_nop||'|'||pmagiao_unt||'|'||ploai_tien||'|'||ptien_giao||'|'||ptien_con||'|'||ptien_thuduoc||'|'||ptien_quyettoan||'|'||pso_bl||'|'||pngay_bl||'|'||psobl_unt||'|'||pngaybl_unt||'|'||pngay_banke||'|'||psonha_ct||'|'||pmatinh_ct||'|'||ptentinh_ct||'|'||pmaquan_ct||'|'||ptenquan_ct||'|'||pmaxa_ct||'|'||ptenxa_ct||'|'||pmobile||'|'||pemail||'|'||psonha_tt||'|'||pmatinh_tt||'|'||ptentinh_tt||'|'||pmaquan_tt||'|'||ptenquan_tt||'|'||pmaxa_tt||'|'||ptenxa_tt);
	s:='insert into tax.nnts_temp(mcq,ma_unt,ten_unt,cbk_unt,ngay_unt,ma_nnt,ten_nnt,sac_thue,chuong,tieu_muc,dia_ban,kbnn,kythue,loaitk_nsnn,han_nop,magiao_unt,loai_tien,tien_giao,tien_con,tien_thuduoc,tien_quyettoan,so_bl,ngay_bl,sobl_unt,ngaybl_unt,ngay_banke,sonha_ct,matinh_ct,tentinh_ct,maquan_ct,tenquan_ct,maxa_ct,tenxa_ct,mobile,email,sonha_tt,matinh_tt,tentinh_tt,maquan_tt,tenquan_tt,maxa_tt,tenxa_tt)
	 values (:mcq,:ma_unt,:ten_unt,:cbk_unt,:ngay_unt,:ma_nnt,:ten_nnt,:sac_thue,:chuong,:tieu_muc,:dia_ban,:kbnn,:kythue,:loaitk_nsnn,:han_nop,:magiao_unt,:loai_tien,:tien_giao,:tien_con,:tien_thuduoc,:tien_quyettoan,:so_bl,:ngay_bl,:sobl_unt,:ngaybl_unt,:ngay_banke,:sonha_ct,:matinh_ct,:tentinh_ct,:maquan_ct,:tenquan_ct,:maxa_ct,:tenxa_ct,:mobile,:email,:sonha_tt,:matinh_tt,:tentinh_tt,:maquan_tt,:tenquan_tt,:maxa_tt,:tenxa_tt)';
	execute immediate s using pmcq,pma_unt,pten_unt,pcbk_unt,pngay_unt,pma_nnt,pten_nnt,psac_thue,pchuong,ptieu_muc,pdia_ban,pkbnn,pkythue,ploaitk_nsnn,phan_nop,pmagiao_unt,ploai_tien,ptien_giao,ptien_con,ptien_thuduoc,ptien_quyettoan,pso_bl,pngay_bl,psobl_unt,pngaybl_unt,pngay_banke,psonha_ct,pmatinh_ct,ptentinh_ct,pmaquan_ct,ptenquan_ct,pmaxa_ct,ptenxa_ct,pmobile,pemail,psonha_tt,pmatinh_tt,ptentinh_tt,pmaquan_tt,ptenquan_tt,pmaxa_tt,ptenxa_tt;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function search_nnts_temp(
	pmcq varchar2,
	pma_unt varchar2,
	pten_unt varchar2,
	pcbk_unt varchar2,
	pngay_unt varchar2,
	pma_nnt varchar2,
	pten_nnt varchar2,
	psac_thue varchar2,
	pchuong varchar2,
	ptieu_muc varchar2,
	pdia_ban varchar2,
	pkbnn varchar2,
	pkythue varchar2,
	ploaitk_nsnn varchar2,
	phan_nop varchar2,
	pmagiao_unt varchar2,
	ploai_tien varchar2,
	ptien_giao varchar2,
	ptien_con varchar2,
	ptien_thuduoc varchar2,
	ptien_quyettoan varchar2,
	pso_bl varchar2,
	pngay_bl varchar2,
	psobl_unt varchar2,
	pngaybl_unt varchar2,
	pngay_banke varchar2,
	psonha_ct varchar2,
	pmatinh_ct varchar2,
	ptentinh_ct varchar2,
	pmaquan_ct varchar2,
	ptenquan_ct varchar2,
	pmaxa_ct varchar2,
	ptenxa_ct varchar2,
	pmobile varchar2,
	pemail varchar2,
	psonha_tt varchar2,
	pmatinh_tt varchar2,
	ptentinh_tt varchar2,
	pmaquan_tt varchar2,
	ptenquan_tt varchar2,
	pmaxa_tt varchar2,
	ptenxa_tt varchar2,
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.nnts_temp|SEARCH',pmcq||'|'||pma_unt||'|'||pten_unt||'|'||pcbk_unt||'|'||pngay_unt||'|'||pma_nnt||'|'||pten_nnt||'|'||psac_thue||'|'||pchuong||'|'||ptieu_muc||'|'||pdia_ban||'|'||pkbnn||'|'||pkythue||'|'||ploaitk_nsnn||'|'||phan_nop||'|'||pmagiao_unt||'|'||ploai_tien||'|'||ptien_giao||'|'||ptien_con||'|'||ptien_thuduoc||'|'||ptien_quyettoan||'|'||pso_bl||'|'||pngay_bl||'|'||psobl_unt||'|'||pngaybl_unt||'|'||pngay_banke||'|'||psonha_ct||'|'||pmatinh_ct||'|'||ptentinh_ct||'|'||pmaquan_ct||'|'||ptenquan_ct||'|'||pmaxa_ct||'|'||ptenxa_ct||'|'||pmobile||'|'||pemail||'|'||psonha_tt||'|'||pmatinh_tt||'|'||ptentinh_tt||'|'||pmaquan_tt||'|'||ptenquan_tt||'|'||pmaxa_tt||'|'||ptenxa_tt);
	s:='select * from tax.nnts_temp where 1=1';
 	if pmcq is not null then s:=s||' and mcq like '''||replace(pmcq,'*','%')||''''; end if;
	if pma_unt is not null then s:=s||' and ma_unt like '''||replace(pma_unt,'*','%')||''''; end if;
	if pten_unt is not null then s:=s||' and ten_unt like '''||replace(pten_unt,'*','%')||''''; end if;
	if pcbk_unt is not null then s:=s||' and cbk_unt like '''||replace(pcbk_unt,'*','%')||''''; end if;
	if pngay_unt is not null then s:=s||' and ngay_unt like '''||replace(pngay_unt,'*','%')||''''; end if;
	if pma_nnt is not null then s:=s||' and ma_nnt like '''||replace(pma_nnt,'*','%')||''''; end if;
	if pten_nnt is not null then s:=s||' and ten_nnt like '''||replace(pten_nnt,'*','%')||''''; end if;
	if psac_thue is not null then s:=s||' and sac_thue like '''||replace(psac_thue,'*','%')||''''; end if;
	if pchuong is not null then s:=s||' and chuong like '''||replace(pchuong,'*','%')||''''; end if;
	if ptieu_muc is not null then s:=s||' and tieu_muc like '''||replace(ptieu_muc,'*','%')||''''; end if;
	if pdia_ban is not null then s:=s||' and dia_ban like '''||replace(pdia_ban,'*','%')||''''; end if;
	if pkbnn is not null then s:=s||' and kbnn like '''||replace(pkbnn,'*','%')||''''; end if;
	if pkythue is not null then s:=s||' and kythue like '''||replace(pkythue,'*','%')||''''; end if;
	if ploaitk_nsnn is not null then s:=s||' and loaitk_nsnn like '''||replace(ploaitk_nsnn,'*','%')||''''; end if;
	if phan_nop is not null then s:=s||' and han_nop like '''||replace(phan_nop,'*','%')||''''; end if;
	if pmagiao_unt is not null then s:=s||' and magiao_unt like '''||replace(pmagiao_unt,'*','%')||''''; end if;
	if ploai_tien is not null then s:=s||' and loai_tien like '''||replace(ploai_tien,'*','%')||''''; end if;
	if ptien_giao is not null then s:=s||' and tien_giao like '''||replace(ptien_giao,'*','%')||''''; end if;
	if ptien_con is not null then s:=s||' and tien_con like '''||replace(ptien_con,'*','%')||''''; end if;
	if ptien_thuduoc is not null then s:=s||' and tien_thuduoc like '''||replace(ptien_thuduoc,'*','%')||''''; end if;
	if ptien_quyettoan is not null then s:=s||' and tien_quyettoan like '''||replace(ptien_quyettoan,'*','%')||''''; end if;
	if pso_bl is not null then s:=s||' and so_bl like '''||replace(pso_bl,'*','%')||''''; end if;
	if pngay_bl is not null then s:=s||' and ngay_bl like '''||replace(pngay_bl,'*','%')||''''; end if;
	if psobl_unt is not null then s:=s||' and sobl_unt like '''||replace(psobl_unt,'*','%')||''''; end if;
	if pngaybl_unt is not null then s:=s||' and ngaybl_unt like '''||replace(pngaybl_unt,'*','%')||''''; end if;
	if pngay_banke is not null then s:=s||' and ngay_banke like '''||replace(pngay_banke,'*','%')||''''; end if;
	if psonha_ct is not null then s:=s||' and sonha_ct like '''||replace(psonha_ct,'*','%')||''''; end if;
	if pmatinh_ct is not null then s:=s||' and matinh_ct like '''||replace(pmatinh_ct,'*','%')||''''; end if;
	if ptentinh_ct is not null then s:=s||' and tentinh_ct like '''||replace(ptentinh_ct,'*','%')||''''; end if;
	if pmaquan_ct is not null then s:=s||' and maquan_ct like '''||replace(pmaquan_ct,'*','%')||''''; end if;
	if ptenquan_ct is not null then s:=s||' and tenquan_ct like '''||replace(ptenquan_ct,'*','%')||''''; end if;
	if pmaxa_ct is not null then s:=s||' and maxa_ct like '''||replace(pmaxa_ct,'*','%')||''''; end if;
	if ptenxa_ct is not null then s:=s||' and tenxa_ct like '''||replace(ptenxa_ct,'*','%')||''''; end if;
	if pmobile is not null then s:=s||' and mobile like '''||replace(pmobile,'*','%')||''''; end if;
	if pemail is not null then s:=s||' and email like '''||replace(pemail,'*','%')||''''; end if;
	if psonha_tt is not null then s:=s||' and sonha_tt like '''||replace(psonha_tt,'*','%')||''''; end if;
	if pmatinh_tt is not null then s:=s||' and matinh_tt like '''||replace(pmatinh_tt,'*','%')||''''; end if;
	if ptentinh_tt is not null then s:=s||' and tentinh_tt like '''||replace(ptentinh_tt,'*','%')||''''; end if;
	if pmaquan_tt is not null then s:=s||' and maquan_tt like '''||replace(pmaquan_tt,'*','%')||''''; end if;
	if ptenquan_tt is not null then s:=s||' and tenquan_tt like '''||replace(ptenquan_tt,'*','%')||''''; end if;
	if pmaxa_tt is not null then s:=s||' and maxa_tt like '''||replace(pmaxa_tt,'*','%')||''''; end if;
	if ptenxa_tt is not null then s:=s||' and tenxa_tt like '''||replace(ptenxa_tt,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
	end;
end;
function edit_nnts_temp(
	pmcq varchar2,
	pma_unt varchar2,
	pten_unt varchar2,
	pcbk_unt varchar2,
	pngay_unt varchar2,
	pma_nnt varchar2,
	pten_nnt varchar2,
	psac_thue varchar2,
	pchuong varchar2,
	ptieu_muc varchar2,
	pdia_ban varchar2,
	pkbnn varchar2,
	pkythue varchar2,
	ploaitk_nsnn varchar2,
	phan_nop varchar2,
	pmagiao_unt varchar2,
	ploai_tien varchar2,
	ptien_giao varchar2,
	ptien_con varchar2,
	ptien_thuduoc varchar2,
	ptien_quyettoan varchar2,
	pso_bl varchar2,
	pngay_bl varchar2,
	psobl_unt varchar2,
	pngaybl_unt varchar2,
	pngay_banke varchar2,
	psonha_ct varchar2,
	pmatinh_ct varchar2,
	ptentinh_ct varchar2,
	pmaquan_ct varchar2,
	ptenquan_ct varchar2,
	pmaxa_ct varchar2,
	ptenxa_ct varchar2,
	pmobile varchar2,
	pemail varchar2,
	psonha_tt varchar2,
	pmatinh_tt varchar2,
	ptentinh_tt varchar2,
	pmaquan_tt varchar2,
	ptenquan_tt varchar2,
	pmaxa_tt varchar2,
	ptenxa_tt varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nnts_temp|EDIT',pmcq||'|'||pma_unt||'|'||pten_unt||'|'||pcbk_unt||'|'||pngay_unt||'|'||pma_nnt||'|'||pten_nnt||'|'||psac_thue||'|'||pchuong||'|'||ptieu_muc||'|'||pdia_ban||'|'||pkbnn||'|'||pkythue||'|'||ploaitk_nsnn||'|'||phan_nop||'|'||pmagiao_unt||'|'||ploai_tien||'|'||ptien_giao||'|'||ptien_con||'|'||ptien_thuduoc||'|'||ptien_quyettoan||'|'||pso_bl||'|'||pngay_bl||'|'||psobl_unt||'|'||pngaybl_unt||'|'||pngay_banke||'|'||psonha_ct||'|'||pmatinh_ct||'|'||ptentinh_ct||'|'||pmaquan_ct||'|'||ptenquan_ct||'|'||pmaxa_ct||'|'||ptenxa_ct||'|'||pmobile||'|'||pemail||'|'||psonha_tt||'|'||pmatinh_tt||'|'||ptentinh_tt||'|'||pmaquan_tt||'|'||ptenquan_tt||'|'||pmaxa_tt||'|'||ptenxa_tt);
	s:='update tax.nnts_temp set  mcq=:mcq,ma_unt=:ma_unt,ten_unt=:ten_unt,cbk_unt=:cbk_unt,ngay_unt=:ngay_unt,ma_nnt=:ma_nnt,ten_nnt=:ten_nnt,sac_thue=:sac_thue,chuong=:chuong,tieu_muc=:tieu_muc,dia_ban=:dia_ban,kbnn=:kbnn,kythue=:kythue,loaitk_nsnn=:loaitk_nsnn,han_nop=:han_nop,magiao_unt=:magiao_unt,loai_tien=:loai_tien,tien_giao=:tien_giao,tien_con=:tien_con,tien_thuduoc=:tien_thuduoc,tien_quyettoan=:tien_quyettoan,so_bl=:so_bl,ngay_bl=:ngay_bl,sobl_unt=:sobl_unt,ngaybl_unt=:ngaybl_unt,ngay_banke=:ngay_banke,sonha_ct=:sonha_ct,matinh_ct=:matinh_ct,tentinh_ct=:tentinh_ct,maquan_ct=:maquan_ct,tenquan_ct=:tenquan_ct,maxa_ct=:maxa_ct,tenxa_ct=:tenxa_ct,mobile=:mobile,email=:email,sonha_tt=:sonha_tt,matinh_tt=:matinh_tt,tentinh_tt=:tentinh_tt,maquan_tt=:maquan_tt,tenquan_tt=:tenquan_tt,maxa_tt=:maxa_tt,tenxa_tt=:tenxa_tt where id=:id';
	execute immediate s using pmcq,pma_unt,pten_unt,pcbk_unt,pngay_unt,pma_nnt,pten_nnt,psac_thue,pchuong,ptieu_muc,pdia_ban,pkbnn,pkythue,ploaitk_nsnn,phan_nop,pmagiao_unt,ploai_tien,ptien_giao,ptien_con,ptien_thuduoc,ptien_quyettoan,pso_bl,pngay_bl,psobl_unt,pngaybl_unt,pngay_banke,psonha_ct,pmatinh_ct,ptentinh_ct,pmaquan_ct,ptenquan_ct,pmaxa_ct,ptenxa_ct,pmobile,pemail,psonha_tt,pmatinh_tt,ptentinh_tt,pmaquan_tt,ptenquan_tt,pmaxa_tt,ptenxa_tt,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_nnts_temp(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nnts_temp|DEL',pId);
	s:='delete from tax.nnts_temp where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;