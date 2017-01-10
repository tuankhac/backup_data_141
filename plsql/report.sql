--------------------------------------------------------
--  File created - Tuesday-January-10-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body REPORT
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "TAX"."REPORT" 
IS

PROCEDURE CAMEL_NOTIFICATION_BILL
is
    text        varchar2(32767);
    agent       sys.aq$_agent   := sys.aq$_agent(' ', null, 0);
    message     sys.aq$_jms_text_message;

    enqueue_options    dbms_aq.enqueue_options_t;
    message_properties dbms_aq.message_properties_t;
    msgid               raw(16);

BEGIN

    message := sys.aq$_jms_text_message.construct;
    message.set_string_property('invoiceType', 'payment_info_detail');
    message.set_string_property('exportType', 'pdf');
    message.set_string_property('AGENT', '79TTT');
    message.set_string_property('PATH', to_char(sysdate,'yyyymmdd'));


    message.set_text('1');

    dbms_aq.enqueue(queue_name => 'invoice_queue',
                       enqueue_options => enqueue_options,
                       message_properties => message_properties,
                       payload => message,
                       msgid => msgid);
    commit;
END;

PROCEDURE REPORT_PAYMENT_NOTIFICATION(
    i_taxcode varchar2,
    report_out OUT SYS_REFCURSOR)

IS
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):= crud.ckn_hientai;
    l_tien_tra number;
    l_tien_chu varchar(200);
    l_khobac varchar(200);
BEGIN
    s:='select 1 from dual';

    open report_out for s;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
END;

function GET_XML_UNT(
   i_province varchar2,
    i_kbnn varchar2,
    i_ct_kbnn varchar2,
    i_ngay_kbnn varchar2,
    i_kh_ct_nh varchar2,
    i_so_ct_nh varchar2,
    i_ngay_ct_nh varchar2,
    i_sotien varchar2,
    i_userid varchar2,
    i_userip varchar2,
    i_seq varchar2,
    i_phuongxa varchar2,
    ploaithue varchar2
    )
return clob
is
    ref_ sys_refcursor;
    s varchar2(32000);
    l_sql varchar2(32000);
    l_sql1 varchar2(32000);
    l_sql2 varchar2(32000);
    l_return clob;
    ckn varchar2(100):= crud.ckn_hientai;
    l_date varchar2(50) :=  TO_CHAR (SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS');
    l_diaban varchar2(10);
    l_cqt varchar2(10);
    l_monbai number;
    l_mamuc number:=1800;
    l_tien number;
    l_null number;
begin
    --Check loai thue mon bai
    select count(1) into l_monbai from tieu_mucs where id =ploaithue and ma_muc =l_mamuc;

    --Lay thong tin co quan thue
    Begin
        select cqt_qlt,cqt_tms into l_diaban,l_cqt from coquanthus where shkb = i_kbnn and rownum=1;
        Exception when others then
            l_diaban :=0; l_cqt :=0;
    End;

    --Insert log
    begin
        s:= 'insert into tax.data_gip(ma_unt, ten_unt, cbk_unt, ngay_unt, mst, ten_nnt,
               so_nha, ma_tinh, ten_tinh, ma_huyen, ten_huyen,ma_xa, ten_xa, mobile, email, so_nha_tt, ma_tinh_tt,
               ten_tinh_tt, ma_huyen_tt, ten_huyen_tt, ma_xa_tt,ten_xa_tt, loai_thue, ma_chuong, ma_tmuc, dia_ban,
               kbnn, kythue, so_taikhoan_co, han_nop, magiao_unt,loai_tien, no_cuoi_ky, tientra, id, ngay_tt,
               sobl_unt, ngaybl_unt, ngay_banke, seq)
                select c.ma_unt,c.ten_unt,d.sobk_unt,to_char(to_date(c.ngay_unt,''dd/mm/yyyy''),''yyyy-mm-dd''),
                a.mst,c.ten_nnt,c.so_nha,
                (select x.ma_dbhc_thue from dbhcs x where x.ma_dbhc = c.ma_tinh),
                (select x.name from dbhcs x where x.ma_dbhc = c.ma_tinh),
                (select y.ma_dbhc_thue from dbhcs y where y.ma_dbhc = c.ma_huyen),
                (select y.name from dbhcs y where y.ma_dbhc = c.ma_huyen),c.ma_xa,
                (select town_name from tax.towns where id = c.ma_xa  and district_id = c.ma_huyen),
                c.mobile,c.email,c.so_nha,
                (select x.ma_dbhc_thue from dbhcs x where x.ma_dbhc = c.ma_tinh_tt),
                (select x.name from dbhcs x where x.ma_dbhc = c.ma_tinh_tt),
                (select y.ma_dbhc_thue from dbhcs y where y.ma_dbhc = c.ma_huyen_tt),
                (select y.name from dbhcs y where y.ma_dbhc = c.ma_huyen_tt),c.ma_xa_tt,
                (select town_name from tax.towns where id = c.ma_xa_tt  and district_id = c.ma_huyen_tt),
                d.loai_thue,d.ma_chuong,a.ma_tmuc,c.dia_ban,c.kbnn,d.chuky,d.so_taikhoan_co,
                to_char(to_date(d.han_nop,''dd/mm/yyyy''),''yyyy-mm-dd''),
                d.magiao_unt,a.loai_tien,d.no_cuoi_ky,a.tientra,b.id,to_char(b.ngay_tt,''yyyy-mm-dd''),
                c.sobl_unt,to_char(to_date(c.ngaybl_unt,''dd/mm/yyyy''),''yyyy-mm-dd''),
                to_char(to_date(c.ngay_banke,''dd/mm/yyyy''),''yyyy-mm-dd''),'||i_seq||' seq
                from tax.ct_tra_'||ckn||' a,(select bpt.* from tax.bangphieutra_'||ckn||'  bpt, nguoigachnos g
                                                where bpt.nguoigachno_id = g.id and g.vnpt =1
                                                and bpt.ngay_thuc > (Select from_time from tax.bankes where id ='||i_seq||')
                                                and bpt.ngay_thuc <= (Select to_time from tax.bankes where id = '||i_seq||')) b ,
                tax.nnts_'||ckn||' c ,(select sum(no_cuoi_ky) no_cuoi_ky,mst,kythue,chuky,ma_tmuc,max(loai_thue) loai_thue,ma_chuong,max(magiao_unt) magiao_unt,
                    max(han_nop) han_nop, max(so_taikhoan_co) so_taikhoan_co,max(sobk_unt) sobk_unt,ma_cq_thu
                    from tax.ct_no_'||ckn||' where ma_cq_thu = '''||l_cqt||'''
                    group by mst,ma_chuong,ma_tmuc,kythue,chuky,ma_cq_thu) d, tieu_mucs e
                where a.phieu_id = b.id
                and a.mst = b.mst and a.mst = c.mst and a.mst = d.mst
                and a.ma_cq_thu = c.ma_cqt_ql and a.ma_cq_thu = d.ma_cq_thu
                and a.kythue = d.kythue and a.chuky = d.chuky
                and a.ma_chuong = d.ma_chuong  and a.ma_tmuc = d.ma_tmuc and a.ma_tmuc = e.id(+)
                and a.ma_tinh ='''||i_province||'''';
        if (i_province='79TTT') then
            s:=s||' and nvl(c.ma_xa,c.ma_xa_tt) = '''||i_phuongxa||'''';
        else
            if l_monbai >0 then s:=s||' and e.ma_muc = '||l_mamuc||' and nvl(c.ma_xa,c.ma_xa_tt) = '''||i_phuongxa||'''';
            else s:=s||' and e.id = '||ploaithue||''; end if;
        end if;
        execute immediate s;

        exception when others then
            null;
    end;



    --Double check money
    select nvl(sum(tientra),0) into l_tien from tax.data_gip where seq = i_seq;

    --Check du lieu
    select count(1) into l_null from tax.data_gip where seq = i_seq and (cbk_unt is null or magiao_unt is null);

    If i_kbnn ='0036' then
        If (l_tien <> to_number(i_sotien)) then
            Rollback;
            dbms_output.put_line('aj   ');
            Return '-1001';
        End if;
    Else
        If ((l_tien <> to_number(i_sotien)) or (l_null >0)) then
            Rollback;
            dbms_output.put_line(l_tien||'vao day2'||to_number(i_sotien));
            Return '-1001';
        End if;
    End if;

    Commit;

    l_sql1  := '<?xml version="1.0" encoding="UTF-8"?><DATA><HEADER><VERSION>1.0</VERSION><SENDER_CODE>UNT00001</SENDER_CODE>
            <RECEIVER_CODE>GIP</RECEIVER_CODE><TRAN_CODE>UNT00001</TRAN_CODE><MSG_ID>'||i_seq||'</MSG_ID><SEND_DATE>'||l_date||'</SEND_DATE>
            </HEADER><BODY><ROW><TYPE>00044</TYPE><NAME>Name GD UNT tu dat</NAME><GNT_UNT><MA_CQT>'||l_cqt||'</MA_CQT>
            <MA_DIA_BAN>'||l_diaban||'</MA_DIA_BAN><KH_CT_KBNN>'||i_kbnn||'</KH_CT_KBNN><SO_CT_KBNN>'||i_ct_kbnn||'</SO_CT_KBNN><NGAY_CT_KB>'||to_char(to_date(i_ngay_kbnn,'dd/mm/yyyy'),'YYYY-MM-DD')||'</NGAY_CT_KB><KH_CT_NH>'||i_kh_ct_nh||'</KH_CT_NH>
            <SO_CT_NH>'||i_so_ct_nh||'</SO_CT_NH><NGAY_CT_NH>'||to_char(to_date(i_ngay_ct_nh,'dd/mm/yyyy'),'YYYY-MM-DD')||'</NGAY_CT_NH><SO_TIEN_NSNN>'||i_sotien||'</SO_TIEN_NSNN><BANG_KE>';
    l_sql2 := '</BANG_KE></GNT_UNT></ROW></BODY></DATA>';
    if (i_province='79TTT') then
        /*l_sql  := 'select tax.rows_to_str_clob(
                    ''select ''''<BANG_KE_BLAI id="''''||rownum||''''"><MA_UNT>''''||c.ma_unt||''''</MA_UNT><TEN_UNT>''''||c.ten_unt||''''</TEN_UNT><SO_BANG_KE_GIAO_UNT>''''||d.sobk_unt||''''</SO_BANG_KE_GIAO_UNT>
                    <NGAY_BANG_KE_GIAO_UNT>''''||to_char(to_date(c.ngay_unt,''''dd/mm/yyyy''''),''''yyyy-mm-dd'''')||''''</NGAY_BANG_KE_GIAO_UNT><MA_NNT>''''||a.mst||''''</MA_NNT><TEN_NNT>''''||c.ten_nnt||''''</TEN_NNT><SO_NHA_DUONG_PHO_TS>''''||c.so_nha||''''</SO_NHA_DUONG_PHO_TS><MA_TINH_TP_TS>''''||(select x.ma_dbhc_thue from dbhcs x where x.ma_dbhc = c.ma_tinh)||''''</MA_TINH_TP_TS><TEN_TINH_TP_TS>''''||(select x.name from dbhcs x where x.ma_dbhc = c.ma_tinh)||''''</TEN_TINH_TP_TS><MA_QUAN_HUYEN_TS>''''||(select y.ma_dbhc_thue from dbhcs y where y.ma_dbhc = c.ma_huyen)||''''</MA_QUAN_HUYEN_TS><TEN_QUAN_HUYEN_TS>''''||(select y.name from dbhcs y where y.ma_dbhc = c.ma_huyen)||''''</TEN_QUAN_HUYEN_TS><MA_PHUONG_XA_TS>''''||c.ma_xa||''''</MA_PHUONG_XA_TS><TEN_PHUONG_XA_TS>''''||(select town_name from tax.towns where id = c.ma_xa  and district_id = c.ma_huyen)||''''</TEN_PHUONG_XA_TS>
                    <DIEN_THOAI>''''||c.mobile||''''</DIEN_THOAI><EMAIL>''''||c.email||''''</EMAIL><SO_NHA_DUONG_PHO_TB>''''||c.so_nha||''''</SO_NHA_DUONG_PHO_TB><MA_TINH_TP_TB>''''||(select x.ma_dbhc_thue from dbhcs x where x.ma_dbhc = c.ma_tinh_tt)||''''</MA_TINH_TP_TB><TEN_TINH_TP_TB>''''||(select x.name from dbhcs x where x.ma_dbhc = c.ma_tinh_tt)||''''</TEN_TINH_TP_TB><MA_QUAN_HUYEN_TB>''''||(select y.ma_dbhc_thue from dbhcs y where y.ma_dbhc = c.ma_huyen_tt)||''''</MA_QUAN_HUYEN_TB><TEN_QUAN_HUYEN_TB>''''||(select y.name from dbhcs y where y.ma_dbhc = c.ma_huyen_tt)||''''</TEN_QUAN_HUYEN_TB><MA_PHUONG_XA_TB>''''||c.ma_xa_tt||''''</MA_PHUONG_XA_TB><TEN_PHUONG_XA_TB>''''||(select town_name from tax.towns where id = c.ma_xa_tt  and district_id = c.ma_huyen_tt)||''''</TEN_PHUONG_XA_TB>
                    <SAC_THUE>''''||d.loai_thue||''''</SAC_THUE><CHUONG>''''||d.ma_chuong||''''</CHUONG><TIEU_MUC>''''||a.ma_tmuc||''''</TIEU_MUC><MA_DIA_BAN>''''||c.dia_ban||''''</MA_DIA_BAN><KBNN>''''||c.kbnn||''''</KBNN><KY_THUE>''''||replace(d.chuky,''''0000'''','''''''')||''''</KY_THUE><LOAI_TAI_KHOAN_NSNN>''''||d.so_taikhoan_co||''''</LOAI_TAI_KHOAN_NSNN><HAN_NOP>''''||to_char(to_date(d.han_nop,''''dd/mm/yyyy''''),''''yyyy-mm-dd'''')||''''</HAN_NOP><MA_GIAO_UNT>''''||d.magiao_unt||''''</MA_GIAO_UNT><LOAI_TIEN>''''||a.loai_tien||''''</LOAI_TIEN><SO_TIEN_GIAO_UNT>''''||d.no_cuoi_ky||''''</SO_TIEN_GIAO_UNT>
                    <SO_TIEN_CON_PHAI_THU>''''||d.no_cuoi_ky||''''</SO_TIEN_CON_PHAI_THU><SO_TIEN_THU_DUOC>''''||a.tientra||''''</SO_TIEN_THU_DUOC><SO_TIEN_KHONG_THU_DUOC_QUYET_TOAN>0</SO_TIEN_KHONG_THU_DUOC_QUYET_TOAN><SO_BIEN_LAI>''''||nvl(f.serial,''''PT/16E'''')||trim(to_char(nvl(f.numb_bill,b.id),''''0000000''''))||''''</SO_BIEN_LAI><NGAY_BIEN_LAI>''''||to_char(b.ngay_tt,''''yyyy-mm-dd'''')||''''</NGAY_BIEN_LAI><SO_BANG_KE_BL_HOP_DONG_UNT>''''||c.sobl_unt||''''</SO_BANG_KE_BL_HOP_DONG_UNT><NGAY_BANG_KE_BL_HOP_DONG_UNT>''''||to_char(to_date(c.ngaybl_unt,''''dd/mm/yyyy''''),''''yyyy-mm-dd'''')||''''</NGAY_BANG_KE_BL_HOP_DONG_UNT><NGAY_NHAN_BANG_KE>''''||to_char(to_date(c.ngay_banke,''''dd/mm/yyyy''''),''''yyyy-mm-dd'''')||''''</NGAY_NHAN_BANG_KE></BANG_KE_BLAI>''''
                    from tax.ct_tra_'||ckn||' a,(select  bpt.* from tax.bangphieutra_'||ckn||'  bpt, nguoigachnos g where bpt.nguoigachno_id = g.id and g.vnpt =1  and bpt.ngay_thuc > (Select from_time from tax.bankes where id ='||i_seq||') and bpt.ngay_thuc <= (Select to_time from tax.bankes where id = '||i_seq||')) b ,
                    tax.nnts_'||ckn||' c ,(select sum(no_cuoi_ky) no_cuoi_ky,mst,kythue,chuky,ma_tmuc,max(loai_thue) loai_thue,ma_chuong,max(magiao_unt) magiao_unt,max(han_nop) han_nop, max(so_taikhoan_co) so_taikhoan_co,max(sobk_unt) sobk_unt,ma_cq_thu from tax.ct_no_'||ckn||' where ma_cq_thu = '''''||l_cqt||''''' group by mst,ma_chuong,ma_tmuc,kythue,chuky,ma_cq_thu) d, tieu_mucs e, hddts f
                    where a.phieu_id = b.id  and a.mst = b.mst and a.mst = c.mst and a.mst = d.mst
                    and a.ma_cq_thu = c.ma_cqt_ql and a.ma_cq_thu = d.ma_cq_thu
                    and a.kythue = d.kythue and a.chuky = d.chuky and a.ma_chuong = d.ma_chuong
                    and a.ma_tmuc = d.ma_tmuc and a.ma_tmuc = e.id(+)  and b.id = f.bill(+)
                    and nvl(c.ma_xa,c.ma_xa_tt) = '||i_phuongxa||' and a.ma_tinh ='''''||i_province||''''''','''') from dual';*/

        l_sql  := 'select  /*+ ALL_ROWS */ tax.rows_to_str_clob(
                    ''select ''''<BANG_KE_BLAI id="''''||rownum||''''"><MA_UNT>''''||c.ma_unt||''''</MA_UNT><TEN_UNT>''''||c.ten_unt||''''</TEN_UNT><SO_BANG_KE_GIAO_UNT>''''||d.sobk_unt||''''</SO_BANG_KE_GIAO_UNT>
                    <NGAY_BANG_KE_GIAO_UNT>''''||to_char(to_date(c.ngay_unt,''''dd/mm/yyyy''''),''''yyyy-mm-dd'''')||''''</NGAY_BANG_KE_GIAO_UNT><MA_NNT>''''||a.mst||''''</MA_NNT><TEN_NNT>''''||c.ten_nnt||''''</TEN_NNT><SO_NHA_DUONG_PHO_TS>''''||c.so_nha||''''</SO_NHA_DUONG_PHO_TS><MA_TINH_TP_TS>''''||(select x.ma_dbhc_thue from dbhcs x where x.ma_dbhc = c.ma_tinh)||''''</MA_TINH_TP_TS><TEN_TINH_TP_TS>''''||(select x.name from dbhcs x where x.ma_dbhc = c.ma_tinh)||''''</TEN_TINH_TP_TS><MA_QUAN_HUYEN_TS>''''||(select y.ma_dbhc_thue from dbhcs y where y.ma_dbhc = c.ma_huyen)||''''</MA_QUAN_HUYEN_TS><TEN_QUAN_HUYEN_TS>''''||(select y.name from dbhcs y where y.ma_dbhc = c.ma_huyen)||''''</TEN_QUAN_HUYEN_TS><MA_PHUONG_XA_TS>''''||c.ma_xa||''''</MA_PHUONG_XA_TS><TEN_PHUONG_XA_TS>''''||(select town_name from tax.towns where id = c.ma_xa  and district_id = c.ma_huyen)||''''</TEN_PHUONG_XA_TS>
                    <DIEN_THOAI>''''||c.mobile||''''</DIEN_THOAI><EMAIL>''''||c.email||''''</EMAIL><SO_NHA_DUONG_PHO_TB>''''||c.so_nha||''''</SO_NHA_DUONG_PHO_TB><MA_TINH_TP_TB>''''||(select x.ma_dbhc_thue from dbhcs x where x.ma_dbhc = c.ma_tinh_tt)||''''</MA_TINH_TP_TB><TEN_TINH_TP_TB>''''||(select x.name from dbhcs x where x.ma_dbhc = c.ma_tinh_tt)||''''</TEN_TINH_TP_TB><MA_QUAN_HUYEN_TB>''''||(select y.ma_dbhc_thue from dbhcs y where y.ma_dbhc = c.ma_huyen_tt)||''''</MA_QUAN_HUYEN_TB><TEN_QUAN_HUYEN_TB>''''||(select y.name from dbhcs y where y.ma_dbhc = c.ma_huyen_tt)||''''</TEN_QUAN_HUYEN_TB><MA_PHUONG_XA_TB>''''||c.ma_xa_tt||''''</MA_PHUONG_XA_TB><TEN_PHUONG_XA_TB>''''||(select town_name from tax.towns where id = c.ma_xa_tt  and district_id = c.ma_huyen_tt)||''''</TEN_PHUONG_XA_TB>
                    <SAC_THUE>''''||d.loai_thue||''''</SAC_THUE><CHUONG>''''||d.ma_chuong||''''</CHUONG><TIEU_MUC>''''||a.ma_tmuc||''''</TIEU_MUC><MA_DIA_BAN>''''||c.dia_ban||''''</MA_DIA_BAN><KBNN>''''||c.kbnn||''''</KBNN><KY_THUE>''''||replace(d.chuky,''''0000'''','''''''')||''''</KY_THUE><LOAI_TAI_KHOAN_NSNN>''''||d.so_taikhoan_co||''''</LOAI_TAI_KHOAN_NSNN><HAN_NOP>''''||to_char(to_date(d.han_nop,''''dd/mm/yyyy''''),''''yyyy-mm-dd'''')||''''</HAN_NOP><MA_GIAO_UNT>''''||d.magiao_unt||''''</MA_GIAO_UNT><LOAI_TIEN>''''||a.loai_tien||''''</LOAI_TIEN><SO_TIEN_GIAO_UNT>''''||d.no_cuoi_ky||''''</SO_TIEN_GIAO_UNT>
                    <SO_TIEN_CON_PHAI_THU>''''||d.no_cuoi_ky||''''</SO_TIEN_CON_PHAI_THU><SO_TIEN_THU_DUOC>''''||a.tientra||''''</SO_TIEN_THU_DUOC><SO_TIEN_KHONG_THU_DUOC_QUYET_TOAN>0</SO_TIEN_KHONG_THU_DUOC_QUYET_TOAN><SO_BIEN_LAI>''''||''''PT/16E''''||trim(to_char(b.id,''''0000000''''))||''''</SO_BIEN_LAI><NGAY_BIEN_LAI>''''||to_char(b.ngay_tt,''''yyyy-mm-dd'''')||''''</NGAY_BIEN_LAI><SO_BANG_KE_BL_HOP_DONG_UNT>''''||c.sobl_unt||''''</SO_BANG_KE_BL_HOP_DONG_UNT><NGAY_BANG_KE_BL_HOP_DONG_UNT>''''||to_char(to_date(c.ngaybl_unt,''''dd/mm/yyyy''''),''''yyyy-mm-dd'''')||''''</NGAY_BANG_KE_BL_HOP_DONG_UNT><NGAY_NHAN_BANG_KE>''''||to_char(to_date(c.ngay_banke,''''dd/mm/yyyy''''),''''yyyy-mm-dd'''')||''''</NGAY_NHAN_BANG_KE></BANG_KE_BLAI>''''
                    from tax.ct_tra_'||ckn||' a,(select  bpt.* from tax.bangphieutra_'||ckn||'  bpt, nguoigachnos g where bpt.nguoigachno_id = g.id and g.vnpt =1  and bpt.ngay_thuc > (Select from_time from tax.bankes where id ='||i_seq||') and bpt.ngay_thuc <= (Select to_time from tax.bankes where id = '||i_seq||')) b ,
                    tax.nnts_'||ckn||' c ,(select sum(no_cuoi_ky) no_cuoi_ky,mst,kythue,chuky,ma_tmuc,max(loai_thue) loai_thue,ma_chuong,max(magiao_unt) magiao_unt,max(han_nop) han_nop, max(so_taikhoan_co) so_taikhoan_co,max(sobk_unt) sobk_unt,ma_cq_thu from tax.ct_no_'||ckn||' where ma_cq_thu = '''''||l_cqt||''''' group by mst,ma_chuong,ma_tmuc,kythue,chuky,ma_cq_thu) d, tieu_mucs e
                    where a.phieu_id = b.id  and a.mst = b.mst and a.mst = c.mst and a.mst = d.mst
                    and a.ma_cq_thu = c.ma_cqt_ql and a.ma_cq_thu = d.ma_cq_thu
                    and a.kythue = d.kythue and a.chuky = d.chuky and a.ma_chuong = d.ma_chuong  and a.ma_tmuc = d.ma_tmuc and a.ma_tmuc = e.id(+) and nvl(c.ma_xa,c.ma_xa_tt) = '||i_phuongxa||' and a.ma_tinh ='''''||i_province||''''''','''') from dual';
    else
        if l_monbai >0 then
            l_sql  := 'select  /*+ ALL_ROWS */ tax.rows_to_str_clob(
                    ''select ''''<BANG_KE_BLAI id="''''||rownum||''''"><MA_UNT>''''||c.ma_unt||''''</MA_UNT><TEN_UNT>''''||c.ten_unt||''''</TEN_UNT><SO_BANG_KE_GIAO_UNT>''''||d.sobk_unt||''''</SO_BANG_KE_GIAO_UNT><NGAY_BANG_KE_GIAO_UNT>''''||to_char(to_date(c.ngay_unt,''''dd/mm/yyyy''''),''''yyyy-mm-dd'''')||''''</NGAY_BANG_KE_GIAO_UNT><MA_NNT>''''||a.mst||''''</MA_NNT><TEN_NNT>''''||c.ten_nnt||''''</TEN_NNT>
                     <SO_NHA_DUONG_PHO_TS>''''||c.so_nha||''''</SO_NHA_DUONG_PHO_TS><MA_TINH_TP_TS>''''||(select x.ma_dbhc_thue from dbhcs x where x.ma_dbhc = c.ma_tinh)||''''</MA_TINH_TP_TS><TEN_TINH_TP_TS>''''||(select x.name from dbhcs x where x.ma_dbhc = c.ma_tinh)||''''</TEN_TINH_TP_TS><MA_QUAN_HUYEN_TS>''''||(select y.ma_dbhc_thue from dbhcs y where y.ma_dbhc = c.ma_huyen)||''''</MA_QUAN_HUYEN_TS><TEN_QUAN_HUYEN_TS>''''||(select y.name from dbhcs y where y.ma_dbhc = c.ma_huyen)||''''</TEN_QUAN_HUYEN_TS><MA_PHUONG_XA_TS>''''||c.ma_xa||''''</MA_PHUONG_XA_TS><TEN_PHUONG_XA_TS>''''||(select town_name from tax.towns where id = c.ma_xa  and district_id = c.ma_huyen)||''''</TEN_PHUONG_XA_TS>
                    <DIEN_THOAI>''''||c.mobile||''''</DIEN_THOAI><EMAIL>''''||c.email||''''</EMAIL><SO_NHA_DUONG_PHO_TB>''''||c.so_nha||''''</SO_NHA_DUONG_PHO_TB><MA_TINH_TP_TB>''''||(select x.ma_dbhc_thue from dbhcs x where x.ma_dbhc = c.ma_tinh_tt)||''''</MA_TINH_TP_TB><TEN_TINH_TP_TB>''''||(select x.name from dbhcs x where x.ma_dbhc = c.ma_tinh_tt)||''''</TEN_TINH_TP_TB><MA_QUAN_HUYEN_TB>''''||(select y.ma_dbhc_thue from dbhcs y where y.ma_dbhc = c.ma_huyen_tt)||''''</MA_QUAN_HUYEN_TB><TEN_QUAN_HUYEN_TB>''''||(select y.name from dbhcs y where y.ma_dbhc = c.ma_huyen_tt)||''''</TEN_QUAN_HUYEN_TB><MA_PHUONG_XA_TB>''''||c.ma_xa_tt||''''</MA_PHUONG_XA_TB><TEN_PHUONG_XA_TB>''''||(select town_name from tax.towns where id = c.ma_xa_tt  and district_id = c.ma_huyen_tt)||''''</TEN_PHUONG_XA_TB>
                    <SAC_THUE>''''||d.loai_thue||''''</SAC_THUE><CHUONG>''''||d.ma_chuong||''''</CHUONG><TIEU_MUC>''''||a.ma_tmuc||''''</TIEU_MUC><MA_DIA_BAN>''''||c.dia_ban||''''</MA_DIA_BAN><KBNN>''''||c.kbnn||''''</KBNN><KY_THUE>''''||d.chuky||''''</KY_THUE><LOAI_TAI_KHOAN_NSNN>''''||d.so_taikhoan_co||''''</LOAI_TAI_KHOAN_NSNN><HAN_NOP>''''||to_char(to_date(d.han_nop,''''dd/mm/yyyy''''),''''yyyy-mm-dd'''')||''''</HAN_NOP><MA_GIAO_UNT>''''||d.magiao_unt||''''</MA_GIAO_UNT><LOAI_TIEN>''''||a.loai_tien||''''</LOAI_TIEN><SO_TIEN_GIAO_UNT>''''||d.no_cuoi_ky||''''</SO_TIEN_GIAO_UNT><SO_TIEN_CON_PHAI_THU>''''||d.no_cuoi_ky||''''</SO_TIEN_CON_PHAI_THU><SO_TIEN_THU_DUOC>''''||a.tientra||''''</SO_TIEN_THU_DUOC>
                    <SO_TIEN_KHONG_THU_DUOC_QUYET_TOAN>0</SO_TIEN_KHONG_THU_DUOC_QUYET_TOAN><SO_BIEN_LAI>''''||b.id||''''</SO_BIEN_LAI><NGAY_BIEN_LAI>''''||to_char(b.ngay_tt,''''yyyy-mm-dd'''')||''''</NGAY_BIEN_LAI><SO_BANG_KE_BL_HOP_DONG_UNT>''''||c.sobl_unt||''''</SO_BANG_KE_BL_HOP_DONG_UNT><NGAY_BANG_KE_BL_HOP_DONG_UNT>''''||to_char(to_date(c.ngaybl_unt,''''dd/mm/yyyy''''),''''yyyy-mm-dd'''')||''''</NGAY_BANG_KE_BL_HOP_DONG_UNT><NGAY_NHAN_BANG_KE>''''||to_char(to_date(c.ngay_banke,''''dd/mm/yyyy''''),''''yyyy-mm-dd'''')||''''</NGAY_NHAN_BANG_KE></BANG_KE_BLAI>''''
                    from tax.ct_tra_'||ckn||' a,(select bpt.* from tax.bangphieutra_'||ckn||'  bpt, nguoigachnos g
                                                    where bpt.nguoigachno_id = g.id and g.vnpt =1
                                                    and bpt.ngay_thuc > (Select from_time from tax.bankes where id ='||i_seq||')
                                                    and bpt.ngay_thuc <= (Select to_time from tax.bankes where id = '||i_seq||')) b ,
                    (select * from tax.nnts_'||ckn||' where nvl(ma_xa,ma_xa_tt) ='||i_phuongxa||') c ,(select * from tax.ct_no_'||ckn||' where ma_cq_thu = '''''||l_cqt||''''') d, tieu_mucs e
                    where a.phieu_id = b.id  and a.mst = b.mst and a.mst = c.mst and a.mst = d.mst
                    and a.ma_cq_thu = c.ma_cqt_ql and a.ma_cq_thu = d.ma_cq_thu
                    and a.kythue = d.kythue and a.chuky = d.chuky
                    and a.ma_chuong = d.ma_chuong  and a.ma_tmuc = d.ma_tmuc and a.ma_tmuc = e.id(+) and e.ma_muc = '||l_mamuc||'
                    and a.ma_tinh ='''''||i_province||''''''','''') from dual';
        else
            l_sql  := 'select  /*+ ALL_ROWS */ tax.rows_to_str_clob(
                    ''select ''''<BANG_KE_BLAI id="''''||rownum||''''"><MA_UNT>''''||c.ma_unt||''''</MA_UNT><TEN_UNT>''''||c.ten_unt||''''</TEN_UNT><SO_BANG_KE_GIAO_UNT>''''||d.sobk_unt||''''</SO_BANG_KE_GIAO_UNT>
                    <NGAY_BANG_KE_GIAO_UNT>''''||to_char(to_date(c.ngay_unt,''''dd/mm/yyyy''''),''''yyyy-mm-dd'''')||''''</NGAY_BANG_KE_GIAO_UNT><MA_NNT>''''||a.mst||''''</MA_NNT><TEN_NNT>''''||c.ten_nnt||''''</TEN_NNT><SO_NHA_DUONG_PHO_TS>''''||c.so_nha||''''</SO_NHA_DUONG_PHO_TS><MA_TINH_TP_TS>''''||(select x.ma_dbhc_thue from dbhcs x where x.ma_dbhc = c.ma_tinh)||''''</MA_TINH_TP_TS><TEN_TINH_TP_TS>''''||(select x.name from dbhcs x where x.ma_dbhc = c.ma_tinh)||''''</TEN_TINH_TP_TS><MA_QUAN_HUYEN_TS>''''||(select y.ma_dbhc_thue from dbhcs y where y.ma_dbhc = c.ma_huyen)||''''</MA_QUAN_HUYEN_TS><TEN_QUAN_HUYEN_TS>''''||(select y.name from dbhcs y where y.ma_dbhc = c.ma_huyen)||''''</TEN_QUAN_HUYEN_TS><MA_PHUONG_XA_TS>''''||c.ma_xa||''''</MA_PHUONG_XA_TS><TEN_PHUONG_XA_TS>''''||(select town_name from tax.towns where id = c.ma_xa  and district_id = c.ma_huyen)||''''</TEN_PHUONG_XA_TS>
                    <DIEN_THOAI>''''||c.mobile||''''</DIEN_THOAI><EMAIL>''''||c.email||''''</EMAIL><SO_NHA_DUONG_PHO_TB>''''||c.so_nha||''''</SO_NHA_DUONG_PHO_TB><MA_TINH_TP_TB>''''||(select x.ma_dbhc_thue from dbhcs x where x.ma_dbhc = c.ma_tinh_tt)||''''</MA_TINH_TP_TB><TEN_TINH_TP_TB>''''||(select x.name from dbhcs x where x.ma_dbhc = c.ma_tinh_tt)||''''</TEN_TINH_TP_TB><MA_QUAN_HUYEN_TB>''''||(select y.ma_dbhc_thue from dbhcs y where y.ma_dbhc = c.ma_huyen_tt)||''''</MA_QUAN_HUYEN_TB><TEN_QUAN_HUYEN_TB>''''||(select y.name from dbhcs y where y.ma_dbhc = c.ma_huyen_tt)||''''</TEN_QUAN_HUYEN_TB><MA_PHUONG_XA_TB>''''||c.ma_xa_tt||''''</MA_PHUONG_XA_TB><TEN_PHUONG_XA_TB>''''||(select town_name from tax.towns where id = c.ma_xa_tt  and district_id = c.ma_huyen_tt)||''''</TEN_PHUONG_XA_TB>
                    <SAC_THUE>''''||d.loai_thue||''''</SAC_THUE><CHUONG>''''||d.ma_chuong||''''</CHUONG><TIEU_MUC>''''||a.ma_tmuc||''''</TIEU_MUC><MA_DIA_BAN>''''||c.dia_ban||''''</MA_DIA_BAN><KBNN>''''||c.kbnn||''''</KBNN><KY_THUE>''''||d.chuky||''''</KY_THUE><LOAI_TAI_KHOAN_NSNN>''''||d.so_taikhoan_co||''''</LOAI_TAI_KHOAN_NSNN><HAN_NOP>''''||to_char(to_date(d.han_nop,''''dd/mm/yyyy''''),''''yyyy-mm-dd'''')||''''</HAN_NOP><MA_GIAO_UNT>''''||d.magiao_unt||''''</MA_GIAO_UNT><LOAI_TIEN>''''||a.loai_tien||''''</LOAI_TIEN><SO_TIEN_GIAO_UNT>''''||d.no_cuoi_ky||''''</SO_TIEN_GIAO_UNT>
                    <SO_TIEN_CON_PHAI_THU>''''||d.no_cuoi_ky||''''</SO_TIEN_CON_PHAI_THU><SO_TIEN_THU_DUOC>''''||a.tientra||''''</SO_TIEN_THU_DUOC><SO_TIEN_KHONG_THU_DUOC_QUYET_TOAN>0</SO_TIEN_KHONG_THU_DUOC_QUYET_TOAN><SO_BIEN_LAI>''''||b.id||''''</SO_BIEN_LAI><NGAY_BIEN_LAI>''''||to_char(b.ngay_tt,''''yyyy-mm-dd'''')||''''</NGAY_BIEN_LAI><SO_BANG_KE_BL_HOP_DONG_UNT>''''||c.sobl_unt||''''</SO_BANG_KE_BL_HOP_DONG_UNT><NGAY_BANG_KE_BL_HOP_DONG_UNT>''''||to_char(to_date(c.ngaybl_unt,''''dd/mm/yyyy''''),''''yyyy-mm-dd'''')||''''</NGAY_BANG_KE_BL_HOP_DONG_UNT><NGAY_NHAN_BANG_KE>''''||to_char(to_date(c.ngay_banke,''''dd/mm/yyyy''''),''''yyyy-mm-dd'''')||''''</NGAY_NHAN_BANG_KE></BANG_KE_BLAI>''''
                    from tax.ct_tra_'||ckn||' a,(select  bpt.* from tax.bangphieutra_'||ckn||'  bpt, nguoigachnos g
                                                    where bpt.nguoigachno_id = g.id and g.vnpt =1
                                                    and bpt.ngay_thuc > (Select from_time from tax.bankes where id ='||i_seq||')
                                                    and bpt.ngay_thuc <= (Select to_time from tax.bankes where id = '||i_seq||')) b ,
                    tax.nnts_'||ckn||' c ,(select * from tax.ct_no_'||ckn||' where ma_cq_thu = '''''||l_cqt||''''') d, tieu_mucs e
                    where a.phieu_id = b.id  and a.mst = b.mst and a.mst = c.mst and a.mst = d.mst
                    and a.ma_cq_thu = c.ma_cqt_ql and a.ma_cq_thu = d.ma_cq_thu
                    and a.kythue = d.kythue and a.chuky = d.chuky
                    and a.ma_chuong = d.ma_chuong  and a.ma_tmuc = d.ma_tmuc and a.ma_tmuc = e.id(+) and e.id = '||ploaithue||'
                    and a.ma_tinh ='''''||i_province||''''''','''') from dual';
        end if;
    end if;
    Execute immediate l_sql into l_return;

    RETURN replace(l_sql1||l_return||l_sql2,'&','');
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||TO_CHAR(SQLCODE)||': '||SQLERRM;
        return err;
    end;

END;


function GET_XML_UNT_DM(
    i_province varchar2,
    i_kbnn varchar2,
    i_ct_kbnn varchar2,
    i_ngay_kbnn varchar2,
    i_kh_ct_nh varchar2,
    i_so_ct_nh varchar2,
    i_ngay_ct_nh varchar2,
    i_sotien varchar2,
    i_userid varchar2,
    i_userip varchar2
    )
return clob
is
    ref_ sys_refcursor;
    l_sql VARCHAR2(32000);
    l_sql1 VARCHAR2(5000);
    l_sql2 VARCHAR2(1000);
    l_return clob;
    ckn varchar2(100):= crud.ckn_hientai;
    l_date varchar2(50) :=  TO_CHAR (SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS');
    l_diaban varchar2(10);
    l_cqt varchar2(10);
begin
    Begin
        select cqt_qlt,cqt_tms into l_diaban,l_cqt from coquanthus where shkb = i_kbnn and rownum=1;
        Exception when others then
            l_diaban :='0';
    End;

    l_sql1  := '<?xml version="1.0" encoding="UTF-8"?><DATA><HEADER><VERSION>1.0</VERSION><SENDER_CODE>11111111</SENDER_CODE>
            <RECEIVER_CODE>GIP</RECEIVER_CODE><TRAN_CODE>11111111</TRAN_CODE><MSG_ID>10000</MSG_ID><SEND_DATE>'||l_date||'</SEND_DATE>
            </HEADER><BODY><ROW><TYPE>00044</TYPE><NAME>Name GD UNT tu dat</NAME><GNT_UNT><MA_CQT>'||l_cqt||'</MA_CQT>
            <MA_DIA_BAN>'||l_diaban||'</MA_DIA_BAN><KH_CT_KBNN>'||i_kbnn||'</KH_CT_KBNN><SO_CT_KBNN>'||i_ct_kbnn||'</SO_CT_KBNN><NGAY_CT_KB>'||to_char(to_date(i_ngay_kbnn,'dd/mm/yyyy'),'YYYY-MM-DD')||'</NGAY_CT_KB><KH_CT_NH>'||i_kh_ct_nh||'</KH_CT_NH>
            <SO_CT_NH>'||i_so_ct_nh||'</SO_CT_NH><NGAY_CT_NH>'||to_char(to_date(i_ngay_ct_nh,'dd/mm/yyyy'),'YYYY-MM-DD')||'</NGAY_CT_NH><SO_TIEN_NSNN>'||i_sotien||'</SO_TIEN_NSNN><BANG_KE>';
    l_sql2 := '</BANG_KE></GNT_UNT></ROW></BODY></DATA>';


    l_sql  := 'select tax.rows_to_str_clob(
            ''select ''''<BANG_KE_BLAI id="''''||rownum||''''"><MA_UNT>''''||c.ma_unt||''''</MA_UNT><TEN_UNT>''''||c.ten_unt||''''</TEN_UNT><SO_BANG_KE_GIAO_UNT>''''||c.ten_unt||''''</SO_BANG_KE_GIAO_UNT>
            <NGAY_BANG_KE_GIAO_UNT>'||l_date||'</NGAY_BANG_KE_GIAO_UNT><MA_NNT>''''||a.mst||''''</MA_NNT><TEN_NNT>''''||c.ten_nnt||''''</TEN_NNT>
             <SO_NHA_DUONG_PHO_TS>''''||c.so_nha||''''</SO_NHA_DUONG_PHO_TS><MA_TINH_TP_TS>''''||(select x.ma_dbhc_thue from dbhcs x where x.ma_dbhc = c.ma_tinh)||''''</MA_TINH_TP_TS><TEN_TINH_TP_TS>''''||tax.uto_khongdau(e.province_name)||''''</TEN_TINH_TP_TS><MA_QUAN_HUYEN_TS>''''||(select y.ma_dbhc_thue from dbhcs y where y.ma_dbhc = c.ma_huyen)||''''</MA_QUAN_HUYEN_TS><TEN_QUAN_HUYEN_TS>''''||tax.uto_khongdau(f.district_name)||''''</TEN_QUAN_HUYEN_TS><MA_PHUONG_XA_TS>''''||c.ma_xa||''''</MA_PHUONG_XA_TS><TEN_PHUONG_XA_TS>''''||tax.uto_khongdau(g.town_name)||''''</TEN_PHUONG_XA_TS>
            <DIEN_THOAI>''''||c.mobile||''''</DIEN_THOAI><EMAIL>''''||c.email||''''</EMAIL>
            <SO_NHA_DUONG_PHO_TB>''''||c.so_nha||''''</SO_NHA_DUONG_PHO_TB><MA_TINH_TP_TB>''''||(select x.ma_dbhc_thue from dbhcs x where x.ma_dbhc = c.ma_tinh_tt)||''''</MA_TINH_TP_TB><TEN_TINH_TP_TB>''''||tax.uto_khongdau(e.province_name)||''''</TEN_TINH_TP_TB><MA_QUAN_HUYEN_TB>''''||(select y.ma_dbhc_thue from dbhcs y where y.ma_dbhc = c.ma_huyen_tt)||''''</MA_QUAN_HUYEN_TB><TEN_QUAN_HUYEN_TB>''''||tax.uto_khongdau(f.district_name)||''''</TEN_QUAN_HUYEN_TB><MA_PHUONG_XA_TB>''''||c.ma_xa_tt||''''</MA_PHUONG_XA_TB><TEN_PHUONG_XA_TB>''''||tax.uto_khongdau(g.town_name)||''''</TEN_PHUONG_XA_TB>
            <SAC_THUE>''''||d.loai_thue||''''</SAC_THUE><CHUONG>''''||d.ma_chuong||''''</CHUONG><TIEU_MUC>''''||a.ma_tmuc||''''</TIEU_MUC><MA_DIA_BAN>''''||c.dia_ban||''''</MA_DIA_BAN><KBNN>''''||c.kbnn||''''</KBNN>
            <KY_THUE>''''||d.kythue||''''</KY_THUE><LOAI_TAI_KHOAN_NSNN>''''||d.so_taikhoan_co||''''</LOAI_TAI_KHOAN_NSNN><HAN_NOP>''''||to_char(to_date(d.han_nop,''''dd/mm/yyyy''''),''''yyyy-mm-dd'''')||''''</HAN_NOP>
            <MA_GIAO_UNT>''''||d.magiao_unt||''''</MA_GIAO_UNT><LOAI_TIEN>''''||a.loai_tien||''''</LOAI_TIEN><SO_TIEN_GIAO_UNT>''''||d.no_cuoi_ky||''''</SO_TIEN_GIAO_UNT>
            <SO_TIEN_CON_PHAI_THU>''''||d.no_cuoi_ky||''''</SO_TIEN_CON_PHAI_THU><SO_TIEN_THU_DUOC>''''||a.tientra||''''</SO_TIEN_THU_DUOC>
            <SO_TIEN_KHONG_THU_DUOC_QUYET_TOAN>0</SO_TIEN_KHONG_THU_DUOC_QUYET_TOAN><SO_BIEN_LAI>''''||b.id||''''</SO_BIEN_LAI>
                  <NGAY_BIEN_LAI>'||l_date||'</NGAY_BIEN_LAI>
                  <SO_BANG_KE_BL_HOP_DONG_UNT>1234</SO_BANG_KE_BL_HOP_DONG_UNT>
                  <NGAY_BANG_KE_BL_HOP_DONG_UNT>'||l_date||'</NGAY_BANG_KE_BL_HOP_DONG_UNT>
                  <NGAY_NHAN_BANG_KE>'||l_date||'</NGAY_NHAN_BANG_KE>
               </BANG_KE_BLAI>''''
            from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b , tax.nnts_'||ckn||' c ,tax.ct_no_'||ckn||' d,
            tax.provinces e, tax.districts f, tax.towns g
            where a.phieu_id = b.id  and a.mst = b.mst and a.mst = c.mst
            and a.mst = d.mst and a.kythue = d.kythue
            and a.ma_chuong = d.ma_chuong  and a.ma_tmuc = d.ma_tmuc
            and e.id = c.ma_tinh and f.id = c.ma_huyen and g.id(+) = c.ma_xa
            and a.ma_tinh ='''''||i_province||''''''','''') from dual';

    EXECUTE IMMEDIATE l_sql into l_return;
    RETURN l_sql1||l_return||l_sql2;
END;

function ACCEPT_SEQ_UNT(
    i_province varchar2,
    i_kbnn varchar2,
    i_ct_kbnn varchar2,
    i_ngay_kbnn varchar2,
    i_kh_ct_nh varchar2,
    i_so_ct_nh varchar2,
    i_ngay_ct_nh varchar2,
    i_sotien varchar2,
    i_userid varchar2,
    i_userip varchar2,
    i_ngay_tt varchar2,
    i_phuongxa varchar2,
    ploaithue varchar2

) return varchar2
is
    id_ varchar2(100):= util.getseq('WS_UNT_SEQ');
    s varchar2(30000);
    l_time number;
    l_count number;
    l_day number;
    l_phuongxa varchar2(10);
    l_monbai number;
begin

    --Lay thong tin cau hinh thoi gian cho du lieu
    Execute immediate' SELECT expire_time FROM tax.config_special_days WHERE agent =:1 and status=1 and rownum =1'
        into l_time Using i_province;

    --Check du lieu lan gui ban ke truoc do
    if (ploaithue ='1801') then
        --if i_province ='01TTT' then
            Select count(1) into l_count from dual
            where to_date(i_ngay_tt,'dd/mm/yyyy')+l_time/24 < (select max(a.to_time) from bankes a
                                                                  where a.phuong_xa = i_phuongxa and a.ma_tinh = i_province
                                                                  and a.so_ct_nh = i_so_ct_nh and a.kbnn = i_kbnn and a.trang_thai=1);
        /*else
            Select count(1) into l_count from dual
            where to_date(i_ngay_tt,'dd/mm/yyyy')+l_time/24 < (select max(a.to_time) from bankes a
                                                                  where a.phuong_xa = i_phuongxa and a.ma_tinh = i_province
                                                                  and a.ct_kbnn = i_ct_kbnn and a.kbnn = i_kbnn and a.trang_thai=1);
        end if;*/
    else
        --if i_province ='01TTT' then
            Select count(1) into l_count from dual
            where to_date(i_ngay_tt,'dd/mm/yyyy')+l_time/24 < (select max(a.to_time) from bankes a
                                                                  where a.ma_tmuc = ploaithue and a.ma_tinh = i_province
                                                                  and a.so_ct_nh = i_so_ct_nh and a.kbnn = i_kbnn and a.trang_thai=1 );

        /*else
            Select count(1) into l_count from dual
            where to_date(i_ngay_tt,'dd/mm/yyyy')+l_time/24 < (select max(a.to_time) from bankes a
                                                                  where a.ma_tmuc = ploaithue and a.ma_tinh = i_province
                                                                  and a.ct_kbnn = i_ct_kbnn and a.kbnn = i_kbnn and a.trang_thai=1 );
        end if;*/
    end if;
    if l_count >0 then
        return '-1001';
    end if;

    --l_day := check_time_exception(i_agent=> i_province);
    l_day := check_time_extend(I_DAY=> i_ngay_tt, I_AGENT=> i_province);
    l_day := l_day +1;

    --Check loai thue mon bai
    select count(1) into l_monbai from tieu_mucs where id =ploaithue and ma_muc =1800;

    if i_province ='79TTT' then
        l_phuongxa := i_phuongxa;
    else
        if l_monbai >0 then
            l_phuongxa := i_phuongxa;
        else
            l_phuongxa := '';
        end if;
    end if;

    s:='insert into tax.bankes(id,ma_tinh,phuong_xa,from_time,to_time,kbnn,ct_kbnn,ngay_ct_kbnn,kh_ct_nh,so_ct_nh,ngay_ct_nh,sotien,ngay_unt,loguser,loguserip,ma_tmuc)
            values (:id,:ma_tinh,:phuong_xa,:from_time,:to_time,:kbnn,:ct_kbnn,:ngay_ct_kbnn,:kh_ct_nh,:so_ct_nh,:ngay_ct_nh,:sotien,:ngay_unt,:loguser,:loguserip,:ma_tmuc)';
    execute immediate s using id_,i_province,l_phuongxa, to_date(i_ngay_tt,'dd/mm/yyyy')+l_time/24, to_date(i_ngay_tt,'dd/mm/yyyy') + l_day + l_time/24 -1/86400, i_kbnn,
        i_ct_kbnn, to_date(i_ngay_kbnn,'dd/mm/yyyy'), i_kh_ct_nh, i_so_ct_nh, to_date(i_ngay_ct_nh,'dd/mm/yyyy'), to_number(i_sotien), sysdate, i_userip, i_userid,ploaithue;
    commit;

    return id_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); rollback; return err;
    end;
end;

function UPDATE_SEQ_UNT(
    i_seq varchar2
) return varchar2
is
    s varchar2(30000);
begin

    s:='update tax.bankes set trang_thai =1 where id =:1';
    execute immediate s using i_seq;
    commit;

    return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        return err;
    end;
end;

function NEW_NNTS_TEMP(
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
    ptenxa_tt varchar2)
return varchar2
is
    s varchar2(5000);
    ckn varchar2(100):=crud.ckn_hientai();
    l_thang varchar2(20):= to_char(sysdate,'mmyyyy');
    id_ varchar2(100):= util.getseq('SEQ_TABLE');
begin

    --Day du lieu vao bang temp
    s:='insert into tax.nnts_temp(id,log_date,mcq,ma_unt,ten_unt,cbk_unt,ngay_unt,ma_nnt,ten_nnt,sac_thue,chuong,tieu_muc,dia_ban,kbnn,kythue,loaitk_nsnn,han_nop,magiao_unt,loai_tien,tien_giao,tien_con,tien_thuduoc,tien_quyettoan,so_bl,ngay_bl,sobl_unt,ngaybl_unt,ngay_banke,sonha_ct,matinh_ct,tentinh_ct,maquan_ct,tenquan_ct,maxa_ct,tenxa_ct,mobile,email,sonha_tt,matinh_tt,tentinh_tt,maquan_tt,tenquan_tt,maxa_tt,tenxa_tt)
     values (:id,:log_date,:mcq,:ma_unt,:ten_unt,:cbk_unt,:ngay_unt,:ma_nnt,:ten_nnt,:sac_thue,:chuong,:tieu_muc,:dia_ban,:kbnn,:kythue,:loaitk_nsnn,:han_nop,:magiao_unt,:loai_tien,:tien_giao,:tien_con,:tien_thuduoc,:tien_quyettoan,:so_bl,:ngay_bl,:sobl_unt,:ngaybl_unt,:ngay_banke,:sonha_ct,:matinh_ct,:tentinh_ct,:maquan_ct,:tenquan_ct,:maxa_ct,:tenxa_ct,:mobile,:email,:sonha_tt,:matinh_tt,:tentinh_tt,:maquan_tt,:tenquan_tt,:maxa_tt,:tenxa_tt)';
    execute immediate s using 1,trunc(sysdate),pmcq,pma_unt,pten_unt,pcbk_unt,pngay_unt,pma_nnt,pten_nnt,psac_thue,pchuong,ptieu_muc,pdia_ban,pkbnn,pkythue,ploaitk_nsnn,phan_nop,pmagiao_unt,ploai_tien,ptien_giao,ptien_con,ptien_thuduoc,ptien_quyettoan,pso_bl,pngay_bl,psobl_unt,pngaybl_unt,pngay_banke,psonha_ct,pmatinh_ct,ptentinh_ct,pmaquan_ct,ptenquan_ct,pmaxa_ct,ptenxa_ct,pmobile,pemail,psonha_tt,pmatinh_tt,ptentinh_tt,pmaquan_tt,ptenquan_tt,pmaxa_tt,ptenxa_tt;

    commit;return '1';
    exception when others then
        return '0';
end;

function SEARCH_BANKES(
    pid varchar2,
    pkbnn varchar2,
    pct_kbnn varchar2,
    pkh_ct_nh varchar2,
    pso_ct_nh varchar2,
    psotien varchar2,
    ptrang_thai varchar2,
    pngay_unt varchar2,
    pType varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    l_agent varchar2(20);
begin
    l_agent := get_agent_user(PUSER=>pUserId);

    s:='select id,kbnn,ct_kbnn,kh_ct_nh,so_ct_nh,to_char(sotien,''fm999,999,999,999,999'') sotien,
    to_char(ngay_unt,''dd/mm/yyyy hh24:mi:ss'') ngay_unt,loguser,decode(trang_thai,0,''ERROR'',''OK'') trang_thai
    from tax.bankes where ma_tinh ='''||l_agent||'''';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if pkbnn is not null then s:=s||' and kbnn like '''||replace(pkbnn,'*','%')||''''; end if;
    if pct_kbnn is not null then s:=s||' and ct_kbnn like '''||replace(pct_kbnn,'*','%')||''''; end if;
    if pkh_ct_nh is not null then s:=s||' and kh_ct_nh like '''||replace(pkh_ct_nh,'*','%')||''''; end if;
    if pso_ct_nh is not null then s:=s||' and so_ct_nh like '''||replace(pso_ct_nh,'*','%')||''''; end if;
    if psotien is not null then s:=s||' and sotien like '''||replace(psotien,'*','%')||''''; end if;
    if ptrang_thai is not null then s:=s||' and trang_thai like '''||replace(ptrang_thai,'*','%')||''''; end if;
    if pngay_unt is not null then s:=s||' and ngay_unt=to_date('''||pngay_unt||''',''dd/mm/yyyy'')'; end if;
    s:=s||' order by id desc';
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

function GET_INFO_TAXCUS(
    i_province varchar2)
return sys_refcursor
is
    ckn varchar2(100):= crud.ckn_hientai();
    ref_ sys_refcursor;
    s varchar2(10000);
begin
    s := 'select b.mst, a.kythue, tax.cfont_utotcvn3(substr(b.ten_nnt,1,250)) ten_nnt, tax.cfont_utotcvn3(substr(b.mota_diachi,1,250)) diachi , b.so, b.mobile, b.email,
                to_char(a.no_cuoi_ky,''fm999,999,999,999,999'') no_cuoi_ky,
                a.MA_CHUONG,a.MA_CQ_THU,a.MA_TMUC,nvl(a.SO_TAIKHOAN_CO,0) TAIKHOAN,nvl(a.SO_QDINH,0) SO_QDINH,
                nvl(a.NGAY_QDINH,'''') NGAY_QDINH,a.LOAI_TIEN,a.TI_GIA,a.LOAI_THUE,
                tax.cfont_utotcvn3(c.ten_chuong) chuong,nvl(tax.cfont_utotcvn3(d.tentieumuc),a.ma_tmuc) tieumuc from
        (
            SELECT mst,kythue,ma_tinh,sum(no_cuoi_ky) no_cuoi_ky,ma_chuong,ma_cq_thu,
                  ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh,
                  loai_tien,ti_gia,loai_thue
              FROM ct_no_'||ckn||' where ma_tinh =:1 group by mst,kythue,ma_tinh,ma_chuong,ma_cq_thu,
                  ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh,
                  loai_tien,ti_gia,loai_thue) a,
            chuongs c, tieu_mucs d, nnts_'||ckn||' b
        where a.mst=b.mst and a.ma_chuong=c.id(+) and a.ma_tmuc=d.id(+)';
    OPEN REF_ for s Using i_province ;
    RETURN ref_;
