--------------------------------------------------------
--  File created - Tuesday-January-10-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body PKG_INFO
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "TAX"."PKG_INFO" AS
  function get_manv_by_tinh(
  pma_tinh varchar2,
  pma_bc varchar2)
return sys_refcursor
is
  s varchar2(1000);
  ref_ sys_refcursor;
begin
--  logger.access('tax.tien_nop|get_manv_by_tinh',pma_tinh||' - '||pma_bc);
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

function new_tt_nopthue(
    p1_mst varchar2,
    p2_ten_nnt varchar2,
    p4_ma_cqt_ql varchar2,
    p6_ma_tinh varchar2,
    p7_ma_huyen varchar2,
    p8_ma_xa varchar2,
    p9_so_nha varchar2,
    p11_ma_tinh_tt varchar2,
    p12_ma_huyen_tt varchar2,
    p13_ma_xa_tt varchar2,
    p14_so_nha_tt varchar2,
    p15_mobile varchar2,
    p16_email varchar2,
    p17_ma_nv varchar2,
    p19_ma_unt varchar2,
    p20_ten_unt varchar2,
    p24_kbnn varchar2,
    p25_so_bl varchar2,
    p26_ngay_bl varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    mota_dia_chi varchar2(1000);
    diachi_tt varchar2(1000);
    p23_dia_ban varchar2(1000);
    p29_ngay_banke  varchar2(1000);
    ckn varchar2(100):= crud.ckn_hientai;
    n number;
begin
	n := tax.check_privileges(i_userid=> pUserId);
	if n=0 then
        return 'USER '||pUserId||' KHONG CO QUYEN THAO TAC !';
    end if;

    --map dia chi
    begin
    select p9_so_nha||' '||town_name||' '||(select district_name from districts where id=p7_ma_huyen)||' '||(select province_name from provinces where id=p6_ma_tinh)
      into mota_dia_chi  from towns where id=p8_ma_xa;
        exception when others then
        mota_dia_chi:= p6_ma_tinh||'-'||p7_ma_huyen||'-'||p8_ma_xa;
    end;

    begin
    select p14_so_nha_tt||' '||town_name||' '||(select district_name from districts where id=p12_ma_huyen_tt)||' '||(select province_name from provinces where id=p11_ma_tinh_tt)
      into diachi_tt  from towns where id=p13_ma_xa_tt;
        exception when others then
        diachi_tt:=p11_ma_tinh_tt||'-'||p12_ma_huyen_tt||'-'||p13_ma_xa_tt;
    end;


    p23_dia_ban :=p4_ma_cqt_ql;
    p29_ngay_banke := sysdate;
    s:='select count(1) from tax.nnts_'||ckn||' where mst=:1';
    execute immediate s into n using p1_mst;
    if(n=1) then
        return 'DUPLICATE';
    end if;
    s:='insert into tax.nnts_'||ckn||'(mst,ten_nnt,ma_cqt_ql,MOTA_DIACHI,ma_tinh,ma_huyen,ma_xa,so_nha,diachi_tt,
                ma_tinh_tt,ma_huyen_tt, ma_xa_tt,so_nha_tt,mobile,email,
                ma_nv,ma_unt,ten_unt,dia_ban,kbnn,ngay_banke,nguoi_cn,ip_cn,loai_dl)
            values (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18,:19,:20,:21,:22,:23,:24)';
    execute immediate s using p1_mst,p2_ten_nnt,p4_ma_cqt_ql,mota_dia_chi,p6_ma_tinh,p7_ma_huyen,p8_ma_xa,p9_so_nha,diachi_tt,
                                p11_ma_tinh_tt,p12_ma_huyen_tt,p13_ma_xa_tt,p14_so_nha_tt,p15_mobile,p16_email,p17_ma_nv,p19_ma_unt,
                                p20_ten_unt,p23_dia_ban,p24_kbnn,sysdate,pUserId,pUserIp,1;

	--insert log
	s:='insert into tax.nnts_log(mst,ten_nnt,ma_cqt_ql,MOTA_DIACHI,ma_tinh,ma_huyen,ma_xa,so_nha,diachi_tt,
                ma_tinh_tt,ma_huyen_tt, ma_xa_tt,so_nha_tt,mobile,email,
                ma_nv,ma_unt,ten_unt,dia_ban,kbnn,ngay_banke,nguoi_cn,ip_cn,loai_dl)
            values (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18,:19,:20,:21,:22,:23,:24)';
    execute immediate s using p1_mst,p2_ten_nnt,p4_ma_cqt_ql,mota_dia_chi,p6_ma_tinh,p7_ma_huyen,p8_ma_xa,p9_so_nha,diachi_tt,
                                p11_ma_tinh_tt,p12_ma_huyen_tt,p13_ma_xa_tt,p14_so_nha_tt,p15_mobile,p16_email,p17_ma_nv,p19_ma_unt,
                                p20_ten_unt,p23_dia_ban,p24_kbnn,sysdate,pUserId,pUserIp,1;

    commit;
    return '1';
    exception when others then
        declare err varchar2(500);
        begin
        err:='Loi thuc hien, ma loi:'||to_char(sqlerrm)||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; return err;
    end;
