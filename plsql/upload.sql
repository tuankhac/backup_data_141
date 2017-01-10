--------------------------------------------------------
--  File created - Tuesday-January-10-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "TAX"."UPLOAD" is

function search_nnts_uploads_temp(
  pfilter varchar2,
  plog_ip varchar2,--nhan biet user dang su dung
  pcurr_id varchar2,
  pRecordPerPage varchar2,
  pPageIndex varchar2
)
return sys_refcursor
is
  s varchar2(5000);
  ref_ sys_refcursor;
begin
    if (pfilter = 'true') then
        s:='select  mcq,ma_unt,ten_unt,cbk_unt,ngay_unt,ma_nnt,ten_nnt,sac_thue,chuong,tieu_muc,dia_ban,kbnn,kythue,loaitk_nsnn,
        han_nop,magiao_unt,loai_tien,tien_giao,tien_con,tien_thuduoc,tien_quyettoan,so_bl,ngay_bl,sobl_unt,ngaybl_unt,ngay_banke,
        sonha_ct,matinh_ct,tentinh_ct,maquan_ct,tenquan_ct,maxa_ct,tenxa_ct,mobile,email,sonha_tt,matinh_tt,tentinh_tt,maquan_tt,
        tenquan_tt,maxa_tt,tenxa_tt,ma_tinh,log_user,log_ip,log_date
        from tax.nnts_uploads_temp
        where ma_unt is not null and kythue is not null and log_ip='''||plog_ip||''' and id='''||pcurr_id||'''
        group by mcq,ma_unt,ten_unt,cbk_unt,ngay_unt,ma_nnt,ten_nnt,sac_thue,chuong,tieu_muc,dia_ban,kbnn,kythue,loaitk_nsnn,
        han_nop,magiao_unt,loai_tien,tien_giao,tien_con,tien_thuduoc,tien_quyettoan,so_bl,ngay_bl,sobl_unt,ngaybl_unt,ngay_banke,
        sonha_ct,matinh_ct,tentinh_ct,maquan_ct,tenquan_ct,maxa_ct,tenxa_ct,mobile,email,sonha_tt,matinh_tt,tentinh_tt,maquan_tt,
        tenquan_tt,maxa_tt,tenxa_tt,ma_tinh,log_user,log_ip,log_date';
    else
        s:='select mcq,ma_unt,ten_unt,cbk_unt,ngay_unt,ma_nnt,ten_nnt,sac_thue,chuong,tieu_muc,dia_ban,kbnn,kythue,loaitk_nsnn,
        han_nop,magiao_unt,loai_tien,tien_giao,tien_con,tien_thuduoc,tien_quyettoan,so_bl,ngay_bl,sobl_unt,ngaybl_unt,ngay_banke,
        sonha_ct,matinh_ct,tentinh_ct,maquan_ct,tenquan_ct,maxa_ct,tenxa_ct,mobile,email,sonha_tt,matinh_tt,tentinh_tt,maquan_tt,
        tenquan_tt,maxa_tt,tenxa_tt,id,ma_tinh,log_user,log_ip,log_date from tax.nnts_uploads_temp  where log_ip='''||plog_ip||'''
        and id='''||pcurr_id||'''';
    end if;
    if(pPageIndex=-1) then
        s:='select ceil(count(*)/:1) nop,count(1) nor from ('||s||')';
    open ref_ for s using  pRecordPerPage;
    elsif(pPageIndex=-2) then
        open ref_ for s;
    else
        open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    end if;
    return ref_;
    close ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function update_nnts_uploads(
  pfilter varchar2,
  plog_ip varchar2,
  pcurr_id varchar2
)
return varchar2
is
    s varchar2(5000);
    ref_ sys_refcursor;
    ref1_ sys_refcursor;
    ref2_ sys_refcursor;
    myRecord nnts_uploads_temp%ROWTYPE;
    ckn varchar2(100):= crud.ckn_hientai;
    l_date varchar2(20):= to_char(trunc(sysdate),'dd/mm/yyyy');
    l_kythue varchar2(20):= to_char(trunc(sysdate),'mmyyyy');
   -- l_kythue varchar2(20):= '102016';

    l_mst varchar2(20);
    l_agent varchar2(20);