end;

function GET_INFO_BILL_01(
    i_province varchar2)
return sys_refcursor
is
    ckn varchar2(100):= crud.ckn_hientai();
    ref_ sys_refcursor;
    s varchar2(32000);
    l_mst_dv varchar2(50);
    l_thang varchar2(20):= to_char(sysdate,'mmyyyy');
    l_nam varchar2(10):= to_char(sysdate,'yyyy');
begin
    s := 'select mst,ten_nnt,diachi_nnt,mobile,lanthu,ten_km1,ma_tm1,tien_no1,tien_ps1,tien_nop1,tt_quy1,
         ten_km2,ma_tm2,tien_no2,tien_ps2,tien_nop2,tt_quy2,
         ten_km3,ma_tm3,tien_no3,tien_ps3,tien_nop3,tt_quy3,
         ten_km4,ma_tm4,tien_no4,tien_ps4,tien_nop4,tt_quy4,
         ten_km5,ma_tm5,tien_no5,tien_ps5,tien_nop5,tt_quy5,
         ten_km6,ma_tm6,tien_no6,tien_ps6,tien_nop6,tt_quy6,
         ten_km7,ma_tm7,tien_no7,tien_ps7,tien_nop7,tt_quy7,
         ten_km8,ma_tm8,tien_no8,tien_ps8,tien_nop8,tt_quy8,
         ten_km9,ma_tm9,tien_no9,tien_ps9,tien_nop9,tt_quy9,
         tong_tien,tien_chu,barcode,mau_so,kh_hd,
         so_hd,tuyen_thu
         from (select a.mst,tax.cfont_utotcvn3(substr(b.ten_nnt,1,250)) ten_nnt,tax.cfont_utotcvn3(substr(b.diachi_nnt,1,250)) diachi_nnt,
            b.mobile,b.lanthu,tax.cfont_utotcvn3(to_char(b.ten_km1)) ten_km1,b.ma_tm1,b.tien_no1,to_char(tax.format_money(b.tien_ps1,''.'')) tien_ps1,
            to_char(tax.format_money(b.tien_nop1,''.'')) tien_nop1,b.tt_quy1,
                     tax.cfont_utotcvn3(to_char(b.ten_km2)) ten_km2,ma_tm2,tien_no2,
                     case when length(trim(b.tien_ps2))>0 then to_char(tax.format_money(b.tien_ps2,''.'')) else b.tien_ps2 end tien_ps2,
                     case when length(trim(b.tien_nop2))>0 then to_char(tax.format_money(b.tien_nop2,''.'')) else b.tien_nop2 end tien_nop2,tt_quy2,
                     ten_km3,ma_tm3,tien_no3,tien_ps3,tien_nop3,tt_quy3,
                     ten_km4,ma_tm4,tien_no4,tien_ps4,tien_nop4,tt_quy4,
                     ten_km5,ma_tm5,tien_no5,tien_ps5,tien_nop5,tt_quy5,
                     ten_km6,ma_tm6,tien_no6,tien_ps6,tien_nop6,tt_quy6,
                     ten_km7,ma_tm7,tien_no7,tien_ps7,tien_nop7,tt_quy7,
                     ten_km8,ma_tm8,tien_no8,tien_ps8,tien_nop8,tt_quy8,
                     ten_km9,ma_tm9,tien_no9,tien_ps9,tien_nop9,tt_quy9,
                     to_char(tax.format_money(b.tong_tien,''.'')) tong_tien,
                     tax.cfont_utotcvn3(to_char(b.tien_chu)) tien_chu,b.barcode,b.mau_so,b.kh_hd,b.so_hd,b.tuyen_thu
         from tax.nnts_'||ckn||' a, in_phieus b
         where a.mst = b.mst
         and b.logdate>= trunc(sysdate)
         and a.ma_tinh =:1 and b.tt_quy1 ='''||l_nam||'''
         order by a.ma_nv,a.ma_t,a.ma_xa,a.ma_huyen)';
    OPEN REF_ for s Using i_province ;
    RETURN ref_;
end;

function GET_INFO_BILL_OTHER(i_province varchar2,i_kythu varchar2, i_khobac varchar2, i_userid varchar2,i_userip varchar2)
return sys_refcursor
is
    ckn varchar2(100):= crud.ckn_hientai();
    ref_ sys_refcursor;
    s varchar2(32000);
    l_mst_dv varchar2(50);
    l_kythu varchar2(100);
    l_upload number:=0;
    l_role number;
    l_exists  number;
    l_cqt varchar2(10);
begin
    l_kythu := i_kythu;
    l_role := tax.check_role_lever(i_user=> i_userid);

    select cqt_tms into l_cqt from coquanthus a where shkb=i_khobac;
    select nvl(max(id),0) into l_upload from nnts_uploads where mcq = l_cqt;


    logger.access('GET_INFO_BILL_OTHER',i_province||'|'||i_userid||'|'||i_userip||'|'||l_kythu||'|'||l_role);
    If l_role <>5 then
        s :=' select ''BAN KHONG CO QUYEN THUC HIEN'' note from dual';
        OPEN REF_ for s;
        RETURN REF_;
    Else
        select count(1) into l_exists from in_phieus where id = l_upload;
        If l_exists >0 then
            s :=' select ''DU LIEU DA DUOC TONG HOP -> KIEM TRA LAI'' note from dual';
            OPEN REF_ for s;
            RETURN REF_;
        ELse
            s:= CREATE_DATA_PRINT(i_agent=> i_province, i_kythue=> l_kythu, i_upload=> l_upload, i_mcq=> l_cqt);

            s := 'select mst,ten_nnt,diachi_nnt,mobile,lanthu,ten_km1,ma_tm1,tien_no1,tien_ps1,tien_nop1,tt_quy1,
                ten_km2,ma_tm2,tien_no2,tien_ps2,tien_nop2,tt_quy2,
                ten_km3,ma_tm3,tien_no3,tien_ps3,tien_nop3,tt_quy3,
                ten_km4,ma_tm4,tien_no4,tien_ps4,tien_nop4,tt_quy4,
                ten_km5,ma_tm5,tien_no5,tien_ps5,tien_nop5,tt_quy5,
                ten_km6,ma_tm6,tien_no6,tien_ps6,tien_nop6,tt_quy6,
                ten_km7,ma_tm7,tien_no7,tien_ps7,tien_nop7,tt_quy7,
                ten_km8,ma_tm8,tien_no8,tien_ps8,tien_nop8,tt_quy8,
                ten_km9,ma_tm9,tien_no9,tien_ps9,tien_nop9,tt_quy9,
                tong_tien,tien_chu,barcode,mau_so,kh_hd,
                so_hd,tuyen_thu
                from (select a.mst,tax.cfont_utotcvn3(substr(b.ten_nnt,1,250)) ten_nnt,tax.cfont_utotcvn3(substr(b.diachi_nnt,1,250)) diachi_nnt,
                    b.mobile,b.lanthu,tax.cfont_utotcvn3(to_char(b.ten_km1)) ten_km1,b.ma_tm1,b.tien_no1,to_char(tax.format_money(b.tien_ps1,''.'')) tien_ps1,
                    to_char(tax.format_money(b.tien_nop1,''.'')) tien_nop1,b.tt_quy1,

                     tax.cfont_utotcvn3(to_char(b.ten_km2)) ten_km2,ma_tm2,tien_no2,
                     case when length(trim(b.tien_ps2))>0 then to_char(tax.format_money(b.tien_ps2,''.'')) else b.tien_ps2 end tien_ps2,
                     case when length(trim(b.tien_nop2))>0 then to_char(tax.format_money(b.tien_nop2,''.'')) else b.tien_nop2 end tien_nop2,tt_quy2,

                     tax.cfont_utotcvn3(to_char(b.ten_km3)) ten_km3,ma_tm3,tien_no3,
                     case when length(trim(b.tien_ps3))>0 then to_char(tax.format_money(b.tien_ps3,''.'')) else b.tien_ps3 end tien_ps3,
                     case when length(trim(b.tien_nop3))>0 then to_char(tax.format_money(b.tien_nop3,''.'')) else b.tien_nop3 end tien_nop3,tt_quy3,

                     tax.cfont_utotcvn3(to_char(b.ten_km4)) ten_km4,ma_tm4,tien_no4,
                     case when length(trim(b.tien_ps4))>0 then to_char(tax.format_money(b.tien_ps4,''.'')) else b.tien_ps4 end tien_ps4,
                     case when length(trim(b.tien_nop4))>0 then to_char(tax.format_money(b.tien_nop4,''.'')) else b.tien_nop4 end tien_nop4,tt_quy4,

                     tax.cfont_utotcvn3(to_char(b.ten_km5)) ten_km5,ma_tm5,tien_no5,
                     case when length(trim(b.tien_ps5))>0 then to_char(tax.format_money(b.tien_ps5,''.'')) else b.tien_ps5 end tien_ps5,
                     case when length(trim(b.tien_nop5))>0 then to_char(tax.format_money(b.tien_nop5,''.'')) else b.tien_nop5 end tien_nop5,tt_quy5,

                     tax.cfont_utotcvn3(to_char(b.ten_km6)) ten_km6,ma_tm6,tien_no6,
                     case when length(trim(b.tien_ps6))>0 then to_char(tax.format_money(b.tien_ps6,''.'')) else b.tien_ps6 end tien_ps6,
                     case when length(trim(b.tien_nop6))>0 then to_char(tax.format_money(b.tien_nop6,''.'')) else b.tien_nop6 end tien_nop6,tt_quy6,

                     tax.cfont_utotcvn3(to_char(b.ten_km7)) ten_km7,ma_tm7,tien_no7,
                     case when length(trim(b.tien_ps7))>0 then to_char(tax.format_money(b.tien_ps7,''.'')) else b.tien_ps7 end tien_ps7,
                     case when length(trim(b.tien_nop7))>0 then to_char(tax.format_money(b.tien_nop7,''.'')) else b.tien_nop7 end tien_nop7,tt_quy7,

                     tax.cfont_utotcvn3(to_char(b.ten_km8)) ten_km8,ma_tm8,tien_no8,
                     case when length(trim(b.tien_ps8))>0 then to_char(tax.format_money(b.tien_ps8,''.'')) else b.tien_ps8 end tien_ps8,
                     case when length(trim(b.tien_nop8))>0 then to_char(tax.format_money(b.tien_nop8,''.'')) else b.tien_nop8 end tien_nop8,tt_quy8,

                     tax.cfont_utotcvn3(to_char(b.ten_km9)) ten_km9,ma_tm9,tien_no9,
                     case when length(trim(b.tien_ps9))>0 then to_char(tax.format_money(b.tien_ps9,''.'')) else b.tien_ps9 end tien_ps9,
                     case when length(trim(b.tien_nop9))>0 then to_char(tax.format_money(b.tien_nop9,''.'')) else b.tien_nop9 end tien_nop9,tt_quy9,

                     to_char(tax.format_money(b.tong_tien,''.'')) tong_tien,
                     tax.cfont_utotcvn3(to_char(b.tien_chu)) tien_chu,b.barcode,b.mau_so,b.kh_hd,b.so_hd,b.tuyen_thu
            from tax.nnts_'||ckn||' a, in_phieus b
            where a.mst = b.mst and b.logdate>= trunc(sysdate) and b.id =:1
            and a.ma_tinh =:2 and b.kythue ='''||l_kythu||''' and b.trang_thai=1
            and exists (select 1 from nnts_uploads c where a.mst =c.ma_nnt and c.id = '||l_upload||')
            order by /*a.ma_nv,a.ma_t,a.ma_xa,a.ma_huyen,b.tuyen_thu*/b.stt)';

            OPEN REF_ for s Using l_upload,i_province ;
            RETURN ref_;
        End if;
    End if;

end;

function GET_INFO_DEPT(
    i_province varchar2)
return sys_refcursor
is
    ckn varchar2(100):= crud.ckn_hientai();
    ref_ sys_refcursor;
    s varchar2(10000);
