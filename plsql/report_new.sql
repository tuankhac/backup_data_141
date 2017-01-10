--------------------------------------------------------
--  File created - Tuesday-January-10-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body REPORT_NEW
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "TAX"."REPORT_NEW" 
IS
function SEARCH_PHIEUTRA_THEO_KHOBAC_NV(
    pma_tinh varchar2,
    pkhobac varchar2,
    pnhanvientt varchar2,
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

    s:=s||' and a.ma_tinh='''||pma_tinh||''' and c.ma_nv = '''||pnhanvientt||'''
            order by a.id';
   dbms_output.put_line(s);

    open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
PROCEDURE REPORT_PAYMENT_ORDER_NV(
    pma_tinh varchar2,
    pkhobac varchar2,
    pma_nv varchar2,
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



    --l_day := check_time_exception(i_agent=> pma_tinh);
    l_day := check_time_extend(I_DAY=> pngay_tt, I_AGENT=> pma_tinh);
    l_day := l_day +1;

    if ptype=1 then --GIAY NOP TIEN
       s:='';
    elsif (ptype=2) then --BANG KE CHI TIET
        s:='';
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

        s:='select rownum stt,'''||l_ten_cct||''' ten_cct,'''||l_tien_tra||''' tong_tien,'''||l_tien_chu||''' tong_tien_chu, tientra tien_tra,
            nvl(ma_nv,''ERROR'') ma_nv,ma_chuong,ten_muc,ma_tmuc,quan,tinh,'''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv
          from (
          select sum(tientra) tientra,tentieumuc ten_muc,ma_tmuc,ma_chuong,quan,tinh,ma_nv from
          (
              select a.tientra,d.ten_chuong,e.tentieumuc,a.ma_tmuc,a.ma_chuong,b.ma_nv,
              (select district_name from districts where id =b.ma_huyen and rownum=1) quan,
              (select province_name from provinces where id =b.ma_tinh and rownum=1) tinh
              from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e,
               bangphieutra_'||CKN||' f,nguoigachnos g
              where a.mst=b.mst and a.ma_cq_thu = b.ma_cqt_ql
              and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+)
              and a.ma_tmuc=e.id(+) and a.phieu_id=f.id and g.id = f.nguoigachno_id and g.vnpt =1';

        s:=s||' and c.shkb='''||pkhobac||'''';
        s:=s||' and f.ngay_thuc between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24
                    and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_day||' + '||l_time||'/24 -1/86400';

        s:=s||' and f.ma_tinh='''||pma_tinh||'''
              ) group by ma_nv,ma_chuong,ma_tmuc,tentieumuc,quan,tinh) order by ma_nv,ma_chuong,ma_tmuc';

    elsif (ptype=4) then --CHI TIET THEO nhan vien
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
    open report_out for s;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;
function CHECK_SUM_DEPT_NV(
    pma_tinh varchar2,
    pkhobac varchar2,
    pnhanvien varchar2,
    pngay_tt varchar2)
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
    s:=s||' and b.ma_nv = '''||pnhanvien||''')';

    execute immediate s into l_tra;

    return l_tra;
    exception when others then
        return 0;
end;
function ACCEPT_SEQ_UNT_NV(
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
    i_nhanvien varchar2,
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
--     Select count(1) into l_count from dual
--     where to_date(i_ngay_tt,'dd/mm/yyyy')+l_time/24 < (select max(a.to_time) from bankes a
--              where a.ma_nv = i_nhanvien and a.ma_tinh = i_province
--               and a.so_ct_nh = i_so_ct_nh and a.kbnn = i_kbnn and a.trang_thai=1 );


    if l_count >0 then
        return '-1001';
    end if;

    --l_day := check_time_exception(i_agent=> i_province);
    l_day := check_time_extend(I_DAY=> i_ngay_tt, I_AGENT=> i_province);
    l_day := l_day +1;


    s:='insert into tax.bankes(id,ma_tinh,phuong_xa,from_time,to_time,kbnn,ct_kbnn,ngay_ct_kbnn,kh_ct_nh,so_ct_nh,ngay_ct_nh,sotien,ngay_unt,loguser,loguserip,ma_nv)
            values (:id,:ma_tinh,:phuong_xa,:from_time,:to_time,:kbnn,:ct_kbnn,:ngay_ct_kbnn,:kh_ct_nh,:so_ct_nh,:ngay_ct_nh,:sotien,:ngay_unt,:loguser,:loguserip,:ma_nv)';
    execute immediate s using id_,i_province,'', to_date(i_ngay_tt,'dd/mm/yyyy')+l_time/24, to_date(i_ngay_tt,'dd/mm/yyyy') + l_day + l_time/24 -1/86400, i_kbnn,
        i_ct_kbnn, to_date(i_ngay_kbnn,'dd/mm/yyyy'), i_kh_ct_nh, i_so_ct_nh, to_date(i_ngay_ct_nh,'dd/mm/yyyy'), to_number(i_sotien), sysdate, i_userip, i_userid,i_nhanvien;
    commit;

    return id_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); rollback; return err;
    end;
end;
function GET_XML_UNT_NV(
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
    i_nhanvien varchar2,
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

            s:=s||' and c.ma_nv = '''||i_nhanvien||'''';

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
            Return '-1001';
        End if;
    Else
        If ((l_tien <> to_number(i_sotien)) or (l_null >0)) then
            Rollback;
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
                    and a.kythue = d.kythue and a.chuky = d.chuky and a.ma_chuong = d.ma_chuong  and a.ma_tmuc = d.ma_tmuc
                    and a.ma_tmuc = e.id(+) and  c.ma_nv = '''''||i_nhanvien||''''' and a.ma_tinh ='''''||i_province||''''''','''') from dual';




    Execute immediate l_sql into l_return;

    RETURN replace(l_sql1||l_return||l_sql2,'&','');
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||TO_CHAR(SQLCODE)||': '||SQLERRM;
        return err;
    end;

END;
PROCEDURE report_general_unt(i_ma_tinh IN VARCHAR2,
                             i_kythue IN VARCHAR2,
                             o_report OUT sys_refcursor)
is
l_sq1 VARCHAR2(3000);
l_sq2 VARCHAR2(3000);
l_sq3 VARCHAR2(3000);
l_sq4 VARCHAR2(3000);
l_sq5 VARCHAR2(3000);
l_sq6 VARCHAR2(3000);
l_sql LONG;
l_cur sys_refcursor;
BEGIN
   --lay du lieu ky truoc
   l_sq1:='SELECT ma_cq_thu, count(DISTINCT mst) num_mst, sum(num_monbai) num_monbai, SUM (num_gtgt) num_gtgt, SUM(num_tncn) num_tncn, sum(num_others) num_others
   FROM (SELECT mst, ma_cq_thu, ma_tmuc, CASE WHEN ma_tmuc IN (''1801'',''1802'',''1803'',''1804'',''1805'',''1806'') THEN sum(tien_no) ELSE 0 end num_monbai,
   CASE WHEN  ma_tmuc = ''1701'' THEN sum(tien_no) ELSE 0 END  num_gtgt,
   CASE WHEN ma_tmuc = ''1003'' THEN sum(tien_no) ELSE 0 END  num_tncn,
   CASE WHEN ma_tmuc NOT IN (''1801'',''1802'',''1803'',''1804'',''1805'',''1806'',''1701'',''1003'' ) THEN  sum(tien_no) ELSE 0 END  num_others FROM (
   SELECT mst, ma_cq_thu, ma_tmuc,no_cuoi_ky tien_no FROM tax.ct_no_2016 WHERE ma_tinh='''||i_ma_tinh||''' AND to_date(kythue,''MMYYYY'') < to_Date('''||i_kythue||''',''MMYYYY'')
   UNION ALL SELECT mst, ma_cq_thu, ma_tmuc, - tientra tien_no FROM tax.ct_tra_2016 a WHERE ma_tinh='''||i_ma_tinh||'''
   AND EXISTS (SELECT 1 FROM tax.bangphieutra_2016 b WHERE b.id =a.phieu_id AND a.mst = b.mst AND b.ngay_tt < to_date('''||i_kythue||''',''MMYYYY''))) GROUP BY  mst, ma_cq_thu, ma_tmuc) GROUP BY ma_cq_thu';

  --no ky nay
   l_sq2:='SELECT ma_cq_thu, count(DISTINCT mst) num_mst, sum(num_monbai) num_monbai, SUM (num_gtgt) num_gtgt, SUM(num_tncn) num_tncn, sum(num_others) num_others
   FROM (SELECT mst, ma_cq_thu, ma_tmuc, CASE WHEN ma_tmuc IN (''1801'',''1802'',''1803'',''1804'',''1805'',''1806'') THEN sum(tien_no) ELSE 0 end num_monbai,
   CASE WHEN  ma_tmuc = ''1701'' THEN sum(tien_no) ELSE 0 END  num_gtgt,
   CASE WHEN ma_tmuc = ''1003'' THEN sum(tien_no) ELSE 0 END  num_tncn,
   CASE WHEN ma_tmuc NOT IN (''1801'',''1802'',''1803'',''1804'',''1805'',''1806'',''1701'',''1003'' ) THEN  sum(tien_no) ELSE 0 END  num_others FROM (
   SELECT mst, ma_cq_thu, ma_tmuc,no_cuoi_ky tien_no FROM tax.ct_no_2016 WHERE ma_tinh='''||i_ma_tinh||''' AND kythue ='''||i_kythue||''')
   GROUP BY  mst, ma_cq_thu, ma_tmuc) GROUP BY ma_cq_thu';

   ---tong so cu va giao moi
   l_sq3:='SELECT ma_cq_thu, count(DISTINCT mst) num_mst, sum(num_monbai) num_monbai, SUM (num_gtgt) num_gtgt, SUM(num_tncn) num_tncn, sum(num_others) num_others
   FROM (SELECT mst, ma_cq_thu, ma_tmuc, CASE WHEN ma_tmuc IN (''1801'',''1802'',''1803'',''1804'',''1805'',''1806'') THEN sum(tien_no) ELSE 0 end num_monbai,
   CASE WHEN  ma_tmuc = ''1701'' THEN sum(tien_no) ELSE 0 END  num_gtgt,
   CASE WHEN ma_tmuc = ''1003'' THEN sum(tien_no) ELSE 0 END  num_tncn,
   CASE WHEN ma_tmuc NOT IN (''1801'',''1802'',''1803'',''1804'',''1805'',''1806'',''1701'',''1003'' ) THEN  sum(tien_no) ELSE 0 END  num_others FROM (
   SELECT mst, ma_cq_thu, ma_tmuc,no_cuoi_ky tien_no FROM tax.ct_no_2016 WHERE ma_tinh='''||i_ma_tinh||''' AND to_date(kythue,''MMYYYY'') < add_months(to_Date('''||i_kythue||''',''MMYYYY''),1)
   UNION ALL SELECT mst, ma_cq_thu, ma_tmuc, - tientra tien_no FROM tax.ct_tra_2016 a WHERE ma_tinh='''||i_ma_tinh||'''
   AND EXISTS (SELECT 1 FROM tax.bangphieutra_2016 b WHERE b.id =a.phieu_id AND a.mst = b.mst AND b.ngay_tt < to_date('''||i_kythue||''',''MMYYYY''))) GROUP BY  mst, ma_cq_thu, ma_tmuc) GROUP BY ma_cq_thu';

   --thu duoc trong thang
   l_sq4:='SELECT ma_cq_thu, count(DISTINCT mst) num_mst, sum(num_monbai) num_monbai, SUM (num_gtgt) num_gtgt, SUM(num_tncn) num_tncn, sum(num_others) num_others
   FROM (SELECT mst, ma_cq_thu, ma_tmuc, CASE WHEN ma_tmuc IN (''1801'',''1802'',''1803'',''1804'',''1805'',''1806'') THEN sum(tien_no) ELSE 0 end num_monbai,
   CASE WHEN  ma_tmuc = ''1701'' THEN sum(tien_no) ELSE 0 END  num_gtgt,
   CASE WHEN ma_tmuc = ''1003'' THEN sum(tien_no) ELSE 0 END  num_tncn,
   CASE WHEN ma_tmuc NOT IN (''1801'',''1802'',''1803'',''1804'',''1805'',''1806'',''1701'',''1003'' ) THEN  sum(tien_no) ELSE 0 END  num_others FROM (
   SELECT mst, ma_cq_thu, ma_tmuc,tientra tien_no FROM tax.ct_tra_2016 a WHERE ma_tinh='''||i_ma_tinh||'''
   AND EXISTS (SELECT 1 FROM tax.bangphieutra_2016 b WHERE b.id =a.phieu_id AND a.mst = b.mst AND b.ngay_tt >= to_date('''||i_kythue||''',''MMYYYY'')
   AND b.ngay_tt < add_months(to_Date('''||i_kythue||''',''MMYYYY''),1) ))
   GROUP BY  mst, ma_cq_thu, ma_tmuc) GROUP BY ma_cq_thu';

   --thu duoc tu dau
   l_sq5:='SELECT ma_cq_thu, count(DISTINCT mst) num_mst, sum(num_monbai) num_monbai, SUM (num_gtgt) num_gtgt, SUM(num_tncn) num_tncn, sum(num_others) num_others
   FROM (SELECT mst, ma_cq_thu, ma_tmuc, CASE WHEN ma_tmuc IN (''1801'',''1802'',''1803'',''1804'',''1805'',''1806'') THEN sum(tien_no) ELSE 0 end num_monbai,
   CASE WHEN  ma_tmuc = ''1701'' THEN sum(tien_no) ELSE 0 END  num_gtgt,
   CASE WHEN ma_tmuc = ''1003'' THEN sum(tien_no) ELSE 0 END  num_tncn,
   CASE WHEN ma_tmuc NOT IN (''1801'',''1802'',''1803'',''1804'',''1805'',''1806'',''1701'',''1003'' ) THEN  sum(tien_no) ELSE 0 END  num_others FROM (
   SELECT mst, ma_cq_thu, ma_tmuc,tientra tien_no FROM tax.ct_tra_2016 a WHERE ma_tinh='''||i_ma_tinh||'''
   AND EXISTS (SELECT 1 FROM tax.bangphieutra_2016 b WHERE b.id =a.phieu_id AND a.mst = b.mst
   AND b.ngay_tt < add_months(to_Date('''||i_kythue||''',''MMYYYY''),1) ))
   GROUP BY  mst, ma_cq_thu, ma_tmuc) GROUP BY ma_cq_thu';

   -- so tien con lai phai thu den thang hien tai
   l_sq6:='SELECT ma_cq_thu, count(DISTINCT mst) num_mst, sum(num_monbai) num_monbai, SUM (num_gtgt) num_gtgt, SUM(num_tncn) num_tncn, sum(num_others) num_others
   FROM (SELECT mst, ma_cq_thu, ma_tmuc, CASE WHEN ma_tmuc IN (''1801'',''1802'',''1803'',''1804'',''1805'',''1806'') THEN sum(tien_no) ELSE 0 end num_monbai,
   CASE WHEN  ma_tmuc = ''1701'' THEN sum(tien_no) ELSE 0 END  num_gtgt,
   CASE WHEN ma_tmuc = ''1003'' THEN sum(tien_no) ELSE 0 END  num_tncn,
   CASE WHEN ma_tmuc NOT IN (''1801'',''1802'',''1803'',''1804'',''1805'',''1806'',''1701'',''1003'' ) THEN  sum(tien_no) ELSE 0 END  num_others FROM (
   SELECT mst, ma_cq_thu, ma_tmuc,no_cuoi_ky tien_no FROM tax.ct_no_2016 WHERE ma_tinh='''||i_ma_tinh||''' AND to_date(kythue,''MMYYYY'') < add_months(to_Date('''||i_kythue||''',''MMYYYY''),1)
   UNION ALL SELECT mst, ma_cq_thu, ma_tmuc, - tientra tien_no FROM tax.ct_tra_2016 a WHERE ma_tinh='''||i_ma_tinh||'''
   AND EXISTS (SELECT 1 FROM tax.bangphieutra_2016 b WHERE b.id =a.phieu_id AND a.mst = b.mst AND b.ngay_tt < add_months(to_Date('''||i_kythue||''',''MMYYYY''),1))) GROUP BY  mst, ma_cq_thu, ma_tmuc) GROUP BY ma_cq_thu';

   l_sql:='select a.ma_cq_thu,(SELECT ten_cqt FROM tax.coquanthus WHERE cqt_tms=a.ma_cq_thu and rownum=1) c2, a.num_mst c3,a.num_monbai c5, a.num_gtgt c6, a.num_tncn c7, a.num_others c8,
   b.num_mst c9,b.num_monbai c11, b.num_gtgt c12, b.num_tncn c13, b.num_others c14,
   c.num_mst c15,c.num_monbai c17, c.num_gtgt c18, c.num_tncn c19, c.num_others c20,
   '''' c21,'''' c22,'''' c23,'''' c24,'''' c25,'''' c26,
   d.num_mst c27,d.num_monbai c29, d.num_gtgt c30, d.num_tncn c31, d.num_others c32,
   '''' c33,'''' c35,'''' c36,'''' c37,'''' c38,'''' c34,
   e.num_mst c39,e.num_monbai c41, e.num_gtgt c42, e.num_tncn c43, e.num_others c44,
   f.num_mst c45,f.num_monbai c47, f.num_gtgt c48, f.num_tncn c49, f.num_others c50 from
   ('||l_sq1||') a,('||l_sq2||') b,('||l_sq3||') c,('||l_sq4||') d,('||l_sq5||') e,('||l_sq6||') f
   where a.ma_cq_thu(+)=b.ma_cq_thu and b.ma_cq_thu(+)=c.ma_cq_thu and c.ma_cq_thu(+)=d.ma_cq_thu
   and d.ma_cq_thu(+)=e.ma_cq_thu and e.ma_cq_thu=f.ma_cq_thu(+)';
   OPEN l_cur FOR l_sql;
   o_report:= l_cur;
   EXCEPTION WHEN others THEN
   OPEN l_cur FOR 'select ''err'' c2 from dual';
   o_report:= l_cur;

END;

--khacvt
function search_log_pos(
  pId varchar2,
  pContent varchar2,
  pTaxcode varchar2,
  pOrder_id varchar2,
  pType_card varchar2,
  pLogdate varchar2,
  pLog_user varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2,
  ptable varchar2,
  pProvince varchar2,
  pType varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
  code varchar2(100);
  Content varchar2(500);
  Taxcode varchar2(500);
  Order_id varchar2(500);
  Type_card varchar2(500);
  Logdate varchar2(500);
  Log_user varchar2(500);
begin
    --logger.access('tax.log_pos |S');
    s:='select log.id,log.content,log.taxcode,log.order_id,log.type_card,to_char(log.logdate,''dd/mm/yyyy hh24:mi:ss'') logdate,log.loguser from tax.log_pos log,'||ptable||' nnt where 1=1';
  if pid is not null then code := replace (pid, '''', ''); s:=s||' and log.id like '''||replace(code,'*','%')||''''; end if;
  if pContent is not null then Content := replace (pContent, '''', ''); s:=s||' and log.content like '''||replace(Content,'*','%')||''''; end if;
  if pTaxcode is not null then Taxcode := replace (pTaxcode, '''', ''); s:=s||' and log.taxcode like '''||replace(Taxcode,'*','%')||''''; end if;
  if pOrder_id is not null then Order_id := replace (pOrder_id, '''', ''); s:=s||' and log.order_id like '''||replace(Order_id,'*','%')||''''; end if;
  if pType_card is not null then Type_card := replace (pType_card, '''', ''); s:=s||' and log.type_card like '''||replace(Type_card,'*','%')||''''; end if;
  if pLogdate is not null then Logdate := replace (pLogdate, '''', ''); s:=s||' and log.logdate like '''||replace(Logdate,'*','%')||''''; end if;
  if pLog_user is not null then Log_user := replace (pLog_user, '''', ''); s:=s||' and log.loguser like '''||replace(Log_user,'*','%')||''''; end if;

  if pProvince is not null then s:=s||' and log.taxcode = nnt.mst and nnt.ma_tinh = '''||pProvince||''''; end if;
    s:=s||' order by log.id';
  DBMS_OUTPUT.PUT_LINE(s);

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

function search_log_bill_ws(
  pCode varchar2,
  pBill varchar2,
  pCashier varchar2,
  pContent varchar2,
  pResponse varchar2,
  pMethod varchar2,
  pLogdate varchar2,
  pMonth varchar2,
  pTimes varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2,
  pProvince varchar2,
  pType varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
  code varchar2(100);
  Bill varchar2(500);
  Cashier varchar2(500);
  Content varchar2(500);
  Response varchar2(500);
  Method varchar2(500);
  Logdate varchar2(500);
  v_Month varchar2(500);
  Times varchar2(500);
begin
    --logger.access('tax.log_pos |S');
    s:='select code,bill,cashier,response,method,to_char(logdate,''dd/mm/yyyy hh24:mi:ss'') logdate,month,times from tax.log_bill_ws log where 1=1';
  if pCode is not null then  code := replace (pCode, '''', ''); s:=s||' and log.code like '''||replace(code,'*','%')||''''; end if;
  if pBill is not null then Bill := replace (pBill, '''', ''); s:=s||' and log.Bill like '''||replace(Bill,'*','%')||''''; end if;
  if pCashier is not null then Cashier := replace (pCashier, '''', ''); s:=s||' and log.Cashier like '''||replace(Cashier,'*','%')||''''; end if;
  if pContent is not null then Content := replace (pContent, '''', ''); s:=s||' and log.Content like '''||replace(Content,'*','%')||''''; end if;
  if pResponse is not null then Response := replace (pResponse, '''', ''); s:=s||' and log.Response like '''||replace(Response,'*','%')||''''; end if;
  if pMethod is not null then Method := replace (pMethod, '''', ''); s:=s||' and log.loguser like '''||replace(Method,'*','%')||''''; end if;
  if pLogdate is not null then Logdate := replace (pLogdate, '''', '');  s:=s||' and log.Logdate like '''||replace(Logdate,'*','%')||''''; end if;
  if pMonth is not null then v_Month := replace (pMonth, '''', ''); s:=s||' and log.Month like '''||replace(v_Month,'*','%')||''''; end if;
  if pTimes is not null then Bill := replace (pBill, '''', ''); s:=s||' and log.Times like '''||replace(pTimes,'*','%')||''''; end if;

  if pProvince is not null then s:=s||' and log.agent = '''||pProvince||''''; end if;
    s:=s||' order by log.code';
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

function new_role(
    pid varchar2,
    prole_name varchar2,
    pdescription varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    l_agent varchar2(10);
    l_lever NUMBER;
begin
    logger.access('new_role|NEW',pid||'|'||prole_name||'|'||pUserId||'|'||pUserIp);
    l_agent := tax.get_agent_user(puser=> pUserId);
    IF instr(UPPER(pid),'ADMIN') > 0 THEN
        select role_lever into l_lever  from user_info where id = pUserId and rownum=1;
        IF l_lever <> 5 THEN
            RETURN 'Permission denied: Role id must not have "admin" word!';
        END IF;
    END IF;
    s:='insert into phanquyen_chucnang(id,role_name,description,agent)
     values (:id,:role_name,:description,:agent)';
    execute immediate s using pid,prole_name,pdescription,l_agent;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin
            err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
            logger.access('new_role|ERR',err);
            return err;
    end;
end;

function edit_role(
    pid varchar2,
    prole_name varchar2,
    pdescription varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('role|EDIT',pid||'|'||prole_name||'|'||pdescription);
    s:='update phanquyen_chucnang set role_name=:role_name,description=:description where id=:id';
    execute immediate s using prole_name,pdescription,pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('edit_role|ERR',err);
        return err;
    end;
end;
function del_role(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('role|DEL',pId);
    s:='delete from phanquyen_chucnang where id=:id';
    execute immediate s using pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('del_role|ERR',err);
        return err;
    end;
end;

function search_role(
      pid varchar2,
      prole_name varchar2,
      pdescription varchar2,
      pRecordPerPage varchar2,
      pPageIndex varchar2,
      pUserId varchar2,
      pUserIp varchar2)
  return sys_refcursor
  as
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    s:='select * from phanquyen_chucnang where 1=1';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if prole_name is not null then s:=s||' and role_name like '''||replace(prole_name,'*','%')||''''; end if;
    if pdescription is not null then s:=s||' and description like '''||replace(pdescription,'*','%')||''''; end if;
    s:=s||' order by id';
    open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function search_nnts(
    pmst varchar2,
    pten_nnt varchar2,
    pma_tinh varchar2,
    pma_huyen varchar2,
    pma_xa varchar2,
    pma_nv varchar2,
    pType varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ckn varchar2(100):=crud.ckn_hientai;
    ref_ sys_refcursor;
begin
    --logger.access('tax.nnts|SEARCH',pmst||'|'||pten_nnt||'|'||ploai_nnt||'|'||pso||'|'||pchuong||'|'||pma_cqt_ql||'|'||pmota_diachi||'|'||pma_tinh||'|'||pma_huyen||'|'||pma_xa||'|'||pmobile||'|'||pemail||'|'||pma_nv);
    s:='select a.mst,a.ten_nnt,a.mota_diachi,a.ma_nv,a.ma_t, sum(no_cuoi_ky) tong_no from tax.nnts_'||ckn||' a,tax.ct_no_'||ckn||' b
      where 1=1 and a.mst = b.mst';
    if pmst is not null then s:=s||' and a.mst like '''||replace(pmst,'*','%')||''''; end if;
    if pten_nnt is not null then s:=s||' and a.ten_nnt like '''||replace(pten_nnt,'*','%')||''''; end if;
    if pma_tinh is not null then s:=s||' and a.ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
    if pma_huyen is not null then s:=s||' and a.ma_huyen like '''||replace(pma_huyen,'*','%')||''''; end if;
    if pma_xa is not null then s:=s||' and a.ma_xa like '''||replace(pma_xa,'*','%')||''''; end if;
    if pma_nv is not null then s:=s||' and a.ma_nv like '''||replace(pma_nv,'*','%')||''''; end if;
    s:=s||' group by a.mst,a.ten_nnt,a.mota_diachi,a.ma_nv,a.ma_t order by a.ten_nnt';
    dbms_output.put_line(s);
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
   -- Enter further code below as specified in the Package spec.
END;

/