begin
    /*if (pfilter = 'true') then
        s:='select mcq,ma_unt,ten_unt,cbk_unt,ngay_unt,ma_nnt,ten_nnt,sac_thue,chuong,tieu_muc,dia_ban,kbnn,kythue,loaitk_nsnn,han_nop,magiao_unt,loai_tien,tien_giao,tien_con,tien_thuduoc,tien_quyettoan,so_bl,ngay_bl,sobl_unt,ngaybl_unt,ngay_banke,sonha_ct,matinh_ct,tentinh_ct,maquan_ct,tenquan_ct,maxa_ct,tenxa_ct,mobile,email,sonha_tt,matinh_tt,tentinh_tt,maquan_tt,tenquan_tt,maxa_tt,tenxa_tt,id,ma_tinh,log_user,log_ip,log_date
        from tax.nnts_uploads_temp
        where ma_unt is not null and kythue is not null and log_ip='''||plog_ip||''' and id='''||pcurr_id||'''
        group by mcq,ma_unt,ten_unt,cbk_unt,ngay_unt,ma_nnt,ten_nnt,sac_thue,chuong,tieu_muc,dia_ban,kbnn,kythue,loaitk_nsnn,han_nop,magiao_unt,loai_tien,tien_giao,tien_con,tien_thuduoc,tien_quyettoan,so_bl,ngay_bl,sobl_unt,ngaybl_unt,ngay_banke,sonha_ct,matinh_ct,tentinh_ct,maquan_ct,tenquan_ct,maxa_ct,tenxa_ct,mobile,email,sonha_tt,matinh_tt,tentinh_tt,maquan_tt,tenquan_tt,maxa_tt,tenxa_tt,id,ma_tinh,log_user,log_ip,log_date';
    else
        s:='select mcq,ma_unt,ten_unt,cbk_unt,ngay_unt,ma_nnt,ten_nnt,sac_thue,chuong,tieu_muc,dia_ban,kbnn,kythue,loaitk_nsnn,han_nop,magiao_unt,loai_tien,tien_giao,tien_con,tien_thuduoc,tien_quyettoan,so_bl,ngay_bl,sobl_unt,ngaybl_unt,ngay_banke,sonha_ct,matinh_ct,tentinh_ct,maquan_ct,tenquan_ct,maxa_ct,tenxa_ct,mobile,email,sonha_tt,matinh_tt,tentinh_tt,maquan_tt,tenquan_tt,maxa_tt,tenxa_tt,id,ma_tinh,log_user,log_ip,log_date from tax.nnts_uploads_temp  where log_ip='''||plog_ip||''' and id='''||pcurr_id||'''';
    end if;*/

    s:='select mcq,ma_unt,ten_unt,cbk_unt,ngay_unt,trim(ma_nnt) ma_nnt,ten_nnt,sac_thue,chuong,tieu_muc,dia_ban,kbnn,kythue,loaitk_nsnn,han_nop,magiao_unt,loai_tien,replace(tien_giao,'','','''') tien_giao,replace(tien_con,'','','''') tien_con,replace(tien_thuduoc,'','','''') tien_thuduoc,replace(tien_quyettoan,'','','''') tien_quyettoan,so_bl,ngay_bl,sobl_unt,ngaybl_unt,ngay_banke,sonha_ct,matinh_ct,tentinh_ct,maquan_ct,tenquan_ct,maxa_ct,tenxa_ct,mobile,email,sonha_tt,matinh_tt,tentinh_tt,maquan_tt,tenquan_tt,maxa_tt,tenxa_tt,id,ma_tinh,log_user,log_ip,log_date from tax.nnts_uploads_temp  where log_ip='''||plog_ip||''' and id='''||pcurr_id||'''';
    open ref_ for s;
    loop fetch ref_ into myRecord;
    exit when ref_%notfound;
        s:='insert into tax.nnts_uploads(mcq,ma_unt,ten_unt,cbk_unt,ngay_unt,ma_nnt,ten_nnt,sac_thue,chuong,tieu_muc,dia_ban,kbnn,kythue,loaitk_nsnn,han_nop,magiao_unt,loai_tien,tien_giao,tien_con,tien_thuduoc,tien_quyettoan,so_bl,ngay_bl,sobl_unt,ngaybl_unt,ngay_banke,sonha_ct,matinh_ct,tentinh_ct,maquan_ct,tenquan_ct,maxa_ct,tenxa_ct,mobile,email,sonha_tt,matinh_tt,tentinh_tt,maquan_tt,tenquan_tt,maxa_tt,tenxa_tt,id,ma_tinh,log_user,log_ip,log_date)
        values (:mcq,:ma_unt,:ten_unt,:cbk_unt,:ngay_unt,:ma_nnt,:ten_nnt,:sac_thue,:chuong,:tieu_muc,:dia_ban,:kbnn,:kythue,:loaitk_nsnn,:han_nop,:magiao_unt,:loai_tien,:tien_giao,:tien_con,:tien_thuduoc,:tien_quyettoan,:so_bl,:ngay_bl,:sobl_unt,:ngaybl_unt,:ngay_banke,:sonha_ct,:matinh_ct,:tentinh_ct,:maquan_ct,:tenquan_ct,:maxa_ct,:tenxa_ct,:mobile,:email,:sonha_tt,:matinh_tt,:tentinh_tt,:maquan_tt,:tenquan_tt,:maxa_tt,:tenxa_tt,:id,:ma_tinh,:log_user,:log_ip,:log_date)';
        execute immediate s using myRecord.mcq,myRecord.ma_unt,myRecord.ten_unt,myRecord.cbk_unt,myRecord.ngay_unt,myRecord.ma_nnt,myRecord.ten_nnt,
        myRecord.sac_thue,myRecord.chuong,myRecord.tieu_muc,myRecord.dia_ban,myRecord.kbnn,myRecord.kythue,myRecord.loaitk_nsnn,myRecord.han_nop,
        myRecord.magiao_unt,myRecord.loai_tien,myRecord.tien_giao,myRecord.tien_con,myRecord.tien_thuduoc,myRecord.tien_quyettoan,myRecord.so_bl,
        myRecord.ngay_bl,myRecord.sobl_unt,myRecord.ngaybl_unt,myRecord.ngay_banke,myRecord.sonha_ct,myRecord.matinh_ct,myRecord.tentinh_ct,
        myRecord.maquan_ct,myRecord.tenquan_ct,myRecord.maxa_ct,myRecord.tenxa_ct,myRecord.mobile,myRecord.email,myRecord.sonha_tt,myRecord.matinh_tt,
        myRecord.tentinh_tt,myRecord.maquan_tt,myRecord.tenquan_tt,myRecord.maxa_tt,myRecord.tenxa_tt,myRecord.id,
        myRecord.ma_tinh,myRecord.log_user,myRecord.log_ip,myRecord.log_date;
    end loop;
    close ref_;

    --lay thong tin tinh thuc hien
    execute immediate 'select ma_tinh from nnts_uploads where id =:1 and rownum=1' into l_agent using pcurr_id;

    --cap nhat du lieu danh ba thue
    /*s:='select distinct a.ma_nnt from nnts_uploads a where a.id =:1
                and not exists (select 1 from nnts_'||ckn||' b where a.ma_nnt=b.mst and b.ma_tinh=a.ma_tinh and b.ma_cqt_ql = a.mcq)
                and magiao_unt is not null';*/
    s:='select distinct a.ma_nnt from nnts_uploads a where a.id =:1
                and not exists (select 1 from nnts_'||ckn||' b where a.ma_nnt=b.mst and b.ma_tinh=a.ma_tinh and b.ma_cqt_ql = a.mcq)
                ';
    open ref1_ for s using pcurr_id;
    loop fetch ref1_ into l_mst;
    exit when ref1_%notfound;
    begin
        s:=' Insert into nnts_'||ckn||'(mst, ten_nnt, so, ma_cqt_ql, mota_diachi, ma_tinh,
                ma_huyen, ma_xa, so_nha, diachi_tt, ma_tinh_tt,
                ma_huyen_tt, ma_xa_tt, so_nha_tt, mobile, email,
                ma_nv, ma_t, ma_unt, ten_unt, cbk_unt, ngay_unt,
                dia_ban, kbnn, so_bl, ngay_bl, sobl_unt, ngaybl_unt,
                ngay_banke, loai_dl, nguoi_cn, ip_cn, id)

            select distinct trim(ma_nnt) ma_nnt,ten_nnt,null so_gt,mcq,sonha_ct||'' ''||TENXA_CT||'' ''||tenquan_ct||'' ''||tentinh_ct diachi_ct,
                 (select ma_dbhc from dbhcs a where a.ma_dbhc_thue = round(matinh_ct)) matinh_ct,
                 (select ma_dbhc from dbhcs a where a.ma_dbhc_thue = round(maquan_ct)) maquan_ct,
                 round(maxa_ct),sonha_ct,sonha_tt||'' ''||tenxa_tt||'' ''||tenquan_tt||'' ''||tentinh_tt diachi_tt,
                 (select ma_dbhc from dbhcs a where a.ma_dbhc_thue = round(matinh_tt)) matinh_tt,
                 (select ma_dbhc from dbhcs a where a.ma_dbhc_thue = round(maquan_tt)) maquan_tt,round(maxa_tt),sonha_tt,
                 mobile,substr(trim(email),1,20),null ma_nv,null ma_t,ma_unt,ten_unt, cbk_unt, ngay_unt,
                 dia_ban,kbnn,so_bl,ngay_bl,(select id_c from config_contract where agent_c = a.ma_tinh and id_ref = a.mcq and rownum=1) sobl_unt,
                 (select date_c from config_contract where agent_c = a.ma_tinh and rownum=1) ngaybl_unt,:1 ngay_banke,0 loai_dl,
                 ''CONVERT'' nguoi_cn, ''127.0.0.1'' ip_cn, id
              from tax.nnts_uploads a
              where a.id =:2 and a.ma_nnt =:3
              and not exists (select 1 from nnts_'||ckn||' b where a.ma_nnt=b.mst and b.ma_tinh=a.ma_tinh and b.ma_cqt_ql = a.mcq) and rownum=1';
        execute immediate s using l_date,pcurr_id,l_mst;
        exception when others then
        return TO_CHAR(SQLCODE)||': '||SQLERRM;
    end;
    end loop;
    close ref1_;

    --Cap nhat du lieu thay doi dia chi
    s:='select distinct a.ma_nnt from nnts_uploads a where a.id =:1
                and exists (select 1 from nnts_'||ckn||' b where a.ma_nnt=b.mst and b.ma_tinh=a.ma_tinh
                            and b.ma_cqt_ql = a.mcq
                            and (trim(a.sonha_ct) <> trim(b.so_nha) or round(a.maxa_ct) <> b.ma_xa ))';
    open ref2_ for s using pcurr_id;
    loop fetch ref2_ into l_mst;
    exit when ref2_%notfound;
        begin
            execute immediate' DELETE from nnts_'||ckn||' a where mst =:1 and rownum=1' using l_mst;

            s:=' Insert into nnts_'||ckn||'(mst, ten_nnt, so, ma_cqt_ql, mota_diachi, ma_tinh,
                ma_huyen, ma_xa, so_nha, diachi_tt, ma_tinh_tt,
                ma_huyen_tt, ma_xa_tt, so_nha_tt, mobile, email,
                ma_nv, ma_t, ma_unt, ten_unt, cbk_unt, ngay_unt,
                dia_ban, kbnn, so_bl, ngay_bl, sobl_unt, ngaybl_unt,
                ngay_banke, loai_dl, nguoi_cn, ip_cn, id)

            select distinct ma_nnt,ten_nnt,null so_gt,mcq,sonha_ct||'' ''||TENXA_CT||'' ''||tenquan_ct||'' ''||tentinh_ct diachi_ct,
                 (select ma_dbhc from dbhcs a where a.ma_dbhc_thue = round(matinh_ct)) matinh_ct,
                 (select ma_dbhc from dbhcs a where a.ma_dbhc_thue = round(maquan_ct)) maquan_ct,
                 round(maxa_ct),sonha_ct,sonha_tt||'' ''||tenxa_tt||'' ''||tenquan_tt||'' ''||tentinh_tt diachi_tt,
                 (select ma_dbhc from dbhcs a where a.ma_dbhc_thue = round(matinh_tt)) matinh_tt,
                 (select ma_dbhc from dbhcs a where a.ma_dbhc_thue = round(maquan_tt)) maquan_tt,round(maxa_tt),sonha_tt,
                 mobile,email,null ma_nv,null ma_t,ma_unt,ten_unt, cbk_unt, ngay_unt,
                 dia_ban,kbnn,so_bl,ngay_bl,(select id_c from config_contract where agent_c = a.ma_tinh and id_ref = a.mcq and rownum=1) sobl_unt,
                 (select date_c from config_contract where agent_c = a.ma_tinh and rownum=1) ngaybl_unt,:1 ngay_banke,0 loai_dl,
                 ''CONVERT'' nguoi_cn, ''127.0.0.1'' ip_cn, id
              from tax.nnts_uploads a
              where a.id =:2 and a.ma_nnt =:3
              and not exists (select 1 from nnts_'||ckn||' b where a.ma_nnt=b.mst and b.ma_tinh=a.ma_tinh and b.ma_cqt_ql = a.mcq) and rownum=1';
            execute immediate s using l_date,pcurr_id,l_mst;

            exception when others then
            return TO_CHAR(SQLCODE)||': '||SQLERRM;
        end;
    end loop;
    close ref2_;


    --Cap nhat du lieu tieu muc thu thue
    if (l_agent ='79TTT') then
        --group du le thu truoc nam hien tai theo tieu muc
        begin
            s:='Insert into ct_no_'||ckn||'(mst, ma_tinh, no_cuoi_ky, kieu_no, ma_chuong,
                ma_tmuc, kythue, so_taikhoan_co, so_qdinh, ngay_qdinh,
                loai_tien, ti_gia, loai_thue, ma_cq_thu, han_nop,
                magiao_unt, chuky, sobk_unt, ngaybk_unt, nguoi_cn,ip_cn, id)

                select max(ma_nnt), (select ma_dbhc from dbhcs a where a.ma_dbhc_thue = round(matinh_ct)) matinh_ct,sum(round(tien_giao)),1 kieu_no,
                max(chuong),max(tieu_muc),max(:1) kythue,max(loaitk_nsnn),null so_qdinh, null ngay_qdinh,
                max(loai_tien), null ti_gia,max(sac_thue) loai_thue, max(mcq), max(han_nop), max(magiao_unt),max(nvl(kythue,''0000'')), max(cbk_unt), max(ngay_unt),
                ''CONVERT'' nguoi_cn, ''127.0.0.1'' ip_cn, max(id) id
                from tax.nnts_uploads a where a.id =:2 and a.tien_giao is not null
                and exists (select 1 from nnts_'||ckn||'  b where a.ma_nnt=b.mst and b.ma_tinh=a.ma_tinh)
                and not exists (select 1 from ct_no_'||ckn||' c where a.ma_nnt=c.mst and a.tieu_muc=c.ma_tmuc
                            and c.chuky=a.kythue and c.kythue =:3 and c.ma_tinh=a.ma_tinh and a.id=c.id)
                and to_number(substr(nvl(kythue,''0000''),1,2)) < to_number(to_char(sysdate,''yy''))
                group by a.ma_nnt,a.tieu_muc,a.matinh_ct';
            execute immediate s using l_kythue,pcurr_id,l_kythue;
            exception when others then
            return TO_CHAR(SQLCODE)||': '||SQLERRM;
        end;

        --insert du lieu thu nam hien tai theo tieu muc
        begin
            s:='Insert into ct_no_'||ckn||'(mst, ma_tinh, no_cuoi_ky, kieu_no, ma_chuong,
                ma_tmuc, kythue, so_taikhoan_co, so_qdinh, ngay_qdinh,
                loai_tien, ti_gia, loai_thue, ma_cq_thu, han_nop,
                magiao_unt, chuky, sobk_unt, ngaybk_unt, nguoi_cn,ip_cn, id)

                select max(ma_nnt), (select ma_dbhc from dbhcs a where a.ma_dbhc_thue = round(matinh_ct)) matinh_ct,sum(round(tien_giao)),1 kieu_no,
                max(chuong),max(tieu_muc),max(:1) kythue,max(loaitk_nsnn),null so_qdinh, null ngay_qdinh,
                max(loai_tien), null ti_gia,max(sac_thue) loai_thue, max(mcq), max(han_nop), max(magiao_unt),max(nvl(kythue,''0000'')), max(cbk_unt), max(ngay_unt),
                ''CONVERT'' nguoi_cn, ''127.0.0.1'' ip_cn, max(id) id
                from tax.nnts_uploads a where a.id =:2 and a.tien_giao is not null
                and exists (select 1 from nnts_'||ckn||'  b where a.ma_nnt=b.mst and b.ma_tinh=a.ma_tinh)
                and not exists (select 1 from ct_no_'||ckn||' c where a.ma_nnt=c.mst and a.tieu_muc=c.ma_tmuc
                            and c.chuky=a.kythue and c.kythue =:3 and c.ma_tinh=a.ma_tinh and a.id=c.id)
                and to_number(substr(nvl(kythue,''0000''),1,2)) >= to_number(to_char(sysdate,''yy''))
                group by a.ma_nnt,a.tieu_muc,kythue,a.matinh_ct';
            execute immediate s using l_kythue,pcurr_id,l_kythue;
            exception when others then
            return TO_CHAR(SQLCODE)||': '||SQLERRM;
        end;
        --update lai so unt
        s:='update tax.ct_no_2016 a SET (a.han_nop, a.sobk_unt,a.ngaybk_unt) = (SELECT c.han_nop,c.cbk_unt,c.ngay_unt FROM tax.nnts_uploads c
        WHERE a.id=c.id AND a.mst=c.ma_nnt AND a.ma_tmuc=c.tieu_muc AND a.chuky=c.kythue AND a.magiao_unt=c.magiao_unt AND rownum=1)
        WHERE id=:1 AND EXISTS(SELECT 1 FROM tax.nnts_uploads b
        WHERE a.id=b.id AND a.mst=b.ma_nnt AND a.ma_tmuc=b.tieu_muc AND a.chuky=b.kythue AND a.magiao_unt=b.magiao_unt AND a.sobk_unt <>b.cbk_unt)';
        execute immediate s USING pcurr_id;

    else
        begin
            s:='Insert into ct_no_'||ckn||'(mst, ma_tinh, no_cuoi_ky, kieu_no, ma_chuong,
                ma_tmuc, kythue, so_taikhoan_co, so_qdinh, ngay_qdinh,
                loai_tien, ti_gia, loai_thue, ma_cq_thu, han_nop,
                magiao_unt, chuky, sobk_unt, ngaybk_unt, nguoi_cn,ip_cn, id)

                select max(ma_nnt), (select ma_dbhc from dbhcs a where a.ma_dbhc_thue = round(matinh_ct)) matinh_ct,sum(round(tien_giao)),1 kieu_no,
                max(chuong),max(to_number(tieu_muc)),max(:1) kythue,max(loaitk_nsnn),null so_qdinh, null ngay_qdinh,
                max(loai_tien), null ti_gia,max(sac_thue) loai_thue, max(mcq), max(han_nop), max(magiao_unt),max(nvl(kythue,''0000'')), max(cbk_unt), max(ngay_unt),
                ''CONVERT'' nguoi_cn, ''127.0.0.1'' ip_cn, max(id) id
                from tax.nnts_uploads a where a.id =:2 and a.tien_giao is not null
                and exists (select 1 from nnts_'||ckn||'  b where a.ma_nnt=b.mst and b.ma_tinh=a.ma_tinh)
                and not exists (select 1 from ct_no_'||ckn||' c where a.ma_nnt=c.mst and a.tieu_muc=c.ma_tmuc
                            and c.chuky=a.kythue and c.kythue =:3 and c.ma_tinh=a.ma_tinh and a.id=c.id)
                group by a.ma_nnt,a.tieu_muc,a.matinh_ct';
            execute immediate s using l_kythue,pcurr_id,l_kythue;
            exception when others then
            return TO_CHAR(SQLCODE)||': '||SQLERRM;
        end;
    end if;

    --map thong tin chu ky thue
    map_kythue;

    --update data cus
    execute immediate 'insert into cus_bill(mst,ma_cqt_ql,ma_tinh,kythue,id)
        select a.mst,a.ma_cqt_ql,a.ma_tinh,:1,a.id from tax.nnts_2016 a where a.id = :2
        and not exists (select 1 from cus_bill c where a.mst=c.mst and a.ma_cqt_ql= c.ma_cqt_ql and c.trang_thai=1) '
        using l_kythue,pcurr_id;
    commit;

    return '1';
    exception when others then
        declare err varchar2(500); begin   err:='Loi thuc hien, ma loi:'||to_char(sqlerrm)||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; return err;
    end;
end;
function insert_uploads_thanhtoan_hcm(
    pfilter varchar2,
    plog_user varchar2,
    plog_ip varchar2,--nhan biet user dang su dung
    pcurr_id varchar2
)
return varchar2
is
    s varchar2(5000);
    ckn varchar2(100):= crud.ckn_hientai();
begin
    s:='insert into tax.thanhtoan_upload (id,ma_cqt,ma_goi_tin,ma_kho_bac,ngay_kho_bac,mst,ten_nnt,diachi_nnt,so_qd,so_lenh_hoan,ngay_lenh_hoan,
        mcq,tk_no,tk_co,tien_te,ty_gia,so_chung_tu,nien_do,chuong,khoan,tieu_muc,ky_thue,so_tien,log_user,log_ip, upload_id)

    select util.getseq(''UPLOADS_THANHTOAN_SEQ''),a.ma_cqt,a.ma_goi_tin,a.ma_kho_bac,a.ngay_kho_bac,a.mst,a.ten_nnt,a.diachi_nnt,a.so_qd,a.so_lenh_hoan,a.ngay_lenh_hoan,a.mcq,
    a.tk_no,a.tk_co,a.tien_te,a.ty_gia,a.so_chung_tu,a.nien_do,a.chuong,a.khoan,a.tieu_muc,a.ky_thue,a.so_tien,a.log_user,a.log_ip,a.upload_id from (';
    s:=s||'select a.ma_cqt,a.ma_goi_tin,a.ma_kho_bac,ngay_kho_bac,a.mst,a.ten_nnt,a.diachi_nnt,a.so_qd,a.so_lenh_hoan,a.ngay_lenh_hoan,a.mcq,
    a.tk_no,a.tk_co,a.tien_te,a.ty_gia,a.so_chung_tu,a.nien_do,a.chuong,a.khoan,a.tieu_muc,a.ky_thue,a.so_tien,a.log_user,a.log_ip,a.upload_id,a.rc_dupp from
    (select a.ma_cqt,a.ma_goi_tin,a.ma_kho_bac,a.ngay_kho_bac,a.mst,a.ten_nnt,a.diachi_nnt,a.so_qd,a.so_lenh_hoan,a.ngay_lenh_hoan,a.mcq,
    a.tk_no,a.tk_co,a.tien_te,a.ty_gia,a.so_chung_tu,a.nien_do,a.chuong,a.khoan,a.tieu_muc,a.ky_thue,a.so_tien,a.log_user,a.log_ip,a.upload_id,
    count(*) over (partition by a.mst,a.tieu_muc,a.ky_thue  order by a.mst,a.tieu_muc,a.ky_thue) rc_dupp
    from tax.thanhtoan_upload_temp a
    where (a.mst is not null and a.ky_thue is not null and a.tieu_muc is not null)
    and a.log_user='''||plog_user||''' and log_ip='''||plog_ip||''' and upload_id='''||pcurr_id||'''
    and (select count(*) from tax.nnts_'||ckn||' b where b.mst = a.mst and b.ma_cqt_ql = a.mcq) > 0 ) a';

    if (pfilter = 'FILTED') then
        s:=s||'  where rc_dupp=1  order by a.ma_cqt) a';
    elsif (pfilter = 'NOT_VALID') then
        s:=s||' where rc_dupp>1
        union all
        select a.ma_cqt,a.ma_goi_tin,a.ma_kho_bac,a.ngay_kho_bac,a.mst,a.ten_nnt,a.diachi_nnt,a.so_qd,a.so_lenh_hoan,a.ngay_lenh_hoan,a.mcq,
        a.tk_no,a.tk_co,a.tien_te,a.ty_gia,a.so_chung_tu,a.nien_do,a.chuong,a.khoan,a.tieu_muc,a.ky_thue,a.so_tien,
        a.log_user,a.log_ip,a.upload_id,
        count(*) over (partition by a.mst,a.tieu_muc,a.ky_thue  order by a.mst,a.tieu_muc,a.ky_thue) rc_dupp
        from tax.thanhtoan_upload_temp a
        where (a.mst is null or a.ky_thue is   null or a.tieu_muc is   null)
        and a.log_user='''||plog_user||''' and log_ip='''||plog_ip||''' and upload_id='''||pcurr_id||'''
        and (select count(*) from tax.nnts_'||ckn||' b where b.mst = a.mst and b.ma_cqt_ql = a.mcq) > 0 ) a';

    else
        s:='insert into tax.thanhtoan_upload (id,ma_cqt,ma_goi_tin,ma_kho_bac,ngay_kho_bac,mst,ten_nnt,diachi_nnt,so_qd,so_lenh_hoan,ngay_lenh_hoan,
        mcq,tk_no,tk_co,tien_te,ty_gia,so_chung_tu,nien_do,chuong,khoan,tieu_muc,ky_thue,so_tien,log_user,log_ip, upload_id)
        select util.getseq(''UPLOADS_THANHTOAN_SEQ''),ma_cqt,ma_goi_tin,ma_kho_bac,ngay_kho_bac,mst,ten_nnt,diachi_nnt,so_qd,so_lenh_hoan,ngay_lenh_hoan,
        mcq,tk_no,tk_co,tien_te,ty_gia,so_chung_tu,nien_do,chuong,khoan,tieu_muc,ky_thue,so_tien,log_user,log_ip, upload_id
        from tax.thanhtoan_upload_temp   where  log_user='''||plog_user||''' and log_ip='''||plog_ip||'''
        and upload_id='''||pcurr_id||''' order by  ma_cqt  ';
    end if;
    execute immediate s;
    commit;

    --thuc hien thanh toan theo tieu chi: MST, MA_TMUC, KYTHUE, CHUKY
    s:= thanhtoan_cct(i_upload =>pcurr_id);

    --thuc hien thanh toan theo tieu chi: MST, MA_TMUC
    s:= thanhtoan_cct_null_hcm(i_upload =>pcurr_id);

    return '1';
    exception when others then
        declare err varchar2(500); begin   err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function thanhtoan_cct_null_hcm(i_upload varchar2) return varchar2
is
    l_res varchar2(1000);
    l_tra varchar2(1000);
    l_user_tt varchar2(100):='system';
    l_matinh varchar2(10);
    l_mabc varchar2(10);
    l_quaythu varchar2(10);
    l_hinthuctt varchar2(5):='6';
    l_count number:=0;
    i_no number:=0;
    l_tientt number;
    ref_ sys_refcursor;
    s varchar2(32000);
    ckn varchar2(100):=crud.ckn_hientai();
    l_mst varchar2(20);
    l_sid number;
    l_mcq varchar2(20);
    l_tientra number;
    l_ngaytt date;
    l_sngaytt varchar2(50);
    l_tieumuc number;
    l_chuky varchar2(20);
    l_kythue varchar2(20);
    l_so_ct varchar2(50);
    l_id number;
    l_payment number:=0;
    l_sql VARCHAR2(1000);
begin
-- thanh toan no ton tai trong ct no, va chua tra
    s:='select b.mst,b.id,b.mcq,round(b.so_tien) tientra,to_char(b.ngay_kho_bac,''dd/mm/yyyy'') ngay_tt,b.tieu_muc,b.ky_thue,b.so_chung_tu,
            (select id_payment from tax.config_contract where id_ref = b.mcq and rownum=1) nguoi_tt
              from tax.thanhtoan_upload b
              where b.upload_id =:1 and b.trang_thai=0
              and b.ky_thue is null
              and EXISTS (select 1 from tax.ct_no_'||ckn||' a where b.mst=a.mst and a.ma_tmuc=b.tieu_muc and a.kythue in (select id from chukynos where is_payment=1))';
    open ref_ for s using i_upload;
        loop fetch ref_ into l_mst,l_sid,l_mcq,l_tientra,l_sngaytt,l_tieumuc,l_chuky,l_so_ct,l_user_tt;
        exit when ref_%notfound;
        begin
            l_sql:='select sum(tien_no) tien_no from (select sum(a.no_cuoi_ky) tien_no from tax.ct_no_'||ckn||' a where a.mst =:1 and a.ma_cq_thu=:2 and a.ma_tmuc=:3
            union all select - sum(b.tientra) tien_no from tax.ct_tra_'||ckn||' b where b.mst =:1 and b.ma_cq_thu=:2 and b.ma_tmuc=:3)';
            EXECUTE IMMEDIATE l_sql into l_count using l_mst,l_mcq,l_tieumuc,l_mst,l_mcq,l_tieumuc;
            if l_count > 0 then --neu tieu muc con no, thuc hien gach no tu ky thue gan nhat
                l_res:=gach_no_tieumuc(i_tiengach=>l_tientra, i_mst=>l_mst, i_tieumuc=>l_tieumuc, i_ma_cqt=>l_mcq, i_nguoigach=>l_user_tt, i_uploadid=>i_upload, i_idnumber=>l_sid, i_sochungtu=>l_so_ct, i_ngay_tt=>l_sngaytt);

            end if;
        end;

    end loop ;
    commit;
    return '1';
    exception when others then
        declare err varchar2(500);
        begin   err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
            return err;
        end;
end;
function gach_no_tieumuc(i_tiengach number,
                         i_mst VARCHAR2,
                         i_tieumuc VARCHAR2,
                         i_ma_cqt VARCHAR2,
                         i_nguoigach VARCHAR2,
                         i_uploadid NUMBER,
                         i_idnumber number,
                         i_sochungtu VARCHAR2,
                         i_ngay_tt VARCHAR2) return VARCHAR2
is
l_sql varchar2(1000);
s varchar2(1000);
l_no number:=0;
l_tiengach number:=i_tiengach;
c_cur sys_refcursor;
l_mst varchar2(100);
l_ma_cq_thu varchar2(20);
l_ma_tmuc VARCHAR2(20);
l_kythue VARCHAR2(20);
l_chuky varchar(20);
l_ma_tinh varchar(20);
l_id varchar(20);
l_tientra number;
ckn varchar2(100):=crud.ckn_hientai();
l_tra VARCHAR2(1000);
l_mabc varchar(20);
l_quaythu varchar(50);
l_res VARCHAR2(50);
l_hinthuctt varchar2(5):='6';
begin
    l_sql:='select mst, ma_cq_thu, ma_tmuc, kythue,chuky,id,ma_tinh
      from tax.ct_no_'||ckn||' where mst=:1 and ma_cq_thu=:2 and ma_tmuc=:3
      order by to_date(kythue,''MMYYYY'') desc ,chuky desc';
    open c_cur for l_sql using i_mst,i_ma_cqt,i_tieumuc;
    loop
    fetch c_cur into l_mst,l_ma_cq_thu,l_ma_tmuc,l_kythue,l_chuky,l_id,l_ma_tinh;
    EXIT when c_cur%notfound;
    if l_tiengach <=0 then exit; end if;
     l_no := tax.check_no_chuky_2(l_mst, l_kythue, l_chuky,l_ma_tmuc,l_ma_cq_thu);
     if ((l_no >0) and (l_tiengach >=0)) then
         if  l_no >= l_tiengach  then
            l_tientra:=l_tiengach;
            l_tiengach:=0;
         else
            l_tientra:=l_no;
            l_tiengach:= l_tiengach - l_no;
         end if;
            begin
                s:='select MST||'',''||KYTHUE||'',''||MA_TINH||'','||l_tientra||',''||MA_CHUONG||'',''||MA_CQ_THU||'',''||MA_TMUC||'',''||SO_TAIKHOAN_CO||'',''||SO_QDINH||'',''||NGAY_QDINH||'',''||LOAI_TIEN||'',''||TI_GIA||'',''||LOAI_THUE||'',''||CHUKY
                 from ct_no_'||ckn||'  where mst=:1 and ma_tmuc=:2 and kythue=:3 and chuky=:4
                 and id=:5 and ma_cq_thu=:6 and rownum<2';
                execute immediate s into l_tra using l_mst,l_ma_tmuc,l_kythue,l_chuky,l_id,l_ma_cq_thu;

                select ma_tinh,mabc_id,quaythu_id into l_ma_tinh,l_mabc,l_quaythu from nguoigachnos where id =i_nguoigach and rownum=1;

                l_res := tax.crud.thanh_toan(pmst=> l_mst,
                                        pma_tinh=> l_ma_tinh,
                                        pma_bc=> l_mabc,
                                        phttt=> l_hinthuctt,
                                        pnguoigachno=> nvl(i_nguoigach,'system'),
                                        pngay_tt=> i_ngay_tt,
                                        pquaythu=> l_quaythu,
                                        ptra=> l_tra);

                insert into tax.thanhtoan_upload_null (mst,ma_cq_thu,ma_tinh,upload_id,thanhtoan_id,phieu_id,tien_tt)
                values(l_mst,l_ma_cq_thu,l_ma_tinh,i_uploadid,i_idnumber,l_res,l_tientra);

                exception when others then
                    return to_char(sqlerrm);

            end;
      end if;
    end loop;
    --cap nhat trang thai thanh toan
     update thanhtoan_upload set trang_thai=2, ngay_tt = sysdate, tien_tt = (i_tiengach - l_tiengach)
     where upload_id = i_uploadid and id =i_idnumber
     and trim(mst)=l_mst and trang_thai=0 and so_chung_tu= i_sochungtu
     and tieu_muc=i_tieumuc;
     commit;
     return '1';
     EXCEPTION when others then
     return 'ERR:'||SQLERRM;

end;
function thanhtoan_cct_null_hcm_bk(i_upload varchar2) return varchar2
is
    l_res varchar2(1000);
    l_tra varchar2(1000);
    l_user_tt varchar2(100):='system';
    l_matinh varchar2(10);
    l_mabc varchar2(10);
    l_quaythu varchar2(10);
    l_hinthuctt varchar2(5):='6';
    l_count number:=0;
    i_no number:=0;
    l_tientt number;
    ref_ sys_refcursor;
    s varchar2(32000);
    ckn varchar2(100):=crud.ckn_hientai();
    l_mst varchar2(20);
    l_sid number;
    l_mcq varchar2(20);
    l_tientra number;
    l_ngaytt date;
    l_sngaytt varchar2(50);
    l_tieumuc number;
    l_chuky varchar2(20);
    l_kythue varchar2(20);
    l_so_ct varchar2(50);
    l_id number;
    l_payment number:=0;
begin
-- thanh toan no ton tai trong ct no, va chua tra
    s:='select a.mst,a.id,a.ma_cq_thu,round(b.so_tien) tientra,to_char(b.ngay_kho_bac,''dd/mm/yyyy'') ngay_tt,b.tieu_muc,a.chuky,a.kythue,b.id,b.so_chung_tu,
            (select id_payment from config_contract where id_ref = b.mcq and rownum=1) nguoi_tt
              from ct_no_'||ckn||' a,thanhtoan_upload b
              where a.mst=trim(b.mst) and b.upload_id =:1  and b.trang_thai=0
              and a.ma_tmuc =b.tieu_muc and b.ky_thue is null
              and a.kythue in (select id from chukynos where is_payment=1)
              and not exists (select 1 from ct_tra_'||ckn||' c where a.mst=c.mst and a.ma_tmuc=c.ma_tmuc and c.kythue=a.kythue)
              order by to_date(a.kythue,''mmyyyy'')desc, chuky desc';
    open ref_ for s using i_upload;
        loop fetch ref_ into l_mst,l_sid,l_mcq,l_tientra,l_sngaytt,l_tieumuc,l_chuky,l_kythue,l_id,l_so_ct,l_user_tt;
        exit when ref_%notfound;

        begin
            select count(1) into l_payment from thanhtoan_upload where upload_id = i_upload and id = l_id and trang_thai=0;
            if l_payment >0 then
            i_no := tax.check_no_chuky(I_TAXCODE=> l_mst, I_KYTHUE=> l_kythue, I_CHUKY=> l_chuky, I_TIEUMUC=> l_tieumuc);
            if ((i_no >0) /*and (i_no = l_tientra)*/) then
                begin
                    s:='select MST||'',''||KYTHUE||'',''||MA_TINH||'','||l_tientra||',''||MA_CHUONG||'',''||MA_CQ_THU||'',''||MA_TMUC||'',''||SO_TAIKHOAN_CO||'',''||SO_QDINH||'',''||NGAY_QDINH||'',''||LOAI_TIEN||'',''||TI_GIA||'',''||LOAI_THUE||'',''||CHUKY
                     from ct_no_'||ckn||'  where mst=:1 and ma_tmuc=:2 and kythue=:3 and chuky=:4
                     and id=:5 and ma_cq_thu=:6 and rownum<2';
                    execute immediate s into l_tra using l_mst,l_tieumuc,l_kythue,l_chuky,l_sid,l_mcq;

                    select ma_tinh,mabc_id,quaythu_id into l_matinh,l_mabc,l_quaythu from nguoigachnos where id =l_user_tt and rownum=1;

                    l_res := tax.crud.thanh_toan(pmst=> l_mst,
                                            pma_tinh=> l_matinh,
                                            pma_bc=> l_mabc,
                                            phttt=> l_hinthuctt,
                                            pnguoigachno=> nvl(l_user_tt,'system'),
                                            pngay_tt=> l_sngaytt,
                                            pquaythu=> l_quaythu,
                                            ptra=> l_tra);

                    --cap nhat trang thai thanh toan
                     update thanhtoan_upload set trang_thai=2, ngay_tt = sysdate, tien_tt = l_tientra
                    where upload_id = i_upload and id =l_id
                    and trim(mst)=l_mst and trang_thai=0 and so_chung_tu= l_so_ct
                    and tieu_muc=l_tieumuc;
                    commit;

                    exception when others then
                        return to_char(sqlerrm);
                end;
            end if;
            end if;
        end;

    end loop ;
    commit;
    -- gach no khong ton tai, ky thue khong ton tai
    s:='select a.mst,a.ma_cqt_ql,round(b.so_tien) tientra,to_char(b.ngay_kho_bac,''dd/mm/yyyy'') ngay_tt,b.tieu_muc,b.ky_thue,to_char(sysdate,''mmyyyy''),b.id,b.so_chung_tu,
            (select id_payment from config_contract where id_ref = b.mcq and rownum=1) nguoi_tt
              from tax.nnts_'||ckn||' a,tax.thanhtoan_upload b
              where a.mst=trim(b.mst) and b.upload_id =:1  and b.trang_thai=0 and b.ky_thue is not null';
    open ref_ for s using i_upload;
        loop fetch ref_ into l_mst,l_mcq,l_tientra,l_sngaytt,l_tieumuc,l_chuky,l_kythue,l_id,l_so_ct,l_user_tt;
        exit when ref_%notfound;
        begin
            select count(1) into l_payment from thanhtoan_upload where upload_id = i_upload and id = l_id and trang_thai=0;
            if l_payment >0 then

                begin
                    select ma_tinh,mabc_id,quaythu_id into l_matinh,l_mabc,l_quaythu from nguoigachnos where id =l_user_tt and rownum=1;

                    l_res := tax.crud.thanh_toan(pmst=> l_mst,
                                            pma_tinh=> l_matinh,
                                            pma_bc=> l_mabc,
                                            phttt=> l_hinthuctt,
                                            pnguoigachno=> nvl(l_user_tt,'system'),
                                            pngay_tt=> l_sngaytt,
                                            pquaythu=> l_quaythu,
                                            ptra=> l_tra);

                    --cap nhat trang thai thanh toan
                    update thanhtoan_upload set trang_thai=3, ngay_tt = sysdate, tien_tt = l_tientra
                    where upload_id = i_upload and id =l_id
                    and trim(mst)=l_mst and trang_thai=0 and so_chung_tu= l_so_ct
                    and tieu_muc=l_tieumuc;
                    commit;

                    exception when others then
                        return to_char(sqlerrm);
                end;
            end if;

        end;

    end loop ;

    commit;
    return '1';
    exception when others then
        declare err varchar2(500);
        begin   err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
            return err;
        end;
end;
procedure map_kythue
is
    ckn varchar2(100):= crud.ckn_hientai;
    l_ky varchar2(50);
begin
    execute immediate 'insert into tax.ck_thue(chuky)
                        select distinct chuky from ct_no_'||ckn||' a
                            where not exists (select 1 from ck_thue b where a.chuky=b.chuky)';

    for j in (select * from tax.ck_thue where ky is null and chuky<>'0000') loop
        begin
            if substr(j.chuky,-2)='CN' then
                l_ky := '20'||substr(j.chuky,1,2);
            else
                l_ky := substr(j.chuky,-2)||'/20'||substr(j.chuky,1,2);
            end if;

            update tax.ck_thue set ky =l_ky where chuky=j.chuky and ky is null;
            commit;
        end;
    end loop;
end;

function info_nnts_uploads(
    plog_ip varchar2,--nhan biet user dang su dung
    pcurr_id varchar2
)
return sys_refcursor
is
    s varchar2(2000);
    ref_ sys_refcursor;
begin
    s:='select max(id) luot_tai, count(distinct ma_nnt) so_mst, sum(round(replace(tien_giao,'','',''''))) tien_con from tax.nnts_uploads_temp
        where ma_unt is not null and log_ip='''||plog_ip||''' and id='''||pcurr_id||''' ';
    open ref_ for s;
    return ref_;
    close ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;