begin

    s := 'select a.mst,a.kythue,to_char(a.no_cuoi_ky,''fm999,999,999,999,999'') no_cuoi_ky,
                to_char(nvl(b.tientra,0),''fm999,999,999,999,999'') tien_tra,
                to_char(a.no_cuoi_ky-nvl(b.tientra,0),''fm999,999,999,999,999'') sotien,
                a.MA_CHUONG,a.MA_CQ_THU,a.MA_TMUC,nvl(a.SO_TAIKHOAN_CO,0) TAIKHOAN,
                nvl(a.SO_QDINH,0) SO_QDINH,nvl(a.NGAY_QDINH,'''') NGAY_QDINH,a.LOAI_TIEN,a.TI_GIA,a.LOAI_THUE,
                C.ten_chuong,nvl(D.tentieumuc,A.ma_tmuc) tentieumuc from
        (
            SELECT mst,kythue,ma_tinh,sum(no_cuoi_ky) no_cuoi_ky,ma_chuong,ma_cq_thu,
                  ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh,
                  loai_tien,ti_gia,loai_thue
              FROM ct_no_'||ckn||' where ma_tinh =:1 group by mst,kythue,ma_tinh,ma_chuong,ma_cq_thu,
                  ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh,loai_tien,ti_gia,loai_thue) a,
        (
            SELECT mst,kythue,ma_tinh,sum(tientra) TIENTRA,ma_chuong,ma_cq_thu,
                  ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh,
                  loai_tien,ti_gia,loai_thue
              FROM ct_tra_'||ckn||' where ma_tinh =:2 group by mst,kythue,ma_tinh,ma_chuong,ma_cq_thu,
                  ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh,loai_tien,ti_gia,loai_thue
        ) b, chuongs c, tieu_mucs d
        where a.mst=b.mst(+) and a.ma_chuong=b.ma_chuong(+) and a.ma_tmuc=b.ma_tmuc(+)
            and a.ma_chuong=C.id(+) and a.ma_tmuc=d.id(+)
            and a.kythue = b.kythue';
    OPEN REF_ for s Using i_province,i_province ;
    RETURN ref_;
end;

FUNCTION EXP_BILL (i_agent varchar2,i_kythu varchar2, i_khobac varchar2, i_userid varchar2, i_userip varchar2)
Return sys_refcursor
Is
    ckn varchar2(100):= crud.ckn_hientai();
    l_sql clob;
    ref_ sys_refcursor;
    l_thang varchar2(20) := to_char(sysdate-1,'yyyymm');
    l_kythue  varchar2(50);
    l_chuky varchar2(100):=to_char(sysdate-1,'mmyyyy');
    l_role number;
    l_id number :=0;
    l_cqt  varchar2(10);
Begin
    l_role := tax.check_role_lever(i_user=> i_userid);
    select cqt_tms into l_cqt from coquanthus a where shkb=i_khobac;
    select nvl(max(id),0) into l_id from nnts_uploads where mcq = l_cqt;

    If l_role = 5 then
        l_kythue := to_char(sysdate-1,'mmyyyy');
        l_sql := 'Select to_clob(''<Invoices><BillTime>'||l_thang||'</BillTime>'') from dual
                Union all
            select  ''<Inv><key>''||replace(trim(x.mst),''-'','''')||''''||replace(b.kythue,''-'','''')||'''||l_id||'</key><Invoice><CusCode>''||replace(trim(x.mst),''-'','''')||''</CusCode><CusName><![CDATA[''||x.TEN_NNT||'']]></CusName><CusAddress><![CDATA[''||x.mota_diachi||'']]></CusAddress><CusTaxCode>''||replace(trim(x.mst),''-'','''')||''</CusTaxCode><Products>''||(select util.rows_to_str2(''select ''''<Product><ProdName><![CDATA[''''||nvl(D.tentieumuc,A.ma_tmuc)||''''|''''||a.chuky||'''']]></ProdName><ProdUnit>''''||a.ma_tmuc||''''</ProdUnit><Amount>''''||round(a.no_cuoi_ky)||''''</Amount><Extra1>0</Extra1><Extra2>''''||round(a.no_cuoi_ky)||''''</Extra2><Remark>''''||a.tenky||''''</Remark></Product>''''from ( SELECT mst,kythue,'''''||l_kythue||''''' tenky,ma_tinh,sum(no_cuoi_ky) no_cuoi_ky,ma_chuong,ma_cq_thu, ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh, loai_tien,ti_gia,loai_thue,chuky
                FROM ct_no_'||ckn||' where mst = ''''''||x.mst||'''''' and id = '||l_id||' group by mst,kythue,ma_tinh,ma_chuong,ma_cq_thu, ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh,loai_tien,ti_gia,loai_thue,chuky order by ma_tmuc) a, tieu_mucs d
                    where a.ma_tmuc=d.id(+) and a.mst = ''''''||x.mst||'''''' and a.kythue=''''''||b.kythue||'''''''','''') from dual)
            ||''</Products><Amount>''||round(b.no_cuoi_ky)||''</Amount><Total></Total><VATRate></VATRate><VATAmount></VATAmount><AmountInWords><![CDATA[''||util.doisosangchu(round(b.no_cuoi_ky))||'']]></AmountInWords><Extra><![CDATA[]]></Extra></Invoice></Inv>''
            from tax.nnts_'||ckn||' x,( select sum(no_cuoi_ky) no_cuoi_ky, mst, kythue from tax.ct_no_'||ckn||'
                                            where kythue ='''||l_chuky||''' and id = '||l_id||' group by mst,kythue) b
            where x.mst = b.mst and x.ma_tinh ='''||i_agent||'''
            and exists (select 1 from nnts_uploads c where x.mst =c.ma_nnt and c.id = '||l_id||')
          Union all
            Select to_clob(''</Invoices>'') from dual';
    Else
        l_sql := 'Select ''BAN KHONG QUYEN THAO TAC'' note from dual';
    End if;
    Open ref_ for  l_sql;
    Return  ref_;

    Exception when others then
        declare err varchar2(500);
        begin    err:='Loi thuc hien, ma loi:'||TO_CHAR(SQLCODE)||': '||SQLERRM;
            open ref_ for 'select :1 err from dual' using err; return ref_;
        End;
End;

FUNCTION EXP_BILL_MB (i_agent varchar2, i_userid varchar2, i_userip varchar2)
Return sys_refcursor
Is
    ckn varchar2(100):= crud.ckn_hientai();
    l_sql clob;
    ref_ sys_refcursor;
    l_kythue  varchar2(20) := to_char(sysdate,'yyyy');
    l_thang varchar2(20) := to_char(sysdate,'yyyymm');
    l_role number;
Begin
    l_role := tax.check_role_lever(i_user=> i_userid);

    If l_role = 5 then
        l_sql := 'Select ''<Invoices><BillTime>'||l_thang||'</BillTime>'' from dual
              Union all
                select ''<Inv><key>''||replace(trim(x.mst),''-'','''')||''''||replace(b.kythue,''-'','''')||''</key><Invoice><CusCode>''||replace(trim(x.mst),''-'','''')||''</CusCode><CusName><![CDATA[''||x.TEN_NNT||'']]></CusName><CusAddress><![CDATA[''||x.mota_diachi||'']]></CusAddress><CusTaxCode>''||replace(trim(x.mst),''-'','''')||''</CusTaxCode><Products>''
                ||(select util.rows_to_str(''select ''''<Product><ProdName><![CDATA[''''||nvl(D.tentieumuc,A.ma_tmuc)||'''']]></ProdName><ProdUnit>''''||a.ma_tmuc||''''</ProdUnit><Amount>''''||a.no_cuoi_ky||''''</Amount><Extra1>0</Extra1><Extra2>''''||a.no_cuoi_ky||''''</Extra2><Remark>''''||a.tenky||''''</Remark></Product>''''from ( SELECT mst,kythue,'''''||l_kythue||''''' tenky,ma_tinh,sum(no_cuoi_ky) no_cuoi_ky,ma_chuong,ma_cq_thu, ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh, loai_tien,ti_gia,loai_thue
                    FROM ct_no_'||ckn||' where ma_tinh = ''''''||x.ma_tinh||'''''' group by mst,kythue,ma_tinh,ma_chuong,ma_cq_thu, ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh,loai_tien,ti_gia,loai_thue order by ma_tmuc) a, tieu_mucs d
                        where a.ma_tmuc=d.id(+) and a.MST = ''''''||x.mst||'''''' and a.kythue=''''''||b.kythue||'''''''','''') from dual)
                ||''</Products><Amount>''||b.no_cuoi_ky||''</Amount><Total></Total><VATRate></VATRate><VATAmount></VATAmount><AmountInWords><![CDATA[''||util.doisosangchu(round(b.no_cuoi_ky))||'']]></AmountInWords><Extra><![CDATA[]]></Extra></Invoice></Inv>''
                from tax.nnts_'||ckn||' x,( select sum(no_cuoi_ky) no_cuoi_ky, mst, kythue from tax.ct_no_'||ckn||'
                                                where kythue ='''||l_kythue||''' and loai_thue =10
                                                group by mst,kythue) b
                where x.mst = b.mst and x.ma_tinh ='''||i_agent||'''
              Union all
                Select ''</Invoices>'' from dual';
    Else
        l_sql := 'Select ''BAN KHONG QUYEN THAO TAC'' note from dual';
    End if;
    Open ref_ for  l_sql;
    Return  ref_;

    Exception when others then
        declare err varchar2(500);
        begin    err:='Loi thuc hien, ma loi:'||TO_CHAR(SQLCODE)||': '||SQLERRM;
            open ref_ for 'select :1 err from dual' using err; return ref_;
        End;
End;

procedure REPORT_DEPT_STAFF(
    pma_tinh varchar2,
    pma_nv varchar2,
    ptu_ngay varchar2,
    pden_ngay varchar2,
    ptype varchar2,report_out OUT SYS_REFCURSOR)
is
    s varchar2(3000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai;
    l_ten_dv varchar(200);
    l_diachi_dv varchar(500);
    l_mst_dv varchar(50);
Begin
    s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
    Execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;

    If ptype='1' then
        s:='Select '''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv,
            (select x.id||''|''||x.ten_nv from nhanvien_tcs x where x.ma_tinh='''||pma_tinh||''' and x.id=ma_nv) ma_nv, tien_giao, nvl(tien_tra,0) tien_tra, nguoi_giao
             from (select a.ma_nv,a.nguoi_giao,sum(a.tien_giao) tien_giao,sum(b.tientra) tien_tra
        from (
                select sum(a.tien_giao) tien_giao,a.ma_nv,a.nguoi_giao,a.mst from tax.phieu_'||ckn||' a
                where exists (select 1 from tax.nhanvien_tcs b where a.ma_nv=b.id and b.ma_tinh =:1)';
                if ptu_ngay is not null then
                    s:=s||' and a.ngay_giao >= to_date('''||ptu_ngay||''',''dd/mm/yyyy'')';
                end if;
                if pden_ngay is not null then
                    s:=s||' and a.ngay_giao < to_date('''||pden_ngay||''',''dd/mm/yyyy'') +1';
                end if;
                if pma_nv is not null then
                    s:=s||' and a.ma_nv = '''||pma_nv||'''';
                end if;

                s:=s||'group by a.ma_nv,a.nguoi_giao,a.mst) a,
                    (select sum(b.tientra) tientra,a.mst from tax.bangphieutra_'||ckn||' a, tax.ct_tra_'||ckn||' b
                        where a.id = b.phieu_id
                        and a.ma_tinh =:2';

                if ptu_ngay is not null then
                    s:=s||' and a.ngay_tt >= to_date('''||ptu_ngay||''',''dd/mm/yyyy'')';
                end if;
                if pden_ngay is not null then
                    s:=s||' and a.ngay_tt < to_date('''||pden_ngay||''',''dd/mm/yyyy'') +1';
                end if;

                s:=s||'group by a.mst,a.mst) b
                where a.mst = b.mst(+) group by a.ma_nv,a.nguoi_giao order by a.ma_nv)';
        Open report_out for s using pma_tinh,pma_tinh;
    Else
        s:='select  '''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv,
        (select x.id||''|''||x.ten_nv from nhanvien_tcs x where x.ma_tinh='''||pma_tinh||''' and x.id=a.ma_nv) ma_nv,
        a.mst,a.tien_giao,a.nguoi_giao,nvl(b.tientra,0) tien_tra,b.nguoigachno_id nguoi_tra,
        to_char(a.ngay_giao,''dd/mm/yyyy hh24:mi:ss'') ngay_giao,to_char(b.ngay_tt,''dd/mm/yyyy hh24:mi:ss'') ngay_tra
        from (
                select sum(a.tien_giao) tien_giao,a.ma_nv,a.nguoi_giao,a.mst,a.ngay_giao from tax.phieu_'||ckn||' a
                where exists (select 1 from tax.nhanvien_tcs b where a.ma_nv=b.id and b.ma_tinh =:1)';
                if ptu_ngay is not null then
                    s:=s||' and a.ngay_giao >= to_date('''||ptu_ngay||''',''dd/mm/yyyy'')';
                end if;
                if pden_ngay is not null then
                    s:=s||' and a.ngay_giao < to_date('''||pden_ngay||''',''dd/mm/yyyy'') +1';
                end if;
                if pma_nv is not null then
                    s:=s||' and a.ma_nv = '''||pma_nv||'''';
                end if;

                s:=s||'group by a.ma_nv,a.nguoi_giao,a.mst,a.ngay_giao) a,
                    (select sum(b.tientra) tientra,a.mst,a.nguoigachno_id,a.ngay_tt from tax.bangphieutra_'||ckn||' a, tax.ct_tra_'||ckn||' b
                        where a.id = b.phieu_id
                        and a.ma_tinh =:2';

                if ptu_ngay is not null then
                    s:=s||' and a.ngay_tt >= to_date('''||ptu_ngay||''',''dd/mm/yyyy'')';
                end if;
                if pden_ngay is not null then
                    s:=s||' and a.ngay_tt < to_date('''||pden_ngay||''',''dd/mm/yyyy'') +1';
                end if;

                s:=s||'group by a.mst,a.nguoigachno_id,a.ngay_tt) b
                where a.mst = b.mst(+) order by a.ma_nv';
        Open report_out for s using pma_tinh,pma_tinh;
    End if;


    Exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    End;
end;

procedure REPORT_DEPT(
    pma_tinh varchar2,
    ptu_ngay varchar2,
    pden_ngay varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(3000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai;
    l_ten_dv varchar(200);
    l_diachi_dv varchar(500);
    l_mst_dv varchar(50);
    l_mst_dm number;
    l_tien_dm number;
    l_mst_vtt number:=0;
    l_tien_vtt number:=0;
    l_mst_cct number:=0;
    l_tien_cct  number:=0;
    l_user_tt varchar2(200):='cct.haibatrung_hni';
Begin
    s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
    Execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;

    Execute immediate 'select count(1), sum(no_cuoi_ky) from ct_no_'||ckn||' where ma_tinh=:1' into l_mst_dm,l_tien_dm using pma_tinh;

    Execute immediate 'select count(1), nvl(sum(tientra),0) from ct_tra_'||ckn||' a
    where exists (select 1 from bangphieutra_'||ckn||' b where a.phieu_id=b.id and b.nguoigachno_id not in (:1)
                    and ngay_thuc between to_date(:2,''dd/mm/yyyy'') and to_date(:3,''dd/mm/yyyy'')) and ma_tinh=:4'
        into l_mst_vtt,l_tien_vtt using l_user_tt,ptu_ngay,pden_ngay,pma_tinh;

    Execute immediate 'select count(1) , nvl(sum(tientra),0) from ct_tra_'||ckn||' a
    where exists (select 1 from bangphieutra_'||ckn||' b where a.phieu_id=b.id and b.nguoigachno_id in (:1)
                    and b.ngay_thuc between to_date(:2,''dd/mm/yyyy'') and to_date(:3,''dd/mm/yyyy'')) and ma_tinh=:4'
        into l_mst_cct,l_tien_cct  using l_user_tt,ptu_ngay,pden_ngay,pma_tinh;


    s:='select  '''||l_ten_dv||''' ten_dv,'||l_mst_dm||' mst,'||l_tien_dm||' tien,
         '||l_mst_vtt||' mst_vtt, '||l_tien_vtt||' tien_vtt,'||l_mst_cct||' mst_cct, '||l_tien_cct||' tien_cct from dual';
    Open report_out for s;

    Exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    End;
end;

procedure REPORT_SUM_TAX(
    pma_tinh varchar2,
    pngay_tt varchar2,
    ptype varchar2,report_out OUT SYS_REFCURSOR)
is
    s varchar2(3000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai;
    l_ten_dv varchar(200);
    l_diachi_dv varchar(500);
    l_mst_dv varchar(50);
    l_user_tt varchar2(200):='cct.haibatrung_hni';
Begin
    s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
    Execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;

    if ptype='1' then
        s:='select '''||l_ten_dv||''' ten_dv, count(distinct a.mst) so1, nvl(sum(no_cuoi_ky),0) so2,count(distinct b.mst) so3, nvl(sum(b.tientra),0) so4,count(distinct c.mst) so5, nvl(sum(c.tientra),0) so6,
                (count(distinct b.mst) + count(distinct c.mst)) so7,(nvl(sum(b.tientra),0) + nvl(sum(c.tientra),0)) so8,
                (count(distinct a.mst) - (count(distinct b.mst) + count(distinct c.mst))) so9, (nvl(sum(no_cuoi_ky),0) - (nvl(sum(b.tientra),0) + nvl(sum(c.tientra),0))) so10,
                round(count(distinct b.mst)*100/count(distinct a.mst),2) so11, round(nvl(sum(b.tientra),0)*100/nvl(sum(no_cuoi_ky),0),2) so12,
                round(count(distinct c.mst)*100/count(distinct a.mst),2) so13, round(nvl(sum(c.tientra),0)*100/nvl(sum(no_cuoi_ky),0),2) so14,
                round((count(distinct b.mst)+count(distinct c.mst))*100/count(distinct a.mst),2) so15, round((nvl(sum(b.tientra),0)+nvl(sum(c.tientra),0))*100/nvl(sum(no_cuoi_ky),0),2) so16,a.kythue
                from
                (select distinct a.mst, a.no_cuoi_ky, a.kythue, a.ma_tmuc, a.chuky from ct_no_'||ckn||' a where a.ma_tinh=:1)a,
                (select distinct a.mst, a.tientra, a.kythue, a.ma_tmuc, a.chuky from ct_tra_'||ckn||' a
                    where exists (select 1 from bangphieutra_'||ckn||' b where a.phieu_id=b.id
                                    and trunc(b.ngay_tt) <= to_date(:2,''dd/mm/yyyy'')
                                        and b.ma_tinh=:3
                                        and exists (select 1 from nguoigachnos us where b.nguoigachno_id = us.id and us.vnpt=1)
                                        ))b,
                (select distinct a.mst, a.tientra, a.kythue, a.ma_tmuc, a.chuky from ct_tra_'||ckn||' a
                    where exists (select 1 from bangphieutra_'||ckn||' b where a.phieu_id=b.id
                                    and trunc(b.ngay_tt) <= to_date(:4,''dd/mm/yyyy'')
                                        and b.ma_tinh=:5
                                        and exists (select 1 from nguoigachnos us where b.nguoigachno_id = us.id and us.vnpt=0)
                                        ))c
                where a.mst = b.mst(+) and a.kythue = b.kythue(+) and a.kythue = c.kythue(+)
                and a.ma_tmuc = c.ma_tmuc(+) and  a.ma_tmuc= b.ma_tmuc(+) and a.chuky = b.chuky(+) and a.chuky = c.chuky(+)
                and a.mst = c.mst(+) group by a.kythue';
        Open report_out for s using pma_tinh,pngay_tt,pma_tinh,pngay_tt,pma_tinh;
    elsif (ptype='2') then
        s:='select '''||l_ten_dv||''' ten_dv,(select id||''|''||tentieumuc from tieu_mucs where id= a.ma_tmuc) tieu_muc,d.ma_nv,a.kythue,

                count(distinct a.mst) so1, nvl(sum(no_cuoi_ky),0) so2,count(distinct b.mst) so3, nvl(sum(b.tientra),0) so4,count(distinct c.mst) so5, nvl(sum(c.tientra),0) so6,
                (count(distinct b.mst) + count(distinct c.mst)) so7,(nvl(sum(b.tientra),0) + nvl(sum(c.tientra),0)) so8,
                (count(distinct a.mst) - (count(distinct b.mst) + count(distinct c.mst))) so9, (nvl(sum(no_cuoi_ky),0) - (nvl(sum(b.tientra),0) + nvl(sum(c.tientra),0))) so10,
                round(count(distinct b.mst)*100/count(distinct a.mst),2) so11, round(nvl(sum(b.tientra),0)*100/nvl(sum(no_cuoi_ky),0),2) so12,
                round(count(distinct c.mst)*100/count(distinct a.mst),2) so13, round(nvl(sum(c.tientra),0)*100/nvl(sum(no_cuoi_ky),0),2) so14,
                round((count(distinct b.mst)+count(distinct c.mst))*100/count(distinct a.mst),2) so15, round((nvl(sum(b.tientra),0)+nvl(sum(c.tientra),0))*100/nvl(sum(no_cuoi_ky),0),2) so16

                from
                (select distinct a.mst,a.no_cuoi_ky,a.ma_tmuc,a.kythue from ct_no_'||ckn||' a where a.ma_tinh=:1)a,
                (select distinct a.mst, a.tientra,a.ma_tmuc,a.kythue from ct_tra_'||ckn||' a
                    where exists (select 1 from bangphieutra_'||ckn||' b where a.phieu_id=b.id
                                    and trunc(b.ngay_thuc) <= to_date(:2,''dd/mm/yyyy'')
                                        and b.ma_tinh=:3
                                        and exists (select 1 from nguoigachnos us where b.nguoigachno_id = us.id and us.vnpt=1)
                                        ))b,
                (select distinct a.mst, a.tientra,a.ma_tmuc,a.kythue from ct_tra_'||ckn||' a
                    where exists (select 1 from bangphieutra_'||ckn||' b where a.phieu_id=b.id
                                    and trunc(b.ngay_thuc) <= to_date(:4,''dd/mm/yyyy'')
                                        and b.ma_tinh=:5
                                        and exists (select 1 from nguoigachnos us where b.nguoigachno_id = us.id and us.vnpt=0)
                                        ))c, nnts_'||ckn||' d
                where a.mst = b.mst(+)
                and a.mst = c.mst(+)
                and a.mst = d.mst and a.ma_tmuc = b.ma_tmuc(+) and a.ma_tmuc = c.ma_tmuc(+)
                and a.kythue = b.kythue(+) and a.kythue = c.kythue(+)
                group by a.ma_tmuc,d.ma_nv,a.kythue order by a.kythue,d.ma_nv';
        Open report_out for s using pma_tinh,pngay_tt,pma_tinh,pngay_tt,pma_tinh;
    else
        s:='select '''||l_ten_dv||''' ten_dv,
                count(distinct a.mst) so1, nvl(sum(no_cuoi_ky),0) so2,count(distinct b.mst) so3, nvl(sum(b.tientra),0) so4,count(distinct c.mst) so5, nvl(sum(c.tientra),0) so6,
                (count(distinct b.mst) + count(distinct c.mst)) so7,(nvl(sum(b.tientra),0) + nvl(sum(c.tientra),0)) so8,
                (count(distinct a.mst) - (count(distinct b.mst) + count(distinct c.mst))) so9, (nvl(sum(no_cuoi_ky),0) - (nvl(sum(b.tientra),0) + nvl(sum(c.tientra),0))) so10,
                round(count(distinct b.mst)*100/count(distinct a.mst),2) so11, round(nvl(sum(b.tientra),0)*100/nvl(sum(no_cuoi_ky),0),2) so12,
                round(count(distinct c.mst)*100/count(distinct a.mst),2) so13, round(nvl(sum(c.tientra),0)*100/nvl(sum(no_cuoi_ky),0),2) so14,
                round((count(distinct b.mst)+count(distinct c.mst))*100/count(distinct a.mst),2) so15, round((nvl(sum(b.tientra),0)+nvl(sum(c.tientra),0))*100/nvl(sum(no_cuoi_ky),0),2) so16,
                a.kythue, (select TOWN_NAME from towns where id = d.ma_xa) phuongxa
                from
                (select distinct a.mst, a.no_cuoi_ky, a.kythue, a.ma_tmuc from ct_no_'||ckn||' a where a.ma_tinh=:1)a,
                (select distinct a.mst, a.tientra, a.kythue, a.ma_tmuc from ct_tra_'||ckn||' a
                    where exists (select 1 from bangphieutra_'||ckn||' b where a.phieu_id=b.id
                                    and trunc(b.ngay_tt) <= to_date(:2,''dd/mm/yyyy'')
                                        and b.ma_tinh=:3
                                        and exists (select 1 from nguoigachnos us where b.nguoigachno_id = us.id and us.vnpt=1)
                                        ))b,
                (select distinct a.mst, a.tientra, a.kythue, a.ma_tmuc from ct_tra_'||ckn||' a
                    where exists (select 1 from bangphieutra_'||ckn||' b where a.phieu_id=b.id
                                    and trunc(b.ngay_tt) <= to_date(:4,''dd/mm/yyyy'')
                                        and b.ma_tinh=:5
                                        and exists (select 1 from nguoigachnos us where b.nguoigachno_id = us.id and us.vnpt=0)
                                        ))c, nnts_'||ckn||' d
                where a.mst = b.mst(+) and a.kythue = b.kythue(+) and a.kythue = c.kythue(+)
                and a.ma_tmuc = c.ma_tmuc(+) and  a.ma_tmuc= b.ma_tmuc(+)
                and a.mst = c.mst(+) and a.mst = d.mst group by a.kythue,d.ma_xa order by a.kythue,d.ma_xa';
        Open report_out for s using pma_tinh,pngay_tt,pma_tinh,pngay_tt,pma_tinh;
    end if;
    Exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    End;
end;

PROCEDURE REPORT_PAYMENT_ORDER(
    pma_tinh varchar2,
    pkhobac varchar2,
    pphuongxa varchar2,
    pngay_tt varchar2,
    ploaithue varchar2,
    ptype varchar2,
    report_out OUT SYS_REFCURSOR)

is
    s varchar2(10000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai;
    l_tien_tra number;
    l_tien_chu varchar(200);
    l_khobac varchar(200);
    l_ten_dv varchar(200);
    l_diachi_dv varchar(500);
    l_mst_dv varchar(50);
    l_tmonbai number :=0;
    l_gtgt number :=0;
    l_tncn number :=0;
    l_ttdb number :=0;
    l_tainguyen number :=0;
    l_bvmt number :=0;
    l_vat_bvmt number :=0;
    l_thuphat number :=0;
    l_chamnop number :=0;
    l_1801 number :=0;
    l_1802 number :=0;
    l_1803 number :=0;
    l_1804 number :=0;
    l_1805 number :=0;
    l_1806 number :=0;
    l_1701 number :=0;
    l_1003 number :=0;
    l_1757 number :=0;
    l_1599 number :=0;
    l_2000 number :=0;
    l_4268 number :=0;
    l_4911 number :=0;
    l_time number;
    l_ten_cct varchar2(100);
    l_day number;
    l_phuongxa varchar2(100);
    l_diaban varchar2(100);
    l_monbai number;
    l_mamuc number:=1800;
    l_districts varchar2(200);
    l_provinces varchar2(200);
    l_cqt number;
    l_coquan varchar2(1000);
    l_cus_add VARCHAR2(500);
    l_cus_name VARCHAR2(500);
    l_cus_mst VARCHAR2(100);
    l_cus_quan VARCHAR2(50);
    l_quan VARCHAR2(50);
    l_nhtm_unthu VARCHAR2(500);
    l_nhtm_mst VARCHAR2(500);
begin
    --Lay ten chi cuc thue quan ly
    Execute immediate 'select ten_cqt from coquanthus where shkb =:1 and ma_tinh =:2 and rownum=1'
        into l_ten_cct using pkhobac,pma_tinh;

    --Lay thong tin cau hinh thoi gian cho du lieu
    Execute immediate' SELECT expire_time FROM tax.config_special_days WHERE agent =:1 and status=1 and rownum =1'
        into l_time Using pma_tinh;

    --Check loai thue mon bai
    select count(1) into l_monbai from tieu_mucs where id =ploaithue and ma_muc =l_mamuc;

    --l_day := check_time_exception(i_agent=> pma_tinh);
    l_day := check_time_extend(I_DAY=> pngay_tt, I_AGENT=> pma_tinh);
    l_day := l_day +1;

    if ptype=1 then --GIAY NOP TIEN
        if pma_tinh ='79TTT' then
            s:='select sum(a.tientra) tong_tien, tax.util.doisosangchu(sum(a.tientra))
              from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f, nguoigachnos g
              where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
              and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+) and a.ma_tmuc=e.id(+) and a.phieu_id=f.id
              and g.id = f.nguoigachno_id and g.vnpt =1 and c.shkb =:1
            and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
            and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400
            and f.ma_tinh =:2';
            s:=s||' and nvl(b.ma_xa,b.ma_xa_tt) = '''||pphuongxa||'''';
            execute immediate s into l_tien_tra,l_tien_chu using pkhobac,pma_tinh;

            /*s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
            execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;*/
            /*UPDATE 12/09/16*/
            s:='SELECT a.name_tin,a.add_tin,a.tin_ref,a.quan_tin,a.cus_tin,a.add_cus_tin,a.tin,a.quan_cus_tin,a.nhtm_uynhiemthu,a.nhtm_mst
            FROM tax.config_contract a WHERE EXISTS(SELECT 1 FROM coquanthus b WHERE a.id_ref=b.cqt_tms AND b.shkb=:1 and rownum <2)';
            execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv,l_quan,l_cus_name,l_cus_add,l_cus_mst,l_cus_quan,l_nhtm_unthu,l_nhtm_mst using pkhobac;

            Begin
                select id,ten_cqt into l_cqt,l_coquan from coquanthus where shkb = pkhobac and rownum=1;
                Exception when others then
                    l_cqt :=0;l_coquan := pkhobac;
            End;

            --lay thong tin quan/tinh
            begin
                select district_name into l_districts from districts where id in (select ma_huyen from coquanthus where shkb=pkhobac) and rownum=1;
                select province_name into l_provinces from provinces where id=pma_tinh;
                exception when others then
                    l_districts :=''; l_provinces :='';
            end;

            --lay thong tin dia ban
            begin
                select town_name into l_diaban from towns where id=pphuongxa and rownum =1;
                exception when others then
                    l_diaban := pphuongxa;
            end;

            s:='select rownum stt,'''||l_ten_cct||''' ten_cct,'||l_tien_tra||' tong_tien,'''||l_tien_chu||''' tong_tien_chu, tientra tien_tra,
                ma_chuong,ten_muc,ma_tmuc,'''||l_districts||''' quan,'''||l_provinces||''' tinh,'''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv,
                '''||l_mst_dv||''' mst_dv, '||l_cqt||' ma_cqt, '''||pphuongxa||''' diaban,
                ''- ''||'''||l_coquan||'''||'' - ''||'''||l_diaban||''' tt_diaban,'''||l_quan||''' quan_nop, '''||l_cus_name||''' ten_thay,
                '''||l_cus_add||''' diachi_thay, '''||l_cus_mst||''' mst_thay,'''||l_cus_quan||''' quan_thay,'''||l_nhtm_unthu||''' nhtm_unthu,'''||l_nhtm_mst||''' nhtm_mst
              from (
              select sum(tientra) tientra,tentieumuc ten_muc,ma_tmuc,ma_chuong from
              (
                  select a.tientra,d.ten_chuong,e.tentieumuc,a.ma_tmuc,a.ma_chuong
                  from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f,nguoigachnos g
                  where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
                  and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+)
                  and a.ma_tmuc=e.id(+) and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1';

            s:=s||' and c.shkb='''||pkhobac||'''';
            s:=s||' and nvl(b.ma_xa,b.ma_xa_tt) = '''||pphuongxa||'''';

            s:=s||' and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
                        and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400';

            s:=s||' and f.ma_tinh='''||pma_tinh||'''
                  ) group by ma_chuong,ma_tmuc,tentieumuc) order by ma_chuong,ma_tmuc';
        else
            if l_monbai >0 then
                select town_name into l_phuongxa from towns where id=pphuongxa and rownum=1;

                s:='select sum(a.tientra) tong_tien, tax.util.doisosangchu(sum(a.tientra))
                  from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f, nguoigachnos g
                  where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
                  and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+) and a.ma_tmuc=e.id(+) and a.phieu_id=f.id
                  and g.id = f.nguoigachno_id and g.vnpt =1 and c.shkb =:1
                and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
                and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400
                and f.ma_tinh =:2';
                if l_monbai >0 then s:=s||' and e.ma_muc = '||l_mamuc||' and nvl(b.ma_xa,b.ma_xa_tt) = '''||pphuongxa||'''';
                else s:=s||' and e.id = '||ploaithue||''; end if;

                execute immediate s into l_tien_tra,l_tien_chu using pkhobac,pma_tinh;

               /* s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
                execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;*/
                 /*UPDATE 12/09/16*/
                s:='SELECT a.name_tin,a.add_tin,a.tin_ref,a.quan_tin,a.cus_tin,a.add_cus_tin,a.tin,a.quan_cus_tin,a.nhtm_uynhiemthu,a.nhtm_mst
                FROM tax.config_contract a WHERE EXISTS(SELECT 1 FROM coquanthus b WHERE a.id_ref=b.cqt_tms AND b.shkb=:1 and rownum <2)';
                execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv,l_quan,l_cus_name,l_cus_add,l_cus_mst,l_cus_quan,l_nhtm_unthu,l_nhtm_mst using pkhobac;

                s:='select rownum stt,'''||l_ten_cct||''' ten_cct,'||l_tien_tra||' tong_tien,'''||l_tien_chu||''' tong_tien_chu, tientra tien_tra,
                    ma_chuong,ten_muc ||'' - ''||'''||l_phuongxa||''' ten_muc,ma_tmuc,quan,tinh,'''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv,
                    '''||l_mst_dv||''' mst_dv,'''||l_quan||''' quan_nop, '''||l_cus_name||''' ten_thay,
                    '''||l_cus_add||''' diachi_thay, '''||l_cus_mst||''' mst_thay,'''||l_cus_quan||''' quan_thay,'''||l_nhtm_unthu||''' nhtm_unthu,'''||l_nhtm_mst||''' nhtm_mst
                  from (
                  select sum(tientra) tientra,tentieumuc ten_muc,ma_tmuc,ma_chuong,quan,tinh from
                  (
                      select a.tientra,d.ten_chuong,e.tentieumuc,a.ma_tmuc,a.ma_chuong,
                      (select district_name from districts where id =b.ma_huyen and rownum=1) quan,
                      (select province_name from provinces where id =b.ma_tinh and rownum=1) tinh
                      from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f,nguoigachnos g
                      where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
                      and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+)
                      and a.ma_tmuc=e.id(+) and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1';

                s:=s||' and c.shkb='''||pkhobac||'''';
                if l_monbai >0 then s:=s||' and e.ma_muc = '||l_mamuc||' and nvl(b.ma_xa,b.ma_xa_tt) = '''||pphuongxa||'''';
                    else s:=s||' and e.id = '||ploaithue||''; end if;

                s:=s||' and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
                            and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400';

                s:=s||' and f.ma_tinh='''||pma_tinh||'''
                      ) group by ma_chuong,ma_tmuc,tentieumuc,quan,tinh) order by ma_chuong,ma_tmuc';
            else
                s:='select sum(a.tientra) tong_tien, tax.util.doisosangchu(sum(a.tientra))
                  from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f, nguoigachnos g
                  where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
                  and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+) and a.ma_tmuc=e.id(+) and a.phieu_id=f.id
                  and g.id = f.nguoigachno_id and g.vnpt =1 and c.shkb =:1
                and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
                and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400
                and f.ma_tinh =:2';
                if l_monbai >0 then s:=s||' and e.ma_muc = '||l_mamuc||' and nvl(b.ma_xa,b.ma_xa_tt) = '''||pphuongxa||'''';
                else s:=s||' and e.id = '||ploaithue||''; end if;

                execute immediate s into l_tien_tra,l_tien_chu using pkhobac,pma_tinh;

                /*s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
                execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;*/
                 /*UPDATE 12/09/16*/
                s:='SELECT a.name_tin,a.add_tin,a.tin_ref,a.quan_tin,a.cus_tin,a.add_cus_tin,a.tin,a.quan_cus_tin,a.nhtm_uynhiemthu,a.nhtm_mst
                FROM tax.config_contract a WHERE EXISTS(SELECT 1 FROM coquanthus b WHERE a.id_ref=b.cqt_tms AND b.shkb=:1 and rownum <2)';
                execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv,l_quan,l_cus_name,l_cus_add,l_cus_mst,l_cus_quan,l_nhtm_unthu,l_nhtm_mst using pkhobac;

                --lay thong tin quan/tinh
                begin
                    select district_name into l_districts from districts where id in (select ma_huyen from coquanthus where shkb=pkhobac) and rownum=1;
                    select province_name into l_provinces from provinces where id=pma_tinh;
                    exception when others then
                        l_districts :=''; l_provinces :='';
                end;
                s:='select rownum stt,'''||l_ten_cct||''' ten_cct,'||l_tien_tra||' tong_tien,'''||l_tien_chu||''' tong_tien_chu, tientra tien_tra,
                     ma_chuong,ten_muc,ma_tmuc,'''||l_districts||''' quan,'''||l_provinces||''' tinh,'''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv,
                     '''||l_mst_dv||''' mst_dv,'''||l_quan||''' quan_nop, '''||l_cus_name||''' ten_thay,
                     '''||l_cus_add||''' diachi_thay, '''||l_cus_mst||''' mst_thay,'''||l_cus_quan||''' quan_thay,'''||l_nhtm_unthu||''' nhtm_unthu,'''||l_nhtm_mst||''' nhtm_mst
                  from (
                  select sum(tientra) tientra,tentieumuc ten_muc,ma_tmuc,ma_chuong from
                  (
                      select a.tientra,d.ten_chuong,e.tentieumuc,a.ma_tmuc,a.ma_chuong
                      from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f,nguoigachnos g
                      where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
                      and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+)
                      and a.ma_tmuc=e.id(+) and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1';

                s:=s||' and c.shkb='''||pkhobac||'''';
                if l_monbai >0 then s:=s||' and e.ma_muc = '||l_mamuc||' and nvl(b.ma_xa,b.ma_xa_tt) = '''||pphuongxa||'''';
                    else s:=s||' and e.id = '||ploaithue||''; end if;

                s:=s||' and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
                            and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400';

                s:=s||' and f.ma_tinh='''||pma_tinh||'''
                      ) group by ma_chuong,ma_tmuc,tentieumuc) order by ma_chuong,ma_tmuc';
            end if;
        end if;
    elsif (ptype=2) then --BANG KE CHI TIET
        if l_monbai >0 then
            select town_name into l_phuongxa from towns where id=pphuongxa and rownum=1;
        end if;
       /* s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
        execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;*/
        /*UPDATE 31/08/16*/
         s:='SELECT a.cus_tin,a.add_cus_tin,a.tin FROM tax.config_contract a WHERE
         EXISTS(SELECT 1 FROM coquanthus b WHERE a.id_ref=b.cqt_tms AND b.shkb=:1 and rownum <2)';
         execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pkhobac;

        --lay thong tin dia ban
        begin
            select town_name into l_diaban from towns where id=pphuongxa and rownum =1;
            exception when others then
                l_diaban := pphuongxa;
        end;

        --lay thong tin co quan thue
        Begin
            select id,ten_cqt into l_cqt,l_coquan from coquanthus where shkb = pkhobac and rownum=1;
            Exception when others then
                l_cqt :=0;l_coquan := pkhobac;
        End;

        if pma_tinh='79TTT' then
            s:='select sum(a.tientra) tong_tien, tax.util.doisosangchu(sum(a.tientra))
              from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f,nguoigachnos g
              where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
              and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+) and a.ma_tmuc=e.id(+)
              and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1 and c.shkb =:1
            and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
            and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400
            and f.ma_tinh =:2
            and nvl(b.ma_xa,b.ma_xa_tt) = '''||pphuongxa||'''';
            execute immediate s into l_tien_tra,l_tien_chu using pkhobac,pma_tinh;

            --Tong cac tieu muc thue mon bai
            s:='select sum(monbai1),sum(monbai2),sum(monbai3),sum(monbai4),sum(monbai5),sum(monbai6),
                sum(gtgt),sum(tncn),sum(ttdb),sum(tainguyen),sum(bvmt),sum(thuphat),sum(chamnop) from ( select
                case when ma_tmuc =1801 then sum(tientra)  else 0 end monbai1,
                case when ma_tmuc =1802 then sum(tientra)  else 0 end monbai2,
                case when ma_tmuc =1803 then sum(tientra)  else 0 end monbai3,
                case when ma_tmuc =1804 then sum(tientra)  else 0 end monbai4,
                case when ma_tmuc =1805 then sum(tientra)  else 0 end monbai5,
                case when ma_tmuc =1806 then sum(tientra)  else 0 end monbai6,
                case when ma_tmuc =1701 then sum(tientra)  else 0 end gtgt,
                case when ma_tmuc =1003 then sum(tientra)  else 0 end tncn,
                case when ma_tmuc =1757 then sum(tientra)  else 0 end ttdb,
                case when ma_tmuc =1599 then sum(tientra)  else 0 end tainguyen,
                case when ma_tmuc in (2001,2002,2003,2004,2005,2006,2007,2008,2009,2019,2041,2042,2043,2044,2045) then sum(tientra)  else 0 end bvmt,
                case when ma_tmuc in (4268,4272,4254) then sum(tientra)  else 0 end thuphat,
                case when ma_tmuc in (4911,4268,4272) then sum(tientra)  else 0 end chamnop
              from (
              select sum(tientra) tientra,ma_tmuc from
              (
                  select b.mst,a.tientra,d.ten_chuong,e.tentieumuc,a.ma_chuong,a.ma_tmuc,b.ten_nnt,f.id so, f.ngay_tt ngay
                  from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f,nguoigachnos g
                  where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
                  and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+)
                  and a.ma_tmuc=e.id(+) and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1';
            s:=s||' and c.shkb='''||pkhobac||'''
                    and nvl(b.ma_xa,b.ma_xa_tt) = '''||pphuongxa||'''
                     and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
                        and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400
                        and f.ma_tinh='''||pma_tinh||'''
                  ) group by ma_tmuc
                  ) group by ma_tmuc)';
            execute immediate s into l_1801,l_1802,l_1803,l_1804,l_1805,l_1806,l_1701,l_1003,l_1757,l_1599,l_2000,l_4268,l_4911;

            --Insert du lieu vao bang log tax.bangke_gnt
            s:='select rownum stt,'''||l_ten_cct||''' ten_cct, '||l_tien_tra||' tong_tien,'''||l_tien_chu||''' tong_tien_chu,
                case when ma_tmuc in (1801,1802,1803,1804,1805,1806) then tientra  else 0 end monbai,
                case when ma_tmuc =1701 then tientra  else 0 end gtgt,
                case when ma_tmuc =1003 then tientra  else 0 end tncn,
                case when ma_tmuc =1757 then tientra  else 0 end ttdb,
                case when ma_tmuc =1599 then tientra  else 0 end tainguyen,
                case when ma_tmuc in (2001,2002,2003,2004,2005,2006,2007,2008,2009,2019,2041,2042,2043,2044,2045) then tientra  else 0 end bvmt,0 vat_bvmt,
                case when ma_tmuc in (4268,4272,4254) then tientra  else 0 end thuphat,
                case when ma_tmuc =4911 then tientra  else 0 end chamnop,
                tientra tien_tra,ma_chuong,ma_tmuc,kythue,ten_nnt,mst,so,to_char(ngay,''dd/mm/yyyy'') ngay,
                '''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv,'''||pphuongxa||''' diaban,
                '||l_1801||' t1801,'||l_1802||' t1802,'||l_1803||' t1803,'||l_1804||' t1804,'||l_1805||' t1805,'||l_1806||' t1806,
                '||l_1701||' t1701,'||l_1003||' t1003,'||l_1757||' t1757,'||l_1599||' t1599,'||l_2000||' t2000,'||l_4268||' t4268,'||l_4911||' t4911,
                '''' kyhieu,''- ''||'''||l_coquan||'''||'' - ''||'''||l_diaban||''' tt_diaban
              from (
              select mst,sum(tientra) tientra,ma_chuong,ma_tmuc,chuky kythue,ten_nnt,so,ngay from
              (
                  select b.mst,a.tientra,d.ten_chuong,e.tentieumuc,a.ma_chuong,a.ma_tmuc,a.chuky,b.ten_nnt,f.id so, f.ngay_tt ngay
                  from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f,nguoigachnos g
                  where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
                  and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+)
                  and a.ma_tmuc=e.id(+) and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1';
            s:=s||' and c.shkb='''||pkhobac||'''';

            s:=s||' and nvl(b.ma_xa,b.ma_xa_tt) = '''||pphuongxa||'''';
            s:=s||' and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
                        and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400';

            s:=s||' and f.ma_tinh='''||pma_tinh||'''
                  ) group by mst,ma_chuong,ma_tmuc,chuky,ten_nnt,so,ngay order by mst)';
        else
            s:='select sum(a.tientra) tong_tien, tax.util.doisosangchu(sum(a.tientra))
              from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f,nguoigachnos g
              where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
              and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+) and a.ma_tmuc=e.id(+)
              and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1 and c.shkb =:1
            and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
            and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400
            and f.ma_tinh =:2';

            if l_monbai >0 then s:=s||' and e.ma_muc = '||l_mamuc||' and nvl(b.ma_xa,b.ma_xa_tt) = '''||pphuongxa||'''';
                else s:=s||' and e.id = '||ploaithue||'';
            end if;
            execute immediate s into l_tien_tra,l_tien_chu using pkhobac,pma_tinh;

            --Insert du lieu vao bang log tax.bangke_gnt
            s:='select rownum stt,'''||l_ten_cct||''' ten_cct, '||l_tien_tra||' tong_tien,'''||l_tien_chu||''' tong_tien_chu,
                case when ma_tmuc in (1801,1802,1803,1804,1805,1806) then tientra  else 0 end monbai,
                case when ma_tmuc =1701 then tientra  else 0 end gtgt,
                case when ma_tmuc =1003 then tientra  else 0 end tncn,
                case when ma_tmuc =1757 then tientra  else 0 end ttdb,
                case when ma_tmuc =1599 then tientra  else 0 end tainguyen,
                case when ma_tmuc in (2001,2002,2003,2004,2005,2006,2007,2008,2009,2019,2041,2042,2043,2044,2045) then tientra  else 0 end bvmt,0 vat_bvmt,
                case when ma_tmuc in (4268,4272,4254) then tientra  else 0 end thuphat,
                case when ma_tmuc =4911 then tientra  else 0 end chamnop,
                tientra tien_tra,ma_chuong,ma_tmuc,ten_nnt,mst,so,to_char(ngay,''dd/mm/yyyy'') ngay,
                '''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv
              from (
              select mst,sum(tientra) tientra,ma_chuong,ma_tmuc,ten_nnt,so,ngay from
              (
                  select b.mst,a.tientra,d.ten_chuong,e.tentieumuc,a.ma_chuong,a.ma_tmuc,b.ten_nnt,f.id so, f.ngay_tt ngay
                  from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f,nguoigachnos g
                  where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
                  and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+)
                  and a.ma_tmuc=e.id(+) and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1';
            s:=s||' and c.shkb='''||pkhobac||'''';

            if l_monbai >0 then s:=s||' and e.ma_muc = '||l_mamuc||' and nvl(b.ma_xa,b.ma_xa_tt) = '''||pphuongxa||'''';
                else s:=s||' and e.id = '||ploaithue||'';
            end if;
            s:=s||' and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
                        and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400';

            s:=s||' and f.ma_tinh='''||pma_tinh||'''
                  ) group by mst,ma_chuong,ma_tmuc,ten_nnt,so,ngay order by mst)';
        end if;
    elsif (ptype=3) then --TONG THEO PHUONG
        s:='select sum(a.tientra) tong_tien, tax.util.doisosangchu(sum(a.tientra))
              from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f, nguoigachnos g
              where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
              and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+) and a.ma_tmuc=e.id(+) and a.phieu_id=f.id
              and g.id = f.nguoigachno_id and g.vnpt =1 and c.shkb =:1
        and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
        and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400
        and f.ma_tinh =:2 ';
        execute immediate s into l_tien_tra,l_tien_chu using pkhobac,pma_tinh;

        /*s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
        execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;*/
        /*UPDATE 31/08/16*/
         s:='SELECT a.cus_tin,a.add_cus_tin,a.tin FROM tax.config_contract a WHERE
         EXISTS(SELECT 1 FROM coquanthus b WHERE a.id_ref=b.cqt_tms AND b.shkb=:1 and rownum <2)';
         execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pkhobac;

        s:='select rownum stt,'''||l_ten_cct||''' ten_cct,'||l_tien_tra||' tong_tien,'''||l_tien_chu||''' tong_tien_chu, tientra tien_tra,
            nvl(ten_phuong,''ERROR'') ten_phuong,ma_chuong,ten_muc,ma_tmuc,quan,tinh,'''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv
          from (
          select sum(tientra) tientra,tentieumuc ten_muc,ma_tmuc,ma_chuong,quan,tinh,ten_phuong from
          (
              select a.tientra,d.ten_chuong,e.tentieumuc,a.ma_tmuc,a.ma_chuong,
              (select district_name from districts where id =b.ma_huyen and rownum=1) quan,
              (select province_name from provinces where id =b.ma_tinh and rownum=1) tinh,(select id||''|''||town_name from towns where id=b.ma_xa) ten_phuong
              from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e,
               bangphieutra_'||CKN||' f,nguoigachnos g
              where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
              and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+)
              and a.ma_tmuc=e.id(+) and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1';

        s:=s||' and c.shkb='''||pkhobac||'''';
        s:=s||' and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
                    and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400';

        s:=s||' and f.ma_tinh='''||pma_tinh||'''
              ) group by ten_phuong,ma_chuong,ma_tmuc,tentieumuc,quan,tinh) order by ten_phuong,ma_chuong,ma_tmuc';
    elsif (ptype=4) then --CHI TIET THEO PHUONG
        s:='select sum(a.tientra) tong_tien, tax.util.doisosangchu(sum(a.tientra))
              from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f, nguoigachnos g
              where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
              and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+) and a.ma_tmuc=e.id(+) and a.phieu_id=f.id
              and g.id = f.nguoigachno_id and g.vnpt =1 and c.shkb =:1
        and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
        and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400
        and f.ma_tinh =:2 ';
        execute immediate s into l_tien_tra,l_tien_chu using pkhobac,pma_tinh;

        /*s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
        execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;*/
        /*UPDATE 31/08/16*/
         s:='SELECT a.cus_tin,a.add_cus_tin,a.tin FROM tax.config_contract a WHERE
         EXISTS(SELECT 1 FROM coquanthus b WHERE a.id_ref=b.cqt_tms AND b.shkb=:1 and rownum <2)';
         execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pkhobac;

        s:='select rownum stt,'''||l_ten_cct||''' ten_cct,'||l_tien_tra||' tong_tien,'''||l_tien_chu||''' tong_tien_chu,
                a.mst,a.tientra tien_tra,a.ma_chuong,a.ma_tmuc,to_char(b.ngay_tt,''dd/mm/yyyy hh24:mi:ss'') ngay_tt,
                g.ten_nnt ten, g.mota_diachi diachi,g.ma_xa phuong,(select id||''|''||town_name from towns where id =g.ma_xa) ten_phuong,
                '''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv
            from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b,tax.nnts_'||ckn||' g,tax.nguoigachnos c
                where a.phieu_id = b.id
                and a.mst = g.mst and a.ma_cq_thu = g.ma_cqt_ql
                and a.ma_tinh = g.ma_tinh
                and a.ma_tinh ='''||pma_tinh||'''
                and c.id = b.nguoigachno_id and c.vnpt =1
                and b.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
                and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400
            order by g.ma_xa,a.ma_tmuc,b.ngay_thuc';
    elsif (ptype=5) then
        s:='select sum(a.tientra) tong_tien, tax.util.doisosangchu(sum(a.tientra))
              from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f, nguoigachnos g
              where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
              and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+) and a.ma_tmuc=e.id(+) and a.phieu_id=f.id
              and g.id = f.nguoigachno_id and g.vnpt =1 and c.shkb =:1 and e.ma_muc != '||l_mamuc||'
        and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
        and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400
        and f.ma_tinh =:2';
        execute immediate s into l_tien_tra,l_tien_chu using pkhobac,pma_tinh;

        /*s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
        execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;*/
        /*UPDATE 81/08/16*/
         s:='SELECT a.name_tin,a.add_tin,a.tin_ref FROM tax.config_contract a WHERE
         EXISTS(SELECT 1 FROM coquanthus b WHERE a.id_ref=b.cqt_tms AND b.shkb=:1 and rownum <2)';
         execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pkhobac;

        s:='select rownum stt,'''||l_ten_cct||''' ten_cct,'||l_tien_tra||' tong_tien,'''||l_tien_chu||''' tong_tien_chu, tientra tien_tra,
            ma_chuong,ten_muc,ma_tmuc,quan,tinh,'''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv
          from (
          select sum(tientra) tientra,tentieumuc ten_muc,ma_tmuc,ma_chuong,quan,tinh from
          (
              select a.tientra,d.ten_chuong,e.tentieumuc,a.ma_tmuc,a.ma_chuong,
              (select district_name from districts where id =b.ma_huyen and rownum=1) quan,
              (select province_name from provinces where id =b.ma_tinh and rownum=1) tinh
              from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f,nguoigachnos g
              where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
              and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+)
              and a.ma_tmuc=e.id(+) and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1 and e.ma_muc != '||l_mamuc||'';

        s:=s||' and c.shkb='''||pkhobac||'''';
        s:=s||' and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
                    and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400';

        s:=s||' and f.ma_tinh='''||pma_tinh||'''
              ) group by ma_chuong,ma_tmuc,tentieumuc,quan,tinh) order by ma_chuong,ma_tmuc';
    elsif (ptype=6) then --CHI TIET THEO TIEU MUC
        s:='select sum(a.tientra) tong_tien, tax.util.doisosangchu(sum(a.tientra))
              from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f, nguoigachnos g
              where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
              and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+) and a.ma_tmuc=e.id(+) and a.phieu_id=f.id
              and g.id = f.nguoigachno_id and g.vnpt =1 and c.shkb =:1
        and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
        and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400
        and f.ma_tinh =:2 ';
        execute immediate s into l_tien_tra,l_tien_chu using pkhobac,pma_tinh;

       /* s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
        execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;*/
        /*UPDATE 31/08/16*/
         s:='SELECT a.name_tin,a.add_tin,a.tin_ref FROM tax.config_contract a WHERE
         EXISTS(SELECT 1 FROM coquanthus b WHERE a.id_ref=b.cqt_tms AND b.shkb=:1 and rownum <2)';
         execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pkhobac;

        s:='select rownum stt,'''||l_ten_cct||''' ten_cct,'||l_tien_tra||' tong_tien,'''||l_tien_chu||''' tong_tien_chu,
                a.mst,a.tientra tien_tra,a.ma_chuong,a.ma_tmuc,to_char(b.ngay_tt,''dd/mm/yyyy hh24:mi:ss'') ngay_tt,
                g.ten_nnt ten, g.mota_diachi diachi,g.ma_xa phuong,(select id||''|''||town_name from towns where id =g.ma_xa) ten_phuong,
                '''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv,
                (select tentieumuc from tieu_mucs where id =a.ma_tmuc and rownum=1) ten_muc
            from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b,tax.nnts_'||ckn||' g,tax.nguoigachnos c,tax.coquanthus d
                where a.phieu_id = b.id
                and a.mst = g.mst and a.ma_cq_thu = g.ma_cqt_ql
                and g.ma_cqt_ql=d.cqt_tms
                and d.shkb ='''||pkhobac||'''
                and a.ma_tinh = g.ma_tinh
                and a.ma_tinh ='''||pma_tinh||'''
                and c.id = b.nguoigachno_id and c.vnpt =1
                and b.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
                and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400
            order by a.ma_tmuc';
    elsif (ptype=7) then
        --lay thong tin co quan thue
        Begin
            select id,ten_cqt into l_cqt,l_coquan from coquanthus where shkb = pkhobac and rownum=1;
            Exception when others then
                l_cqt :=0;l_coquan := pkhobac;
        End;

        if pma_tinh='79TTT' then
            s:='select sum(a.tientra) tong_tien, tax.util.doisosangchu(sum(a.tientra))
              from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f,nguoigachnos g
              where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
              and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+) and a.ma_tmuc=e.id(+)
              and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1 and c.shkb =:1
            and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
            and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400
            and f.ma_tinh =:2';
            execute immediate s into l_tien_tra,l_tien_chu using pkhobac,pma_tinh;

            --Tong cac tieu muc thue mon bai
            s:='select sum(monbai1),sum(monbai2),sum(monbai3),sum(monbai4),sum(monbai5),sum(monbai6),
                sum(gtgt),sum(tncn),sum(ttdb),sum(tainguyen),sum(bvmt),sum(thuphat),sum(chamnop) from ( select
                case when ma_tmuc =1801 then sum(tientra)  else 0 end monbai1,
                case when ma_tmuc =1802 then sum(tientra)  else 0 end monbai2,
                case when ma_tmuc =1803 then sum(tientra)  else 0 end monbai3,
                case when ma_tmuc =1804 then sum(tientra)  else 0 end monbai4,
                case when ma_tmuc =1805 then sum(tientra)  else 0 end monbai5,
                case when ma_tmuc =1806 then sum(tientra)  else 0 end monbai6,
                case when ma_tmuc =1701 then sum(tientra)  else 0 end gtgt,
                case when ma_tmuc =1003 then sum(tientra)  else 0 end tncn,
                case when ma_tmuc =1757 then sum(tientra)  else 0 end ttdb,
                case when ma_tmuc =1599 then sum(tientra)  else 0 end tainguyen,
                case when ma_tmuc in (2001,2002,2003,2004,2005,2006,2007,2008,2009,2019,2041,2042,2043,2044,2045) then sum(tientra)  else 0 end bvmt,
                case when ma_tmuc in (4268,4272,4254) then sum(tientra)  else 0 end thuphat,
                case when ma_tmuc in (4911,4268,4272) then sum(tientra)  else 0 end chamnop
              from (
              select sum(tientra) tientra,ma_tmuc from
              (
                  select b.mst,a.tientra,d.ten_chuong,e.tentieumuc,a.ma_chuong,a.ma_tmuc,b.ten_nnt,f.id so, f.ngay_tt ngay
                  from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f,nguoigachnos g
                  where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
                  and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+)
                  and a.ma_tmuc=e.id(+) and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1';
            s:=s||' and c.shkb='''||pkhobac||'''
                     and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
                        and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400
                        and f.ma_tinh='''||pma_tinh||'''
                  ) group by ma_tmuc
                  ) group by ma_tmuc)';
            execute immediate s into l_1801,l_1802,l_1803,l_1804,l_1805,l_1806,l_1701,l_1003,l_1757,l_1599,l_2000,l_4268,l_4911;

            --Insert du lieu vao bang log tax.bangke_gnt
            s:='select rownum stt,'''||l_ten_cct||''' ten_cct, '||l_tien_tra||' tong_tien,'''||l_tien_chu||''' tong_tien_chu,
                case when ma_tmuc in (1801,1802,1803,1804,1805,1806) then tientra  else 0 end monbai,
                case when ma_tmuc =1701 then tientra  else 0 end gtgt,
                case when ma_tmuc =1003 then tientra  else 0 end tncn,
                case when ma_tmuc =1757 then tientra  else 0 end ttdb,
                case when ma_tmuc =1599 then tientra  else 0 end tainguyen,
                case when ma_tmuc in (2001,2002,2003,2004,2005,2006,2007,2008,2009,2019,2041,2042,2043,2044,2045) then tientra  else 0 end bvmt,0 vat_bvmt,
                case when ma_tmuc in (4268,4272,4254) then tientra  else 0 end thuphat,
                case when ma_tmuc =4911 then tientra  else 0 end chamnop,
                tientra tien_tra,ma_chuong,ma_tmuc,kythue,ten_nnt,mst,so,to_char(ngay,''dd/mm/yyyy'') ngay,phuongxa,
                '''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv,'''||pphuongxa||''' diaban,
                '||l_1801||' t1801,'||l_1802||' t1802,'||l_1803||' t1803,'||l_1804||' t1804,'||l_1805||' t1805,'||l_1806||' t1806,
                '||l_1701||' t1701,'||l_1003||' t1003,'||l_1757||' t1757,'||l_1599||' t1599,'||l_2000||' t2000,'||l_4268||' t4268,'||l_4911||' t4911,
                '''' kyhieu
              from (
              select mst,sum(tientra) tientra,ma_chuong,ma_tmuc,chuky kythue,ten_nnt,so,ngay,phuongxa from
              (
                  select b.mst,a.tientra,d.ten_chuong,e.tentieumuc,a.ma_chuong,a.ma_tmuc,a.chuky,b.ten_nnt,f.id so, f.ngay_tt ngay,
                        (select id||''|''||town_name from towns where id =b.ma_xa) phuongxa
                  from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f,nguoigachnos g
                  where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
                  and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+)
                  and a.ma_tmuc=e.id(+) and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1';
            s:=s||' and c.shkb='''||pkhobac||'''';

            s:=s||' and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
                        and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400';

            s:=s||' and f.ma_tinh='''||pma_tinh||'''
                  ) group by mst,ma_chuong,ma_tmuc,chuky,ten_nnt,so,ngay,phuongxa order by phuongxa,mst)';
        else
            s:='select sum(a.tientra) tong_tien, tax.util.doisosangchu(sum(a.tientra))
              from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f,nguoigachnos g
              where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
              and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+) and a.ma_tmuc=e.id(+)
              and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1 and c.shkb =:1
            and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
            and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400
            and f.ma_tinh =:2';
            execute immediate s into l_tien_tra,l_tien_chu using pkhobac,pma_tinh;

            --Insert du lieu vao bang log tax.bangke_gnt
            s:='select rownum stt,'''||l_ten_cct||''' ten_cct, '||l_tien_tra||' tong_tien,'''||l_tien_chu||''' tong_tien_chu,
                case when ma_tmuc in (1801,1802,1803,1804,1805,1806) then tientra  else 0 end monbai,
                case when ma_tmuc =1701 then tientra  else 0 end gtgt,
                case when ma_tmuc =1003 then tientra  else 0 end tncn,
                case when ma_tmuc =1757 then tientra  else 0 end ttdb,
                case when ma_tmuc =1599 then tientra  else 0 end tainguyen,
                case when ma_tmuc in (2001,2002,2003,2004,2005,2006,2007,2008,2009,2019,2041,2042,2043,2044,2045) then tientra  else 0 end bvmt,0 vat_bvmt,
                case when ma_tmuc in (4268,4272,4254) then tientra  else 0 end thuphat,
                case when ma_tmuc =4911 then tientra  else 0 end chamnop,
                tientra tien_tra,ma_chuong,ma_tmuc,ten_nnt,mst,so,to_char(ngay,''dd/mm/yyyy'') ngay,phuongxa,
                '''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv
              from (
              select mst,sum(tientra) tientra,ma_chuong,ma_tmuc,ten_nnt,so,ngay,phuongxa from
              (
                  select b.mst,a.tientra,d.ten_chuong,e.tentieumuc,a.ma_chuong,a.ma_tmuc,b.ten_nnt,f.id so, f.ngay_tt ngay,
                        (select id||''|''||town_name from towns where id =b.ma_xa) phuongxa
                  from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f,nguoigachnos g
                  where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
                  and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+)
                  and a.ma_tmuc=e.id(+) and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1';
            s:=s||' and c.shkb='''||pkhobac||'''';
            s:=s||' and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
                        and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400';

            s:=s||' and f.ma_tinh='''||pma_tinh||'''
                  ) group by mst,ma_chuong,ma_tmuc,ten_nnt,so,ngay,phuongxa order by phuongxa,mst)';
        end if;
    end if;
    open report_out for s;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;

PROCEDURE REPORT_INFO_DEBT(
    pma_tinh varchar2,
    pdonvi varchar2,
    pbuucuc varchar2,
    pquaythu varchar2,
    pnguoigachno varchar2,
    ptungay varchar2,
    pdenngay varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(32000);
    l_mst number;
    ckn varchar2(100):=crud.ckn_hientai();
begin
    s:='select sum(sl_mst) from (select count(distinct a.mst) sl_mst
        from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b, in_phieus i,
        tax.nguoigachnos c, tax.quaythus d, tax.buucucthus e, (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') f, tax.nnts_'||ckn||' g, tax.hinhthuc_tts h
        where a.phieu_id = b.id and b.nguoigachno_id = c.id
        and c.quaythu_id = d.id and d.mabc_id = e.id
        and e.donviql_id = f.id and a.mst = g.mst and a.ma_cq_thu = g.ma_cqt_ql
        and a.ma_tinh = g.ma_tinh and b.httt_id = h.id and a.mst||''/''||a.kythue= i.barcode(+)
        and a.ma_tinh ='''||pma_tinh||'''';

    if pdonvi is not null then s:=s||' and f.id like '''||replace(pdonvi,'*','%')||''''; end if;
    if pbuucuc is not null then s:=s||' and e.id like '''||replace(pbuucuc,'*','%')||''''; end if;
    if pquaythu is not null then s:=s||' and d.id like '''||replace(pquaythu,'*','%')||''''; end if;
    if pnguoigachno is not null then s:=s||' and b.nguoigachno_id like '''||replace(pnguoigachno,'*','%')||''''; end if;
    if ptungay is not null then s:=s||' and b.ngay_thuc >= to_date('''||ptungay||''',''dd/mm/yyyy'')'; end if;
    if pdenngay is not null then s:=s||' and b.ngay_thuc < to_date('''||pdenngay||''',''dd/mm/yyyy'') +1'; end if;
    s:=s||' group by a.mst,a.kythue)';
    execute immediate s into l_mst;

    s:='select rownum stt,a.mst,a.tientra,(select TEN_CHUONG from  tax.chuongs where a.ma_chuong = id) ten_chuong,
        (select TENTIEUMUC from  tax.tieu_mucs where a.ma_tmuc = id) ten_muc, a.phieu_id,
        to_char(b.ngay_thuc,''dd/mm/yyyy hh24:mi:ss'') ngay_tt, b.nguoigachno_id,d.tenquay,
        e.tenbuucuc,f.ten_dv, g.ten_nnt, g.mota_diachi diachi, h.name hinhthuc,i.stt tt_in,
        a.phieu_id, a.kythue, '||l_mst||' sl_mst,g.ma_nv manv,(select id||'' - ''||ten_nv from nhanvien_tcs where ma_tinh='''||pma_tinh||''' and id =g.ma_nv and rownum =1) ma_nv
         from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b, in_phieus i,
         tax.nguoigachnos c, tax.quaythus d, tax.buucucthus e, (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') f, tax.nnts_'||ckn||' g, tax.hinhthuc_tts h
        where a.phieu_id = b.id and b.nguoigachno_id = c.id
        and c.quaythu_id = d.id and d.mabc_id = e.id
        and e.donviql_id = f.id and a.mst = g.mst
        and a.ma_tinh = g.ma_tinh and b.httt_id = h.id and a.mst||''/''||a.kythue= i.barcode(+)
        and a.ma_tinh ='''||pma_tinh||'''';

    if pdonvi is not null then s:=s||' and f.id like '''||replace(pdonvi,'*','%')||''''; end if;
    if pbuucuc is not null then s:=s||' and e.id like '''||replace(pbuucuc,'*','%')||''''; end if;
    if pquaythu is not null then s:=s||' and d.id like '''||replace(pquaythu,'*','%')||''''; end if;
    if pnguoigachno is not null then s:=s||' and b.nguoigachno_id like '''||replace(pnguoigachno,'*','%')||''''; end if;
    if ptungay is not null then s:=s||' and b.ngay_thuc >= to_date('''||ptungay||''',''dd/mm/yyyy'')'; end if;
    if pdenngay is not null then s:=s||' and b.ngay_thuc < to_date('''||pdenngay||''',''dd/mm/yyyy'') +1'; end if;

    s:=s||' order by f.ten_dv,e.tenbuucuc,d.tenquay,b.nguoigachno_id,h.name,g.ma_nv,i.stt,a.kythue,b.ngay_thuc';

    open report_out for s;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;

PROCEDURE REPORT_STAFF_INVOICE(
    pma_tinh varchar2,
    pdonvi varchar2,
    pbuucuc varchar2,
    pquaythu varchar2,
    pnguoigachno varchar2,
    pduongthu varchar2,
    pkythu varchar2,
    ptungay varchar2,
    pdenngay varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(1000);
    ckn varchar2(100):=crud.ckn_hientai();
    l_tien number;
begin

    s:='select sum(a.tien_giao) tien
            from tax.phieu_'||ckn||' a, tax.nhanvien_tcs b, tax.buucucthus c,
            (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') d,tax.nnts_'||ckn||' e
            where a.ma_nv = b.id
            and b.mabc_id = c.id
            and c.donviql_id = d.id
            and a.mst = e.mst
            and b.ma_tinh =:1';

    if pdonvi is not null then s:=s||' and c.donviql_id like '''||replace(pdonvi,'*','%')||''''; end if;
    if pbuucuc is not null then s:=s||' and b.mabc_id like '''||replace(pbuucuc,'*','%')||''''; end if;
    if pduongthu is not null then s:=s||' and a.ma_nv like '''||replace(pduongthu,'*','%')||''''; end if;
    if ptungay is not null then s:=s||' and a.ngay_giao >= to_date('''||ptungay||''',''dd/mm/yyyy'')'; end if;
    if pdenngay is not null then s:=s||' and a.ngay_giao < to_date('''||pdenngay||''',''dd/mm/yyyy'') +1'; end if;
    if pkythu is not null then s:=s||' and a.kythue ='''||pkythu||''''; end if;
    execute immediate s into l_tien  using pma_tinh;

    s:='select rownum stt,'||l_tien||' tong_giao,d.ten_dv,c.tenbuucuc,a.kythue,
        (select x.id||''|''||x.ten_nv from nhanvien_tcs x where x.ma_tinh='''||pma_tinh||''' and x.id=a.ma_nv) ma_nv,
        a.mst,a.tien_giao,to_char(a.ngay_giao,''dd/mm/yyyy hh24:mi:ss'') ngay_giao,a.nguoi_giao,a.trangthai_tt,e.ten_nnt,e.mota_diachi diachi
            from tax.phieu_'||ckn||' a, tax.nhanvien_tcs b, tax.buucucthus c, (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') d,tax.nnts_'||ckn||' e
            where a.ma_nv = b.id
            and b.mabc_id = c.id
            and c.donviql_id = d.id
            and a.mst = e.mst
            and b.ma_tinh =:1';

    if pdonvi is not null then s:=s||' and c.donviql_id like '''||replace(pdonvi,'*','%')||''''; end if;
    if pbuucuc is not null then s:=s||' and b.mabc_id like '''||replace(pbuucuc,'*','%')||''''; end if;
    if pduongthu is not null then s:=s||' and a.ma_nv like '''||replace(pduongthu,'*','%')||''''; end if;
    if ptungay is not null then s:=s||' and a.ngay_giao >= to_date('''||ptungay||''',''dd/mm/yyyy'')'; end if;
    if pdenngay is not null then s:=s||' and a.ngay_giao < to_date('''||pdenngay||''',''dd/mm/yyyy'') +1'; end if;
    if pkythu is not null then s:=s||' and a.kythue ='''||pkythu||''''; end if;

    s:=s||' order by d.ten_dv,c.tenbuucuc,a.ma_nv,a.ngay_giao,a.kythue';
    open report_out for s using pma_tinh;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;

PROCEDURE REPORT_STAFF_NO_INVOICE(
    pma_tinh varchar2,
    pdonvi varchar2,
    pbuucuc varchar2,
    pquaythu varchar2,
    pnguoigachno varchar2,
    pduongthu varchar2,
    pkythu varchar2,
    ptungay varchar2,
    pdenngay varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(1000);
    ckn varchar2(100):=crud.ckn_hientai();
    l_tien number;
begin

    s:='select a.mst,a.ten_nnt,a.mota_diachi diachi,nvl(c.tien_giao,0) tien_giao,
        b.sotien-nvl(c.tien_giao,0) so_tien, f.ten_dv,e.tenbuucuc,a.ma_nv,b.kythue
        from tax.nnts_'||ckn||' a,
        (select sum(no_cuoi_ky) sotien,mst,kythue from ct_no_'||ckn||' group by mst,kythue) b,
        (select sum(tien_giao) tien_giao,mst,kythue from phieu_'||ckn||' group by mst,kythue) c,
        tax.nhanvien_tcs d, tax.buucucthus e, (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') f
        where a.mst=b.mst and b.mst=c.mst(+) and b.kythue= c.kythue(+) and b.sotien-nvl(c.tien_giao,0)>0
        and a.ma_nv = d.id and d.mabc_id = e.id and e.donviql_id = f.id and a.ma_tinh =:1
        and not exists (select 1 from ct_tra_'||ckn||' ct where a.mst = ct.mst and b.kythue = ct.kythue)';
    if pdonvi is not null then s:=s||' and e.donviql_id like '''||replace(pdonvi,'*','%')||''''; end if;
    if pbuucuc is not null then s:=s||' and d.mabc_id like '''||replace(pbuucuc,'*','%')||''''; end if;
    if pduongthu is not null then s:=s||' and a.ma_nv like '''||replace(pduongthu,'*','%')||''''; end if;
    if pkythu is not null then s:=s||' and b.kythue ='''||pkythu||''''; end if;
    s:=s||' order by f.ten_dv,e.tenbuucuc,a.ma_nv,b.kythue';
    open report_out for s using pma_tinh;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;

function SEARCH_PHIEUTRA_THEO_KHOBAC(
    pma_tinh varchar2,
    pkhobac varchar2,
    pphuongxa varchar2,
    pngay_tt varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai;
    l_time number;
    l_day number;
begin
    --Lay thong tin cau hinh thoi gian cho du lieu
    Execute immediate' SELECT expire_time FROM tax.config_special_days WHERE agent =:1 and status=1 and rownum =1'
        into l_time Using pma_tinh;

    --l_day := check_time_exception(i_agent=> pma_tinh);
    l_day := check_time_extend(I_DAY=> pngay_tt, I_AGENT=> pma_tinh);
    l_day := l_day +1;

    s:='select a.*,to_char(a.ngay_tt,''dd/mm/yyyy hh24:mi'') ngay_tt1,to_char(a.ngay_thuc,''dd/mm/yyyy hh24:mi'') ngay_thuc1,to_char(b.tien_tra,''fm999,999,999,999,999'') tien_tra
    from tax.bangphieutra_'||ckn||' a, nguoigachnos g,
        (select sum(tientra) tien_tra,phieu_id from ct_tra_'||ckn||' group by phieu_id) b,
        nnts_'||ckn||' c, coquanthus d, khobacs e
    where a.id=b.phieu_id and a.mst=c.mst and c.ma_cqt_ql=d.cqt_tms and d.shkb=e.id
    and g.id = a.nguoigachno_id and g.vnpt =1';
    if pkhobac is not null then s:=s||' and e.id ='''||pkhobac||''''; end if;

    s:=s||' and a.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
                and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400 ';

    s:=s||' and a.ma_tinh='''||pma_tinh||''' and nvl(c.ma_xa,c.ma_xa_tt) = '''||pphuongxa||'''
            order by a.id';
  dbms_output.put_line(s);
    open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
function SEARCH_PHIEUTRA_THEO_KB_MUC(
    pma_tinh varchar2,
    pkhobac varchar2,
    pphuongxa varchar2,
    pngay_tt varchar2,
    ploaithue varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai;
    l_time number;
    l_day number;
    l_monbai number;
    l_mamuc number:=1800;
begin
    --Lay thong tin cau hinh thoi gian cho du lieu
    Execute immediate' SELECT expire_time FROM tax.config_special_days WHERE agent =:1 and status=1 and rownum =1'
        into l_time Using pma_tinh;

    --l_day := check_time_exception(i_agent=> pma_tinh);
    l_day := check_time_extend(I_DAY=> pngay_tt, I_AGENT=> pma_tinh);
    l_day := l_day +1;

    --Check loai thue mon bai
    select count(1) into l_monbai from tieu_mucs where id =ploaithue and ma_muc =l_mamuc;

    s:='select to_char(sum(tientra),''fm999,999,999,999'') tientra,ten_chuong,tentieumuc from
        (select a.tientra,a.ma_chuong||''|''||d.ten_chuong ten_chuong,a.ma_tmuc||''|''||e.tentieumuc tentieumuc
            from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f, nguoigachnos g
            where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
            and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+) and a.ma_tmuc=e.id(+)
            and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1';

    if pkhobac is not null then s:=s||' and c.shkb like '''||pkhobac||''''; end if;
    if l_monbai >0 then s:=s||' and e.ma_muc = '||l_mamuc||''; else s:=s||' and e.id = '||ploaithue||''; end if;

    s:=s||' and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
                and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400 ';

    s:=s||' and f.ma_tinh='''||pma_tinh||''' and nvl(b.ma_xa,b.ma_xa_tt) = '''||pphuongxa||'''
            ) group by ten_chuong,tentieumuc';
    dbms_output.put_line(s);
    commit;
    open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function CHECK_SUM_DEPT(
    pma_tinh varchar2,
    pkhobac varchar2,
    pphuongxa varchar2,
    pngay_tt varchar2,
    ploaithue varchar2)
return number
is
    s varchar2(1000);
    l_tra number;
    ckn varchar2(100):=crud.ckn_hientai;
    l_time number;
    l_day number;
    l_monbai number;
    l_mamuc number:=1800;
begin
    --Lay thong tin cau hinh thoi gian cho du lieu
    Execute immediate' SELECT expire_time FROM tax.config_special_days WHERE agent =:1 and status=1 and rownum =1'
        into l_time Using pma_tinh;

    --Check loai thue mon bai
    select count(1) into l_monbai from tieu_mucs where id =ploaithue and ma_muc =l_mamuc;

    --l_day := check_time_exception(i_agent=> pma_tinh);
    l_day := check_time_extend(I_DAY=> pngay_tt, I_AGENT=> pma_tinh);
    l_day := l_day +1;

    s:='select sum(tientra) tientra from (select a.tientra,a.ma_chuong||''|''||d.ten_chuong ten_chuong,a.ma_tmuc||''|''||e.tentieumuc tentieumuc
            from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f, nguoigachnos g
            where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
            and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+) and a.ma_tmuc=e.id(+)
            and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1
             and c.shkb = '''||pkhobac||''' and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
             and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400
             and f.ma_tinh='''||pma_tinh||'''';
    if pma_tinh='79TTT' then
        s:=s||' and nvl(b.ma_xa,b.ma_xa_tt) = '''||pphuongxa||''')';
    else
        if l_monbai >0 then s:=s||' and e.ma_muc = '||l_mamuc||' and nvl(b.ma_xa,b.ma_xa_tt) = '''||pphuongxa||''')';
            else s:=s||' and e.id = '||ploaithue||')';
        end if;
    end if;
    dbms_output.put_line(s);
    execute immediate s into l_tra;

    return l_tra;
    exception when others then
        return 0;
end;

procedure REPORT_DEPT_STAFF_NO_BILL(
    pma_tinh varchar2,
    pma_nv varchar2,
    ptu_ngay varchar2,
    pden_ngay varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(3000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai;
    l_ten_dv varchar(200);
    l_diachi_dv varchar(500);
    l_mst_dv varchar(50);
Begin
    s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
    Execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;


    s:='select  '''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv,
            (select x.id||''|''||x.ten_nv from nhanvien_tcs x where x.ma_tinh='''||pma_tinh||''' and x.id=a.ma_nv) ma_nv,
            a.mst,a.tien_giao,a.nguoi_giao,b.ten_nnt,b.MOTA_DIACHI diachi_nnt,
            to_char(a.ngay_giao,''dd/mm/yyyy hh24:mi:ss'') ngay_giao
    from (
            select sum(a.tien_giao) tien_giao,a.ma_nv,a.nguoi_giao,a.mst,a.ngay_giao,a.kythue from tax.phieu_'||ckn||' a
            where exists (select 1 from tax.nhanvien_tcs b where a.ma_nv=b.id and b.ma_tinh =:1)';
            if ptu_ngay is not null then
                s:=s||' and a.ngay_giao >= to_date('''||ptu_ngay||''',''dd/mm/yyyy'')';
            end if;
            if pden_ngay is not null then
                s:=s||' and a.ngay_giao < to_date('''||pden_ngay||''',''dd/mm/yyyy'') +1';
            end if;
            if pma_nv is not null then
                s:=s||' and a.ma_nv = '''||pma_nv||'''';
            end if;

            s:=s||'group by a.ma_nv,a.nguoi_giao,a.mst,a.kythue,a.ngay_giao) a, nnts_'||ckn||' b
            where a.mst = b.mst
            and not exists(select 1 from ketquaphats c where a.mst = c.mst and a.kythue = c.chuky)
            and not exists(select 1 from ct_tra_'||ckn||' d where a.mst = d.mst and a.kythue = d.kythue and d.ma_tinh=:2)
            order by a.ma_nv,a.nguoi_giao';
    Open report_out for s using pma_tinh,pma_tinh;

    Exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    End;
end;

function NNTS_RESIZE(
    ptin varchar2,
    pten varchar2,
    pma_nh varchar2,
    pten_nh varchar2,
    pma_kb varchar2,
    pten_kb varchar2,
    --pcqt varchar2,
    pngay_ht varchar2,
    pma_chuong varchar2,
    pma_khoan varchar2,
    pma_tieumuc varchar2,
    pnoidung varchar2,
    pngay_kb varchar2,
    pngay_nh varchar2,
    pngay_nhan varchar2,
    psotien varchar2
)
return varchar2
is
    s varchar2(5000);
    ckn varchar2(100):=crud.ckn_hientai();
    l_thang varchar2(20):= to_char(sysdate,'mmyyyy');
begin
    s:='insert into thanhtoan_temp(MST,TEN_NNTHUE,MA_NHANG,NGAN_HANG,MA_KBAC,TEN_KBAC,/*MA_CQTHU,*/NGAY_HT,MA_CHUONG,MA_KHOAN,MA_TMUC,NOI_DUNG,NGAY_KBAC,NGAY_NH,NGAY_NHAN,SO_TIEN)
     values (:TIN,:TEN_NNTHUE,:MA_NHANG,:NGAN_HANG,:MA_KBAC,:TEN_KBAC,/*:MA_CQTHU,*/:NGAY_HT,:MA_CHUONG,:MA_KHOAN,:MA_TMUC,:NOI_DUNG,:NGAY_KBAC,:NGAY_NH,:NGAY_NHAN,:SO_TIEN)';
    execute immediate s using ptin,pten ,pma_nh ,pten_nh ,pma_kb ,pten_kb ,/*pcqt ,*/pngay_ht ,pma_chuong ,pma_khoan ,pma_tieumuc ,pnoidung ,pngay_kb ,pngay_nh ,pngay_nhan ,psotien;
    commit;
    return '1';
    exception when others then
        return '0';
end;


function NEW_NNTS_UPLOADS(
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
    pid number,
    pma_tinh varchar2,
    plog_user varchar2,
    plog_ip varchar2,
    plog_date date )
return varchar2
is
    s varchar2(5000);
    ckn varchar2(100):=crud.ckn_hientai();
    l_thang varchar2(20):= to_char(sysdate,'mmyyyy');
    id_nnts_uploads varchar2(100):= util.getseq('SEQ_NNTS_UPLOADS');
begin
    --Day du lieu vao bang NNTS_UPLOADS
    s:='insert into tax.nnts_uploads(mcq,ma_unt,ten_unt,cbk_unt,ngay_unt,ma_nnt,ten_nnt,sac_thue,chuong,tieu_muc,dia_ban,kbnn,kythue,loaitk_nsnn,han_nop,magiao_unt,loai_tien,tien_giao,tien_con,tien_thuduoc,tien_quyettoan,so_bl,ngay_bl,sobl_unt,ngaybl_unt,ngay_banke,sonha_ct,matinh_ct,tentinh_ct,maquan_ct,tenquan_ct,maxa_ct,tenxa_ct,mobile,email,sonha_tt,matinh_tt,tentinh_tt,maquan_tt,tenquan_tt,maxa_tt,tenxa_tt,id,ma_tinh,log_user,log_ip,log_date)
            values (:mcq,:ma_unt,:ten_unt,:cbk_unt,:ngay_unt,:ma_nnt,:ten_nnt,:sac_thue,:chuong,:tieu_muc,:dia_ban,:kbnn,:kythue,:loaitk_nsnn,:han_nop,:magiao_unt,:loai_tien,:tien_giao,:tien_con,:tien_thuduoc,:tien_quyettoan,:so_bl,:ngay_bl,:sobl_unt,:ngaybl_unt,:ngay_banke,:sonha_ct,:matinh_ct,:tentinh_ct,:maquan_ct,:tenquan_ct,:maxa_ct,:tenxa_ct,:mobile,:email,:sonha_tt,:matinh_tt,:tentinh_tt,:maquan_tt,:tenquan_tt,:maxa_tt,:tenxa_tt,:id,:ma_tinh,:log_user,:log_ip,:log_date)';
    execute immediate s using pmcq,pma_unt,pten_unt,pcbk_unt,pngay_unt,pma_nnt,pten_nnt,psac_thue,pchuong,ptieu_muc,pdia_ban,pkbnn,pkythue,ploaitk_nsnn,phan_nop,pmagiao_unt,ploai_tien,ptien_giao,ptien_con,ptien_thuduoc,ptien_quyettoan,pso_bl,pngay_bl,psobl_unt,pngaybl_unt,pngay_banke,psonha_ct,pmatinh_ct,ptentinh_ct,pmaquan_ct,ptenquan_ct,pmaxa_ct,ptenxa_ct,pmobile,pemail,psonha_tt,pmatinh_tt,ptentinh_tt,pmaquan_tt,ptenquan_tt,pmaxa_tt,ptenxa_tt,id_nnts_uploads,pma_tinh,plog_user,plog_ip,SYSDATE;
    commit;return '1';
    exception when others then
        return '0';
end;

function NEW_NNTS_UPLOADS_TEMP(
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
    pid number,
    pma_tinh varchar2,
    plog_user varchar2,
    plog_ip varchar2,
    plog_date date )
return varchar2
is
    s varchar2(5000);
    ckn varchar2(100):=crud.ckn_hientai();
    l_thang varchar2(20):= to_char(sysdate,'mmyyyy');
    id_nnts_uploads varchar2(100):= util.getseq('SEQ_NNTS_UPLOADS_TEMP');
begin
    --Day du lieu vao bang NNTS_UPLOADS_TEMP
    s:='insert into tax.nnts_uploads_temp(mcq,ma_unt,ten_unt,cbk_unt,ngay_unt,ma_nnt,ten_nnt,sac_thue,chuong,tieu_muc,dia_ban,kbnn,kythue,loaitk_nsnn,han_nop,magiao_unt,loai_tien,tien_giao,tien_con,tien_thuduoc,tien_quyettoan,so_bl,ngay_bl,sobl_unt,ngaybl_unt,ngay_banke,sonha_ct,matinh_ct,tentinh_ct,maquan_ct,tenquan_ct,maxa_ct,tenxa_ct,mobile,email,sonha_tt,matinh_tt,tentinh_tt,maquan_tt,tenquan_tt,maxa_tt,tenxa_tt,id,ma_tinh,log_user,log_ip,log_date)
     values (:mcq,:ma_unt,:ten_unt,:cbk_unt,:ngay_unt,:ma_nnt,:ten_nnt,:sac_thue,:chuong,:tieu_muc,:dia_ban,:kbnn,:kythue,:loaitk_nsnn,:han_nop,:magiao_unt,:loai_tien,:tien_giao,:tien_con,:tien_thuduoc,:tien_quyettoan,:so_bl,:ngay_bl,:sobl_unt,:ngaybl_unt,:ngay_banke,:sonha_ct,:matinh_ct,:tentinh_ct,:maquan_ct,:tenquan_ct,:maxa_ct,:tenxa_ct,:mobile,:email,:sonha_tt,:matinh_tt,:tentinh_tt,:maquan_tt,:tenquan_tt,:maxa_tt,:tenxa_tt,:id,:ma_tinh,:log_user,:log_ip,:log_date)';
    execute immediate s using pmcq,pma_unt,pten_unt,pcbk_unt,pngay_unt,pma_nnt,pten_nnt,psac_thue,pchuong,ptieu_muc,pdia_ban,pkbnn,pkythue,ploaitk_nsnn,phan_nop,pmagiao_unt,ploai_tien,ptien_giao,ptien_con,ptien_thuduoc,ptien_quyettoan,pso_bl,pngay_bl,psobl_unt,pngaybl_unt,pngay_banke,psonha_ct,pmatinh_ct,ptentinh_ct,pmaquan_ct,ptenquan_ct,pmaxa_ct,ptenxa_ct,pmobile,pemail,psonha_tt,pmatinh_tt,ptentinh_tt,pmaquan_tt,ptenquan_tt,pmaxa_tt,ptenxa_tt,id_nnts_uploads,pma_tinh,plog_user,plog_ip,SYSDATE;
    commit;return '1';
    exception when others then
        return '0';
end;

function GET_ALL_NNTS_UPLOADS_TEMP
return sys_refcursor
is
  s varchar2(5000);
  ref_ sys_refcursor;
begin
   --logger.access('tax.getAll_NNTS_UPLOADS_TEMP|NEW','');
   s:='select * from tax.nnts_uploads_temp';
    open ref_ for s;
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function search_duongthus_log(
    pid varchar2,
    pma_nv varchar2,
    pma_tinh varchar2,
    pnguoi_cn varchar2,
    pngay_cn varchar2,
    pip_cn varchar2,
    pdescription varchar2,
    paction_type varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    s:='select a.id,a.ma_nv,a.ma_tinh,a.nguoi_cn,to_char(a.ngay_cn,''dd/mm/yyyy hh24:mi:ss'') ngay_cn,a.ip_cn,a.description,a.action_type from tax.duongthus_log a where 1=1';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if pma_nv is not null then s:=s||' and ma_nv like '''||replace(pma_nv,'*','%')||''''; end if;
    if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
    if pnguoi_cn is not null then s:=s||' and nguoi_cn like '''||replace(pnguoi_cn,'*','%')||''''; end if;
    if pngay_cn is not null then s:=s||' and ngay_cn=to_date('''||pngay_cn||''',''dd/mm/yyyy'')'; end if;
    if pip_cn is not null then s:=s||' and ip_cn like '''||replace(pip_cn,'*','%')||''''; end if;
    if pdescription is not null then s:=s||' and description like '''||replace(pdescription,'*','%')||''''; end if;
    if paction_type is not null then s:=s||' and action_type like '''||replace(paction_type,'*','%')||''''; end if;
    s:=s||' order by a.ngay_cn DESC';
  if(pPageIndex=-1) then
      s:='select ceil(count(*)/:1) nop,count(1) nor from ('||s||')';
      open ref_ for s using  pRecordPerPage;
  else
      open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
  end if;
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
function EDIT_DUONGTHUS (
  pid_user_info varchar2,
  pma_nvs varchar2,
  pnguoi_cn varchar2,
  pngay_cp date,
  pip_cn varchar2,
  pdescription varchar2
)
return varchar2
is
   s varchar2(1000);
  rs_ util.stringarray; --danh sach ma_nv
  pma_tinh varchar2(10);
  action_type varchar(1);
  out_ util.stringarray;
  ref_ sys_refcursor;
  in_ varchar(200);
  i NUMBER;
begin
    SAVEPOINT p1;

    s:='select count(*) from tax.user_info where id=:1';
    execute immediate s into i using pid_user_info;
    if(i = 0)then
        return 'USER_NOT_EXIST';
    end if;

    if(pma_nvs is null) then
        s:='select a.ma_nv, a.ma_tinh from duongthus  a where a.id=:1 and  a.action_type=:2';
        open ref_ for s using pid_user_info,'1';
        loop fetch ref_ into in_,pma_tinh;
        exit when ref_%notfound;
            action_type:='0';
            s:='insert into tax.duongthus_log values (:id,:ma_nv,:ma_tinh,:nguoi_cn,:ngay_cp,:ip_cn,:description,:action_type)';
            execute immediate s using pid_user_info,in_,pma_tinh,pnguoi_cn,sysdate,pip_cn,pdescription,action_type;
        end loop;
        close ref_;
        s:='delete from duongthus where id=:1';
        execute immediate s using pid_user_info;
    else
        action_type:='1';
        s:='delete from duongthus where id=:1';
        execute immediate s using pid_user_info;
        rs_:=util.str_to_array(pma_nvs);--danh sach ma_nv

        for n in rs_.first..rs_.last loop
            in_:=in_||''''||rs_(n)||''',';
            --lay ma_tinh tu ma_nv o bang nhanvien_tcs
            s:='select ma_tinh from tax.nhanvien_tcs where id=:1';
            execute immediate s into pma_tinh using rs_(n);
            --insert vao bang duongthus
            s:='insert into tax.duongthus values (:id,:ma_nv,:ma_tinh,:nguoi_cn,:ngay_cp,:ip_cn,:description,:action_type)';
            execute immediate s using pid_user_info,rs_(n),pma_tinh,pnguoi_cn,sysdate,pip_cn,pdescription,action_type;
            s:='select count(*) from tax.duongthus_log a where a.id=:1 and a.ma_nv=:2 and a.action_type=:3';
            execute immediate s into i using pid_user_info,rs_(n),'1';
            if(i=0) then
                s:='insert into tax.duongthus_log values (:id,:ma_nv,:ma_tinh,:nguoi_cn,:ngay_cp,:ip_cn,:description,:action_type)';
                execute immediate s using pid_user_info,rs_(n),pma_tinh,pnguoi_cn,sysdate,pip_cn,pdescription,action_type;
            end if;
        end loop;
        commit;

        in_:=substr(in_,1,length(in_)-1);-- xuat ra ds ma_nv, cach nhau boi dau phay(,), vd: '0003005G','0003005H'
        s:='select a.ma_nv from duongthus_log a where a.ma_nv not in ('||in_||') and a.id='''||pid_user_info||''' group by a.ma_nv';
        open ref_ for s;
        -- lay ds ma_nv con lai trong bang duongthus_log
        loop fetch ref_ into in_;
        exit when ref_%notfound;
        --insert 0 vao bang duongthus_log theo ma_nv con lai
            action_type:='0';
            s:='insert into tax.duongthus_log values (:id,:ma_nv,:ma_tinh,:nguoi_cn,:ngay_cp,:ip_cn,:description,:action_type)';
            execute immediate s using pid_user_info,in_,pma_tinh,pnguoi_cn,sysdate,pip_cn,pdescription,action_type;

        end loop;
        close ref_;
    end if;

    commit;return '1';
    exception when others then
        declare err varchar2(500); begin  ROLLBACK TO p1;  err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;


function SEARCH_TIEN_NOP_DIEM_THU(
    PMA_TINH VARCHAR2,
    psearch_key VARCHAR2,
    pRecordPerPage varchar2 default 1000,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    s:='select id, tenbuucuc from buucucthus a where 1=1 ';
    if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
    if psearch_key is not null then s:=s||' and (a.id like ''%'||(psearch_key)||'%'' or tax.uto_khongdau(upper(a.tenbuucuc)) like ''%'
    ||tax.uto_khongdau(upper(psearch_key))||'%'')'; end if;
    s:=s||' order by a.id';

    open ref_ for s;
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
function new_tien_nop(
    pma_bc varchar2,
    pma_nv varchar2,
    pngay_nop varchar2,
    ptien varchar2,
    pnguoi_cn varchar2,
    pngay_cn varchar2,
    pip_cn varchar2,
    pid varchar2,
    pnoi_dung varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    n number;
    l_agent varchar2(10);
begin

    if(pma_bc is null and pma_nv is null) then
        return 'MA_BC_NV_NULL';
    elsif(pma_bc is null) then
        return 'MA_BC_NULL';
    elsif (pma_nv is null) then
        return 'MA_NV_NULL';
    end if;

    l_agent := tax.get_agent_user(PUSER=>pUserId);
    s:='insert into tax.tien_nop(ma_tinh,ma_bc,ma_nv,ngay_nop,tien,nguoi_cn,ngay_cn,ip_cn,id,noi_dung)
        values (:ma_tinh,:ma_bc,:ma_nv,:ngay_nop,:tien,:nguoi_cn,:ngay_cn,:ip_cn,:id,:noi_dung)';
    execute immediate s using l_agent,pma_bc,pma_nv,to_date(pngay_nop,'dd/mm/yyyy'),ptien,pUserId,sysdate,pUserIp,util.GETSEQ('TIEN_NOP_SEQ'),pnoi_dung;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function search_tien_nop(
    pma_bc varchar2,
    pma_nv varchar2,
    pngay_nop varchar2,
    ptien varchar2,
    pnguoi_cn varchar2,
    pngay_cn varchar2,
    pip_cn varchar2,
    pid varchar2,
    pnoi_dung varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    s:='select ma_bc,ma_nv,to_char(ngay_nop,''dd/mm/yyyy'') ngay_nop,tien,nguoi_cn,to_char(ngay_cn,''dd/mm/yyyy hh24:mi:ss'') ngay_cn,ip_cn,id,noi_dung from tax.tien_nop where 1=1';
    if pma_bc is not null then s:=s||' and ma_bc like '''||replace(pma_bc,'*','%')||''''; end if;
    if pma_nv is not null then s:=s||' and ma_nv like '''||replace(pma_nv,'*','%')||''''; end if;
    if pngay_nop is not null then s:=s||' and ngay_nop=to_char('''||pngay_nop||''',''dd/mm/yyyy'')'; end if;
    if ptien is not null then s:=s||' and tien like '''||replace(ptien,'*','%')||''''; end if;
    if pnguoi_cn is not null then s:=s||' and nguoi_cn like '''||replace(pnguoi_cn,'*','%')||''''; end if;
    if pngay_cn is not null then s:=s||' and ngay_cn=to_date('''||pngay_cn||''',''dd/mm/yyyy'')'; end if;
    if pip_cn is not null then s:=s||' and ip_cn like '''||replace(pip_cn,'*','%')||''''; end if;
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if pnoi_dung is not null then s:=s||' and noi_dung like '''||replace(pnoi_dung,'*','%')||''''; end if;
    s:=s||' order by ngay_cn desc';
    if(pPageIndex=-1) then
        s:='select ceil(count(*)/:1) nop,count(1) nor from ('||s||')';
        open ref_ for s using  pRecordPerPage;
    else
        open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    end if;
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
function edit_tien_nop(
    pma_bc varchar2,
    pma_nv varchar2,
    pngay_nop varchar2,
    ptien varchar2,
    pnguoi_cn varchar2,
    pngay_cn varchar2,
    pip_cn varchar2,
    pid varchar2,
    pnoi_dung varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin

    s:='update tax.tien_nop set  ma_bc=:ma_bc,ma_nv=:ma_nv,ngay_nop=:ngay_nop,tien=:tien,nguoi_cn=:nguoi_cn,ngay_cn=:ngay_cn,ip_cn=:ip_cn,id=:id,noi_dung=:noi_dung where id=:id';
    execute immediate s using pma_bc,pma_nv,to_date(pngay_nop,'dd/mm/yyyy'),ptien,pnguoi_cn,sysdate,pip_cn,pid,pnoi_dung,pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_tien_nop(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin

    s:='delete from tax.tien_nop where id=:id';
    execute immediate s using pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function get_duongthus_by_buucuc_tinh(
  pma_tinh varchar2,
  pma_bc varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    if(pma_bc is null) then
        s:='select id,''[''||id||''] ''||ten_nv name from tax.nhanvien_tcs where ma_tinh=:1';
        open ref_ for s using pma_tinh;
    else
        s:='select id,''[''||id||''] ''||ten_nv name from tax.nhanvien_tcs where ma_tinh=:1 and mabc_id=:2';
        open ref_ for s using pma_tinh,pma_bc;
    end if;

    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function new_chuyentuyens(
    pmst varchar2,
    pten varchar2,
    pma_tinh varchar2,
    pdia_chi varchar2,
    pma_nv_cu varchar2,
    pma_nv varchar2,
    pkieu varchar2,
    pnoidung varchar2,
    pnguoi_cn varchar2,
    pngay_cn varchar2,
    pip_cn varchar2,
    pid varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    if(pmst is null) then
        return 'MST_NOT_NULL';
    end if;
    s:='insert into tax.chuyentuyens(mst,ma_tinh,ma_nv_cu,ma_nv,kieu,noidung,nguoi_cn,ngay_cn,ip_cn,id)
            values (:mst,:ten,:ma_tinh,:dia_chi,:ma_nv_cu,:ma_nv,:kieu,:noidung,:nguoi_cn,:ngay_cn,:ip_cn,:id)';
    execute immediate s using pmst,pma_tinh,pma_nv_cu,pma_nv,pkieu,pnoidung,pnguoi_cn,sysdate,pip_cn,util.GETSEQ('CHUYEN_TUYEN_SEQ');
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function search_chuyentuyens(
    pmst varchar2,
    pten varchar2,
    pma_tinh varchar2,
    pdia_chi varchar2,
    pma_nv_cu varchar2,
    pma_nv varchar2,
    pkieu varchar2,
    pnoidung varchar2,
    pnguoi_cn varchar2,
    pngay_cn varchar2,
    pip_cn varchar2,
    pid varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    s:='select * from tax.chuyentuyens where 1=1';
    if pmst is not null then s:=s||' and mst like '''||replace(pmst,'*','%')||''''; end if;
    if pten is not null then s:=s||' and ten like '''||replace(pten,'*','%')||''''; end if;
    if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
    if pdia_chi is not null then s:=s||' and dia_chi like '''||replace(pdia_chi,'*','%')||''''; end if;
    if pma_nv_cu is not null then s:=s||' and ma_nv_cu like '''||replace(pma_nv_cu,'*','%')||''''; end if;
    if pma_nv is not null then s:=s||' and ma_nv like '''||replace(pma_nv,'*','%')||''''; end if;
    if pkieu is not null then s:=s||' and kieu like '''||replace(pkieu,'*','%')||''''; end if;
    if pnoidung is not null then s:=s||' and noidung like '''||replace(pnoidung,'*','%')||''''; end if;
    if pnguoi_cn is not null then s:=s||' and nguoi_cn like '''||replace(pnguoi_cn,'*','%')||''''; end if;
    if pngay_cn is not null then s:=s||' and ngay_cn=to_date('''||pngay_cn||''',''dd/mm/yyyy'')'; end if;
    if pip_cn is not null then s:=s||' and ip_cn like '''||replace(pip_cn,'*','%')||''''; end if;
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    s:=s||' order by ngay_cn desc';
    if(pPageIndex=-1) then
        s:='select ceil(count(*)/:1) nop,count(1) nor from ('||s||')';
        open ref_ for s using  pRecordPerPage;
    else
        open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    end if;
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
function edit_chuyentuyens(
    pmst varchar2,
    pten varchar2,
    pma_tinh varchar2,
    pdia_chi varchar2,
    pma_nv_cu varchar2,
    pma_nv varchar2,
    pkieu varchar2,
    pnoidung varchar2,
    pnguoi_cn varchar2,
    pngay_cn varchar2,
    pip_cn varchar2,
    pid varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    s:='update tax.chuyentuyens set  mst=:mst,ten=:ten,ma_tinh=:ma_tinh,dia_chi=:dia_chi,ma_nv_cu=:ma_nv_cu,ma_nv=:ma_nv,kieu=:kieu,noidung=:noidung,nguoi_cn=:nguoi_cn,ngay_cn=:ngay_cn,ip_cn=:ip_cn,id=:id where id=:id';
    execute immediate s using pmst,pten,pma_tinh,pdia_chi,pma_nv_cu,pma_nv,pkieu,pnoidung,pnguoi_cn,to_date(pngay_cn,'dd/mm/yyyy'),pip_cn,pid,pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_chuyentuyens(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    s:='delete from tax.chuyentuyens where id=:id';
    execute immediate s using pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function search_phieuhuys(
    pma_tinh varchar2,
    ptu_ngay varchar2,
    pden_ngay varchar2,
    pma_cq_thu varchar2,
    pma_bc varchar2,
    pquaythu_id varchar2,
    pnguoi_huy varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(2000);
    ref_ sys_refcursor;
begin
    s:='select a.mst,f.tentieumuc,b.name httt_name, to_char(a.ngay_huy, ''dd/mm/yyyy hh24:mi:ss'') ngay_huy,
    to_char(a.ngay_tt, ''dd/mm/yyyy hh24:mi:ss'') ngay_tt,a.nguoi_huy,c.TENBUUCUC,e.TENQUAY,d.TEN_DV
    from tax.phieuhuys a
    left join tax.hinhthuc_tts b on (a.httt_id = b.id)
    left join TAX.BUUCUCTHUS c on (a.ma_bc = c.id  )
    left join TAX.DONVI_QLS d on (c.DONVIQL_ID = d.ID and c.ma_tinh = d.ma_tinh)
    left join TAX.QUAYTHUS e on (a.QUAYTHU_ID = e.ID  )
    left join TAX.TIEU_MUCS f on (a.ma_tmuc = f.ID  ) where 1=1  ';
  if pma_tinh is not null then s:=s||' and a.ma_tinh = '''||pma_tinh||''''; end if;
  if ptu_ngay is not null then s:=s||' and ngay_huy >= to_date('''||ptu_ngay||''',''dd/mm/yyyy hh24:mi:ss'')'; end if;
  if pden_ngay is not null then s:=s||' and ngay_huy < to_date('''||pden_ngay||''',''dd/mm/yyyy hh24:mi:ss'')+1'; end if;
  if pma_bc is not null then s:=s||' and a.MA_BC = '''||pma_bc||''''; end if;
  if pma_cq_thu is not null then s:=s||' and c.donviql_id = '''||pma_cq_thu||''''; end if;
  if pquaythu_id is not null then s:=s||' and a.QUAYTHU_ID = '''||pquaythu_id||''''; end if;
  if pnguoi_huy is not null then s:=s||' and a.NGUOI_HUY = '''||pnguoi_huy||''''; end if;
  s:=s||' order by a.id desc';
  if(pPageIndex=-1) then
    s:='select ceil(count(*)/:1) nop,count(1) nor from ('||s||')';
    open ref_ for s using  pRecordPerPage;
  else
      open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
  end if;
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
PROCEDURE REPORT_PHIEUHUYS(
    pma_tinh varchar2,
    ptu_ngay varchar2,
    pden_ngay varchar2,
    pdon_vi varchar2,
    pma_bc varchar2,
    pquaythu_id varchar2,
    pnguoi_huy varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(1000);

begin
    s:='select a.mst,f.tentieumuc,b.name httt_name, to_char(a.ngay_huy, ''dd/mm/yyyy hh24:mi:ss'') ngay_huy,
    to_char(a.ngay_tt, ''dd/mm/yyyy hh24:mi:ss'') ngay_tt,a.nguoi_huy,c.TENBUUCUC,e.TENQUAY,d.TEN_DV, a.SOTIEN,
    a.ma_chuan_chi mcc,a.so_tham_chieu stc
    from tax.phieuhuys a
    left join tax.hinhthuc_tts b on (a.httt_id = b.id)
    left join TAX.BUUCUCTHUS c on (a.ma_bc = c.id )
    left join TAX.DONVI_QLS d on (c.DONVIQL_ID = d.ID and c.ma_tinh = d.ma_tinh)
    left join TAX.QUAYTHUS e on (a.QUAYTHU_ID = e.ID )
    left join TAX.TIEU_MUCS f on (a.ma_tmuc = f.ID  ) where 1=1  ';

    if pma_tinh is not null then s:=s||' and a.ma_tinh = '''||pma_tinh||''''; end if;
    if ptu_ngay is not null then s:=s||' and ngay_huy >= to_date('''||ptu_ngay||''',''dd/mm/yyyy hh24:mi:ss'')'; end if;
    if pden_ngay is not null then s:=s||' and ngay_huy < to_date('''||pden_ngay||''',''dd/mm/yyyy hh24:mi:ss'')+1'; end if;
    if pma_bc is not null then s:=s||' and a.MA_BC = '''||pma_bc||''''; end if;
    if pdon_vi is not null then s:=s||' and c.donviql_id = '''||pdon_vi||''''; end if;
    if pquaythu_id is not null then s:=s||' and a.QUAYTHU_ID = '''||pquaythu_id||''''; end if;
    if pnguoi_huy is not null then s:=s||' and a.NGUOI_HUY = '''||pnguoi_huy||''''; end if;
    s:=s||' order by a.id desc';
    open report_out for s ;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;

function search_phieuhuys_nguoihuy(
    pma_tinh varchar2,
    pma_dvi varchar2,
    pma_bc varchar2,
    pquaythu_id varchar2)
return sys_refcursor
is
    s varchar2(2000);
    ref_ sys_refcursor;
begin
    s:='select a.nguoi_huy id, b.last_name from TAX.PHIEUHUYS a
    left join TAX.USER_INFO b on (a.nguoi_huy = b.id and a.ma_tinh = b.agent)
    left join TAX.BUUCUCTHUS c on (a.ma_bc = c.id and a.ma_tinh = c.ma_tinh)
    where 1=1 ';

    if pma_tinh is not null then s:=s||' and a.ma_tinh = '''||pma_tinh||''''; end if;
    if pma_dvi is not null then s:=s||' and c.donviql_id = '''||pma_dvi||''''; end if;
    if pma_bc is not null then s:=s||' and a.MA_BC = '''||pma_bc||''''; end if;
    if pquaythu_id is not null then s:=s||' and a.QUAYTHU_ID = '''||pquaythu_id||''''; end if;
    s:=s||' group by a.nguoi_huy,b.last_name';

    open ref_ for s;
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
function search_report_ketquaphats(
    pma_tinh varchar2,
    ptu_ngay varchar2,
    pden_ngay varchar2,
    pma_cq_thu varchar2,
    pma_bc varchar2,
    pquaythu_id varchar2,
    pnguoi_huy varchar2,
    pduong_thu varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(2000);
    ref_ sys_refcursor;
begin
    s:='select a.MST,e.NAME CHUNGTU_NAME,a.CHUKY,to_char(a.NGAY_NHAP, ''dd/mm/yyyy hh24:mi:ss'') NGAY_NHAP,
    decode(a.TRANG_THAI,1, ''Phat duoc'', ''Nhan ve'') KET_QUA
    from TAX.KETQUAPHATS a
    left join TAX.NGUOIGACHNOS b on (a.LOGUSER = b.ID and a.MA_TINH = b.MA_TINH)
    left join TAX.BUUCUCTHUS c on (b.MABC_ID = c.ID and a.MA_TINH = c.MA_TINH)
    left join TAX.DONVI_QLS d on (c.DONVIQL_ID = d.ID and a.MA_TINH = d.MA_TINH)
    left join TAX.CHUNGTU e on (a.CHUNGTU_ID = e.ID) where 1=1 ';

    if pma_tinh is not null then s:=s||' and a.ma_tinh = '''||pma_tinh||''''; end if;
    if ptu_ngay is not null then s:=s||' and NGAY_NHAP >= to_date('''||ptu_ngay||''',''dd/mm/yyyy hh24:mi:ss'')'; end if;
    if pden_ngay is not null then s:=s||' and NGAY_NHAP < to_date('''||pden_ngay||''',''dd/mm/yyyy hh24:mi:ss'')+1'; end if;
    if pma_bc is not null then s:=s||' and b.MABC_ID = '''||pma_bc||''''; end if;
    if pma_cq_thu is not null then s:=s||' and d.ID = '''||pma_cq_thu||''''; end if;
    if pquaythu_id is not null then s:=s||' and b.QUAYTHU_ID = '''||pquaythu_id||''''; end if;
    if pnguoi_huy is not null then s:=s||' and a.LOGUSER = '''||pnguoi_huy||''''; end if;
    if pduong_thu is not null then s:=s||' and a.MA_NV = '''||pduong_thu||''''; end if;
    s:=s||' order by a.ID desc ';

    if(pPageIndex=-1) then
      s:='select ceil(count(*)/:1) nop,count(1) nor from ('||s||')';
      open ref_ for s using  pRecordPerPage;
    else
        open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    end if;
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
PROCEDURE REPORT_KETQUAPHATS(
    pma_tinh varchar2,
    ptu_ngay varchar2,
    pden_ngay varchar2,
    pma_cq_thu varchar2,
    pma_bc varchar2,
    pquaythu_id varchar2,
    pnguoi_huy varchar2,
    pduong_thu varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(1000);
begin
    s:='select a.MST,e.NAME CHUNGTU_NAME,a.CHUKY,to_char(a.NGAY_NHAP, ''dd/mm/yyyy hh24:mi:ss'') NGAY_NHAP,
    decode(a.TRANG_THAI,1, ''Phat duoc'', ''Nhan ve'') KET_QUA,c.TENBUUCUC,d.TEN_DV,f.tenquay,b.id HOVATEN,a.MA_NV,a.loguser nguoi_nhap
    from TAX.KETQUAPHATS a
    left join TAX.NGUOIGACHNOS b on (a.LOGUSER = b.ID and a.MA_TINH = b.MA_TINH)
    left join TAX.BUUCUCTHUS c on (b.MABC_ID = c.ID and a.MA_TINH = c.MA_TINH)
    left join TAX.DONVI_QLS d on (c.DONVIQL_ID = d.ID and a.MA_TINH = d.MA_TINH)
    left join TAX.CHUNGTU e on (a.CHUNGTU_ID = e.ID)
    left join TAX.QUAYTHUS f on (b.MABC_ID = f.ID and f.MA_TINH = a.MA_TINH) where 1=1 ';

    if pma_tinh is not null then s:=s||' and a.ma_tinh = '''||pma_tinh||''''; end if;
    if ptu_ngay is not null then s:=s||' and NGAY_NHAP >= to_date('''||ptu_ngay||''',''dd/mm/yyyy hh24:mi:ss'')'; end if;
    if pden_ngay is not null then s:=s||' and NGAY_NHAP < to_date('''||pden_ngay||''',''dd/mm/yyyy hh24:mi:ss'')+1'; end if;
    if pma_bc is not null then s:=s||' and b.MABC_ID = '''||pma_bc||''''; end if;
    if pma_cq_thu is not null then s:=s||' and d.ID = '''||pma_cq_thu||''''; end if;
    if pquaythu_id is not null then s:=s||' and b.QUAYTHU_ID = '''||pquaythu_id||''''; end if;
    if pnguoi_huy is not null then s:=s||' and a.LOGUSER = '''||pnguoi_huy||''''; end if;
    if pduong_thu is not null then s:=s||' and a.MA_NV = '''||pduong_thu||''''; end if;
    s:=s||' order by d.TEN_DV,c.TENBUUCUC,f.tenquay,b.id,a.MA_NV ';
    open report_out for s ;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;
function search_report_tiennop(
    pma_tinh varchar2,
    ptu_ngay varchar2,
    pden_ngay varchar2,
    pma_cq_thu varchar2,
    pma_bc varchar2,
    pquaythu_id varchar2,
    pnguoi_huy varchar2,
    pduong_thu varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(2000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai();
begin

    s:='select a.ma_nv,(select ten_nv from nhanvien_tcs where ma_tinh='''||pma_tinh||''' and id=a.ma_nv) ten_nv, to_char(a.tientra,''fm999,999,999,999,999'') tientra,
        to_char(nvl(b.tien_nop,0),''fm999,999,999,999,999'') tien_nop, to_char(nvl(a.tientra,0)-nvl(b.tien_nop,0),''fm999,999,999,999,999'') tien_lech,
    d.tenbuucuc tenbuucuc,a.id nguoi_gach,a.tenquay,a.ten_dv
    from ( select sum(a.tientra) tientra, a.ma_nv,a.id,a.tenquay,a.ten_dv
    from ( select a.tientra,c.ma_nv,d.id,h.tenquay,f.ten_dv from
    (select * from ct_tra_'||ckn||' where ma_tinh='''||pma_tinh||''') a,
    (select * from bangphieutra_'||ckn||' where ma_tinh='''||pma_tinh||'''
        and ngay_thuc >= to_date('''||ptu_ngay||''',''dd/mm/yyyy hh24:mi:ss'')
        and ngay_thuc < to_date('''||pden_ngay||''',''dd/mm/yyyy hh24:mi:ss'')+1) b,
    (select * from nnts_'||ckn||' where ma_tinh='''||pma_tinh||''') c,
    (select * from nguoigachnos where ma_tinh='''||pma_tinh||''') d,
    (select * from buucucthus where ma_tinh='''||pma_tinh||''') e,
    (select * from donvi_qls  where ma_tinh='''||pma_tinh||''') f,
    (select * from duongthus where ma_tinh='''||pma_tinh||''') g,
    (select * from quaythus where ma_tinh='''||pma_tinh||''') h
    where a.phieu_id = b.id and a.mst = c.mst
    and b.nguoigachno_id = d.id and d.mabc_id = e.id and e.donviql_id = f.id
    and d.quaythu_id=h.id and b.nguoigachno_id = g.id and g.ma_nv = c.ma_nv';

    if pma_cq_thu is not null then s:=s||' and e.donviql_id = '''||pma_cq_thu||''''; end if;
    if pma_bc is not null then s:=s||' and e.id = '''||pma_bc||''''; end if;
    if pquaythu_id is not null then s:=s||' and  b.quaythu_id = '''||pquaythu_id||''''; end if;
    if pnguoi_huy is not null then s:=s||' and d.id = '''||pnguoi_huy||''''; end if;
    if pduong_thu is not null then s:=s||' and g.id = '''||pduong_thu||''''; end if;

    s:=s||')a  group by a.ma_nv,a.id,a.tenquay,a.ten_dv ) a
    left join nhanvien_tcs c on a.ma_nv=c.id
    left join buucucthus d on c.mabc_id=d.id
    left join (select sum(tien) tien_nop,ma_nv from tien_nop where ma_tinh ='''||pma_tinh||'''';
    if ptu_ngay is not null then s:=s||'  and ngay_nop >= to_date('''||ptu_ngay||''',''dd/mm/yyyy hh24:mi:ss'')'; end if;
    if pden_ngay is not null then s:=s||' and ngay_nop < to_date('''||pden_ngay||''',''dd/mm/yyyy hh24:mi:ss'')+1'; end if;
      s:=s||'group by ma_nv) b on a.ma_nv = b.ma_nv order by a.ma_nv';

    if(pPageIndex=-1) then
      s:='select ceil(count(*)/:1) nop,count(1) nor from ('||s||')';
      open ref_ for s using  pRecordPerPage;
    else
        open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    end if;
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

PROCEDURE REPORT_TIENNOP(
    pma_tinh varchar2,
    ptu_ngay varchar2,
    pden_ngay varchar2,
    pma_cq_thu varchar2,
    pma_bc varchar2,
    pquaythu_id varchar2,
    pnguoi_huy varchar2,
    pduong_thu varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(2000);
    ckn varchar2(100):=crud.ckn_hientai();
begin
    s:='select a.ma_nv,(select ten_nv from nhanvien_tcs where ma_tinh='''||pma_tinh||''' and id=a.ma_nv) ten_nv,
    a.tientra,nvl(b.tien_nop,0) tien_nop,nvl(a.tientra,0)-nvl(b.tien_nop,0) tien_lech,
    d.tenbuucuc tenbuucuc,a.id nguoi_gach,a.tenquay,a.ten_dv
    from ( select sum(a.tientra) tientra, a.ma_nv,a.id,a.tenquay,a.ten_dv
    from ( select a.tientra,c.ma_nv,d.id,h.tenquay,f.ten_dv
    from (select * from ct_tra_'||ckn||' where ma_tinh ='''||pma_tinh||''') a,
    (select * from bangphieutra_'||ckn||' where ma_tinh ='''||pma_tinh||'''
        and ngay_thuc >= to_date('''||ptu_ngay||''',''dd/mm/yyyy hh24:mi:ss'')
        and ngay_thuc < to_date('''||pden_ngay||''',''dd/mm/yyyy hh24:mi:ss'')+1)b,
    (select * from nnts_'||ckn||' where ma_tinh ='''||pma_tinh||''') c,
    nguoigachnos d, buucucthus e, donvi_qls f,duongthus g, quaythus h
    where a.phieu_id = b.id and a.mst = c.mst and c.ma_tinh ='''||pma_tinh||'''
    and e.ma_tinh='''||pma_tinh||'''
    and b.nguoigachno_id = d.id and d.vnpt=1 and d.mabc_id = e.id and e.donviql_id = f.id and f.ma_tinh='''||pma_tinh||'''
    and d.quaythu_id=h.id and c.ma_nv = g.ma_nv(+)';

    if pma_cq_thu is not null then s:=s||' and e.DONVIQL_ID = '''||pma_cq_thu||''''; end if;
    if pma_bc is not null then s:=s||' and e.ID = '''||pma_bc||''''; end if;
    if pquaythu_id is not null then s:=s||' and  b.quaythu_id = '''||pquaythu_id||''''; end if;
    if pnguoi_huy is not null then s:=s||' and d.ID = '''||pnguoi_huy||''''; end if;
    if pduong_thu is not null then s:=s||' and g.ID = '''||pduong_thu||''''; end if;

    s:=s||')a  group by a.ma_nv,a.id,a.tenquay,a.ten_dv ) a
    left join nhanvien_tcs c on a.ma_nv=c.id
    left join buucucthus d on c.mabc_id=d.id and c.ma_tinh =d.ma_tinh
    left join (select sum(tien) tien_nop,ma_nv from tien_nop where ma_tinh ='''||pma_tinh||'''
                and ngay_nop >= to_date('''||ptu_ngay||''',''dd/mm/yyyy hh24:mi:ss'')
                and ngay_nop < to_date('''||pden_ngay||''',''dd/mm/yyyy hh24:mi:ss'')+1
    group by ma_nv) b on a.ma_nv = b.ma_nv order by a.ten_dv,d.tenbuucuc,a.tenquay,a.id,a.ma_nv';

    open report_out for s ;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;

PROCEDURE report_receipts(pphieu varchar2,
    pma_tinh varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(10000);
    ckn varchar2(100):=crud.ckn_hientai();
    l_tien_tra number;
    l_tien_chu varchar(200);
    l_ten_dv varchar2(200);
    l_diachi_dv varchar2(500);
    l_mst_dv varchar2(100);
    l_tinh varchar2(200);
    l_kythu varchar2(200);
    l_lanthu varchar2(200);
    l_tieno number:=0;
    l_tienps number:=0;
    l_mst varchar2(20);
begin
    l_kythu := 'Quy '||TO_CHAR(sysdate,'Q')||'/'|| to_char(sysdate,'yyyy')||'-'||to_char(sysdate,'mm');

    s:='select max(mst), max(a.kythue), sum(a.tientra), tax.util.doisosangchu(sum(a.tientra))
         from tax.ct_tra_'||ckn||' a
        where  a.phieu_id =:1
        and a.ma_tinh =:2';
    execute immediate s into l_mst,l_lanthu,l_tien_tra,l_tien_chu using pphieu,pma_tinh;

    --Tien no
    execute immediate 'select sum(no_cuoi_ky) from ct_no_'||ckn||' where mst =:1 and kythue =:2 and kieu_no =0'
        into l_tieno using l_mst,l_lanthu;

    --Tien phat sinh
    execute immediate 'select sum(no_cuoi_ky) from ct_no_'||ckn||' where mst =:1 and kythue =:2 and kieu_no =1'
        into l_tienps using l_mst,l_lanthu;

    begin
        /*s:='select a.ten_dv,a.diachi diachi_dv,a.mst mst_dv,(select province_name from provinces where id = a.ma_tinh and rownum =1)
                from donvi_qls a where ma_tinh =:1 and ID=0 and rownum=1';
        execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv,l_tinh using pma_tinh;*/
        s:='SELECT name_phieu,add_phieu,mst_phieu,(select province_name from provinces where id = a.agent_c and rownum =1) tinh FROM tax.config_contract a WHERE EXISTS(SELECT 1 FROM  tax.nnts_2016 b
        WHERE a.id_ref =b.ma_cqt_ql AND EXISTS (SELECT 1 FROM tax.ct_tra_2016 c WHERE b.mst=c.mst and c.phieu_id=:1))';
        execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv,l_tinh using pphieu;
        exception when others then
            l_ten_dv :='';l_diachi_dv :='';l_mst_dv :='';l_tinh :='';
    end;

    s:='select rownum stt,d.ky kythu, '''||l_lanthu||''' lanthu, '||nvl(l_tieno,0)||' tien_no,
        '''||l_ten_dv||''' ten_dv, '''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv, '''||l_tinh||''' tinh,
        '||l_tien_tra||' tong_tien,'''||l_tien_chu||''' tong_tien_chu,a.mst,a.ma_tmuc tieumuc_id,
        a.tientra tien_tieu_muc,e.no_cuoi_ky tien_muc,(select TEN_CHUONG from  tax.chuongs where a.ma_chuong = id) ten_chuong,
        (select TENTIEUMUC from  tax.tieu_mucs where a.ma_tmuc = id) tieu_muc, c.ma_nv||'':''||c.ma_t ma_nv, b.quaythu_id quaythu,
         a.phieu_id, to_char(b.ngay_tt,''dd/mm/yyyy'') ngay_tt, c.mobile, c.mst||'''||l_lanthu||''' barcode, b.seri
         from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b, nnts_'||ckn||' c, ck_thue d, tax.ct_no_'||ckn||' e
        where a.phieu_id = b.id and a.phieu_id =:1
        and a.mst = c.mst and a.chuky = d.chuky(+)
        and a.mst = e.mst and a.ma_tmuc = e.ma_tmuc
        and a.kythue = e.kythue and a.chuky = e.chuky
        and a.ma_cq_thu = c.ma_cqt_ql and a.ma_cq_thu = e.ma_cq_thu
        and a.ma_tinh =:2 order by rownum,a.chuky  ';
    open report_out for s using pphieu,pma_tinh;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;

FUNCTION EXP_DATA_PAYMENT (i_agent varchar2, i_user varchar2, i_kythu varchar2, i_khobac varchar2)
Return sys_refcursor
Is
    ckn varchar2(100):= crud.ckn_hientai();
    l_sql clob;
    ref_ sys_refcursor;
    l_role number;
    l_cqt varchar2(10);
Begin
    l_role := tax.check_role_lever(i_user=> i_user);
    select cqt_tms into l_cqt from coquanthus a where shkb=i_khobac;

    l_sql :='select a.mst,nvl(c.ma_nv,'' '') ma_nv,tax.cfont_utotcvn3(substr(c.ten_nnt,1,250)) ten_nnt,
                tax.cfont_utotcvn3(substr(c.mota_diachi,1,250)) diachi,to_char(tax.format_money(a.tientra,''.'')) tientra,a.ma_tmuc,
                a.kythue,b.nguoigachno_id nguoi_gach,to_char(b.ngay_tt,''dd/mm/yyyy hh24:mi:ss'') ngay_tt
        from ct_tra_'||ckn||' a, bangphieutra_'||ckn||' b, nnts_'||ckn||' c where a.phieu_id=b.id
            and a.ma_cq_thu = c.ma_cqt_ql
                and a.mst=c.mst and c.ma_tinh='''||i_agent||'''';

    If l_cqt is not null then
        l_sql := l_sql||' and a.ma_cq_thu ='''||l_cqt||'''';
    End if;
    If i_kythu is not null then
        l_sql := l_sql||' and a.kythue ='''||i_kythu||'''';
    End if;

    If l_role = 0 then
        l_sql := l_sql||' and rownum<1';
    End if;

    l_sql := l_sql||' order by c.ma_nv,c.ma_xa,a.kythue,b.ngay_tt,b.nguoigachno_id';
    Open ref_ for  l_sql;
    Return  ref_;

    Exception when others then
        declare err varchar2(500);
        begin    err:='Loi thuc hien, ma loi:'||TO_CHAR(SQLCODE)||': '||SQLERRM;
            open ref_ for 'select :1 err from dual' using err; return ref_;
        End;
End;

FUNCTION EXP_DATA_DEPT (i_agent varchar2,i_user varchar2, i_kythu varchar2, i_khobac varchar2)
Return sys_refcursor
Is
    ckn varchar2(100):= crud.ckn_hientai();
    l_sql clob;
    ref_ sys_refcursor;
    l_role number;
    l_cqt varchar2(10);
Begin
    l_role := tax.check_role_lever(i_user=> i_user);
    select cqt_tms into l_cqt from coquanthus a where shkb=i_khobac;

    l_sql :='select a.mst,tax.cfont_utotcvn3(substr(b.ten_nnt,1,250)) ten_nnt,tax.cfont_utotcvn3(substr(nvl(b.mota_diachi,'' ''),1,250)) diachi,
                to_char(tax.format_money(a.no_cuoi_ky,''.'')) tien_no,a.ma_tmuc,a.kythue,a.chuky, nvl(b.ma_nv,'' '') ma_nv
                from ct_no_'||ckn||' a, nnts_'||ckn||' b where a.mst=b.mst
                and a.ma_cq_thu = b.ma_cqt_ql
                and a.ma_tinh='''||i_agent||'''';

    If l_cqt is not null then
        l_sql := l_sql||' and a.ma_cq_thu ='''||l_cqt||'''';
    End if;
    If i_kythu is not null then
        l_sql := l_sql||' and a.kythue ='''||i_kythu||'''';
    End if;

    If l_role = 0 then
        l_sql := l_sql||' and rownum<1';
    End if;
    Open ref_ for  l_sql;
    Return  ref_;

    Exception when others then
        declare err varchar2(500);
        begin    err:='Loi thuc hien, ma loi:'||TO_CHAR(SQLCODE)||': '||SQLERRM;
            open ref_ for 'select :1 err from dual' using err; return ref_;
        End;
End;


procedure REPORT_INFO_PAYMENT(
    pma_tinh varchar2,
    pdonvi varchar2,
    pbuucuc varchar2,
    pquaythu varchar2,
    pnguoigachno varchar2,
    pduongthu varchar2,
    pkythu varchar2,
    ptungay varchar2,
    pdenngay varchar2,
    ptype varchar2,
    report_out OUT SYS_REFCURSOR,
    pdata varchar2 default 1
    )
is
    s varchar2(3000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai;
    l_ten_dv varchar(200);
    l_diachi_dv varchar(500);
    l_mst_dv varchar(50);
Begin
    s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
    Execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;

    If ptype=1 then
        s:='Select '''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv,
          (select x.id||''|''||x.ten_nv from nhanvien_tcs x where x.ma_tinh='''||pma_tinh||''' and x.id=ma_nv) ma_nv,
              tien_giao, nvl(tien_tra,0) tien_tra, nguoi_giao, quay, buucuc, donvi, kythue, sophieu
           from (select a.ma_nv,a.nguoi_giao,sum(a.tien_giao) tien_giao,sum(b.tientra) tien_tra,
              d.tenquay quay,e.tenbuucuc buucuc,f.ten_dv donvi,a.kythue,count(1) sophieu
        from (
            select sum(a.tien_giao) tien_giao,a.ma_nv,a.nguoi_giao,a.mst,a.kythue from tax.phieu_'||ckn||' a
            where exists (select 1 from tax.nhanvien_tcs b where a.ma_nv=b.id and b.ma_tinh =:1)';

            if ptungay is not null then
                s:=s||' and a.ngay_giao >= to_date('''||ptungay||''',''dd/mm/yyyy'')';
            end if;
            if pdenngay is not null then
                s:=s||' and a.ngay_giao < to_date('''||pdenngay||''',''dd/mm/yyyy'') +1';
            end if;

            s:=s||'group by a.ma_nv,a.nguoi_giao,a.mst,a.kythue) a,
                (select sum(b.tientra) tientra,a.mst,b.kythue from tax.bangphieutra_'||ckn||' a, tax.ct_tra_'||ckn||' b, nguoigachnos c
                    where a.id = b.phieu_id and a.nguoigachno_id=c.id and c.vnpt ='||pdata||'
                    and a.ma_tinh =:2';

            if ptungay is not null then
                s:=s||' and a.ngay_tt >= to_date('''||ptungay||''',''dd/mm/yyyy'')';
            end if;
            if pdenngay is not null then
                s:=s||' and a.ngay_tt < to_date('''||pdenngay||''',''dd/mm/yyyy'') +1';
            end if;

            s:=s||'group by a.mst,a.mst,b.kythue) b,
            tax.nguoigachnos c, (select * from tax.quaythus where ma_tinh='''||pma_tinh||''')d,
            (select * from tax.buucucthus where ma_tinh='''||pma_tinh||''') e,
            (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') f
            where a.mst = b.mst(+) and a.kythue =b.kythue(+) and a.nguoi_giao = c.id and c.quaythu_id = d.id
            and d.mabc_id = e.id and e.donviql_id = f.id';

            if pdonvi is not null then s:=s||' and f.id = '''||pdonvi||''''; end if;
            if pbuucuc is not null then s:=s||' and e.id = '''||pbuucuc||''''; end if;
            if pquaythu is not null then s:=s||' and d.id = '''||pquaythu||''''; end if;
            if pnguoigachno is not null then s:=s||' and c.id = '''||pnguoigachno||''''; end if;
            if pduongthu is not null then s:=s||' and a.ma_nv = '''||pduongthu||''''; end if;
            if pkythu is not null then s:=s||' and a.kythue = '''||pkythu||''''; end if;
        s:=s||' group by  f.ten_dv,e.tenbuucuc,d.tenquay,a.ma_nv,a.kythue,a.nguoi_giao order by f.ten_dv,e.tenbuucuc,d.tenquay,a.nguoi_giao,a.ma_nv,a.kythue)';

        Open report_out for s using pma_tinh,pma_tinh;

    Elsif (ptype=2) then

        s:='select  '''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv,
            (select x.id||''|''||x.ten_nv from nhanvien_tcs x where x.ma_tinh='''||pma_tinh||''' and x.id=a.ma_nv) ma_nv,
            a.mst,a.tien_giao,a.nguoi_giao,nvl(b.tientra,0) tien_tra,b.nguoigachno_id nguoi_tra,
            to_char(a.ngay_giao,''dd/mm/yyyy hh24:mi:ss'') ngay_giao,to_char(b.ngay_tt,''dd/mm/yyyy hh24:mi:ss'') ngay_tra,
                d.tenquay quay,e.tenbuucuc buucuc,f.ten_dv donvi,a.kythue
            from (
                    select sum(a.tien_giao) tien_giao,a.ma_nv,a.nguoi_giao,a.mst,a.kythue,a.ngay_giao from tax.phieu_'||ckn||' a
                    where exists (select 1 from tax.nhanvien_tcs b where a.ma_nv=b.id and b.ma_tinh =:1)';
                    if ptungay is not null then
                        s:=s||' and a.ngay_giao >= to_date('''||ptungay||''',''dd/mm/yyyy'')';
                    end if;
                    if pdenngay is not null then
                        s:=s||' and a.ngay_giao < to_date('''||pdenngay||''',''dd/mm/yyyy'') +1';
                    end if;

                    s:=s||' group by a.ma_nv,a.nguoi_giao,a.mst,a.kythue,a.ngay_giao) a,
                        (select sum(b.tientra) tientra,a.mst,b.kythue,a.nguoigachno_id,max(a.ngay_tt) ngay_tt
                            from tax.bangphieutra_'||ckn||' a, tax.ct_tra_'||ckn||' b, nguoigachnos c
                            where a.id = b.phieu_id and a.nguoigachno_id=c.id and c.vnpt ='||pdata||'
                            and a.ma_tinh =:2';

                    if ptungay is not null then
                        s:=s||' and a.ngay_tt >= to_date('''||ptungay||''',''dd/mm/yyyy'')';
                    end if;
                    if pdenngay is not null then
                        s:=s||' and a.ngay_tt < to_date('''||pdenngay||''',''dd/mm/yyyy'') +1';
                    end if;

                    s:=s||' group by a.mst,b.kythue,a.nguoigachno_id) b,
                        tax.nguoigachnos c, (select * from tax.quaythus where ma_tinh='''||pma_tinh||''')d,
                        (select * from tax.buucucthus where ma_tinh='''||pma_tinh||''') e,
                        (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') f
                        where a.mst = b.mst(+) and a.kythue=b.kythue(+) and a.nguoi_giao = c.id and c.quaythu_id = d.id
                        and d.mabc_id = e.id and e.donviql_id = f.id';

                    if pdonvi is not null then s:=s||' and f.id = '''||pdonvi||''''; end if;
                    if pbuucuc is not null then s:=s||' and e.id = '''||pbuucuc||''''; end if;
                    if pquaythu is not null then s:=s||' and d.id = '''||pquaythu||''''; end if;
                    if pnguoigachno is not null then s:=s||' and c.id = '''||pnguoigachno||''''; end if;
                    if pduongthu is not null then s:=s||' and a.ma_nv = '''||pduongthu||''''; end if;
                    if pkythu is not null then s:=s||' and a.kythue = '''||pkythu||''''; end if;
        s:=s||' order by f.ten_dv,e.tenbuucuc,d.tenquay,a.nguoi_giao,a.ma_nv';
        Open report_out for s using pma_tinh,pma_tinh;
    Elsif (ptype=3) then
        s:='select  '''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv,
            (select x.id||''|''||x.ten_nv from nhanvien_tcs x where x.ma_tinh='''||pma_tinh||''' and x.id=a.ma_nv) ma_nv,
            a.mst,a.kythue,a.tien_giao,a.nguoi_giao,b.ten_nnt,b.MOTA_DIACHI diachi_nnt,
            to_char(a.ngay_giao,''dd/mm/yyyy hh24:mi:ss'') ngay_giao,d.tenquay quay,e.tenbuucuc buucuc,f.ten_dv donvi
        from (
                select sum(a.tien_giao) tien_giao,a.ma_nv,a.nguoi_giao,a.mst,a.ngay_giao,a.kythue from tax.phieu_'||ckn||' a
                where exists (select 1 from tax.nhanvien_tcs b where a.ma_nv=b.id and b.ma_tinh =:1)';
                if ptungay is not null then
                    s:=s||' and a.ngay_giao >= to_date('''||ptungay||''',''dd/mm/yyyy'')';
                end if;
                if pdenngay is not null then
                    s:=s||' and a.ngay_giao < to_date('''||pdenngay||''',''dd/mm/yyyy'') +1';
                end if;
                if pduongthu is not null then
                    s:=s||' and a.ma_nv = '''||pduongthu||'''';
                end if;

                s:=s||'group by a.ma_nv,a.nguoi_giao,a.mst,a.kythue,a.ngay_giao) a, nnts_'||ckn||' b,
                        tax.nguoigachnos c, (select * from tax.quaythus where ma_tinh='''||pma_tinh||''')d,
                        (select * from tax.buucucthus where ma_tinh='''||pma_tinh||''') e,
                        (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') f
                where a.mst = b.mst and a.nguoi_giao = c.id and c.quaythu_id = d.id
                and d.mabc_id = e.id and e.donviql_id = f.id
                and not exists(select 1 from ketquaphats c where a.mst = c.mst and a.kythue = c.chuky)
                and not exists(select 1 from ct_tra_'||ckn||' d where a.mst = d.mst and a.kythue = d.kythue and d.ma_tinh=:2)';

                if pdonvi is not null then s:=s||' and f.id = '''||pdonvi||''''; end if;
                if pbuucuc is not null then s:=s||' and e.id = '''||pbuucuc||''''; end if;
                if pquaythu is not null then s:=s||' and d.id = '''||pquaythu||''''; end if;
                if pnguoigachno is not null then s:=s||' and c.id = '''||pnguoigachno||''''; end if;
                if pduongthu is not null then s:=s||' and a.ma_nv = '''||pduongthu||''''; end if;
                if pkythu is not null then s:=s||' and a.kythue = '''||pkythu||''''; end if;

                s:=s||' order by f.ten_dv,e.tenbuucuc,d.tenquay,a.nguoi_giao,a.ma_nv';
        Open report_out for s using pma_tinh,pma_tinh;
    Else
        s:='select  '''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv,
            (select x.id||''|''||x.ten_nv from nhanvien_tcs x where x.ma_tinh='''||pma_tinh||''' and x.id=a.ma_nv) ma_nv,
            a.mst,a.kythue,a.tien_giao,a.nguoi_giao,b.ten_nnt,b.MOTA_DIACHI diachi_nnt,
            to_char(a.ngay_giao,''dd/mm/yyyy hh24:mi:ss'') ngay_giao,d.tenquay quay,e.tenbuucuc buucuc,f.ten_dv donvi
        from (
                select sum(a.tien_giao) tien_giao,a.ma_nv,a.nguoi_giao,a.mst,a.ngay_giao,a.kythue from tax.phieu_'||ckn||' a
                where exists (select 1 from tax.nhanvien_tcs b where a.ma_nv=b.id and b.ma_tinh =:1)';
                if ptungay is not null then
                    s:=s||' and a.ngay_giao >= to_date('''||ptungay||''',''dd/mm/yyyy'')';
                end if;
                if pdenngay is not null then
                    s:=s||' and a.ngay_giao < to_date('''||pdenngay||''',''dd/mm/yyyy'') +1';
                end if;
                if pduongthu is not null then
                    s:=s||' and a.ma_nv = '''||pduongthu||'''';
                end if;

                s:=s||'group by a.ma_nv,a.nguoi_giao,a.mst,a.kythue,a.ngay_giao) a, nnts_'||ckn||' b,
                        tax.nguoigachnos c, (select * from tax.quaythus where ma_tinh='''||pma_tinh||''')d,
                        (select * from tax.buucucthus where ma_tinh='''||pma_tinh||''') e,
                        (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') f
                where a.mst = b.mst and a.nguoi_giao = c.id and c.quaythu_id = d.id
                and d.mabc_id = e.id and e.donviql_id = f.id
                and not exists(select 1 from ct_tra_'||ckn||' d where a.mst = d.mst and a.kythue = d.kythue and d.ma_tinh=:2)';

                if pdonvi is not null then s:=s||' and f.id = '''||pdonvi||''''; end if;
                if pbuucuc is not null then s:=s||' and e.id = '''||pbuucuc||''''; end if;
                if pquaythu is not null then s:=s||' and d.id = '''||pquaythu||''''; end if;
                if pnguoigachno is not null then s:=s||' and c.id = '''||pnguoigachno||''''; end if;
                if pduongthu is not null then s:=s||' and a.ma_nv = '''||pduongthu||''''; end if;
                if pkythu is not null then s:=s||' and a.kythue = '''||pkythu||''''; end if;

                s:=s||' order by f.ten_dv,e.tenbuucuc,d.tenquay,a.nguoi_giao,a.ma_nv';
        Open report_out for s using pma_tinh,pma_tinh;
    End if;

    Exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm)|| ', Detail:'|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; open report_out for 'select :1 err from dual' using err;
    End;
end;

PROCEDURE REPORT_INFO_DEBT_NEW(
    pma_tinh varchar2,
    pdonvi varchar2,
    pbuucuc varchar2,
    pquaythu varchar2,
    pnguoigachno varchar2,
    pduongthu varchar2,
    pkythu varchar2,
    ptungay varchar2,
    pdenngay varchar2,
    report_out OUT SYS_REFCURSOR,
    pdata varchar2 default 1)
is
    s varchar2(32000);
    l_mst number;
    ckn varchar2(100):=crud.ckn_hientai();
begin
    s:='select sum(sl_mst) from (select count(distinct a.mst) sl_mst
        from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b, (select mst,barcode,max(stt) stt from in_phieus group by mst,barcode) i,
        tax.nguoigachnos c,
        (select * from tax.quaythus where ma_tinh='''||pma_tinh||''') d,
        (select * from tax.buucucthus where ma_tinh='''||pma_tinh||''') e,
        (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') f,
         tax.nnts_'||ckn||' g, tax.hinhthuc_tts h
        where a.phieu_id = b.id and b.nguoigachno_id = c.id and c.vnpt ='||pdata||'
        and c.quaythu_id = d.id and d.mabc_id = e.id
        and e.donviql_id = f.id and a.mst = g.mst and a.ma_cq_thu = g.ma_cqt_ql
        and a.ma_tinh = g.ma_tinh and b.httt_id = h.id and a.mst||''/''||a.kythue= i.barcode(+)
        and a.ma_tinh ='''||pma_tinh||'''';

    if pdonvi is not null then s:=s||' and f.id like '''||replace(pdonvi,'*','%')||''''; end if;
    if pbuucuc is not null then s:=s||' and e.id like '''||replace(pbuucuc,'*','%')||''''; end if;
    if pquaythu is not null then s:=s||' and d.id like '''||replace(pquaythu,'*','%')||''''; end if;
    if pnguoigachno is not null then s:=s||' and b.nguoigachno_id like '''||replace(pnguoigachno,'*','%')||''''; end if;
    if ptungay is not null then s:=s||' and b.ngay_thuc >= to_date('''||ptungay||''',''dd/mm/yyyy'')'; end if;
    if pdenngay is not null then s:=s||' and b.ngay_thuc < to_date('''||pdenngay||''',''dd/mm/yyyy'') +1'; end if;
    if pduongthu is not null then s:=s||' and g.ma_nv = '''||pduongthu||''''; end if;
    if pkythu is not null then s:=s||' and a.kythue = '''||pkythu||''''; end if;
    s:=s||' group by a.mst,a.kythue)';
    execute immediate s into l_mst;

    if pma_tinh='79TTT' then
        s:='select rownum stt,a.mst,a.tientra,(select TEN_CHUONG from  tax.chuongs where a.ma_chuong = id) ten_chuong,
            (select ''[''||ID||'']''||TENTIEUMUC from  tax.tieu_mucs where a.ma_tmuc = id)||''|''||ck.ky ten_muc, a.phieu_id,
            to_char(b.ngay_thuc,''dd/mm/yyyy hh24:mi:ss'') ngay_tt, b.nguoigachno_id,b.ma_chuan_chi,b.so_tham_chieu,d.tenquay,
            e.tenbuucuc,f.ten_dv, g.ten_nnt, g.mota_diachi diachi, h.name hinhthuc,null tt_in,
            a.phieu_id, a.kythue, '||l_mst||' sl_mst,g.ma_nv manv,b.seri,b.ky_hieu,a.ma_tmuc,a.chuky,g.ma_xa,
            (select id||'' - ''||ten_nv from nhanvien_tcs where ma_tinh='''||pma_tinh||''' and id =g.ma_nv and rownum =1) ma_nv
             from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b, tax.nguoigachnos c,
            (select * from tax.quaythus where ma_tinh='''||pma_tinh||''') d,
            (select * from tax.buucucthus where ma_tinh='''||pma_tinh||''') e,
            (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') f, tax.nnts_'||ckn||' g, tax.hinhthuc_tts h, tax.ck_thue ck
            where a.phieu_id = b.id and b.nguoigachno_id = c.id and c.vnpt ='||pdata||'
            and c.quaythu_id = d.id and d.mabc_id = e.id
            and e.donviql_id = f.id and a.mst = g.mst and a.ma_cq_thu = g.ma_cqt_ql
            and a.ma_tinh = g.ma_tinh and b.httt_id = h.id
            and a.chuky = ck.chuky(+)
            and a.ma_tinh ='''||pma_tinh||'''';
    else
        s:='select rownum stt,a.mst,a.tientra,(select TEN_CHUONG from  tax.chuongs where a.ma_chuong = id) ten_chuong,
            (select ''[''||ID||'']''||TENTIEUMUC from  tax.tieu_mucs where a.ma_tmuc = id)||''|''||a.chuky ten_muc, a.phieu_id,
            to_char(b.ngay_thuc,''dd/mm/yyyy hh24:mi:ss'') ngay_tt, b.nguoigachno_id,d.tenquay,
            e.tenbuucuc,f.ten_dv, g.ten_nnt, g.mota_diachi diachi, h.name hinhthuc,i.stt tt_in,
            a.phieu_id, a.kythue, '||l_mst||' sl_mst,g.ma_nv manv,(select id||'' - ''||ten_nv from nhanvien_tcs where ma_tinh='''||pma_tinh||''' and id =g.ma_nv and rownum =1) ma_nv
             from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b, (select mst,barcode,max(stt) stt from in_phieus group by mst,barcode) i,
             tax.nguoigachnos c,
            (select * from tax.quaythus where ma_tinh='''||pma_tinh||''') d,
            (select * from tax.buucucthus where ma_tinh='''||pma_tinh||''') e,
            (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') f, tax.nnts_'||ckn||' g, tax.hinhthuc_tts h
            where a.phieu_id = b.id and b.nguoigachno_id = c.id and c.vnpt ='||pdata||'
            and c.quaythu_id = d.id and d.mabc_id = e.id
            and e.donviql_id = f.id and a.mst = g.mst and a.ma_cq_thu = g.ma_cqt_ql
            and a.ma_tinh = g.ma_tinh and b.httt_id = h.id
            and a.mst||''/''||a.kythue= i.barcode(+)
            and a.ma_tinh ='''||pma_tinh||'''';
    end if;

    if pdonvi is not null then s:=s||' and f.id like '''||replace(pdonvi,'*','%')||''''; end if;
    if pbuucuc is not null then s:=s||' and e.id like '''||replace(pbuucuc,'*','%')||''''; end if;
    if pquaythu is not null then s:=s||' and d.id like '''||replace(pquaythu,'*','%')||''''; end if;
    if pnguoigachno is not null then s:=s||' and b.nguoigachno_id like '''||replace(pnguoigachno,'*','%')||''''; end if;
    if ptungay is not null then s:=s||' and b.ngay_thuc >= to_date('''||ptungay||''',''dd/mm/yyyy'')'; end if;
    if pdenngay is not null then s:=s||' and b.ngay_thuc < to_date('''||pdenngay||''',''dd/mm/yyyy'') +1'; end if;
    if pduongthu is not null then s:=s||' and g.ma_nv = '''||pduongthu||''''; end if;
    if pkythu is not null then s:=s||' and a.kythue = '''||pkythu||''''; end if;

    if pma_tinh='01TTT' then
        s:=s||' order by f.ten_dv,e.tenbuucuc,d.tenquay,h.name,b.nguoigachno_id,g.ma_nv,a.mst,i.stt,a.kythue,b.ngay_thuc';
    else
        s:=s||' order by f.ten_dv,e.tenbuucuc,d.tenquay,h.name,b.nguoigachno_id,g.ma_nv,a.mst,a.kythue,b.ngay_thuc';
    end if;

    open report_out for s;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;

PROCEDURE REPORT_INFO_DEBT_SUM(
    pma_tinh varchar2,
    pdonvi varchar2,
    pbuucuc varchar2,
    pquaythu varchar2,
    pnguoigachno varchar2,
    pduongthu varchar2,
    pkythu varchar2,
    ptungay varchar2,
    pdenngay varchar2,
    report_out OUT SYS_REFCURSOR,
    pdata varchar2 default 1)
is
    s varchar2(32000);
    l_mst number;
    ckn varchar2(100):=crud.ckn_hientai();
begin

    s:='select sum(tientra) tientra,kythue,ten_muc,ngay_tt,nguoigachno_id,tenquay,tenbuucuc,ten_dv,hinhthuc,ma_nv
        from (select a.mst,a.tientra,(select ''[''||ID||'']''||TENTIEUMUC from  tax.tieu_mucs where a.ma_tmuc = id) ten_muc,
        to_char(b.ngay_thuc,''dd/mm/yyyy'') ngay_tt, b.nguoigachno_id,d.tenquay,
        e.tenbuucuc,f.ten_dv,h.name hinhthuc, a.kythue,
        (select id||'' - ''||ten_nv from nhanvien_tcs where ma_tinh='''||pma_tinh||''' and id =g.ma_nv and rownum =1) ma_nv
         from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b,
         tax.nguoigachnos c,
         (select * from tax.quaythus where ma_tinh='''||pma_tinh||''') d,
         (select * from tax.buucucthus where ma_tinh='''||pma_tinh||''') e,
         (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') f, tax.nnts_'||ckn||' g, tax.hinhthuc_tts h
        where a.phieu_id = b.id and b.nguoigachno_id = c.id and c.vnpt ='||pdata||'
        and c.quaythu_id = d.id and d.mabc_id = e.id
        and e.donviql_id = f.id and a.mst = g.mst and a.ma_cq_thu = g.ma_cqt_ql
        and a.ma_tinh = g.ma_tinh and b.httt_id = h.id
        and a.ma_tinh ='''||pma_tinh||'''';


    if pdonvi is not null then s:=s||' and f.id like '''||replace(pdonvi,'*','%')||''''; end if;
    if pbuucuc is not null then s:=s||' and e.id like '''||replace(pbuucuc,'*','%')||''''; end if;
    if pquaythu is not null then s:=s||' and d.id like '''||replace(pquaythu,'*','%')||''''; end if;
    if pnguoigachno is not null then s:=s||' and b.nguoigachno_id like '''||replace(pnguoigachno,'*','%')||''''; end if;
    if ptungay is not null then s:=s||' and b.ngay_thuc >= to_date('''||ptungay||''',''dd/mm/yyyy'')'; end if;
    if pdenngay is not null then s:=s||' and b.ngay_thuc < to_date('''||pdenngay||''',''dd/mm/yyyy'') +1'; end if;
    if pduongthu is not null then s:=s||' and g.ma_nv = '''||pduongthu||''''; end if;
    if pkythu is not null then s:=s||' and a.kythue = '''||pkythu||''''; end if;

    s:=s||' ) group by kythue,ten_muc,ngay_tt,nguoigachno_id,tenquay,tenbuucuc,ten_dv,hinhthuc,ma_nv
    order by ten_dv,tenbuucuc,tenquay,hinhthuc,nguoigachno_id,ma_nv,ngay_tt,kythue,ten_muc';

    open report_out for s;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;

procedure REPORT_PAY_RATE(
    pma_tinh varchar2,
    pdonvi varchar2,
    pbuucuc varchar2,
    pquaythu varchar2,
    pkythu varchar2,
    pbaocao varchar2,
    ptungay varchar2,
    pdenngay varchar2,
    ptype varchar2,report_out OUT SYS_REFCURSOR)
is
    s varchar2(32000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai;
    l_ten_dv varchar(200);
    l_diachi_dv varchar(500);
    l_mst_dv varchar(50);
    l_user_tt varchar2(200):='cct.haibatrung_hni';
Begin
    s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
    Execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;

    if ptype='1' then
        s:='select '''||l_ten_dv||''' ten_dv,'''' tenbuucuc,f.ten_dv donvi,
                count(distinct a.mst) so1, nvl(sum(no_cuoi_ky),0) so2,count(distinct b.mst) so3, nvl(sum(b.tientra),0) so4,count(distinct c.mst) so5, nvl(sum(c.tientra),0) so6,
                (count(distinct b.mst) + count(distinct c.mst)) so7,(nvl(sum(b.tientra),0) + nvl(sum(c.tientra),0)) so8,
                (count(distinct a.mst) - (count(distinct b.mst) + count(distinct c.mst))) so9, (nvl(sum(no_cuoi_ky),0) - (nvl(sum(b.tientra),0) + nvl(sum(c.tientra),0))) so10,
                round(count(distinct b.mst)*100/count(distinct a.mst),2) so11, round(nvl(sum(b.tientra),0)*100/nvl(sum(no_cuoi_ky),0),2) so12,
                round(count(distinct c.mst)*100/count(distinct a.mst),2) so13, round(nvl(sum(c.tientra),0)*100/nvl(sum(no_cuoi_ky),0),2) so14,
                round((count(distinct b.mst)+count(distinct c.mst))*100/count(distinct a.mst),2) so15, round((nvl(sum(b.tientra),0)+nvl(sum(c.tientra),0))*100/nvl(sum(no_cuoi_ky),0),2) so16,a.kythue
                from
                (select a.mst, a.no_cuoi_ky, a.kythue, a.ma_tmuc, a.chuky, a.ma_cq_thu from ct_no_'||ckn||' a where a.ma_tinh=:1)a,
                (select a.mst, sum(a.tientra) tientra, a.kythue, a.ma_tmuc, a.chuky, a.ma_cq_thu from ct_tra_'||ckn||' a, bangphieutra_'||ckn||' b
                    where a.phieu_id=b.id
                                    and trunc(b.ngay_thuc) >= to_date(:2,''dd/mm/yyyy'')
                                    and trunc(b.ngay_thuc) < to_date(:3,''dd/mm/yyyy'')+1
                                        and b.ma_tinh=:4
                                        and exists (select 1 from nguoigachnos us where b.nguoigachno_id = us.id and us.vnpt=1)
                                        group by a.mst, a.kythue, a.ma_tmuc, a.chuky, a.ma_cq_thu)b,
                (select a.mst, sum(a.tientra) tientra, a.kythue, a.ma_tmuc, a.chuky, a.ma_cq_thu from ct_tra_'||ckn||' a,bangphieutra_'||ckn||' b
                    where a.phieu_id=b.id
                                    and trunc(b.ngay_thuc) >= to_date(:5,''dd/mm/yyyy'')
                                    and trunc(b.ngay_thuc) < to_date(:6,''dd/mm/yyyy'')+1
                                        and b.ma_tinh=:7
                                        and exists (select 1 from nguoigachnos us where b.nguoigachno_id = us.id and us.vnpt=0)
                                        group by a.mst, a.kythue, a.ma_tmuc, a.chuky, a.ma_cq_thu)c,tax.nnts_'||ckn||' g,
                                (select * from tax.nhanvien_tcs where ma_tinh =:8)d,
                                (select * from tax.buucucthus where ma_tinh =:9) e,
                                (select * from tax.donvi_qls where ma_tinh =:10) f, tax.tieu_mucs t
                where a.mst = b.mst(+) and a.kythue = b.kythue(+) and a.kythue = c.kythue(+)
                and a.chuky = b.chuky(+)  and a.chuky = c.chuky(+)
                and a.ma_tmuc = c.ma_tmuc(+) and  a.ma_tmuc= b.ma_tmuc(+)
                and a.mst = c.mst(+) and a.ma_tmuc = t.id
                and a.mst = g.mst and g.ma_nv=d.id(+)
                and a.ma_cq_thu = c.ma_cq_thu(+)
                and a.ma_cq_thu = b.ma_cq_thu(+) and a.ma_cq_thu = g.ma_cqt_ql
                and d.mabc_id = e.id (+) and e.donviql_id = f.id(+)';
                if pdonvi is not null then s:=s||' and f.id = '''||pdonvi||''''; end if;
                if pbuucuc is not null then s:=s||' and e.id = '''||pbuucuc||''''; end if;
                if pkythu is not null then s:=s||' and a.kythue = '''||pkythu||''''; end if;
                if pbaocao='1' then
                    s:=s||' and t.ma_muc =1800';
                    s:=s||' group by a.kythue,f.ten_dv order by f.ten_dv,a.kythue';
                elsif pbaocao='2' then
                    s:=s||' and t.ma_muc !=1800';
                    s:=s||' group by a.kythue,f.ten_dv order by f.ten_dv,a.kythue';
                else
                    s:=s||' group by a.kythue,f.ten_dv order by f.ten_dv,a.kythue';
                end if;


        Open report_out for s using pma_tinh,ptungay,pdenngay,pma_tinh,ptungay,pdenngay,pma_tinh,pma_tinh,pma_tinh,pma_tinh;
    elsif ptype='2' then
        s:='select '''||l_ten_dv||''' ten_dv,e.tenbuucuc tenbuucuc,f.ten_dv donvi,
                count(distinct a.mst) so1, nvl(sum(no_cuoi_ky),0) so2,count(distinct b.mst) so3, nvl(sum(b.tientra),0) so4,count(distinct c.mst) so5, nvl(sum(c.tientra),0) so6,
                (count(distinct b.mst) + count(distinct c.mst)) so7,(nvl(sum(b.tientra),0) + nvl(sum(c.tientra),0)) so8,
                (count(distinct a.mst) - (count(distinct b.mst) + count(distinct c.mst))) so9, (nvl(sum(no_cuoi_ky),0) - (nvl(sum(b.tientra),0) + nvl(sum(c.tientra),0))) so10,
                round(count(distinct b.mst)*100/count(distinct a.mst),2) so11, round(nvl(sum(b.tientra),0)*100/nvl(sum(no_cuoi_ky),0),2) so12,
                round(count(distinct c.mst)*100/count(distinct a.mst),2) so13, round(nvl(sum(c.tientra),0)*100/nvl(sum(no_cuoi_ky),0),2) so14,
                round((count(distinct b.mst)+count(distinct c.mst))*100/count(distinct a.mst),2) so15, round((nvl(sum(b.tientra),0)+nvl(sum(c.tientra),0))*100/nvl(sum(no_cuoi_ky),0),2) so16,a.kythue
                from
                (select a.mst, a.no_cuoi_ky, a.kythue, a.ma_tmuc, a.chuky, a.ma_cq_thu from ct_no_'||ckn||' a where a.ma_tinh=:1)a,
                (select a.mst, sum(a.tientra) tientra, a.kythue, a.ma_tmuc, a.chuky, a.ma_cq_thu from ct_tra_'||ckn||' a, bangphieutra_'||ckn||' b
                    where a.phieu_id=b.id
                                    and trunc(b.ngay_thuc) >= to_date(:2,''dd/mm/yyyy'')
                                    and trunc(b.ngay_thuc) < to_date(:3,''dd/mm/yyyy'')+1
                                        and b.ma_tinh=:4
                                        and exists (select 1 from nguoigachnos us where b.nguoigachno_id = us.id and us.vnpt=1)
                                         group by a.mst, a.kythue, a.ma_tmuc, a.chuky, a.ma_cq_thu)b,
                (select a.mst, sum(a.tientra) tientra, a.kythue, a.ma_tmuc, a.chuky, a.ma_cq_thu from ct_tra_'||ckn||' a,bangphieutra_'||ckn||' b
                    where a.phieu_id=b.id
                                    and trunc(b.ngay_thuc) >= to_date(:5,''dd/mm/yyyy'')
                                    and trunc(b.ngay_thuc) < to_date(:6,''dd/mm/yyyy'')+1
                                        and b.ma_tinh=:7
                                        and exists (select 1 from nguoigachnos us where b.nguoigachno_id = us.id and us.vnpt=0)
                                        group by a.mst, a.kythue, a.ma_tmuc, a.chuky, a.ma_cq_thu)c,tax.nnts_'||ckn||' g,
                                (select * from tax.nhanvien_tcs where ma_tinh =:8)d,
                                (select * from tax.buucucthus where ma_tinh =:9) e,
                                (select * from tax.donvi_qls where ma_tinh =:10) f, tax.tieu_mucs t
                where a.mst = b.mst(+) and a.kythue = b.kythue(+) and a.kythue = c.kythue(+)
                and a.chuky = b.chuky(+)  and a.chuky = c.chuky(+)
                and a.ma_tmuc = c.ma_tmuc(+) and  a.ma_tmuc= b.ma_tmuc(+)
                and a.mst = c.mst(+) and a.ma_tmuc = t.id
                and a.mst = g.mst and g.ma_nv=d.id(+)
                and a.ma_cq_thu = c.ma_cq_thu(+)
                and a.ma_cq_thu = b.ma_cq_thu(+) and a.ma_cq_thu = g.ma_cqt_ql
                and d.mabc_id = e.id (+) and e.donviql_id = f.id(+)';
                if pdonvi is not null then s:=s||' and f.id = '''||pdonvi||''''; end if;
                if pbuucuc is not null then s:=s||' and e.id = '''||pbuucuc||''''; end if;
                if pkythu is not null then s:=s||' and a.kythue = '''||pkythu||''''; end if;
                if pbaocao='1' then
                    s:=s||' and t.ma_muc =1800';
                    s:=s||' group by a.kythue,e.tenbuucuc,f.ten_dv order by f.ten_dv,e.tenbuucuc,a.kythue';
                elsif pbaocao='2' then
                    s:=s||' and t.ma_muc !=1800';
                    s:=s||' group by a.kythue,e.tenbuucuc,f.ten_dv order by f.ten_dv,e.tenbuucuc,a.kythue';
                else
                    s:=s||' group by a.kythue,e.tenbuucuc,f.ten_dv order by f.ten_dv,e.tenbuucuc,a.kythue';
                end if;
        Open report_out for s using pma_tinh,ptungay,pdenngay,pma_tinh,ptungay,pdenngay,pma_tinh,pma_tinh,pma_tinh,pma_tinh;
    elsif ptype='3' then
        s:='select '''||l_ten_dv||''' ten_dv,g.ma_nv,e.tenbuucuc,f.ten_dv donvi,
                count(distinct a.mst) so1, nvl(sum(no_cuoi_ky),0) so2,count(distinct b.mst) so3, nvl(sum(b.tientra),0) so4,count(distinct c.mst) so5, nvl(sum(c.tientra),0) so6,
                (count(distinct b.mst) + count(distinct c.mst)) so7,(nvl(sum(b.tientra),0) + nvl(sum(c.tientra),0)) so8,
                (count(distinct a.mst) - (count(distinct b.mst) + count(distinct c.mst))) so9, (nvl(sum(no_cuoi_ky),0) - (nvl(sum(b.tientra),0) + nvl(sum(c.tientra),0))) so10,
                round(count(distinct b.mst)*100/count(distinct a.mst),2) so11, round(nvl(sum(b.tientra),0)*100/nvl(sum(no_cuoi_ky),0),2) so12,
                round(count(distinct c.mst)*100/count(distinct a.mst),2) so13, round(nvl(sum(c.tientra),0)*100/nvl(sum(no_cuoi_ky),0),2) so14,
                round((count(distinct b.mst)+count(distinct c.mst))*100/count(distinct a.mst),2) so15, round((nvl(sum(b.tientra),0)+nvl(sum(c.tientra),0))*100/nvl(sum(no_cuoi_ky),0),2) so16,a.kythue
                from
                (select a.mst, a.no_cuoi_ky, a.kythue, a.ma_tmuc, a.chuky, a.ma_cq_thu from ct_no_'||ckn||' a where a.ma_tinh=:1)a,
                (select a.mst, sum(a.tientra) tientra, a.kythue, a.ma_tmuc, a.chuky, a.ma_cq_thu from ct_tra_'||ckn||' a, bangphieutra_'||ckn||' b
                    where a.phieu_id=b.id
                                    and trunc(b.ngay_thuc) >= to_date(:2,''dd/mm/yyyy'')
                                    and trunc(b.ngay_thuc) < to_date(:3,''dd/mm/yyyy'')+1
                                        and b.ma_tinh=:4
                                        and exists (select 1 from nguoigachnos us where b.nguoigachno_id = us.id and us.vnpt=1)
                                        group by a.mst, a.kythue, a.ma_tmuc, a.chuky, a.ma_cq_thu)b,
                (select a.mst, sum(a.tientra) tientra, a.kythue, a.ma_tmuc, a.chuky, a.ma_cq_thu from ct_tra_'||ckn||' a,bangphieutra_'||ckn||' b
                    where a.phieu_id=b.id
                                    and trunc(b.ngay_thuc) >= to_date(:5,''dd/mm/yyyy'')
                                    and trunc(b.ngay_thuc) < to_date(:6,''dd/mm/yyyy'')+1
                                        and b.ma_tinh=:7
                                        and exists (select 1 from nguoigachnos us where b.nguoigachno_id = us.id and us.vnpt=0)
                                        group by a.mst, a.kythue, a.ma_tmuc, a.chuky, a.ma_cq_thu)c,tax.nnts_'||ckn||' g,
                                (select * from tax.nhanvien_tcs where ma_tinh =:8)d,
                                (select * from tax.buucucthus where ma_tinh =:9) e,
                                (select * from tax.donvi_qls where ma_tinh =:10) f, tax.tieu_mucs t
                where a.mst = b.mst(+) and a.kythue = b.kythue(+) and a.kythue = c.kythue(+)
                and a.chuky = b.chuky(+)  and a.chuky = c.chuky(+)
                and a.ma_tmuc = c.ma_tmuc(+) and  a.ma_tmuc= b.ma_tmuc(+)
                and a.mst = c.mst(+) and a.ma_tmuc = t.id
                and a.mst = g.mst and g.ma_nv = d.id
                and a.ma_cq_thu = c.ma_cq_thu(+)
                and a.ma_cq_thu = b.ma_cq_thu(+) and a.ma_cq_thu = g.ma_cqt_ql
                and d.mabc_id = e.id and e.donviql_id = f.id';
                if pdonvi is not null then s:=s||' and f.id = '''||pdonvi||''''; end if;
                if pbuucuc is not null then s:=s||' and e.id = '''||pbuucuc||''''; end if;
                if pkythu is not null then s:=s||' and a.kythue = '''||pkythu||''''; end if;
                if pbaocao='1' then
                    s:=s||' and t.ma_muc =1800';
                elsif pbaocao='2' then
                    s:=s||' and t.ma_muc !=1800';
                end if;
                s:=s||' group by a.kythue,g.ma_nv,e.tenbuucuc,f.ten_dv';
        Open report_out for s using pma_tinh,ptungay,pdenngay,pma_tinh,ptungay,pdenngay,pma_tinh,pma_tinh,pma_tinh,pma_tinh;
    else
        s:='select '''||l_ten_dv||''' ten_dv,a.ma_tmuc||''|''||t.tentieumuc ten_muc,max(f.ten_dv) donvi,a.kythue,
                count(distinct a.mst) so1, nvl(sum(no_cuoi_ky),0) so2,count(distinct b.mst) so3, nvl(sum(b.tientra),0) so4,count(distinct c.mst) so5, nvl(sum(c.tientra),0) so6,
                (count(distinct b.mst) + count(distinct c.mst)) so7,(nvl(sum(b.tientra),0) + nvl(sum(c.tientra),0)) so8,
                (count(distinct a.mst) - (count(distinct b.mst) + count(distinct c.mst))) so9, (nvl(sum(no_cuoi_ky),0) - (nvl(sum(b.tientra),0) + nvl(sum(c.tientra),0))) so10,
                round(count(distinct b.mst)*100/count(distinct a.mst),2) so11, round(nvl(sum(b.tientra),0)*100/nvl(sum(no_cuoi_ky),0),2) so12,
                round(count(distinct c.mst)*100/count(distinct a.mst),2) so13, round(nvl(sum(c.tientra),0)*100/nvl(sum(no_cuoi_ky),0),2) so14,
                round((count(distinct b.mst)+count(distinct c.mst))*100/count(distinct a.mst),2) so15, round((nvl(sum(b.tientra),0)+nvl(sum(c.tientra),0))*100/nvl(sum(no_cuoi_ky),0),2) so16
                from
                (select a.mst, a.no_cuoi_ky, a.kythue, a.ma_tmuc, a.chuky, a.ma_cq_thu from ct_no_'||ckn||' a where a.ma_tinh=:1)a,
                (select a.mst, sum(a.tientra) tientra, a.kythue, a.ma_tmuc, a.chuky, a.ma_cq_thu from ct_tra_'||ckn||' a, bangphieutra_'||ckn||' b
                    where a.phieu_id=b.id
                                    and trunc(b.ngay_thuc) >= to_date(:2,''dd/mm/yyyy'')
                                    and trunc(b.ngay_thuc) < to_date(:3,''dd/mm/yyyy'')+1
                                        and b.ma_tinh=:4
                                        and exists (select 1 from nguoigachnos us where b.nguoigachno_id = us.id and us.vnpt=1)
                                        group by a.mst, a.kythue, a.ma_tmuc, a.chuky, a.ma_cq_thu)b,
                (select a.mst, sum(a.tientra) tientra, a.kythue, a.ma_tmuc, a.chuky, a.ma_cq_thu from ct_tra_'||ckn||' a,bangphieutra_'||ckn||' b
                    where a.phieu_id=b.id
                                    and trunc(b.ngay_thuc) >= to_date(:5,''dd/mm/yyyy'')
                                    and trunc(b.ngay_thuc) < to_date(:6,''dd/mm/yyyy'')+1
                                        and b.ma_tinh=:7
                                        and exists (select 1 from nguoigachnos us where b.nguoigachno_id = us.id and us.vnpt=0)
                                        group by a.mst, a.kythue, a.ma_tmuc, a.chuky, a.ma_cq_thu)c,tax.nnts_'||ckn||' g,
                                (select * from tax.nhanvien_tcs where ma_tinh =:8)d,
                                (select * from tax.buucucthus where ma_tinh =:9) e,
                                (select * from tax.donvi_qls where ma_tinh =:10) f, tax.tieu_mucs t
                where a.mst = b.mst(+) and a.kythue = b.kythue(+) and a.kythue = c.kythue(+)
                and a.ma_tmuc = c.ma_tmuc(+) and  a.ma_tmuc= b.ma_tmuc(+)
                and a.chuky = b.chuky(+)  and a.chuky = c.chuky(+)
                and a.mst = c.mst(+) and a.ma_tmuc = t.id
                and a.ma_cq_thu = c.ma_cq_thu(+)
                and a.ma_cq_thu = b.ma_cq_thu(+) and a.ma_cq_thu = g.ma_cqt_ql
                and a.mst = g.mst  and g.ma_tinh='''||pma_tinh||'''
                and  g.ma_nv=d.id(+) and d.mabc_id = e.id (+) and e.donviql_id = f.id(+)';

                if pdonvi is not null then s:=s||' and f.id = '''||pdonvi||''''; end if;
                if pbuucuc is not null then s:=s||' and e.id = '''||pbuucuc||''''; end if;
                if pkythu is not null then s:=s||' and a.kythue = '''||pkythu||''''; end if;
                if pbaocao='1' then
                    s:=s||' and t.ma_muc =1800';
                elsif pbaocao='2' then
                    s:=s||' and t.ma_muc !=1800';
                end if;

                s:=s||' group by a.ma_tmuc,a.kythue,t.tentieumuc order by a.kythue,a.ma_tmuc';
        Open report_out for s using pma_tinh,ptungay,pdenngay,pma_tinh,ptungay,pdenngay,pma_tinh,pma_tinh,pma_tinh,pma_tinh;

    end if;
    Exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    End;
end;

procedure BANGKE_NOPTIEN(
    pma_tinh varchar2,
    pdonvi varchar2,
    pbuucuc varchar2,
    ptungay varchar2,
    pdenngay varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(3000);
    ref_ sys_refcursor;
    refngay_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai;
    l_ten_dv varchar(200);
    l_diachi_dv varchar(500);
    l_mst_dv varchar(50);
    l_dauky number;
    l_cuoiky number;
    l_ngay date;
    l_tientra number;
    l_tiennop number;
    l_httt number;
    l_mabc varchar2(10);
    l_donvi varchar2(10);
Begin

    --Tong hop du lieu
    s:= 'select distinct trunc(b.ngay_thuc) ngay_thuc from ct_tra_'||ckn||' a, bangphieutra_'||ckn||' b
                where a.phieu_id=b.id and a.ma_tinh = :1
                and b.ngay_thuc >= to_date(:2,''dd/mm/yyyy'')
                and b.ngay_thuc < to_date(:3,''dd/mm/yyyy'')
                and b.nguoigachno_id <> ''cct.haibatrung_hni'' order by trunc(b.ngay_thuc)';

    open ref_ for s using pma_tinh,ptungay,pdenngay;
    loop fetch ref_ into l_ngay;
    exit when ref_%notfound;
        begin
            --Lay thong quan ly
            s:=' select sum(a.tien_tra) tien_tra,nvl(sum(a.tien_nop),0) tien_nop,a.httt_id,a.mabc_id,b.donviql_id from (
                select a.tien_tra,a.httt_id,b.tien_nop,a.ma_nv,a.mabc_id from
                (select sum(a.tientra) tien_tra,b.httt_id,d.mabc_id,c.ma_nv from ct_tra_'||ckn||' a, bangphieutra_'||ckn||' b, nnts_'||ckn||' c, nguoigachnos d
                where a.phieu_id=b.id and c.mst=a.mst(+) and b.nguoigachno_id =d.id
                and trunc(b.ngay_thuc) = :1 and a.ma_tinh =:2
                group by b.httt_id,c.ma_nv,d.mabc_id
                )a,
                (select sum(tien) tien_nop,a.ma_nv  from tien_nop a
                where trunc(a.ngay_cn) = :3
                group by a.ma_nv
                )b
                where a.ma_nv=b.ma_nv(+)
                ) a, buucucthus b  where a.mabc_id=b.id and b.ma_tinh =:4
                group by a.httt_id,a.mabc_id,b.donviql_id';
            open refngay_ for s using l_ngay,pma_tinh,l_ngay,pma_tinh;
            loop fetch refngay_ into l_tientra,l_tiennop,l_httt,l_mabc,l_donvi;
            exit when refngay_%notfound;
                begin
                     --Tinh luy ke tien no dau ky theo buu cuc
                     begin
                         select nvl(ton_cuoi,0) into l_dauky from bc_thunop where ma_bc = l_mabc and ma_tinh = pma_tinh
                             and ngay_bc = (select max(ngay_bc) from bc_thunop where ma_bc = l_mabc and ma_tinh = pma_tinh);
                         exception when others then
                            l_dauky :=0;
                     end;

                     --Tinh no cuoi ky
                     l_cuoiky := (l_dauky + l_tientra) - l_tiennop;

                     --Tong hop du lieu bao cao
                     Insert into bc_thunop (ma_tinh,ma_dv,ma_bc,hinhthuc_tt,ton_dau,tong_thu,tong_nop,ton_cuoi,ngay_bc,ghichu,loai_bc)
                     values (pma_tinh,l_donvi,l_mabc,l_httt,l_dauky,l_tientra,l_tiennop,l_cuoiky,l_ngay,'TH '||to_char(l_ngay,'dd/mm/yyyy'),1);
                     Commit;
                 end;
            end loop;
            close refngay_;
        end;
    end loop;
    close ref_;

    --Bao cao
    s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
    Execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;

    s:='select '''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, a.ton_dau tondau,a.tong_thu tongthu,a.tong_nop tongnop,a.ton_cuoi toncuoi,
            (select name from hinhthuc_tts where id= a.hinhthuc_tt) hinhthuc,b.tenbuucuc buucuc,c.ten_dv donvi
            from bc_thunop a, buucucthus b, donvi_qls c
            where a.ma_bc = b.id
            and b.donviql_id = c.id
            and b.ma_tinh = c.ma_tinh
            and c.ma_tinh ='''||pma_tinh||'''
            and a.ngay_bc >= to_date('''||ptungay||''',''dd/mm/yyyy'')
            and a.ngay_bc < to_date('''||pdenngay||''',''dd/mm/yyyy'')
            order by c.ten_dv,b.tenbuucuc,a.ngay_bc';

    Open report_out for s;
    Exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm)|| ', Detail:'|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; open report_out for 'select :1 err from dual' using err;
    End;
end;

PROCEDURE report_staff_invoice_retail(
    pma_tinh varchar2,
    pphieu varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(1000);
    ckn varchar2(100):=crud.ckn_hientai();
    l_ten_dv varchar2(200);
    l_diachi_dv varchar2(500);
    l_mst_dv varchar2(100);
    l_tinh varchar2(200);
begin
    begin
        s:='select a.ten_dv,a.diachi diachi_dv,a.mst mst_dv,(select province_name from provinces where id = a.ma_tinh and rownum =1)
                from donvi_qls a where ma_tinh =:1 and ID=0 and rownum=1';
        execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv,l_tinh using pma_tinh;
        exception when others then
            l_ten_dv :='';l_diachi_dv :='';l_mst_dv :='';l_tinh :='';
    end;

    s:='select rownum stt,'''||l_ten_dv||''' ten_dv,c.tenbuucuc,a.ma_nv,a.mst,ct.no_cuoi_ky tien_giao,
        to_char(a.ngay_giao,''dd/mm/yyyy hh24:mi:ss'') ngay_giao,a.nguoi_giao,a.trangthai_tt,
            e.ten_nnt,e.mota_diachi diachi, b.ten_nv||'':''||b.mobile ten_nv,a.id phieu_id,
            (select id||''|''||tentieumuc||''|''||ct.chuky from tieu_mucs where id=ct.ma_tmuc) tieu_muc, a.kythue
            from tax.phieu_'||ckn||' a, tax.nhanvien_tcs b, tax.buucucthus c,tax.nnts_'||ckn||' e, ct_no_'||ckn||' ct
            where a.ma_nv = b.id
            and b.mabc_id = c.id
            and a.mst = e.mst
            and b.ma_tinh =:1 and a.id =:2
            and a.mst = ct.mst and a.kythue = ct.kythue
            order by a.kythue,c.tenbuucuc,a.ma_nv,a.mst,a.ngay_giao';

    open report_out for s using pma_tinh,pphieu;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;

FUNCTION dataCus(i_agent VARCHAR2)
RETURN clob
IS
    l_sql clob;
    l_return clob;
    ckn varchar2(100):= crud.ckn_hientai();
BEGIN

    l_sql:='select tax.rows_to_str_clob(''select ''''<Customer><Name><![CDATA[''''||util.convert_utd(x.TEN_NNT)||'''']]></Name><Code>''''||x.mst||''''</Code>
            <TaxCode></TaxCode><Address><![CDATA[''''||util.convert_utd(x.mota_diachi)||'''']]></Address><BankAccountName></BankAccountName><BankName></BankName>
            <BankNumber></BankNumber><Email><![CDATA[''''||x.EMAIL||'''']]></Email><Fax></Fax><Phone></Phone><ContactPerson></ContactPerson><RepresentPerson></RepresentPerson><CusType>0</CusType></Customer>''''
            from tax.nnts_'||ckn||' x where
            and not exists (select 1 from cus_bill y where x.mst = y.mst)
            and  x.ma_tinh ='''''||i_agent||''''''','''') from dual';
    EXECUTE IMMEDIATE l_sql into l_return;

    Return l_return;
END;

FUNCTION exp_dataCus(i_agent VARCHAR2, i_khobac VARCHAR2)
RETURN sys_refcursor
IS
    l_sql clob;
    l_s VARCHAR2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):= crud.ckn_hientai();
    l_ma_cq VARCHAR2(100);
BEGIN
    if i_khobac is null then
          l_sql:='select ''<Customers>''||tax.rows_to_str_clob(''select ''''<Customer><Name><![CDATA[''''||x.TEN_NNT||'''']]></Name><Code>''''||replace(x.mst,''''-'''','''''''')||''''</Code>
            <TaxCode></TaxCode><Address><![CDATA[''''||x.mota_diachi||'''']]></Address><BankAccountName></BankAccountName><BankName></BankName>
            <BankNumber></BankNumber><Email><![CDATA[''''||x.EMAIL||'''']]></Email><Fax></Fax><Phone></Phone><ContactPerson></ContactPerson><RepresentPerson></RepresentPerson><CusType>0</CusType></Customer>''''
            from tax.nnts_'||ckn||' x where not exists (select 1 from cus_bill y where x.mst = y.mst and x.ma_cqt_ql = y.ma_cqt_ql and y.trang_thai=1 and x.ma_tinh ='''''||i_agent||''''''','''')||''</Customers>'' data from dual';
    else
    l_s:='select cqt_tms from tax.coquanthus where shkb='''||i_khobac||''' and ma_tinh='''||i_agent||''' and rownum =1';
    EXECUTE IMMEDIATE l_s into l_ma_cq;
    l_sql:='select ''<Customers>''||tax.rows_to_str_clob(''select ''''<Customer><Name><![CDATA[''''||x.TEN_NNT||'''']]></Name><Code>''''||replace(x.mst,''''-'''','''''''')||''''</Code>
            <TaxCode></TaxCode><Address><![CDATA[''''||x.mota_diachi||'''']]></Address><BankAccountName></BankAccountName><BankName></BankName>
            <BankNumber></BankNumber><Email><![CDATA[''''||x.EMAIL||'''']]></Email><Fax></Fax><Phone></Phone><ContactPerson></ContactPerson><RepresentPerson></RepresentPerson><CusType>0</CusType></Customer>''''
            from tax.nnts_'||ckn||' x where not exists (select 1 from cus_bill y where x.mst = y.mst and x.ma_cqt_ql = y.ma_cqt_ql and y.trang_thai=1) and x.MA_CQT_QL='''''||l_ma_cq||''''' and x.ma_tinh ='''''||i_agent||''''''','''')||''</Customers>'' data from dual';
    end if;
     Open ref_ for  l_sql;

    Return  ref_;

    EXCEPTION when OTHERS then
     open ref_ for 'select ''<error>'||SQLERRM||'</error>'' data from dual';
     Return  ref_;
END;

function CREATE_DATA_PRINT(i_agent varchar2, i_kythue varchar2, i_upload varchar2, i_mcq varchar2)
return varchar2
is
    ckn varchar2(100):= crud.ckn_hientai();
    ref_ sys_refcursor;
    sref_ sys_refcursor;
    cref_ sys_refcursor;
    s varchar2(32000);
    l_mst_dv varchar2(50);
    l_kythu varchar2(100);
    l_kythu1 varchar2(100):='';
    l_kythu2 varchar2(100):='';

    ten_km1 varchar2(500):='';
    ten_km2 varchar2(500):='';
    ten_km3 varchar2(500):='';
    ten_km4 varchar2(500):='';
    ten_km5 varchar2(500):='';
    ten_km6 varchar2(500):='';
    ten_km7 varchar2(500):='';
    ten_km8 varchar2(500):='';
    ten_km9 varchar2(500):='';
    tien_ps1 varchar2(10):='';
    tien_ps2 varchar2(10):='';
    tien_ps3 varchar2(10):='';
    tien_ps4 varchar2(10):='';
    tien_ps5 varchar2(10):='';
    tien_ps6 varchar2(10):='';
    tien_ps7 varchar2(10):='';
    tien_ps8 varchar2(10):='';
    tien_ps9 varchar2(10):='';
    ma_tm1 varchar2(10):='';
    ma_tm2 varchar2(10):='';
    ma_tm3 varchar2(10):='';
    ma_tm4 varchar2(10):='';
    ma_tm5 varchar2(10):='';
    ma_tm6 varchar2(10):='';
    ma_tm7 varchar2(10):='';
    ma_tm8 varchar2(10):='';
    ma_tm9 varchar2(10):='';
    tien_no2 varchar2(10):='';
    tien_no3 varchar2(10):='';
    tien_no4 varchar2(10):='';
    tien_no5 varchar2(10):='';
    tien_no6 varchar2(10):='';
    tien_no7 varchar2(10):='';
    tien_no8 varchar2(10):='';
    tien_no9 varchar2(10):='';
    tongtien number;
    l_stt number :=0;
    l_mst varchar2(100);
    l_row number;
    l_tieumuc number;
    l_chuky varchar2(100);
    l_id varchar2(100);
    l_hoadon varchar2(100);
    l_tuyen varchar2(100);
    l_seq number:=0;
begin
    l_seq := i_upload;
    l_id := i_upload;
    s:='select distinct a.mst from tax.nnts_'||ckn||' a, tax.ct_no_'||ckn||' ct
                 where a.mst = ct.mst and ct.kythue =:1 and ct.id =:2
                 and exists (select 1 from hddts c where a.mst=c.taxcode and month =:3 and c.log_date >= trunc(sysdate))
                 and a.ma_tinh =:4';
    open ref_ for s using i_kythue,l_seq,i_kythue,i_agent;
    loop fetch ref_ into l_mst;
        exit when ref_%notfound;
        begin
            s:='select rownum stt,ma_tmuc,chuky from tax.ct_no_'||ckn||'
                        where kythue =:1 and mst =:2 and id = '||l_seq||' ';
            open sref_ for s using i_kythue,l_mst;
            loop fetch sref_ into l_row,l_tieumuc,l_chuky;
                exit when sref_%notfound;
                begin
                    if l_row =1 then
                        ma_tm1 := l_tieumuc; l_kythu1 := l_chuky;
                        execute immediate 'select sum(round(no_cuoi_ky)) tieno,
                            (select tentieumuc from tieu_mucs where id=ma_tmuc and rownum=1)||''|''||'''||l_chuky||'''  from tax.ct_no_'||ckn||'
                         where kythue =:1 and mst =:2 and ma_tmuc =:3  and chuky =:4 and id = '||l_seq||'
                         group by ma_tmuc' into tien_ps1,ten_km1 using i_kythue,l_mst,l_tieumuc,l_chuky;
                    elsif l_row =2 then
                        ma_tm2 := l_tieumuc;
                        execute immediate 'select sum(round(no_cuoi_ky)) tieno,
                            (select tentieumuc from tieu_mucs where id=ma_tmuc and rownum=1)||''|''||'''||l_chuky||'''  from tax.ct_no_'||ckn||'
                         where kythue =:1 and mst =:2 and ma_tmuc =:3  and chuky =:4 and id = '||l_seq||'
                         group by ma_tmuc' into tien_ps2,ten_km2 using i_kythue,l_mst,l_tieumuc,l_chuky;

                    elsif l_row =3 then
                        ma_tm3 := l_tieumuc;
                        execute immediate 'select sum(round(no_cuoi_ky)) tieno,
                            (select tentieumuc from tieu_mucs where id=ma_tmuc and rownum=1)||''|''||'''||l_chuky||'''  from tax.ct_no_'||ckn||'
                         where kythue =:1 and mst =:2 and ma_tmuc =:3  and chuky =:4 and id = '||l_seq||'
                         group by ma_tmuc' into tien_ps3,ten_km3 using i_kythue,l_mst,l_tieumuc,l_chuky;
                    elsif l_row =4 then
                        ma_tm4 := l_tieumuc;
                        execute immediate 'select sum(round(no_cuoi_ky)) tieno,
                            (select tentieumuc from tieu_mucs where id=ma_tmuc and rownum=1)||''|''||'''||l_chuky||'''  from tax.ct_no_'||ckn||'
                         where kythue =:1 and mst =:2 and ma_tmuc =:3  and chuky =:4 and id = '||l_seq||'
                         group by ma_tmuc' into tien_ps4,ten_km4 using i_kythue,l_mst,l_tieumuc,l_chuky;
                    elsif l_row =5 then
                        ma_tm5 := l_tieumuc;
                        execute immediate 'select sum(round(no_cuoi_ky)) tieno,
                            (select tentieumuc from tieu_mucs where id=ma_tmuc and rownum=1)||''|''||'''||l_chuky||'''  from tax.ct_no_'||ckn||'
                         where kythue =:1 and mst =:2 and ma_tmuc =:3  and chuky =:4 and id = '||l_seq||'
                         group by ma_tmuc' into tien_ps5,ten_km5 using i_kythue,l_mst,l_tieumuc,l_chuky;
                    elsif l_row =6 then
                        ma_tm6 := l_tieumuc;
                        execute immediate 'select sum(round(no_cuoi_ky)) tieno,
                            (select tentieumuc from tieu_mucs where id=ma_tmuc and rownum=1)||''|''||'''||l_chuky||'''  from tax.ct_no_'||ckn||'
                         where kythue =:1 and mst =:2 and ma_tmuc =:3  and chuky =:4 and id = '||l_seq||'
                         group by ma_tmuc' into tien_ps6,ten_km6 using i_kythue,l_mst,l_tieumuc,l_chuky;
                    elsif l_row =7 then
                        ma_tm7 := l_tieumuc;
                        execute immediate 'select sum(round(no_cuoi_ky)) tieno,
                            (select tentieumuc from tieu_mucs where id=ma_tmuc and rownum=1)||''|''||'''||l_chuky||'''  from tax.ct_no_'||ckn||'
                         where kythue =:1 and mst =:2 and ma_tmuc =:3  and chuky =:4 and id = '||l_seq||'
                         group by ma_tmuc' into tien_ps7,ten_km7 using i_kythue,l_mst,l_tieumuc,l_chuky;
                    elsif l_row =8 then
                        ma_tm8 := l_tieumuc;
                        execute immediate 'select sum(round(no_cuoi_ky)) tieno,
                            (select tentieumuc from tieu_mucs where id=ma_tmuc and rownum=1)||''|''||'''||l_chuky||'''  from tax.ct_no_'||ckn||'
                         where kythue =:1 and mst =:2 and ma_tmuc =:3  and chuky =:4 and id = '||l_seq||'
                         group by ma_tmuc' into tien_ps8,ten_km8 using i_kythue,l_mst,l_tieumuc,l_chuky;
                    else
                        ma_tm9 := l_tieumuc;
                        execute immediate 'select sum(round(no_cuoi_ky)) tieno,
                            (select tentieumuc from tieu_mucs where id=ma_tmuc and rownum=1)||''|''||'''||l_chuky||'''  from tax.ct_no_'||ckn||'
                         where kythue =:1 and mst =:2 and ma_tmuc =:3  and chuky =:4 and id = '||l_seq||'
                         group by ma_tmuc' into tien_ps9,ten_km9 using i_kythue,l_mst,l_tieumuc,l_chuky;
                    end if;
                    exception when others then
                        null;
                end;
            end loop;

            tongtien := to_number(tien_ps1)+to_number(nvl(tien_ps2,0))+to_number(nvl(tien_ps3,0))+to_number(nvl(tien_ps4,0))+to_number(nvl(tien_ps5,0))
                        +to_number(nvl(tien_ps6,0))+to_number(nvl(tien_ps7,0))+to_number(nvl(tien_ps8,0))+to_number(nvl(tien_ps9,0));

            if to_number(tien_ps2) >0 then
                tien_no2 :='0';
            end if;
            if to_number(tien_ps3) >0 then
                tien_no3 :='0';
            end if;
            if to_number(tien_ps4) >0 then
                tien_no4 :='0';
            end if;
            if to_number(tien_ps5) >0 then
                tien_no5 :='0';
            end if;
            if to_number(tien_ps6) >0 then
                tien_no6 :='0';
            end if;
            if to_number(tien_ps7) >0 then
                tien_no7 :='0';
            end if;
            if to_number(tien_ps8) >0 then
                tien_no8 :='0';
            end if;
            if to_number(tien_ps9) >0 then
                tien_no9 :='0';
            end if;

            s:='insert into in_phieus(mst, ten_nnt, diachi_nnt, mobile, lanthu, ten_km1,
                                       ma_tm1, tien_no1, tien_ps1, tien_nop1, tt_quy1,
                                       ten_km2, ma_tm2, tien_no2, tien_ps2, tien_nop2,
                                       tt_quy2, ten_km3, ma_tm3, tien_no3, tien_ps3,
                                       tien_nop3, tt_quy3, ten_km4, ma_tm4, tien_no4,
                                       tien_ps4, tien_nop4, tt_quy4, ten_km5, ma_tm5,
                                       tien_no5, tien_ps5, tien_nop5, tt_quy5, ten_km6,
                                       ma_tm6, tien_no6, tien_ps6, tien_nop6, tt_quy6,
                                       ten_km7, ma_tm7, tien_no7, tien_ps7, tien_nop7,
                                       tt_quy7, ten_km8, ma_tm8, tien_no8, tien_ps8,
                                       tien_nop8, tt_quy8, ten_km9, ma_tm9, tien_no9,
                                       tien_ps9, tien_nop9, tt_quy9, tong_tien, tien_chu,
                                       barcode, mau_so, kh_hd, so_hd, tuyen_thu, ma_tinh,id,KYTHUE,mcq)
            select a.mst,a.ten_nnt,a.mota_diachi,
                 a.mobile, '''||i_kythue||''' lanthu, '''||ten_km1||''' ten_km1,
                 '||ma_tm1||' ma_tm1,''0'' tien_no1, '||tien_ps1||' tien_ps1, '||tien_ps1||' tien_nop1,'''||i_kythue||''' tt_quy1,
                 '''||nvl(ten_km2,' ')||''' ten_km2,'''||nvl(ma_tm2,' ')||''' ma_tm2,'''||tien_no2||''' tien_no2,'''||nvl(tien_ps2,' ')||''' tien_ps2,'''||nvl(tien_ps2,' ')||''' tien_nop2,'' '' tt_quy2,

                 '''||nvl(ten_km3,' ')||''' ten_km3,'''||nvl(ma_tm3,' ')||''' ma_tm3,'''||tien_no3||''' tien_no3,'''||nvl(tien_ps3,' ')||''' tien_ps3,'''||nvl(tien_ps3,' ')||''' tien_nop3,'' '' tt_quy3,
                 '''||nvl(ten_km4,' ')||''' ten_km4,'''||nvl(ma_tm4,' ')||''' ma_tm4,'''||tien_no4||''' tien_no4,'''||nvl(tien_ps4,' ')||''' tien_ps4,'''||nvl(tien_ps4,' ')||''' tien_nop4,'' '' tt_quy4,
                 '''||nvl(ten_km5,' ')||''' ten_km5,'''||nvl(ma_tm5,' ')||''' ma_tm5,'''||tien_no5||''' tien_no5,'''||nvl(tien_ps5,' ')||''' tien_ps5,'''||nvl(tien_ps5,' ')||''' tien_nop5,'' '' tt_quy5,
                 '''||nvl(ten_km6,' ')||''' ten_km6,'''||nvl(ma_tm6,' ')||''' ma_tm6,'''||tien_no6||''' tien_no6,'''||nvl(tien_ps6,' ')||''' tien_ps6,'''||nvl(tien_ps6,' ')||''' tien_nop6,'' '' tt_quy6,
                 '''||nvl(ten_km7,' ')||''' ten_km7,'''||nvl(ma_tm7,' ')||''' ma_tm7,'''||tien_no7||''' tien_no7,'''||nvl(tien_ps7,' ')||''' tien_ps7,'''||nvl(tien_ps7,' ')||''' tien_nop7,'' '' tt_quy7,
                 '''||nvl(ten_km8,' ')||''' ten_km8,'''||nvl(ma_tm8,' ')||''' ma_tm8,'''||tien_no8||''' tien_no8,'''||nvl(tien_ps8,' ')||''' tien_ps8,'''||nvl(tien_ps8,' ')||''' tien_nop8,'' '' tt_quy8,
                 '''||nvl(ten_km9,' ')||''' ten_km9,'''||nvl(ma_tm9,' ')||''' ma_tm9,'''||tien_no9||''' tien_no9,'''||nvl(tien_ps9,' ')||''' tien_ps9,'''||nvl(tien_ps9,' ')||''' tien_nop9,'' '' tt_quy9,

                 '||tongtien||' tong_tien, util.doisosangchu('||tongtien||') tien_chu,
                 to_char(a.mst||''/''||'''||i_kythue||''') barcode,to_char(hd.pattern) mau_so, to_char(hd.serial) kh_hd,
                 to_char(hd.numb_bill) so_hd, to_char(a.ma_nv||''/''||a.ma_t||'' - STT: '') tuyen_thu,:1,'||l_id||','''||i_kythue||''','''||i_mcq||'''
                 from tax.nnts_'||ckn||' a, tax.hddts hd
                 where hd.fkey = replace(trim(a.mst||'''||i_kythue||'''),''-'','''')||'||l_seq||'
                 and a.ma_tinh =:2 and a.mst =:3 and hd.log_date >= trunc(sysdate)';
            execute immediate s using i_agent,i_agent,l_mst;
            commit;

            ten_km1 :=''; tien_ps1 :=''; ma_tm1 :='';
            ten_km2 :=''; tien_ps2 :=''; ma_tm2 :=''; tien_no2 :='';
            ten_km3 :=''; tien_ps3 :=''; ma_tm3 :=''; tien_no3 :='';
            ten_km4 :=''; tien_ps4 :=''; ma_tm4 :=''; tien_no4 :='';
            ten_km5 :=''; tien_ps5 :=''; ma_tm5 :=''; tien_no5 :='';
            ten_km6 :=''; tien_ps6 :=''; ma_tm6 :=''; tien_no6 :='';
            ten_km7 :=''; tien_ps7 :=''; ma_tm7 :=''; tien_no7 :='';
            ten_km8 :=''; tien_ps8 :=''; ma_tm8 :=''; tien_no8 :='';
            ten_km9 :=''; tien_ps9 :=''; ma_tm9 :=''; tien_no9 :='';
            exception when others then
                null;
        end;
    end loop;


    --Lay gia tri STT in
    select nvl(max(stt),0) into l_stt from in_phieus where mcq = i_mcq;

    --Cap nhat STT in
    s:='select a.mst,b.so_hd,b.tuyen_thu from  tax.nnts_'||ckn||' a, in_phieus b
         where logdate >= TRUNC(SYSDATE) and a.mst = b.mst
         and a.ma_tinh =:1 and b.id =:2
         order by a.ma_nv,a.ma_t,a.ma_xa,a.ma_huyen';
        open cref_ for s using i_agent,l_seq;
        loop fetch cref_ into l_mst,l_hoadon,l_tuyen;
            exit when cref_%notfound;
            begin
                l_stt:=l_stt+1;
                update in_phieus set tuyen_thu=l_tuyen||l_stt , stt=l_stt
                    where mst =l_mst and so_hd =l_hoadon and kythue =i_kythue and id = l_seq;
            end;
        end loop;
    commit;
    return '1';

    exception when others then
    return '0|'||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
end;

procedure REPORT_ROLLBACK_BILL(
    pma_tinh varchar2,
    pdonvi varchar2,
    pbuucuc varchar2,
    pquaythu varchar2,
    pkythu varchar2,
    ptungay varchar2,
    pdenngay varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(3000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai;
    l_ten_dv varchar(200);
    l_diachi_dv varchar(500);
    l_mst_dv varchar(50);
    l_user_tt varchar2(200):='cct.haibatrung_hni';
Begin
    s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
    Execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;

    s:='select '''||l_ten_dv||''' ten_dv,e.tenbuucuc,f.ten_dv donvi,
                a.mst,a.tien_no,nvl(b.tien_tra,0) tien_tra,g.ten_nnt, g.mota_diachi diachi,g.ma_nv,'''||pkythu||''' kythue
            from
            (select mst,sum(no_cuoi_ky) tien_no from ct_no_'||ckn||' where ma_tinh =:1 and kythue =:2 group by mst)a,
            (select a.mst,sum(a.tientra) tien_tra from ct_tra_'||ckn||' a
                where a.ma_tinh =:3 and a.kythue =:4
                and exists (select 1 from bangphieutra_'||ckn||' b where a.phieu_id = b.id
                                and trunc(b.ngay_thuc) >= to_date(:5,''dd/mm/yyyy'')
                                and trunc(b.ngay_thuc) < to_date(:6,''dd/mm/yyyy'')+1 )
                group by mst)b,tax.nnts_'||ckn||' g,
                            (select * from tax.nhanvien_tcs where ma_tinh =:7)d,
                            (select * from tax.buucucthus where ma_tinh =:8) e,
                            (select * from tax.donvi_qls where ma_tinh =:9) f
            where a.mst = b.mst(+)
            and a.mst = g.mst and a.ma_cq_thu = g.ma_cqt_ql and g.ma_nv = d.id
            and d.mabc_id = e.id and e.donviql_id = f.id and a.tien_no - nvl(b.tien_tra,0) <=0';
            if pdonvi is not null then s:=s||' and f.id = '''||pdonvi||''''; end if;
            if pbuucuc is not null then s:=s||' and e.id = '''||pbuucuc||''''; end if;
        s:=s||' order by g.ma_nv';

        Open report_out for s using pma_tinh,pkythu,pma_tinh,pkythu,ptungay,pdenngay,pma_tinh,pma_tinh,pma_tinh;

    Exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    End;
end;

procedure REPORT_CHANGE_STAFF(
    pma_tinh varchar2,
    pdonvi varchar2,
    pbuucuc varchar2,
    pquaythu varchar2,
    puser varchar2,
    ptungay varchar2,
    pdenngay varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(3000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai;
    l_ten_dv varchar(200);
    l_diachi_dv varchar(500);
    l_mst_dv varchar(50);
Begin
    s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
    Execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;

    s:='select '''||l_ten_dv||''' ten_dv,c.tenbuucuc,d.ten_dv donvi, a.id,a.ma_nv||'' - ''||ten_nv ma_nv,a.nguoi_cn, to_char(a.ngay_cn, ''dd/mm/yyyy hh24:mi:ss'') ngay_cn
            from duongthus a, (select * from tax.nhanvien_tcs where ma_tinh =:1)b,
                            (select * from tax.buucucthus where ma_tinh =:2) c,
                            (select * from tax.donvi_qls where ma_tinh =:3) d
            where a.ma_nv = b.id
            and b.mabc_id = c.id and c.donviql_id = d.id
            and trunc(a.ngay_cn) >= to_date(:4,''dd/mm/yyyy'')
            and trunc(a.ngay_cn) < to_date(:5,''dd/mm/yyyy'')+1';
            if pdonvi is not null then s:=s||' and d.id = '''||pdonvi||''''; end if;
            if pbuucuc is not null then s:=s||' and c.id = '''||pbuucuc||''''; end if;
            if puser is not null then s:=s||' and a.id = '''||puser||''''; end if;
    s:=s||' order by a.id ';
        Open report_out for s using pma_tinh,pma_tinh,pma_tinh,ptungay,pdenngay;

    Exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    End;
end;

PROCEDURE REPORT_LIST_MENTION_DEPT(
    pagent varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(1000);
    ckn varchar2(100):=crud.ckn_hientai;
    l_ten_dv varchar2(200);
    l_diachi_dv varchar2(500);
    l_mst_dv varchar2(100);
    l_tinh varchar2(200);
begin
    begin
        s:='select a.ten_dv,a.diachi diachi_dv,a.mst mst_dv,(select province_name from provinces where id = a.ma_tinh and rownum =1)
                from donvi_qls a where ma_tinh =:1 and ID=0 and rownum=1';
        execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv,l_tinh using pagent;
        exception when others then
            l_ten_dv :='';l_diachi_dv :='';l_mst_dv :='';l_tinh :='';
    end;

    s:='select rownum stt,'''||l_ten_dv||''' ten_dv,c.tien_no,a.ten_nnt,a.mota_diachi diachi,a.mst,b.lydos,to_char(b.ngayhen_tt,''dd/mm/yyyy hh24:mi:ss'') ngayhen_tt,b.luot_nhacno
          from tax.nhatky_thus b, tax.nnts_'||ckn||' a,(select sum(no_cuoi_ky) tien_no,mst from tax.ct_no_'||ckn||'
                                                where ma_tinh =:1 group by mst)c
            where b.mst = a.mst and a.mst = c.mst
            and a.ma_tinh =:2';
    open report_out for s using pagent,pagent;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;

procedure REPORT_MANAGE_SERI(
    pma_tinh varchar2,
    pdonvi varchar2,
    pbuucuc varchar2,
    pquaythu varchar2,
    pkythu varchar2,
    ptungay varchar2,
    pdenngay varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(3000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai;
    l_ten_dv varchar(200);
    l_diachi_dv varchar(500);
    l_mst_dv varchar(50);
Begin
    s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
    Execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;

    s:= 'select a.seri_from, a.seri_to, (a.seri_to-a.seri_from)+1  seri_sum,
        ((a.seri_to-a.seri_from)+1 - b.seri_use) seri_not_use, b.seri_use,a.ky_hieu,
        c.tenbuucuc,d.ten_dv donvi,'''||l_ten_dv||''' ten_dv
    from
    (select min(seri) seri_from, max(seri) seri_to, ky_hieu, mabc_id from (
    select b.seri,b.ky_hieu,c.mabc_id from ct_tra_'||ckn||' a,bangphieutra_'||ckn||' b, nguoigachnos c
    where a.ma_tinh=:1 and b.seri is not null
    and a.phieu_id = b.id and b.nguoigachno_id=c.id
    and trunc(b.ngay_thuc) >= to_date(:2,''dd/mm/yyyy'')
    and trunc(b.ngay_thuc) < to_date(:3,''dd/mm/yyyy'')+1';
    if pkythu is not null then s:=s||' and a.kythue = '''||pkythu||''''; end if;
    s:=s||') group by ky_hieu, mabc_id)a,
    (select count(distinct b.seri) seri_use,b.ky_hieu,c.mabc_id
    from ct_tra_'||ckn||' a,bangphieutra_'||ckn||' b,nguoigachnos c
    where a.ma_tinh=:4 and b.seri is not null
    and a.phieu_id = b.id and b.nguoigachno_id=c.id
    and trunc(b.ngay_thuc) >= to_date(:5,''dd/mm/yyyy'')
    and trunc(b.ngay_thuc) < to_date(:6,''dd/mm/yyyy'')+1';
    if pkythu is not null then s:=s||' and a.kythue = '''||pkythu||''''; end if;
    s:=s||' group by b.ky_hieu,c.mabc_id) b,
    (select * from buucucthus where ma_tinh=:7)c,
    (select * from donvi_qls where ma_tinh=:8)d
    where a.ky_hieu =b.ky_hieu
    and a.mabc_id=c.id and c.donviql_id =d.id';
    if pdonvi is not null then s:=s||' and d.id = '''||pdonvi||''''; end if;
    if pbuucuc is not null then s:=s||' and c.id = '''||pbuucuc||''''; end if;
    s:=s||' order by a.ky_hieu,d.id,c.id';

    Open report_out for s using pma_tinh,ptungay,pdenngay,pma_tinh,ptungay,pdenngay,pma_tinh,pma_tinh;

    Exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm)|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; open report_out for 'select :1 err from dual' using err;
    End;
end;

procedure REPORT_HIS_CUS_DETAIL(
    pma_tinh varchar2,
    pdonvi varchar2,
    pbuucuc varchar2,
    pquaythu varchar2,
    pkythu varchar2,
    ptungay varchar2,
    pdenngay varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(3000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai;
    l_ten_dv varchar(200);
    l_diachi_dv varchar(500);
    l_mst_dv varchar(50);
Begin
    s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
    Execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;

    s:= 'select a.mst,a.ten_nnt,a.mota_diachi diachi,b.nguoi_cn, to_char(b.ngay_cn,''dd/mm/yyyy hh24:mi:ss'') ngay_cn,
            decode(b.trang_thai,0,''DELETE'',1,''NEW'',''EDIT'') trang_thai,
            d.tenbuucuc,e.ten_dv donvi,'''||l_ten_dv||''' ten_dv, a.ma_nv,
            (select id||''|''||tentieumuc from tieu_mucs where id =b.ma_tmuc and rownum=1) tieu_muc,
            b.no_cuoi_ky so_tien, b.kythue ky_thue, b.chuky chu_ky, b.magiao_unt ma_unt
    from nnts_'||ckn||' a, ct_no_log b, (select * from nhanvien_tcs where ma_tinh =:1) c,
    (select * from buucucthus where ma_tinh=:2)d,
    (select * from donvi_qls where ma_tinh=:3)e
    where a.ma_tinh=:4 and a.mst = b.mst
    and trunc(b.ngay_cn) >= to_date(:5,''dd/mm/yyyy'')
    and trunc(b.ngay_cn) < to_date(:6,''dd/mm/yyyy'')+1
    and a.ma_nv = c.id and c.mabc_id = d.id and d.donviql_id = e.id';
    if pkythu is not null then s:=s||' and b.kythue = '''||pkythu||''''; end if;
    if pdonvi is not null then s:=s||' and e.id = '''||pdonvi||''''; end if;
    if pbuucuc is not null then s:=s||' and d.id = '''||pbuucuc||''''; end if;
    s:=s||' order by e.id,d.id,b.nguoi_cn,b.mst,b.ngay_cn';
    Open report_out for s using pma_tinh,pma_tinh,pma_tinh,pma_tinh,ptungay,pdenngay;

    Exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm)|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; open report_out for 'select :1 err from dual' using err;
    End;
end;
procedure REPORT_HIS_CUS(
    pma_tinh varchar2,
    pdonvi varchar2,
    pbuucuc varchar2,
    pquaythu varchar2,
    pkythu varchar2,
    ptungay varchar2,
    pdenngay varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(3000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai;
    l_ten_dv varchar(200);
    l_diachi_dv varchar(500);
    l_mst_dv varchar(50);
Begin

    s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
    Execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;

    s:= 'select a.mst,a.ten_nnt,a.mota_diachi diachi,a.nguoi_cn, to_char(a.ngay_cn,''dd/mm/yyyy hh24:mi:ss'') ngay_cn,
            decode(a.trang_thai,0,''DELETE'',1,''NEW'',''EDIT'') trang_thai,
            c.tenbuucuc,d.ten_dv donvi,'''||l_ten_dv||''' ten_dv, a.ma_nv||'' - ''||b.ten_nv  ma_nv
    from nnts_log a, (select * from nhanvien_tcs where ma_tinh =:1) b,
    (select * from buucucthus where ma_tinh=:2)c,
    (select * from donvi_qls where ma_tinh=:3)d
    where a.ma_tinh=:4
    and trunc(a.ngay_cn) >= to_date(:5,''dd/mm/yyyy'')
    and trunc(a.ngay_cn) < to_date(:6,''dd/mm/yyyy'')+1
    and a.ma_nv = b.id and b.mabc_id = c.id and c.donviql_id = d.id';
    if pdonvi is not null then s:=s||' and d.id = '''||pdonvi||''''; end if;
    if pbuucuc is not null then s:=s||' and c.id = '''||pbuucuc||''''; end if;
    s:=s||' order by d.id,c.id,a.nguoi_cn,a.mst,a.ngay_cn';

    Open report_out for s using pma_tinh,pma_tinh,pma_tinh,pma_tinh,ptungay,pdenngay;

    Exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm)|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; open report_out for 'select :1 err from dual' using err;
    End;
end;

procedure REPORT_HIS_PAY_MANUAL(
    pma_tinh varchar2,
    pdonvi varchar2,
    pbuucuc varchar2,
    pquaythu varchar2,
    pkythu varchar2,
    ptungay varchar2,
    pdenngay varchar2,
    ptrang_thai varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(3000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai;
    l_ten_dv varchar(200);
    l_diachi_dv varchar(500);
    l_mst_dv varchar(50);
    trang_thai varchar2 (10);
Begin
    s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
    Execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;

    s:= 'select a.mst,a.ten_nnt,a.so_chung_tu,(select id||''|''||tentieumuc from tieu_mucs where id=to_number(a.tieu_muc)) tieu_muc,
            a.tieu_muc ma_muc,a.ky_thue ky_thue,to_number(nvl(a.tien_tt,0)) tien_tt, to_number(nvl(a.so_tien,0))  so_tien,
            to_char(a.ngay_kho_bac,''dd/mm/yyyy'') ngay_tt,
            a.log_user nguoi_cn, to_char(a.log_date,''dd/mm/yyyy hh24:mi:ss'') ngay_cn,
            c.tenbuucuc,d.ten_dv donvi,'''||l_ten_dv||''' ten_dv
    from thanhtoan_upload a,nnts_'||ckn||' e,
    (select * from nhanvien_tcs where ma_tinh =:1) b,
    (select * from buucucthus where ma_tinh=:2)c,
    (select * from donvi_qls where ma_tinh=:3)d
    where a.mcq in (select cqt_tms from coquanthus where ma_tinh=:4) and a.mst=e.mst(+)
    and a.mcq = e.ma_cqt_ql(+)
    and e.ma_nv = b.id(+) and b.mabc_id = c.id(+) and c.donviql_id = d.id(+)
    and trunc(a.log_date) >= to_date(:5,''dd/mm/yyyy'')
    and trunc(a.log_date) < to_date(:6,''dd/mm/yyyy'')+1';
    if ptrang_thai <> 4 then
      s := s|| ' and decode(a.trang_thai,2,1,3,1,1,1,a.trang_thai) =:7';
    end if;

    if pdonvi is not null then s:=s||' and d.id = '''||pdonvi||''''; end if;
    if pbuucuc is not null then s:=s||' and c.id = '''||pbuucuc||''''; end if;
    if pkythu is not null then s:=s||' and a.ky_thue = '''||pkythu||''''; end if;
    trang_thai := ptrang_thai;
    if trang_thai = '4' then
      s:= s|| ' and not exists (select nnt.mst from nnts_'||ckn||' nnt where nnt.mst = a.mst and nnt.ma_tinh = :7)';
    else
      if trang_thai = '1' then
        s:= s|| ' and a.ky_thue is not null and exists (select nnt.mst from nnts_'||ckn||' nnt where nnt.mst = a.mst and nnt.ma_tinh = :8)';
        trang_thai := 1;
      else if trang_thai = '2' then
              s:= s|| ' and a.ky_thue is  null and exists (select nnt.mst from nnts_'||ckn||' nnt where nnt.mst = a.mst and nnt.ma_tinh = :8)';
              trang_thai := 1;
            else trang_thai := 0;
          end if;
      end if;
    end if;

    --dbms_output.put_line(s);
    s:=s||' order by d.id,c.id,a.log_date,a.ky_thue,a.ngay_kho_bac,a.mst';
    if trang_thai = 0 then
        Open report_out for s using pma_tinh,pma_tinh,pma_tinh,pma_tinh,ptungay,pdenngay,trang_thai;
      else
        if trang_thai = 1 then
          Open report_out for s using pma_tinh,pma_tinh,pma_tinh,pma_tinh,ptungay,pdenngay,trang_thai,pma_tinh;
          else Open report_out for s using pma_tinh,pma_tinh,pma_tinh,pma_tinh,ptungay,pdenngay,pma_tinh;
        end if;
    end if;

    Exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm)|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; open report_out for 'select :1 err from dual' using err;
    End;
end;

procedure REPORT_HIS_PAY_MANUAL_SUB1(
    pma_tinh varchar2,
    pmst varchar2,
    pso_ct varchar2,
    ptmuc varchar2,
    report_out OUT SYS_REFCURSOR)
as
  s varchar2(1000);
  ckn varchar2(100):=crud.ckn_hientai;
begin 
  s := 'select a.mst,a.so_chung_tu,c.kythue,c.tientra,c.chuky from thanhtoan_upload a, thanhtoan_upload_null b, ct_tra_'||ckn||' c 
      where a.id = b.thanhtoan_id and b.phieu_id = c.phieu_id';
  if pmst is not null then s := s|| ' and a.mst = :1 '; end if;
  if pso_ct is not null then s := s || '  and a.so_chung_tu = :2 '; end if;
  if ptmuc is not null then s := s || ' and a.tieu_muc = :3 ' ; end if;
  if pma_tinh is not null then s := s || ' and b.ma_tinh = :4'; end if;
  --dbms_output.put_line(s);
  s := s || ' order by a.mst,a.so_chung_tu,c.kythue,c.tientra,c.chuky';
  open report_out for s using pmst,pso_ct,ptmuc,pma_tinh;
  Exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm)|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; open report_out for 'select :1 err from dual' using err;
  End;
end;

PROCEDURE REPORT_PAYMENT_UNC(
    pma_tinh varchar2,
    pkhobac varchar2,
    ptenkho varchar2,
    ptungay varchar2,
    pdenngay varchar2,
    report_out OUT SYS_REFCURSOR)

is
    s varchar2(10000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai;
    l_tien_tra number;
    l_tien_chu varchar(200);
    l_khobac varchar(200);
    l_ten_dv varchar(200);
    l_diachi_dv varchar(500);
    l_mst_dv varchar(50);
    l_tmonbai number :=0;
    l_gtgt number :=0;
    l_tncn number :=0;
    l_ttdb number :=0;
    l_tainguyen number :=0;
    l_bvmt number :=0;
    l_vat_bvmt number :=0;
    l_thuphat number :=0;
    l_chamnop number :=0;
    l_1801 number :=0;
    l_1802 number :=0;
    l_1803 number :=0;
    l_1804 number :=0;
    l_1805 number :=0;
    l_1806 number :=0;
    l_1701 number :=0;
    l_1003 number :=0;
    l_1757 number :=0;
    l_1599 number :=0;
    l_2000 number :=0;
    l_4268 number :=0;
    l_4911 number :=0;
    l_time number;
    l_ten_cct varchar2(100);
    l_day number;
    l_phuongxa varchar2(100);
    l_diaban varchar2(100);
    l_monbai number;
    l_mamuc number:=1800;
    l_districts varchar2(200);
    l_provinces varchar2(200);
    l_cqt number;
    l_coquan varchar2(1000);
begin
    --Lay ten chi cuc thue quan ly
    Execute immediate 'select ten_cqt from coquanthus where shkb =:1 and ma_tinh =:2 and rownum=1'
        into l_ten_cct using pkhobac,pma_tinh;

    --Lay thong tin cau hinh thoi gian cho du lieu
    Execute immediate' SELECT expire_time FROM tax.config_special_days WHERE agent =:1 and status=1 and rownum =1'
        into l_time Using pma_tinh;

    --lay thong tin co quan thue
    Begin
        select id,ten_cqt into l_cqt,l_coquan from coquanthus where shkb = pkhobac and rownum=1;
        Exception when others then
            l_cqt :=0;l_coquan := pkhobac;
    End;

    if pma_tinh='79TTT' then
        s:='select sum(a.tientra) tong_tien, tax.util.doisosangchu(sum(a.tientra))
          from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f,nguoigachnos g
          where a.mst=b.mst and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+) and a.ma_tmuc=e.id(+)
          and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1 and c.shkb =:1
        and f.ngay_thuc between to_date('''||ptungay||''',''dd/mm/yyyy'') + '||l_time||'/24
        and  to_date('''||pdenngay||''',''dd/mm/yyyy'') + '||l_time||'/24 -1/86400
        and f.ma_tinh =:2';
        execute immediate s into l_tien_tra,l_tien_chu using pkhobac,pma_tinh;

        --Tong cac tieu muc thue mon bai
        s:='select sum(monbai1),sum(monbai2),sum(monbai3),sum(monbai4),sum(monbai5),sum(monbai6),
            sum(gtgt),sum(tncn),sum(ttdb),sum(tainguyen),sum(bvmt),sum(thuphat),sum(chamnop) from ( select
            case when ma_tmuc =1801 then sum(tientra)  else 0 end monbai1,
            case when ma_tmuc =1802 then sum(tientra)  else 0 end monbai2,
            case when ma_tmuc =1803 then sum(tientra)  else 0 end monbai3,
            case when ma_tmuc =1804 then sum(tientra)  else 0 end monbai4,
            case when ma_tmuc =1805 then sum(tientra)  else 0 end monbai5,
            case when ma_tmuc =1806 then sum(tientra)  else 0 end monbai6,
            case when ma_tmuc =1701 then sum(tientra)  else 0 end gtgt,
            case when ma_tmuc =1003 then sum(tientra)  else 0 end tncn,
            case when ma_tmuc =1757 then sum(tientra)  else 0 end ttdb,
            case when ma_tmuc =1599 then sum(tientra)  else 0 end tainguyen,
            case when ma_tmuc in (2001,2002,2003,2004,2005,2006,2007,2008,2009,2019,2041,2042,2043,2044,2045) then sum(tientra)  else 0 end bvmt,
            case when ma_tmuc in (4268,4272,4254) then sum(tientra)  else 0 end thuphat,
            case when ma_tmuc in (4911,4268,4272) then sum(tientra)  else 0 end chamnop
          from (
          select sum(tientra) tientra,ma_tmuc from
          (
              select b.mst,a.tientra,d.ten_chuong,e.tentieumuc,a.ma_chuong,a.ma_tmuc,b.ten_nnt,f.id so, f.ngay_tt ngay
              from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f,nguoigachnos g
              where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
              and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+)
              and a.ma_tmuc=e.id(+) and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1';
        s:=s||' and c.shkb='''||pkhobac||'''
                    and f.ngay_thuc between to_date('''||ptungay||''',''dd/mm/yyyy'') + '||l_time||'/24
                    and  to_date('''||pdenngay||''',''dd/mm/yyyy'') + '||l_time||'/24 -1/86400
                    and f.ma_tinh='''||pma_tinh||'''
              ) group by ma_tmuc
              ) group by ma_tmuc)';
        execute immediate s into l_1801,l_1802,l_1803,l_1804,l_1805,l_1806,l_1701,l_1003,l_1757,l_1599,l_2000,l_4268,l_4911;

        --Insert du lieu vao bang log tax.bangke_gnt
        s:='select rownum stt,'''||l_ten_cct||''' ten_cct, '||l_tien_tra||' tong_tien,'''||l_tien_chu||''' tong_tien_chu,
            case when ma_tmuc in (1801,1802,1803,1804,1805,1806) then tientra  else 0 end monbai,
            case when ma_tmuc =1701 then tientra  else 0 end gtgt,
            case when ma_tmuc =1003 then tientra  else 0 end tncn,
            case when ma_tmuc =1757 then tientra  else 0 end ttdb,
            case when ma_tmuc =1599 then tientra  else 0 end tainguyen,
            case when ma_tmuc in (2001,2002,2003,2004,2005,2006,2007,2008,2009,2019,2041,2042,2043,2044,2045) then tientra  else 0 end bvmt,0 vat_bvmt,
            case when ma_tmuc in (4268,4272,4254) then tientra  else 0 end thuphat,
            case when ma_tmuc =4911 then tientra  else 0 end chamnop,
            tientra tien_tra,ma_chuong,ma_tmuc,kythue,ten_nnt,mst,so,to_char(ngay,''dd/mm/yyyy'') ngay,phuongxa,
            '''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv,'''' diaban,
            '||l_1801||' t1801,'||l_1802||' t1802,'||l_1803||' t1803,'||l_1804||' t1804,'||l_1805||' t1805,'||l_1806||' t1806,
            '||l_1701||' t1701,'||l_1003||' t1003,'||l_1757||' t1757,'||l_1599||' t1599,'||l_2000||' t2000,'||l_4268||' t4268,'||l_4911||' t4911,
            '''' kyhieu
          from (
          select mst,sum(tientra) tientra,ma_chuong,ma_tmuc,chuky kythue,ten_nnt,so,ngay,phuongxa from
          (
              select b.mst,a.tientra,d.ten_chuong,e.tentieumuc,a.ma_chuong,a.ma_tmuc,a.chuky,b.ten_nnt,f.id so, f.ngay_tt ngay,
                    (select id||''|''||town_name from towns where id =b.ma_xa) phuongxa
              from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f,nguoigachnos g
              where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
              and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+)
              and a.ma_tmuc=e.id(+) and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1';
        s:=s||' and c.shkb='''||pkhobac||'''';

        s:=s||' and f.ngay_thuc between to_date('''||ptungay||''',''dd/mm/yyyy'') + '||l_time||'/24
                and  to_date('''||pdenngay||''',''dd/mm/yyyy'') + '||l_time||'/24 -1/86400';

        s:=s||' and f.ma_tinh='''||pma_tinh||'''
              ) group by mst,ma_chuong,ma_tmuc,chuky,ten_nnt,so,ngay,phuongxa order by phuongxa,mst)';
    else
        s:='select sum(a.tientra) tong_tien, tax.util.doisosangchu(sum(a.tientra))
          from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f,nguoigachnos g
          where a.mst=b.mst and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+) and a.ma_tmuc=e.id(+)
          and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1 and c.shkb =:1
        and f.ngay_thuc between to_date('''||ptungay||''',''dd/mm/yyyy'') + '||l_time||'/24
        and  to_date('''||pdenngay||''',''dd/mm/yyyy'') + '||l_time||'/24 -1/86400
        and f.ma_tinh =:2';
        execute immediate s into l_tien_tra,l_tien_chu using pkhobac,pma_tinh;

        --Insert du lieu vao bang log tax.bangke_gnt
        s:='select rownum stt,'''||l_ten_cct||''' ten_cct, '||l_tien_tra||' tong_tien,'''||l_tien_chu||''' tong_tien_chu,
            case when ma_tmuc in (1801,1802,1803,1804,1805,1806) then tientra  else 0 end monbai,
            case when ma_tmuc =1701 then tientra  else 0 end gtgt,
            case when ma_tmuc =1003 then tientra  else 0 end tncn,
            case when ma_tmuc =1757 then tientra  else 0 end ttdb,
            case when ma_tmuc =1599 then tientra  else 0 end tainguyen,
            case when ma_tmuc in (2001,2002,2003,2004,2005,2006,2007,2008,2009,2019,2041,2042,2043,2044,2045) then tientra  else 0 end bvmt,0 vat_bvmt,
            case when ma_tmuc in (4268,4272,4254) then tientra  else 0 end thuphat,
            case when ma_tmuc =4911 then tientra  else 0 end chamnop,
            tientra tien_tra,ma_chuong,ma_tmuc,ten_nnt,mst,so,to_char(ngay,''dd/mm/yyyy'') ngay,phuongxa,
            '''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv
          from (
          select mst,sum(tientra) tientra,ma_chuong,ma_tmuc,ten_nnt,so,ngay,phuongxa from
          (
              select b.mst,a.tientra,d.ten_chuong,e.tentieumuc,a.ma_chuong,a.ma_tmuc,b.ten_nnt,f.id so, f.ngay_tt ngay,
                    (select id||''|''||town_name from towns where id =b.ma_xa) phuongxa
              from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f,nguoigachnos g
              where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
              and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+)
              and a.ma_tmuc=e.id(+) and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1';
        s:=s||' and c.shkb='''||pkhobac||'''';
        s:=s||' and f.ngay_thuc between to_date('''||ptungay||''',''dd/mm/yyyy'') + '||l_time||'/24
        and  to_date('''||pdenngay||''',''dd/mm/yyyy'') + '||l_time||'/24 -1/86400';

        s:=s||' and f.ma_tinh='''||pma_tinh||'''
              ) group by mst,ma_chuong,ma_tmuc,ten_nnt,so,ngay,phuongxa order by phuongxa,mst,ngay)';
    end if;

    open report_out for s;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;
PROCEDURE REPORT_INFO_DAILY_DEBT(
    pma_tinh varchar2,
    pdonvi varchar2,
    pbuucuc varchar2,
    pquaythu varchar2,
    pnguoigachno varchar2,
    pduongthu varchar2,
    pkythu varchar2,
    ptungay varchar2,
    report_out OUT SYS_REFCURSOR,
    pdata varchar2 default 1)
is
    s varchar2(32000);
    l_mst number;
    ckn varchar2(100):=crud.ckn_hientai();
    l_time NUMBER;
    l_time_end VARCHAR2(1000);
begin
    s:='select sum(sl_mst) from (select count(distinct a.mst) sl_mst
        from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b, (select mst,barcode,max(stt) stt from in_phieus group by mst,barcode) i,
        tax.nguoigachnos c,
        (select * from tax.quaythus where ma_tinh='''||pma_tinh||''') d,
        (select * from tax.buucucthus where ma_tinh='''||pma_tinh||''') e,
        (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') f,
         tax.nnts_'||ckn||' g, tax.hinhthuc_tts h
        where a.phieu_id = b.id and b.nguoigachno_id = c.id and c.vnpt ='||pdata||'
        and c.quaythu_id = d.id and d.mabc_id = e.id
        and e.donviql_id = f.id and a.mst = g.mst
        and a.ma_tinh = g.ma_tinh and b.httt_id = h.id and a.mst||''/''||a.kythue= i.barcode(+)
        and a.ma_tinh ='''||pma_tinh||'''';

    if pdonvi is not null then s:=s||' and f.id like '''||replace(pdonvi,'*','%')||''''; end if;
    if pbuucuc is not null then s:=s||' and e.id like '''||replace(pbuucuc,'*','%')||''''; end if;
    if pquaythu is not null then s:=s||' and d.id like '''||replace(pquaythu,'*','%')||''''; end if;
    if pnguoigachno is not null then s:=s||' and b.nguoigachno_id like '''||replace(pnguoigachno,'*','%')||''''; end if;
    if ptungay is not null then s:=s||' and b.ngay_thuc >= to_date('''||ptungay||''',''dd/mm/yyyy'') and b.ngay_thuc < to_date('''||ptungay||''',''dd/mm/yyyy'') +1'; end if;
    if pduongthu is not null then s:=s||' and g.ma_nv = '''||pduongthu||''''; end if;
    if pkythu is not null then s:=s||' and a.kythue = '''||pkythu||''''; end if;
    s:=s||' group by a.mst,a.kythue)';
    execute immediate s into l_mst;


    if pma_tinh='79TTT' then
        s:='select rownum stt,a.mst,a.tientra,(select TEN_CHUONG from  tax.chuongs where a.ma_chuong = id) ten_chuong,
            (select ''[''||ID||'']''||TENTIEUMUC from  tax.tieu_mucs where a.ma_tmuc = id)||''|''||ck.ky ten_muc, a.phieu_id,
            to_char(b.ngay_thuc,''dd/mm/yyyy hh24:mi:ss'') ngay_tt, b.nguoigachno_id,b.ma_chuan_chi,b.so_tham_chieu,d.tenquay,
            e.tenbuucuc,f.ten_dv, g.ten_nnt, g.mota_diachi diachi, h.name hinhthuc,null tt_in,
            a.phieu_id, a.kythue, '||l_mst||' sl_mst,g.ma_nv manv,b.seri,b.ky_hieu,a.ma_tmuc,a.chuky,
            (select id||'' - ''||ten_nv from nhanvien_tcs where ma_tinh='''||pma_tinh||''' and id =g.ma_nv and rownum =1) ma_nv
             from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b, tax.nguoigachnos c,
            (select * from tax.quaythus where ma_tinh='''||pma_tinh||''') d,
            (select * from tax.buucucthus where ma_tinh='''||pma_tinh||''') e,
            (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') f, tax.nnts_'||ckn||' g, tax.hinhthuc_tts h, tax.ck_thue ck
            where a.phieu_id = b.id and b.nguoigachno_id = c.id and c.vnpt ='||pdata||'
            and c.quaythu_id = d.id and d.mabc_id = e.id
            and e.donviql_id = f.id and a.mst = g.mst
            and a.ma_tinh = g.ma_tinh and b.httt_id = h.id
            and a.chuky = ck.chuky(+)
            and a.ma_tinh ='''||pma_tinh||'''';
    ELSE
        BEGIN
            s:='SELECT expire_time FROM config_special_days WHERE agent=:1 AND status=1';
            EXECUTE IMMEDIATE s INTO l_time USING pma_tinh;
            IF l_time = 0 THEN l_time_end:='23:59:59';
            ELSE l_time_end:= to_char(l_time-1)||':59:59'; end IF;
            EXCEPTION WHEN OTHERS THEN
            l_time:=0;
        END;

        s:='select rownum stt,a.mst,a.tientra,(select TEN_CHUONG from  tax.chuongs where a.ma_chuong = id) ten_chuong,
            (select ''[''||ID||'']''||TENTIEUMUC from  tax.tieu_mucs where a.ma_tmuc = id)||''|''||a.chuky ten_muc, a.phieu_id,
            to_char(b.ngay_thuc,''dd/mm/yyyy hh24:mi:ss'') ngay_tt, b.nguoigachno_id,d.tenquay,
            CASE When to_number(to_char(b.ngay_thuc,''HH24'')) < '||l_time||' then ''00:00:00 - '||l_time_end||''' else '''||l_time||':00:00 - 23:59:59'' end time_expire,
            e.tenbuucuc,f.ten_dv, g.ten_nnt, g.mota_diachi diachi, h.name hinhthuc,i.stt tt_in,
            a.phieu_id, a.kythue, '||l_mst||' sl_mst,g.ma_nv manv,(select id||'' - ''||ten_nv from nhanvien_tcs where ma_tinh='''||pma_tinh||''' and id =g.ma_nv and rownum =1) ma_nv
             from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b, (select mst,barcode,max(stt) stt from in_phieus group by mst,barcode) i,
             tax.nguoigachnos c,
            (select * from tax.quaythus where ma_tinh='''||pma_tinh||''') d,
            (select * from tax.buucucthus where ma_tinh='''||pma_tinh||''') e,
            (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') f, tax.nnts_'||ckn||' g, tax.hinhthuc_tts h
            where a.phieu_id = b.id and b.nguoigachno_id = c.id and c.vnpt ='||pdata||'
            and c.quaythu_id = d.id and d.mabc_id = e.id
            and e.donviql_id = f.id and a.mst = g.mst
            and a.ma_tinh = g.ma_tinh and b.httt_id = h.id
            and a.mst||''/''||a.kythue= i.barcode(+)
            and a.ma_tinh ='''||pma_tinh||'''';
    end if;

    if pdonvi is not null then s:=s||' and f.id like '''||replace(pdonvi,'*','%')||''''; end if;
    if pbuucuc is not null then s:=s||' and e.id like '''||replace(pbuucuc,'*','%')||''''; end if;
    if pquaythu is not null then s:=s||' and d.id like '''||replace(pquaythu,'*','%')||''''; end if;
    if pnguoigachno is not null then s:=s||' and b.nguoigachno_id like '''||replace(pnguoigachno,'*','%')||''''; end if;
    if ptungay is not null then s:=s||' and b.ngay_thuc >= to_date('''||ptungay||''',''dd/mm/yyyy'') and b.ngay_thuc < to_date('''||ptungay||''',''dd/mm/yyyy'') +1'; end if;
    if pduongthu is not null then s:=s||' and g.ma_nv = '''||pduongthu||''''; end if;
    if pkythu is not null then s:=s||' and a.kythue = '''||pkythu||''''; end if;

    if pma_tinh='01TTT' then
        s:=s||' order by time_expire,f.ten_dv,e.tenbuucuc,d.tenquay,h.name,b.nguoigachno_id,g.ma_nv,a.mst,i.stt,a.kythue,b.ngay_thuc';
    else
        s:=s||' order by f.ten_dv,e.tenbuucuc,d.tenquay,h.name,b.nguoigachno_id,g.ma_nv,a.mst,a.kythue,b.ngay_thuc';
    end if;

    open report_out for s;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;
PROCEDURE REPORT_INFO_DAILY_DEBT_SUM(
    pma_tinh varchar2,
    pdonvi varchar2,
    pbuucuc varchar2,
    pquaythu varchar2,
    pnguoigachno varchar2,
    pduongthu varchar2,
    pkythu varchar2,
    ptungay varchar2,
    report_out OUT SYS_REFCURSOR,
    pdata varchar2 default 1)
is
    s varchar2(32000);
    l_mst number;
    ckn varchar2(100):=crud.ckn_hientai();
    l_time NUMBER;
    l_time_end VARCHAR2(1000);
BEGIN
    BEGIN
        s:='SELECT expire_time FROM config_special_days WHERE agent=:1 AND status=1';
        EXECUTE IMMEDIATE s INTO l_time USING pma_tinh;
        IF l_time = 0 THEN l_time_end:='23:59:59';
        ELSE l_time_end:= to_char(l_time-1)||':59:59'; end IF;
        EXCEPTION WHEN OTHERS THEN
        l_time:=0;
    END;

    s:='select sum(tientra) tientra,kythue,ten_muc,ngay_tt,nguoigachno_id,tenquay,tenbuucuc,ten_dv,hinhthuc,ma_nv,decode(time_expire,0,''00:00:00 - '||l_time_end||' '','''||l_time||':00:00 - 23:59:59'') time_expire
        from (select a.mst,a.tientra,(select ''[''||ID||'']''||TENTIEUMUC from  tax.tieu_mucs where a.ma_tmuc = id) ten_muc,
        to_char(b.ngay_thuc,''dd/mm/yyyy'') ngay_tt, b.nguoigachno_id,d.tenquay,
        e.tenbuucuc,f.ten_dv,h.name hinhthuc, a.kythue,CASE When to_number(to_char(b.ngay_thuc,''HH24'')) < '||l_time||' then 0 else '||l_time||' end time_expire,
        (select id||'' - ''||ten_nv from nhanvien_tcs where ma_tinh='''||pma_tinh||''' and id =g.ma_nv and rownum =1) ma_nv
         from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b,
         tax.nguoigachnos c,
         (select * from tax.quaythus where ma_tinh='''||pma_tinh||''') d,
         (select * from tax.buucucthus where ma_tinh='''||pma_tinh||''') e,
         (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') f, tax.nnts_'||ckn||' g, tax.hinhthuc_tts h
        where a.phieu_id = b.id and b.nguoigachno_id = c.id and c.vnpt ='||pdata||'
        and c.quaythu_id = d.id and d.mabc_id = e.id
        and e.donviql_id = f.id and a.mst = g.mst
        and a.ma_tinh = g.ma_tinh and b.httt_id = h.id
        and a.ma_tinh ='''||pma_tinh||'''';

    if pdonvi is not null then s:=s||' and f.id like '''||replace(pdonvi,'*','%')||''''; end if;
    if pbuucuc is not null then s:=s||' and e.id like '''||replace(pbuucuc,'*','%')||''''; end if;
    if pquaythu is not null then s:=s||' and d.id like '''||replace(pquaythu,'*','%')||''''; end if;
    if pnguoigachno is not null then s:=s||' and b.nguoigachno_id like '''||replace(pnguoigachno,'*','%')||''''; end if;
    if ptungay is not null then s:=s||' and b.ngay_thuc >= to_date('''||ptungay||''',''dd/mm/yyyy'') and b.ngay_thuc < to_date('''||ptungay||''',''dd/mm/yyyy'') +1'; end if;
    if pduongthu is not null then s:=s||' and g.ma_nv = '''||pduongthu||''''; end if;
    if pkythu is not null then s:=s||' and a.kythue = '''||pkythu||''''; end if;

    s:=s||' ) group by time_expire,kythue,ten_muc,ngay_tt,nguoigachno_id,tenquay,tenbuucuc,ten_dv,hinhthuc,ma_nv
    order by time_expire,ten_dv,tenbuucuc,tenquay,hinhthuc,nguoigachno_id,ma_nv,ngay_tt,kythue,ten_muc';

    open report_out for s;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;
Function list_info_debt_daily(
    ptungay varchar2,
    pma_tinh varchar2,
    pdonvi varchar2,
    pbuucuc varchar2,
    pquaythu varchar2,
    pnguoigachno varchar2,
    pType varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(3000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai();
begin

    s:='select a.mst,to_char(a.tientra,''fm999,999,999,999'') tientra,(select TEN_CHUONG from  tax.chuongs where a.ma_chuong = id) ten_chuong,
        (select TENTIEUMUC from  tax.tieu_mucs where a.ma_tmuc = id) ten_muc, a.phieu_id,
        to_char(b.ngay_tt,''dd/mm/yyyy hh24:mi:ss'') ngay_tt,b.nguoigachno_id,d.tenquay,e.tenbuucuc,f.ten_dv,g.name hinhthuc_tt
         from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b,tax.nguoigachnos c,
         tax.quaythus d, tax.buucucthus e, (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') f, tax.hinhthuc_tts g
        where a.phieu_id = b.id and b.nguoigachno_id = c.id
        and c.quaythu_id = d.id and d.mabc_id = e.id
        and e.donviql_id = f.id and b.httt_id = g.id
        and a.ma_tinh ='''||pma_tinh||'''';

    if pdonvi is not null then s:=s||' and f.id like '''||replace(pdonvi,'*','%')||''''; end if;
    if pbuucuc is not null then s:=s||' and e.id like '''||replace(pbuucuc,'*','%')||''''; end if;
    if pquaythu is not null then s:=s||' and d.id like '''||replace(pquaythu,'*','%')||''''; end if;
    if pnguoigachno is not null then s:=s||' and b.nguoigachno_id like '''||replace(pnguoigachno,'*','%')||''''; end if;
    if ptungay is not null then s:=s||' and b.ngay_tt >= to_date('''||ptungay||''',''dd/mm/yyyy'') and b.ngay_tt < to_date('''||ptungay||''',''dd/mm/yyyy'') +1'; end if;

    s:=s||' order by f.ten_dv,e.tenbuucuc,d.tenquay,b.nguoigachno_id,b.ngay_tt';
    if pType='1' then
       open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
       return ref_;
    end if;

    if pType='2' then
       return util.GetTotalRecord(s,pPageIndex,pRecordPerPage);
    end if;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
END;

/