end;

function search_tt_nopthue(
    p1_mst varchar2,
    p2_ten_nnt varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
     s  VARCHAR2 (32767);
     ref_ sys_refcursor;
     ckn varchar2(100):= crud.ckn_hientai;
     l_agent varchar2(10):= tax.get_agent_user(pUserId);
begin
    s:=' select a.mst, a.ten_nnt, a.so, a.ma_cqt_ql edit_ma_cqt_ql, a.ma_cqt_ql ma_cqt_ql, a.mota_diachi, a.so_nha, a.diachi_tt,
       a.ma_tinh edit_ma_tinh, a.ma_tinh, a.ma_huyen edit_ma_huyen, a.ma_huyen, a.ma_xa, a.ma_xa edit_ma_xa,
       a.ma_tinh_tt, a.ma_tinh_tt edit_ma_tinh_tt,  a.ma_huyen_tt, a.ma_huyen_tt edit_ma_huyen_tt, a.ma_xa_tt, a.ma_xa_tt edit_ma_xa_tt,
       a.ma_nv, a.dia_ban, a.kbnn , a.so_nha_tt, a.mobile, a.email, a.ma_t, a.ma_unt, a.ten_unt
       , a.cbk_unt, a.ngay_unt, a.so_bl, a.ngay_bl, a.sobl_unt, a.ngaybl_unt, a.ngay_banke from tax.nnts_'||ckn||' a
	   where a.ma_tinh= '''||l_agent||'''';

    if p1_mst is not null then s:=s||' and lower(a.mst) like ''%'||replace(lower(p1_mst)||'%','*')||''''; end if;
    if p2_ten_nnt is not null then s:=s||' and lower(a.ten_nnt) like ''%'||replace(lower(p2_ten_nnt)||'%','*')||''''; end if;
    s:=s||' order by a.ngay_banke desc';

    if(pPageIndex=-1) then
        s:='select ceil(count(*)/:1) nop,count(1) nor from ('||s||')';
        open ref_ for s using  pRecordPerPage;
    else
        open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    end if;
    return ref_;
    exception when others then
        declare err varchar2(500); begin
        err:='Loi thuc hien, ma loi:'||to_char(sqlerrm)||'----'||s;
        open ref_ for 'select :1 err from dual' using err;
        return ref_;
    end;
end;
function edit_tt_nopthue(
    p1_mst varchar2,
    p2_ten_nnt varchar2,
    p4_ma_cqt_ql varchar2,
    p6_ma_tinh varchar2,
    p7_ma_huyen varchar2,
    p8_ma_xa varchar2,
    p9_so_nha varchar2,
    p11_ma_tinh_tt varchar2,
    p12_ma_huyen_tt varchar2,
    p13_ma_xa_tt varchar2,
    p14_so_nha_tt varchar2,
    p15_mobile varchar2,
    p16_email varchar2,
    p17_ma_nv varchar2,
    p19_ma_unt varchar2,
    p20_ten_unt varchar2,
    p24_kbnn varchar2,
    p25_so_bl varchar2,
    p26_ngay_bl varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    mota_dia_chi varchar2(1000);
    diachi_tt varchar2(1000);
    p23_dia_ban varchar2(1000);
    p29_ngay_banke  varchar2(1000);
    ckn varchar2(100):= crud.ckn_hientai;
    l_diaban varchar2(10);
    n number;
    l_edit number;
begin
    --check mst duoc phep edit
    /*l_edit := tax.check_loai_dl(i_mst=> p1_mst);
    if l_edit=0 then
        return 'MST '||p1_mst||' KHONG DUOC PHEP CAP NHAT';
    end if;*/

	n := tax.check_privileges(i_userid=> pUserId);
	if n=0 then
        return 'USER '||pUserId||' KHONG CO QUYEN THAO TAC !';
    end if;


    begin
    select p9_so_nha||' '||town_name||' '||(select district_name from districts where id=p7_ma_huyen)||' '||(select province_name from provinces where id=p6_ma_tinh)
      into mota_dia_chi  from towns where id=p8_ma_xa;
        exception when others then
        mota_dia_chi:= p6_ma_tinh||'-'||p7_ma_huyen||'-'||p8_ma_xa;
    end;

    begin
    select p14_so_nha_tt||' '||town_name||' '||(select district_name from districts where id=p12_ma_huyen_tt)||' '||(select province_name from provinces where id=p11_ma_tinh_tt)
      into diachi_tt  from towns where id=p13_ma_xa_tt;
        exception when others then
        diachi_tt:=p11_ma_tinh_tt||'-'||p12_ma_huyen_tt||'-'||p13_ma_xa_tt;
    end;

    p29_ngay_banke := sysdate;

    begin
        select cqt_qlt into l_diaban from coquanthus where cqt_tms=p4_ma_cqt_ql;
        exception when others then
            l_diaban := p4_ma_cqt_ql;
    end;

    p23_dia_ban := l_diaban;

	execute immediate 'insert into nnts_log(mst, ten_nnt, so, ma_cqt_ql, mota_diachi, ma_tinh,
       ma_huyen, ma_xa, so_nha, diachi_tt, ma_tinh_tt,ma_huyen_tt, ma_xa_tt, so_nha_tt, mobile, email,
       ma_nv, ma_t, ma_unt, ten_unt, cbk_unt, ngay_unt,dia_ban, kbnn, so_bl, ngay_bl, sobl_unt, ngaybl_unt,
       ngay_banke, loai_dl, nguoi_cn, ip_cn, trang_thai)
            select mst, ten_nnt, so, ma_cqt_ql, mota_diachi, ma_tinh,ma_huyen, ma_xa, so_nha, diachi_tt, ma_tinh_tt,
                ma_huyen_tt, ma_xa_tt, so_nha_tt, mobile, email,ma_nv, ma_t, ma_unt, ten_unt, cbk_unt, ngay_unt,
                dia_ban, kbnn, so_bl, ngay_bl, sobl_unt, ngaybl_unt,ngay_banke, loai_dl, :1, :2, :3
            from tax.nnts_'||ckn||' where mst=:4'  using pUserId,pUserIp,2,p1_mst;

    s:='update tax.nnts_'||ckn||'
            set ten_nnt=:ten_nnt,ma_cqt_ql=:ma_cqt_ql,MOTA_DIACHI=:mota_dia_chi,ma_tinh=:ma_tinh,ma_huyen=:ma_huyen,ma_xa=:ma_xa,so_nha=:so_nha,diachi_tt=:diachi_tt,
                ma_tinh_tt=:ma_tinh_tt,ma_huyen_tt=:ma_huyen_tt, ma_xa_tt=:ma_xa_tt,so_nha_tt=:so_nha_tt,mobile=:mobile,email=:email,
                ma_nv=:ma_nv,ma_unt=:ma_unt,ten_unt=:ten_unt,dia_ban=:dia_ban,kbnn=:kbnn,sobl_unt=:sobl_unt,ngaybl_unt=:ngaybl_unt,ngay_banke=:ngay_banke,nguoi_cn=:nguoi_cn,ip_cn=:ip_cn
                where mst=:mst and loai_dl=1';
    execute immediate s using p2_ten_nnt,p4_ma_cqt_ql,mota_dia_chi,p6_ma_tinh,p7_ma_huyen,p8_ma_xa,p9_so_nha,diachi_tt,p11_ma_tinh_tt,p12_ma_huyen_tt,p13_ma_xa_tt,p14_so_nha_tt,
            p15_mobile,p16_email,p17_ma_nv,p19_ma_unt,p20_ten_unt,p23_dia_ban,p24_kbnn,p25_so_bl,p26_ngay_bl,sysdate,pUserId,pUserIp,p1_mst;
    commit;return '1';
    exception when others then
        declare err varchar2(500);
        begin
        err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_tt_nopthue(
    p1_mst varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    ckn varchar2(100):= crud.ckn_hientai;
    l_edit number;
    l_exists number;
	n number :=0;
begin
    --check mst duoc phep edit
    /*l_edit := tax.check_loai_dl(i_mst=> p1_mst);
    if l_edit=0 then
        return 'MST '||p1_mst||' KHONG DUOC PHEP XOA';
    end if;*/

	n := tax.check_privileges(i_userid=> pUserId);
	if n=0 then
        return 'USER '||pUserId||' KHONG CO QUYEN THAO TAC !';
    end if;

    --check thong tin no thue
    execute immediate 'select count(1) from ct_no_'||ckn||' where mst =:1' into l_exists using p1_mst;
    if l_exists>0 then
        return 'MST '||p1_mst||' KHONG DUOC PHEP XOA DO VAN TON TAI THONG TIN NOP THUE';
    end if;

    execute immediate 'insert into nnts_log(mst, ten_nnt, so, ma_cqt_ql, mota_diachi, ma_tinh,
       ma_huyen, ma_xa, so_nha, diachi_tt, ma_tinh_tt,ma_huyen_tt, ma_xa_tt, so_nha_tt, mobile, email,
       ma_nv, ma_t, ma_unt, ten_unt, cbk_unt, ngay_unt,dia_ban, kbnn, so_bl, ngay_bl, sobl_unt, ngaybl_unt,
       ngay_banke, loai_dl, nguoi_cn, ip_cn, trang_thai)
            select mst, ten_nnt, so, ma_cqt_ql, mota_diachi, ma_tinh,ma_huyen, ma_xa, so_nha, diachi_tt, ma_tinh_tt,
                ma_huyen_tt, ma_xa_tt, so_nha_tt, mobile, email,ma_nv, ma_t, ma_unt, ten_unt, cbk_unt, ngay_unt,
                dia_ban, kbnn, so_bl, ngay_bl, sobl_unt, ngaybl_unt,ngay_banke, loai_dl, :1, :2, :3
            from tax.nnts_'||ckn||' where mst=:4'  using pUserId,pUserIp,0,p1_mst;

    s:='delete from tax.nnts_'||ckn||' where mst=:mst and rownum=1';
    execute immediate s using p1_mst;
    commit;return '1';

    exception when others then
        declare err varchar2(500);
        begin
        rollback;
        err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

--------------------------------------------------------------------------------------------------------------------------------------

function new_danhba(
    p1_mst varchar2,
    p2_ma_tinh varchar2,
    p3_no_cuoi_ky varchar2,
    p4_kieu_no varchar2,
    p5_ma_chuong varchar2,
    p6_ma_tmuc varchar2,
    p7_kythue varchar2,
    p8_so_taikhoan_co varchar2,
    p9_so_qdinh varchar2,
    p10_ngay_qdinh varchar2,
    p11_loai_tien varchar2,
    p13_loai_thue varchar2,
    p14_ma_cq_thu varchar2,
    p15_han_nop varchar2,
    p16_magiao_unt varchar2,

    p17_chuky varchar2,
    p18_sobk_unt varchar2,
    p19_ngaybk_unt  varchar2,
    pUserId varchar2,
    pUserIp varchar2
    )
return varchar2
is
    s varchar2(1000);
    n number:=0;
    ckn varchar2(100):= crud.ckn_hientai;
	l_id number:= UTIL.GETSEQ('DATA_CUS_SEQ');
begin
	n := tax.check_privileges(i_userid=> pUserId);
	if n=0 then
        return 'USER '||pUserId||' KHONG CO QUYEN THAO TAC !';
    end if;

	s:='select count(1) from tax.nnts_'||ckn||' where mst=:1 and ma_tinh=:2';
    execute immediate s into n using p1_mst,p2_ma_tinh;
    if(n=0) then
        return 'NOT EXISTS';
    end if;

    s:='select count(1) from tax.ct_no_'||ckn||' where mst=:1 and ma_tmuc=:2 and kythue=:3 and chuky=:4';
    execute immediate s into n using p1_mst,p6_ma_tmuc,p7_kythue,p17_chuky;
    if(n=1) then
        return 'DUPLICATE';
    end if;

	s:='select count(1) from tax.ct_no_'||ckn||' where mst=:1 and ma_tinh=:2 and magiao_unt=:3';
    execute immediate s into n using p1_mst,p2_ma_tinh,p16_magiao_unt;
    if(n>0) then
        return 'MA GIAO UNT DA TON TAI';
    end if;


    s:='insert into tax.ct_no_'||ckn||'(mst,ma_tinh,no_cuoi_ky,kieu_no,ma_chuong,ma_tmuc,kythue,so_taikhoan_co,so_qdinh,ngay_qdinh,
                                        loai_tien,loai_thue,ma_cq_thu,han_nop,magiao_unt,chuky,sobk_unt,ngaybk_unt,nguoi_cn,ip_cn,id)
            values (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18,:19,:20,:21)';
    execute immediate s using p1_mst,p2_ma_tinh,p3_no_cuoi_ky,1,p5_ma_chuong,p6_ma_tmuc,p7_kythue,p8_so_taikhoan_co,
                             p9_so_qdinh, p10_ngay_qdinh, p11_loai_tien, p13_loai_thue,p14_ma_cq_thu,p15_han_nop, p16_magiao_unt,
                             p17_chuky,p18_sobk_unt,p19_ngaybk_unt,pUserId,pUserIp,l_id;

	--insert log
	s:='insert into tax.ct_no_log(mst,ma_tinh,no_cuoi_ky,kieu_no,ma_chuong,ma_tmuc,kythue,so_taikhoan_co,so_qdinh,ngay_qdinh,
                                        loai_tien,loai_thue,ma_cq_thu,han_nop,magiao_unt,chuky,sobk_unt,ngaybk_unt,nguoi_cn,ip_cn,id)
            values (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18,:19,:20,:21)';
    execute immediate s using p1_mst,p2_ma_tinh,p3_no_cuoi_ky,1,p5_ma_chuong,p6_ma_tmuc,p7_kythue,p8_so_taikhoan_co,
                             p9_so_qdinh, p10_ngay_qdinh, p11_loai_tien, p13_loai_thue,p14_ma_cq_thu,p15_han_nop, p16_magiao_unt,
                             p17_chuky,p18_sobk_unt,p19_ngaybk_unt,pUserId,pUserIp,l_id;

    commit;
    return '1';
    exception when others then
        declare err varchar2(500);
        begin
        err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function search_danhba(
    p1_mst varchar2,
    p2_ma_tinh varchar2,
    p3_no_cuoi_ky varchar2,
    --p4_kieu_no varchar2,
    p5_ma_chuong varchar2,
    p6_ma_tmuc varchar2,
    p7_kythue varchar2,
    --p8_so_taikhoan_co varchar2,
    p9_so_qdinh varchar2,
    p10_ngay_qdinh varchar2,
    --p11_loai_tien varchar2,
    --p12_ti_gia varchar2,
    --p13_loai_thue varchar2,
    p14_ma_cq_thu varchar2,
    p15_han_nop varchar2,
    p16_magiao_unt varchar2,
    p17_chuky varchar2,
    p18_sobk_unt varchar2,
    p19_ngaybk_unt varchar2,


    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s  VARCHAR2 (32767);
    ref_ sys_refcursor;
    ckn varchar2(100):= crud.ckn_hientai;
begin

    s:='select  a.mst, c.province_name ma_tinh, a.ma_tinh edit_ma_tinh, a.no_cuoi_ky, a.kieu_no, d.ten_chuong ma_chuong, a.ma_chuong edit_ma_chuong,
                e.tentieumuc ma_tmuc, a.ma_tmuc edit_ma_tmuc, a.kythue, a.kythue edit_kythue, a.so_taikhoan_co, a.so_qdinh, a.ngay_qdinh,
                a.loai_tien, a.ti_gia, a.loai_thue, b.ten_cqt ma_cq_thu, a.ma_cq_thu edit_ma_cq_thu, a.han_nop, a.magiao_unt, a.chuky,
                 a.chuky edit_chuky, a.sobk_unt, a.ngaybk_unt ';
    s :=s||' from tax.ct_no_'||ckn||' a';
    s :=s||' , tax.coquanthus b , tax.provinces c,  tax.chuongs d, tax.tieu_mucs e, tax.chukynos g ';
    s :=s||' where 1=1 and a.ma_cq_thu = b.cqt_tms ';
    s :=s||' and a.ma_tinh =c.id and a.ma_chuong=d.id and a.ma_tmuc=e.id  and g.id=a.kythue';


    if p1_mst is not null then s:=s||' and a.mst= '''||p1_mst||''''; end if;
    if p2_ma_tinh is not null then s:=s||' and a.ma_tinh = '''||p2_ma_tinh||''''; end if;
    if p3_no_cuoi_ky is not null then s:=s||' and a.no_cuoi_ky ='||p3_no_cuoi_ky; end if;
    --if p4_kieu_no is not null then s:=s||' and a.kieu_no ='||p4_kieu_no; end if;
    if p5_ma_chuong is not null then s:=s||' and a.ma_chuong = '''||p5_ma_chuong||''''; end if;
    if p6_ma_tmuc is not null then s:=s||' and a.ma_tmuc = '''||p6_ma_tmuc||''''; end if;
    if p7_kythue is not null then s:=s||' and a.kythue = '''||p7_kythue||''''; end if;
    --if p8_so_taikhoan_co is not null then s:=s||' and lower(a.so_taikhoan_co) like ''%'||replace(lower(p8_so_taikhoan_co)||'%','*')||''''; end if;
    if p9_so_qdinh is not null then s:=s||' and a.so_qdinh = '''||p9_so_qdinh||''''; end if;
    if p10_ngay_qdinh is not null then s:=s||' and a.ngay_qdinh  = '''||p10_ngay_qdinh||''''; end if;

    --if p11_loai_tien is not null then s:=s||' and lower(a.loai_tien) like ''%'||replace(lower(p11_loai_tien)||'%','*')||''''; end if;
    --if p12_ti_gia is not null then s:=s||' and lower(a.ti_gia) like ''%'||replace(lower(p12_ti_gia)||'%','*')||''''; end if;
    --if p13_loai_thue is not null then s:=s||' and lower(a.loai_thue) like ''%'||replace(lower(p13_loai_thue)||'%','*')||''''; end if;
    if p14_ma_cq_thu is not null then s:=s||' and a.ma_cq_thu = '''||p14_ma_cq_thu||''''; end if;
    if p15_han_nop is not null then s:=s||' and a.han_nop = '''||p15_han_nop||''''; end if;

    if p16_magiao_unt is not null then s:=s||' and a.magiao_unt = '''||p16_magiao_unt||''''; end if;
    if p17_chuky is not null then s:=s||' and a.chuky = '''||p17_chuky||''''; end if;
    if p18_sobk_unt is not null then s:=s||' and a.sobk_unt = '''||p18_sobk_unt||''''; end if;
    if p19_ngaybk_unt is not null then s:=s||' and a.ngaybk_unt = '''||p19_ngaybk_unt||''''; end if;
    s:=s||' order by a.ngaybk_unt desc';

  if(pPageIndex=-1) then
      s:='select ceil(count(*)/:1) nop,count(1) nor from ('||s||')';
      open ref_ for s using  pRecordPerPage;
  else
      open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
  end if;
    return ref_;
    exception when others then
        declare err varchar2(500); begin
        err:='Loi thuc hien, ma loi:'||to_char(sqlerrm)||'----'||s;
        open ref_ for 'select :1 err from dual' using err;
        return ref_;
    end;
end;

function edit_danhba(
    p1_mst varchar2,
    p2_ma_tinh varchar2,
    p3_no_cuoi_ky varchar2,
    p4_kieu_no varchar2,
    p5_ma_chuong varchar2,
    p6_ma_tmuc varchar2,
    p7_kythue varchar2,
    p8_so_taikhoan_co varchar2,
    p9_so_qdinh varchar2,
    p10_ngay_qdinh varchar2,
    p11_loai_tien varchar2,
    p13_loai_thue varchar2,
    p14_ma_cq_thu varchar2,
    p15_han_nop varchar2,
    p16_magiao_unt varchar2,
    p17_chuky varchar2,
    p18_sobk_unt varchar2,
    p19_ngaybk_unt  varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    n number;
    ckn varchar2(100):= crud.ckn_hientai;
    l_edit number;
begin

    --check mst duoc phep edit
    /*l_edit := tax.check_loai_dl(i_mst=> p1_mst);
    if l_edit=0 then
        return 'MST '||p1_mst||' KHONG DUOC PHEP CAP NHAT';
    end if;*/
	n := tax.check_privileges(i_userid=> pUserId);
	if n=0 then
        return 'USER '||pUserId||' KHONG CO QUYEN THAO TAC !';
    end if;

	--luu log truoc khi xoa
    execute immediate 'insert into ct_no_log(mst, ma_tinh, no_cuoi_ky, kieu_no, ma_chuong,ma_tmuc, kythue,
                        so_taikhoan_co, so_qdinh, ngay_qdinh,loai_tien, ti_gia, loai_thue, ma_cq_thu, han_nop,
                        magiao_unt, chuky, sobk_unt, ngaybk_unt, nguoi_cn,ip_cn, id, trang_thai)
                        select mst, ma_tinh, no_cuoi_ky, kieu_no, ma_chuong,ma_tmuc, kythue,
                        so_taikhoan_co, so_qdinh, ngay_qdinh,loai_tien, ti_gia, loai_thue, ma_cq_thu, han_nop,
                        magiao_unt, chuky, sobk_unt, ngaybk_unt, :1,:2, id, 2 from tax.ct_no_'||ckn||'
                            where mst=:3 and kythue=:4 and chuky=:5 and ma_tmuc=:6 and ma_chuong=:7 and magiao_unt=:8 and rownum=1'
                        using pUserId,pUserIp,p1_mst,p7_kythue,p17_chuky,p6_ma_tmuc,p5_ma_chuong,p16_magiao_unt;

    s:='update tax.ct_no_'||ckn||' set no_cuoi_ky=:1,han_nop=:2,sobk_unt=:3,ngaybk_unt=:4,nguoi_cn =:5, ip_cn=:6
        where mst=:7 and ma_chuong=:8 and ma_tmuc=:9 and kythue=:10 and chuky=:11 and magiao_unt=:12 and rownum=1';
    execute immediate s using p3_no_cuoi_ky,p15_han_nop,p18_sobk_unt,p19_ngaybk_unt,pUserId,pUserIp,p1_mst,
								p5_ma_chuong,p6_ma_tmuc,p7_kythue,p17_chuky,p16_magiao_unt;

    commit;
    return '1';

    exception when others then
        declare err varchar2(500);
        begin
        err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); rollback; return err;
    end;
end;

function del_danhba(
    p1_mst varchar2,
    p5_ma_chuong varchar2,
    p6_ma_tmuc varchar2,
    p7_kythue varchar2,
    p17_chuky varchar2,
	p16_magiao_unt varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    ckn varchar2(100):= crud.ckn_hientai;
    l_edit number;
	n number:=0;
begin
    --check mst duoc phep edit
    /*l_edit := tax.check_loai_dl(i_mst=> p1_mst);
    if l_edit=0 then
        return 'MST '||p1_mst||' KHONG DUOC PHEP XOA';
    end if;*/

	n := tax.check_privileges(i_userid=> pUserId);
	if n=0 then
        return 'USER '||pUserId||' KHONG CO QUYEN THAO TAC !';
    end if;

    --luu log truoc khi xoa
    execute immediate 'insert into ct_no_log(mst, ma_tinh, no_cuoi_ky, kieu_no, ma_chuong,ma_tmuc, kythue,
                        so_taikhoan_co, so_qdinh, ngay_qdinh,loai_tien, ti_gia, loai_thue, ma_cq_thu, han_nop,
                        magiao_unt, chuky, sobk_unt, ngaybk_unt, nguoi_cn,ip_cn, id, trang_thai)
                        select mst, ma_tinh, no_cuoi_ky, kieu_no, ma_chuong,ma_tmuc, kythue,
                        so_taikhoan_co, so_qdinh, ngay_qdinh,loai_tien, ti_gia, loai_thue, ma_cq_thu, han_nop,
                        magiao_unt, chuky, sobk_unt, ngaybk_unt, :1,:2, id, 0 from tax.ct_no_'||ckn||'
                            where mst=:3 and kythue=:4 and chuky=:5 and ma_tmuc=:6 and ma_chuong=:7 and magiao_unt=:8'
                        using pUserId,pUserIp,p1_mst,p7_kythue,p17_chuky,p6_ma_tmuc,p5_ma_chuong,p16_magiao_unt;

    s:='delete from tax.ct_no_'||ckn||' where mst=:1 and kythue=:2 and chuky=:3 and ma_tmuc=:4 and ma_chuong=:5 and magiao_unt=:6 and rownum=1';
    execute immediate s using p1_mst,p7_kythue,p17_chuky,p6_ma_tmuc,p5_ma_chuong,p16_magiao_unt;

    commit;return '1';
    exception when others then
        declare err varchar2(500);
        begin
        rollback;
        err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function get_mst(pma_tinh varchar2)
return sys_refcursor
is
    s varchar2(4000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai();
    l_agent varchar2(15);
begin

    s:='select a.mst||'' :''||a.ten_nnt name ,a.mst id from tax.nnts_'||ckn||' a where a.ma_tinh =:1';
    open ref_ for s using pma_tinh;
    return ref_;
    exception when others then
        declare err varchar2(500); begin
        err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

END PKG_INFO;

/