function search_uploads_thanhtoan_temp(
    pfilted varchar2,
    plog_user varchar2,
    plog_ip varchar2,--nhan biet user dang su dung
    pcurr_id varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2
)
return sys_refcursor
is
    s varchar2(5000);
    ref_ sys_refcursor;
    ckn varchar2(100):= crud.ckn_hientai();
 begin

    s:='select a.* from
        (select a.ma_cqt,a.ma_goi_tin,a.ma_kho_bac,a.ngay_kho_bac,a.mst,a.ten_nnt,a.diachi_nnt,a.so_qd,a.so_lenh_hoan,a.ngay_lenh_hoan,a.mcq,
        a.tk_no,a.tk_co,a.tien_te,a.ty_gia,a.so_chung_tu,a.nien_do,a.chuong,a.khoan,a.tieu_muc,a.ky_thue,a.so_tien,a.log_user,a.log_ip,
        count(*) over (partition by a.mst,a.tieu_muc,a.ky_thue  order by a.mst,a.tieu_muc,a.ky_thue) rc_dupp
        from tax.thanhtoan_upload_temp a
        where (a.mst is not null and a.ky_thue is not null and a.tieu_muc is not null)
        and a.log_user='''||plog_user||''' and log_ip='''||plog_ip||''' and upload_id='''||pcurr_id||'''
        and (select count(*) from tax.nnts_'||ckn||' b where b.mst = a.mst and b.ma_cqt_ql = a.mcq) > 0 ) a';
    if (pfilted = 'FILTED') then
        s:=s||'  where rc_dupp=1  order by a.ma_cqt';
    elsif (pfilted = 'NOT_VALID') then
        s:=s||' where rc_dupp>1
            union all
        select a.ma_cqt,a.ma_goi_tin,a.ma_kho_bac,a.ngay_kho_bac,a.mst,a.ten_nnt,a.diachi_nnt,a.so_qd,a.so_lenh_hoan,a.ngay_lenh_hoan,a.mcq,
        a.tk_no,a.tk_co,a.tien_te,a.ty_gia,a.so_chung_tu,a.nien_do,a.chuong,a.khoan,a.tieu_muc,a.ky_thue,a.so_tien,a.log_user,a.log_ip,
        count(*) over (partition by a.mst,a.tieu_muc,a.ky_thue  order by a.mst,a.tieu_muc,a.ky_thue) rc_dupp
        from tax.thanhtoan_upload_temp a
        where (a.mst is null or a.ky_thue is   null or a.tieu_muc is   null)
        and a.log_user='''||plog_user||''' and log_ip='''||plog_ip||''' and upload_id='''||pcurr_id||'''
        and (select count(*) from tax.nnts_'||ckn||' b where b.mst = a.mst and b.ma_cqt_ql = a.mcq) > 0';
    else
        s:='select a.* from tax.thanhtoan_upload_temp a where a.log_user='''||plog_user||''' and log_ip='''||plog_ip||'''
        and upload_id='''||pcurr_id||''' order by a.ma_cqt ';
    end if;
    if(pPageIndex=-1) then
        s:='select ceil(count(*)/:1) nop,count(1) nor from ('||s||')';
        open ref_ for s using  pRecordPerPage;
    elsif(pPageIndex=-2) then
        open ref_ for s;
    else
        open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    end if;
    return ref_;
    close ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function insert_uploads_thanhtoan(
    pfilter varchar2,
    plog_user varchar2,
    plog_ip varchar2,--nhan biet user dang su dung
    pcurr_id varchar2
)
return varchar2
is
    s varchar2(5000);
    ckn varchar2(100):= crud.ckn_hientai();
begin
    s:='insert into tax.thanhtoan_upload (id,ma_cqt,ma_goi_tin,ma_kho_bac,ngay_kho_bac,mst,ten_nnt,diachi_nnt,so_qd,so_lenh_hoan,ngay_lenh_hoan,
        mcq,tk_no,tk_co,tien_te,ty_gia,so_chung_tu,nien_do,chuong,khoan,tieu_muc,ky_thue,so_tien,log_user,log_ip, upload_id)

    select util.getseq(''UPLOADS_THANHTOAN_SEQ''),a.ma_cqt,a.ma_goi_tin,a.ma_kho_bac,a.ngay_kho_bac,a.mst,a.ten_nnt,a.diachi_nnt,a.so_qd,a.so_lenh_hoan,a.ngay_lenh_hoan,a.mcq,
    a.tk_no,a.tk_co,a.tien_te,a.ty_gia,a.so_chung_tu,a.nien_do,a.chuong,a.khoan,a.tieu_muc,a.ky_thue,a.so_tien,a.log_user,a.log_ip,a.upload_id from (';
    s:=s||'select a.ma_cqt,a.ma_goi_tin,a.ma_kho_bac,ngay_kho_bac,a.mst,a.ten_nnt,a.diachi_nnt,a.so_qd,a.so_lenh_hoan,a.ngay_lenh_hoan,a.mcq,
    a.tk_no,a.tk_co,a.tien_te,a.ty_gia,a.so_chung_tu,a.nien_do,a.chuong,a.khoan,a.tieu_muc,a.ky_thue,a.so_tien,a.log_user,a.log_ip,a.upload_id,a.rc_dupp from
    (select a.ma_cqt,a.ma_goi_tin,a.ma_kho_bac,a.ngay_kho_bac,a.mst,a.ten_nnt,a.diachi_nnt,a.so_qd,a.so_lenh_hoan,a.ngay_lenh_hoan,a.mcq,
    a.tk_no,a.tk_co,a.tien_te,a.ty_gia,a.so_chung_tu,a.nien_do,a.chuong,a.khoan,a.tieu_muc,a.ky_thue,a.so_tien,a.log_user,a.log_ip,a.upload_id,
    count(*) over (partition by a.mst,a.tieu_muc,a.ky_thue  order by a.mst,a.tieu_muc,a.ky_thue) rc_dupp
    from tax.thanhtoan_upload_temp a
    where (a.mst is not null and a.ky_thue is not null and a.tieu_muc is not null)
    and a.log_user='''||plog_user||''' and log_ip='''||plog_ip||''' and upload_id='''||pcurr_id||'''
    and (select count(*) from tax.nnts_'||ckn||' b where b.mst = a.mst and b.ma_cqt_ql = a.mcq) > 0 ) a';

    if (pfilter = 'FILTED') then
        s:=s||'  where rc_dupp=1  order by a.ma_cqt) a';
    elsif (pfilter = 'NOT_VALID') then
        s:=s||' where rc_dupp>1
        union all
        select a.ma_cqt,a.ma_goi_tin,a.ma_kho_bac,a.ngay_kho_bac,a.mst,a.ten_nnt,a.diachi_nnt,a.so_qd,a.so_lenh_hoan,a.ngay_lenh_hoan,a.mcq,
        a.tk_no,a.tk_co,a.tien_te,a.ty_gia,a.so_chung_tu,a.nien_do,a.chuong,a.khoan,a.tieu_muc,a.ky_thue,a.so_tien,
        a.log_user,a.log_ip,a.upload_id,
        count(*) over (partition by a.mst,a.tieu_muc,a.ky_thue  order by a.mst,a.tieu_muc,a.ky_thue) rc_dupp
        from tax.thanhtoan_upload_temp a
        where (a.mst is null or a.ky_thue is   null or a.tieu_muc is   null)
        and a.log_user='''||plog_user||''' and log_ip='''||plog_ip||''' and upload_id='''||pcurr_id||'''
        and (select count(*) from tax.nnts_'||ckn||' b where b.mst = a.mst and b.ma_cqt_ql = a.mcq) > 0 ) a';

    else
        s:='insert into tax.thanhtoan_upload (id,ma_cqt,ma_goi_tin,ma_kho_bac,ngay_kho_bac,mst,ten_nnt,diachi_nnt,so_qd,so_lenh_hoan,ngay_lenh_hoan,
        mcq,tk_no,tk_co,tien_te,ty_gia,so_chung_tu,nien_do,chuong,khoan,tieu_muc,ky_thue,so_tien,log_user,log_ip, upload_id)
        select util.getseq(''UPLOADS_THANHTOAN_SEQ''),ma_cqt,ma_goi_tin,ma_kho_bac,ngay_kho_bac,mst,ten_nnt,diachi_nnt,so_qd,so_lenh_hoan,ngay_lenh_hoan,
        mcq,tk_no,tk_co,tien_te,ty_gia,so_chung_tu,nien_do,chuong,khoan,tieu_muc,ky_thue,so_tien,log_user,log_ip, upload_id
        from tax.thanhtoan_upload_temp   where  log_user='''||plog_user||''' and log_ip='''||plog_ip||'''
        and upload_id='''||pcurr_id||''' order by  ma_cqt  ';
    end if;
    execute immediate s;
    commit;

    --thuc hien thanh toan theo tieu chi: MST, MA_TMUC, KYTHUE, CHUKY
    s:= thanhtoan_cct(i_upload =>pcurr_id);

    --thuc hien thanh toan theo tieu chi: MST, MA_TMUC
    --s:= thanhtoan_cct_null(i_upload =>pcurr_id);

    return '1';
    exception when others then
        declare err varchar2(500); begin   err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function info_uploads_thanhtoan(
  plog_user varchar2,
  plog_ip varchar2,--nhan biet user dang su dung
  pcurr_id varchar2
)
return sys_refcursor
is
  s varchar2(2000);
  ref_ sys_refcursor;
  l_exists number:=0;
  l_table varchar2(100);
begin
    select count(1) into l_exists from thanhtoan_upload where upload_id = pcurr_id;
    if l_exists>0 then
        l_table :='tax.thanhtoan_upload';
    else
        l_table :='tax.thanhtoan_upload_temp';
    end if;

    s:='select max(upload_id) luot_tai,count(distinct mst) so_mst,sum(round(so_tien)) so_tien from '||l_table||'
        where  log_user='''||plog_user||''' and  log_ip='''||plog_ip||''' and upload_id='''||pcurr_id||'''  ';
    open ref_ for s;
    return ref_;
    close ref_;
    exception when others then
      declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function edit_chuyen_tinh(pid varchar2,pagent varchar2)
return varchar2
is
    s varchar2(1000);
begin
    s:='update user_info set agent=:agent where id=:id';
    execute immediate s using pagent,pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function uploadfile_ketquaphats(
    pmst varchar2,
    pchuky varchar2,
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
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    l_id number := util.getseq('PHATCHUNGTU_SEQ');
    l_agent varchar2(20);
    l_agent1 varchar2(20);
    l_exists number;
begin
    l_agent := tax.get_agent_taxcode(pmst);
    l_agent1 := crud.search_agent_info(pUserId);
    if l_agent <> l_agent1 then
        return 'BAN KHONG DUOC THAO TAC VOI DU LIEU CUA TINH KHAC';
    end if;

    select count(1) into l_exists from tax.ketquaphats where mst = pmst and chuky = pchuky;
    if l_exists >0 then
        return 'HOA DON '||pmst||' DA DUOC NHAP !';
    end if;

    s:='insert into tax.ketquaphats(id,mst,ma_tinh,chuky,chungtu_id,ma_nv,bill,ngay_phat,ngay_nhap,nguoi_nhan,lan_phat,lan_thu,trang_thai,ma_daily,diem_thu,ghichu,loguser,logdate)
     values (:id,:mst,:ma_tinh,:chuky,:chungtu_id,:ma_nv,:bill,:ngay_phat,:ngay_nhap,:nguoi_nhan,:lan_phat,:lan_thu,:trang_thai,:ma_daily,:diem_thu,:ghichu,:loguser,:logdate)';
    execute immediate s using l_id,pmst,l_agent1,pchuky,pchungtu_id,pma_nv,pbill,to_date(pngay_phat,'dd/mm/yyyy'),to_date(pngay_nhap,'dd/mm/yyyy'),pnguoi_nhan,plan_phat,plan_thu,ptrang_thai,pma_daily,pdiem_thu,pghichu,pUserId,sysdate;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function thanhtoan_cct(i_upload varchar2) return varchar2
is
    l_res varchar2(1000);
    l_tra varchar2(1000);
    l_user_tt varchar2(100):='system';
    l_matinh varchar2(10);
    l_mabc varchar2(10);
    l_quaythu varchar2(10);
    l_hinthuctt varchar2(5):='6';
    l_count number:=0;
    i_no number:=0;
    l_tientt number;
    ref_ sys_refcursor;
    s varchar2(32000);
    ckn varchar2(100):=crud.ckn_hientai();
    l_mst varchar2(20);
    l_sid number;
    l_mcq varchar2(20);
    l_tientra number;
    l_ngaytt date;
    l_sngaytt varchar2(50);
    l_tieumuc number;
    l_chuky varchar2(20);
    l_kythue varchar2(20);
    l_so_ct varchar2(50);
    l_id number;
begin
    s:='select a.mst,a.id,a.ma_cq_thu,round(b.so_tien) tientra,to_char(b.ngay_kho_bac,''dd/mm/yyyy'') ngay_tt,to_number(b.tieu_muc) tieu_muc,a.chuky,a.kythue,b.id,b.so_chung_tu,
            (select id_payment from config_contract where id_ref = b.mcq and rownum=1) nguoi_tt
              from ct_no_'||ckn||' a,thanhtoan_upload b
              where a.mst=trim(b.mst) and b.upload_id =:1  and b.trang_thai=0
              and a.ma_tmuc =to_number(b.tieu_muc) and a.chuky = b.ky_thue
              and not exists (select 1 from ct_tra_'||ckn||' c where a.mst=c.mst and a.ma_tmuc=c.ma_tmuc and c.kythue=a.kythue)';
    open ref_ for s using i_upload;
        loop fetch ref_ into l_mst,l_sid,l_mcq,l_tientra,l_sngaytt,l_tieumuc,l_chuky,l_kythue,l_id,l_so_ct,l_user_tt;
        exit when ref_%notfound;

        begin
            i_no := tax.check_no_chuky(I_TAXCODE=> l_mst, I_KYTHUE=> l_kythue, I_CHUKY=> l_chuky, I_TIEUMUC=> l_tieumuc);
            if (i_no >0) then
                begin
                    if (i_no > l_tientra) then
                        l_tientt := l_tientra;
                    else
                        l_tientt := i_no;
                    end if;

                    s:='select MST||'',''||KYTHUE||'',''||MA_TINH||'','||l_tientt||',''||MA_CHUONG||'',''||MA_CQ_THU||'',''||MA_TMUC||'',''||SO_TAIKHOAN_CO||'',''||SO_QDINH||'',''||NGAY_QDINH||'',''||LOAI_TIEN||'',''||TI_GIA||'',''||LOAI_THUE||'',''||CHUKY
                     from ct_no_'||ckn||'  where mst=:1 and ma_tmuc=:2 and kythue=:3 and chuky=:4
                     and id=:5 and ma_cq_thu=:6 and rownum<2';
                    execute immediate s into l_tra using l_mst,l_tieumuc,l_kythue,l_chuky,l_sid,l_mcq;

                    select ma_tinh,mabc_id,quaythu_id into l_matinh,l_mabc,l_quaythu from nguoigachnos where id =l_user_tt and rownum=1;

                    l_res := tax.crud.thanh_toan(pmst=> l_mst,
                                            pma_tinh=> l_matinh,
                                            pma_bc=> l_mabc,
                                            phttt=> l_hinthuctt,
                                            pnguoigachno=> nvl(l_user_tt,'system'),
                                            pngay_tt=> l_sngaytt,
                                            pquaythu=> l_quaythu,
                                            ptra=> l_tra);

                    --cap nhat trang thai thanh toan
                    update thanhtoan_upload set trang_thai=1, ngay_tt = sysdate, tien_tt = l_tientt
                    where upload_id = i_upload and id =l_id
                    and trim(mst)=l_mst and trang_thai=0 and so_chung_tu= l_so_ct
                    and tieu_muc=l_tieumuc and ky_thue=l_chuky;
                    commit;

                    exception when others then
                        return to_char(sqlerrm);
                end;

            end if;
        end;

    end loop ;
    commit;
    return '1';
    exception when others then
        declare err varchar2(500);
        begin   err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
            return err;
        end;
end;

/*
    --Thanh toan ky thue NULL
    --Chi thanh toan khi tien no tren he thong = tien thanh toan qua kho bac khi upload
*/
function thanhtoan_cct_null(i_upload varchar2) return varchar2
is
    l_res varchar2(1000);
    l_tra varchar2(1000);
    l_user_tt varchar2(100):='system';
    l_matinh varchar2(10);
    l_mabc varchar2(10);
    l_quaythu varchar2(10);
    l_hinthuctt varchar2(5):='6';
    l_count number:=0;
    i_no number:=0;
    l_tientt number;
    ref_ sys_refcursor;
    s varchar2(32000);
    ckn varchar2(100):=crud.ckn_hientai();
    l_mst varchar2(20);
    l_sid number;
    l_mcq varchar2(20);
    l_tientra number;
    l_ngaytt date;
    l_sngaytt varchar2(50);
    l_tieumuc number;
    l_chuky varchar2(20);
    l_kythue varchar2(20);
    l_so_ct varchar2(50);
    l_id number;
    l_payment number:=0;
begin
    s:='select a.mst,a.id,a.ma_cq_thu,round(b.so_tien) tientra,to_char(b.ngay_kho_bac,''dd/mm/yyyy'') ngay_tt,b.tieu_muc,a.chuky,a.kythue,b.id,b.so_chung_tu,
            (select id_payment from config_contract where id_ref = b.mcq and rownum=1) nguoi_tt
              from ct_no_'||ckn||' a,thanhtoan_upload b
              where a.mst=trim(b.mst) and b.upload_id =:1  and b.trang_thai=0
              and a.ma_tmuc =b.tieu_muc and b.ky_thue is null
              and a.kythue in (select id from chukynos where is_payment=1)
              and not exists (select 1 from ct_tra_'||ckn||' c where a.mst=c.mst and a.ma_tmuc=c.ma_tmuc and c.kythue=a.kythue)
              order by a.kythue desc';
    open ref_ for s using i_upload;
        loop fetch ref_ into l_mst,l_sid,l_mcq,l_tientra,l_sngaytt,l_tieumuc,l_chuky,l_kythue,l_id,l_so_ct,l_user_tt;
        exit when ref_%notfound;

        begin
            select count(1) into l_payment from thanhtoan_upload where upload_id = i_upload and id = l_id and trang_thai=0;
            if l_payment >0 then
            i_no := tax.check_no_chuky(I_TAXCODE=> l_mst, I_KYTHUE=> l_kythue, I_CHUKY=> l_chuky, I_TIEUMUC=> l_tieumuc);
            if ((i_no >0) and (i_no = l_tientra)) then
                begin
                    s:='select MST||'',''||KYTHUE||'',''||MA_TINH||'','||l_tientra||',''||MA_CHUONG||'',''||MA_CQ_THU||'',''||MA_TMUC||'',''||SO_TAIKHOAN_CO||'',''||SO_QDINH||'',''||NGAY_QDINH||'',''||LOAI_TIEN||'',''||TI_GIA||'',''||LOAI_THUE||'',''||CHUKY
                     from ct_no_'||ckn||'  where mst=:1 and ma_tmuc=:2 and kythue=:3 and chuky=:4
                     and id=:5 and ma_cq_thu=:6 and rownum<2';
                    execute immediate s into l_tra using l_mst,l_tieumuc,l_kythue,l_chuky,l_sid,l_mcq;

                    select ma_tinh,mabc_id,quaythu_id into l_matinh,l_mabc,l_quaythu from nguoigachnos where id =l_user_tt and rownum=1;

                    l_res := tax.crud.thanh_toan(pmst=> l_mst,
                                            pma_tinh=> l_matinh,
                                            pma_bc=> l_mabc,
                                            phttt=> l_hinthuctt,
                                            pnguoigachno=> nvl(l_user_tt,'system'),
                                            pngay_tt=> l_sngaytt,
                                            pquaythu=> l_quaythu,
                                            ptra=> l_tra);

                    --cap nhat trang thai thanh toan
                     update thanhtoan_upload set trang_thai=2, ngay_tt = sysdate, tien_tt = l_tientra
                    where upload_id = i_upload and id =l_id
                    and trim(mst)=l_mst and trang_thai=0 and so_chung_tu= l_so_ct
                    and tieu_muc=l_tieumuc;
                    commit;

                    exception when others then
                        return to_char(sqlerrm);
                end;
            end if;
            end if;
        end;

    end loop ;
    commit;
    return '1';
    exception when others then
        declare err varchar2(500);
        begin   err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
            return err;
        end;
end;

/*function thanhtoan_cct_2(i_upload varchar2) return varchar2
is
    l_res varchar2(1000);
    l_tra varchar2(1000);
    l_user_tt varchar2(100):='system';
    l_matinh varchar2(10);
    l_mabc varchar2(10);
    l_quaythu varchar2(10);
    l_hinthuctt varchar2(5):='1';
    l_count number:=0;
    i_no number:=0;
    l_tientt number;
    ref_ sys_refcursor;
    s varchar2(32000);
    ckn varchar2(100):=crud.ckn_hientai();
    l_mst varchar2(20);
    l_sid number;
    l_mcq varchar2(20);
    l_tientra number;
    l_ngaytt date;
    l_tieumuc number;
    l_chuky varchar2(20);
    l_kythue varchar2(20);
    l_so_ct varchar2(50);
    l_id number;
    l_payment number:=0;
begin
    s:='select a.mst,a.id,a.ma_cq_thu,round(b.so_tien) tientra,b.ngay_kho_bac ngay_tt,b.tieu_muc,a.chuky,a.kythue,b.id,b.so_chung_tu,
            (select id_payment from config_contract where id_ref = b.mcq and rownum=1) nguoi_tt
              from ct_no_'||ckn||' a,thanhtoan_upload b
              where a.mst=trim(b.mst) and b.upload_id =:1  and b.trang_thai=0
              and a.ma_tmuc =b.tieu_muc and b.ky_thue is null
              and a.kythue in (select id from chukynos where is_payment=1)
              and not exists (select 1 from ct_tra_'||ckn||' c where a.mst=c.mst and a.ma_tmuc=c.ma_tmuc and c.kythue=a.kythue)
              order by a.kythue desc';
    open ref_ for s using i_upload;
        loop fetch ref_ into l_mst,l_sid,l_mcq,l_tientra,l_ngaytt,l_tieumuc,l_chuky,l_kythue,l_id,l_so_ct,l_user_tt;
        exit when ref_%notfound;

        begin
            select count(1) into l_payment from thanhtoan_upload where upload_id = i_upload and id = l_id and trang_thai=0;
            if l_payment >0 then
            i_no := tax.check_no_chuky(I_TAXCODE=> l_mst, I_KYTHUE=> l_kythue, I_CHUKY=> l_chuky, I_TIEUMUC=> l_tieumuc);
            if ((i_no >0) and (i_no = l_tientra)) then
                begin
                    s:='select MST||'',''||KYTHUE||'',''||MA_TINH||'','||l_tientra||',''||MA_CHUONG||'',''||MA_CQ_THU||'',''||MA_TMUC||'',''||SO_TAIKHOAN_CO||'',''||SO_QDINH||'',''||NGAY_QDINH||'',''||LOAI_TIEN||'',''||TI_GIA||'',''||LOAI_THUE||'',''||CHUKY
                     from ct_no_'||ckn||'  where mst=:1 and ma_tmuc=:2 and kythue=:3 and chuky=:4
                     and id=:5 and ma_cq_thu=:6 and rownum<2';
                    execute immediate s into l_tra using l_mst,l_tieumuc,l_kythue,l_chuky,l_sid,l_mcq;

                    select ma_tinh,mabc_id,quaythu_id into l_matinh,l_mabc,l_quaythu from nguoigachnos where id =l_user_tt;

                    l_res := tax.crud.thanh_toan(pmst=> l_mst,
                                            pma_tinh=> l_matinh,
                                            pma_bc=> l_mabc,
                                            phttt=> l_hinthuctt,
                                            pnguoigachno=> nvl(l_user_tt,'system'),
                                            pngay_tt=> l_ngaytt,
                                            pquaythu=> l_quaythu,
                                            ptra=> l_tra);

                    --cap nhat trang thai thanh toan
                     update thanhtoan_upload set trang_thai=2, ngay_tt = sysdate, tien_tt = l_tientra
                    where upload_id = i_upload and id =l_id
                    and trim(mst)=l_mst and trang_thai=0 and so_chung_tu= l_so_ct
                    and tieu_muc=l_tieumuc;
                    commit;

                    exception when others then
                        return to_char(sqlerrm);
                end;
            end if;
            end if;
        end;

    end loop ;
    commit;
    return '1';
    exception when others then
        declare err varchar2(500);
        begin   err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
            return err;
        end;
end;*/

function search_ct_tra(
    pma_tinh varchar2,
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
    pType varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(10000);
    ckn varchar2(100):=crud.ckn_hientai();
    ref_ sys_refcursor;
begin
    s:='select  a.mst,c.ten_nnt,c.mota_diachi,a.ma_cq_thu,a.kythue,a.chuky,a.ma_chuong,a.ma_tmuc,a.tientra,b.nguoigachno_id,b.id
            from ct_tra_'||ckn||' a, bangphieutra_'||ckn||' b , nnts_'||ckn||' c
            where a.phieu_id = b.id and a.ma_tinh=c.ma_tinh
            and a.mst = c.mst';
    if pma_tinh is not null then s:=s||' and a.ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;   
    if pmst is not null then s:=s||' and a.mst like '''||replace(pmst,'*','%')||''''; end if;
    if pten_nnt is not null then s:=s||' and c.ten_nnt like '''||replace(pten_nnt,'*','%')||''''; end if;
    if pmota_diachi is not null then s:=s||' and c.mota_diachi like '''||replace(pmota_diachi,'*','%')||''''; end if;
    if pma_cq_thu is not null then s:=s||' and a.ma_cq_thu like '''||replace(pma_cq_thu,'*','%')||''''; end if;
    if pkythue is not null then s:=s||' and a.kythue like '''||replace(pkythue,'*','%')||''''; end if;
    if pchuky is not null then s:=s||' and a.chuky like '''||replace(pchuky,'*','%')||''''; end if;
    if pma_chuong is not null then s:=s||' and a.ma_chuong like '''||replace(pma_chuong,'*','%')||''''; end if;
    if pma_tmuc is not null then s:=s||' and a.ma_tmuc like '''||replace(pma_tmuc,'*','%')||''''; end if;
    if pnguoigachno_id is not null then s:=s||' and b.nguoigachno_id like '''||replace(pnguoigachno_id,'*','%')||''''; end if;
    if pid is not null then s:=s||' and b.id like '''||replace(pid,'*','%')||''''; end if;
    s:=s||' order by b.id,a.mst';
    --DBMS_OUTPUT.PUT_LINE(s);   
      if pType='1' then
       open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
       return ref_;
    end if;
    if pType='2' then
       return util.GetTotalRecord(s,pPageIndex,pRecordPerPage);
    end if;
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function del_ct_tra(
    pma_tinh varchar2,
    pid varchar2,
    pmst varchar2,
    pkythue varchar2,
    pchuky varchar2,
    pma_tmuc varchar2,
    pnguoigachno_id varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    l_count number;
    ckn varchar2(100):=crud.ckn_hientai();
begin
    logger.access('tax.del_ct_tra|EDIT',pmst||'|'||pkythue||'|'||pchuky||'|'||pma_tmuc||'|'||pnguoigachno_id||'|'||pid);

    Execute immediate 'Select count(1) from tax.bangphieutra_'||ckn||' where id=:id' into l_count using pId;
    If l_count =0 then
        Return 'BILL NOT EXISTING';
    Else
        Execute immediate 'Select count(1) from tax.bangphieutra_'||ckn||' a where a.id=:id and a.nguoigachno_id=:nguoigachno_id
                            and exists (select 1 from nguoigachnos b where a.nguoigachno_id=b.id and b.vnpt =0)' into l_count using pId,pnguoigachno_id;
        If l_count =0 then
            Return 'BAN CHI CO QUYEN XOA PHIEU KHONG THU QUA VNPT';
        End if;
    End if;

    --Luu du lieu log
    execute immediate 'insert into tax.phieuhuys(id,ma_tinh,mst,ma_bc,httt_id,sotien,ngay_huy,nguoi_huy,may_huy,
        quaythu_id,group_id,seri,ky_hieu,ma_chuong,ma_cq_thu,ma_tmuc,ngay_tt,nguoi_tt,kythue,chuky,ma_chuan_chi,so_tham_chieu,loai_the)
    select a.id,a.ma_tinh,a.mst,a.ma_bc,a.httt_id,b.tientra,sysdate,:1,:2,a.quaythu_id,a.group_id,a.seri,a.ky_hieu,
        b.ma_chuong,b.ma_cq_thu,b.ma_tmuc,a.ngay_thuc,a.nguoigachno_id,b.kythue,b.chuky,a.ma_chuan_chi,a.so_tham_chieu,a.loai_the
    from tax.bangphieutra_'||ckn||' a,tax.ct_tra_'||ckn||' b
    where a.id = b.phieu_id
    and a.mst = b.mst
    and a.id = :3' Using pUserId,pUserIp,pId;

    --Xoa du lieu tra
    s:='delete from tax.ct_tra_'||ckn||' where phieu_id=:id and mst=:mst';
    execute immediate s using pid,pmst;

    --Xoa du lieu bang phieu
    s:='delete from tax.bangphieutra_'||ckn||' where id=:id';
    execute immediate s using pid;

    --Huy thanh toan/xoa hoa BLDT
    crud.enqueue_el_bill(i_agent=> pma_tinh,i_taxcode => pmst,i_month => pkythue,i_bill => pId,i_cashier_code => pUserId,i_type => 2);

    return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

FUNCTION UpdateCus(i_agent VARCHAR2, i_id VARCHAR2)
RETURN varchar2
IS
    l_sql clob;
    l_return clob;
    ckn varchar2(100):= crud.ckn_hientai();
BEGIN

    l_sql:='select tax.rows_to_str_clob(''select ''''<Customer><Name><![CDATA[''''||util.convert_utd(x.TEN_NNT)||'''']]></Name><Code>''''||x.mst||''''</Code>
            <TaxCode></TaxCode><Address><![CDATA[''''||util.convert_utd(x.mota_diachi)||'''']]></Address><BankAccountName></BankAccountName><BankName></BankName>
            <BankNumber></BankNumber><Email><![CDATA[''''||x.EMAIL||'''']]></Email><Fax></Fax><Phone></Phone><ContactPerson></ContactPerson><RepresentPerson></RepresentPerson><CusType>0</CusType></Customer>''''
            from tax.nnts_'||ckn||' x where not exists (select 1 from cus_bill y where x.mst = y.mst and x.ma_cqt_ql = y.ma_cqt_ql and y.trang_thai =0)
            and x.ma_tinh ='''''||i_agent||''''''','''') from dual';
    EXECUTE IMMEDIATE l_sql into l_return;

    l_sql := tax.invoke_internal(l_sql, '192.168.114.78', '80','','', 'UpdateCus', 'https://unttadmin.vnpt-invoice.com.vn/BusinessService.asmx','','');
    Return '0';
    EXCEPTION WHEN others THEN
    return TO_CHAR(SQLCODE)||': '||SQLERRM;

END;
END;

/
