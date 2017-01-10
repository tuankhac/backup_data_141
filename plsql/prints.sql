--------------------------------------------------------
--  File created - Tuesday-January-10-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body PRINTS
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "TAX"."PRINTS" 
IS
    FUNCTION get_data_receipt_offline(i_manv VARCHAR2,
                                      i_mst VARCHAR2,
                                      i_tieumuc VARCHAR2,
                                      i_chuky VARCHAR2,
                                      i_type_print VARCHAR2,
                                      i_typePage VARCHAR2,
                                      i_pageNum VARCHAR2,
                                      i_pageRec VARCHAR2,
                                      i_userId VARCHAR2,
                                      i_userIp VARCHAR2 )
    RETURN sys_refcursor
    IS
        l_cur sys_refcursor;
        l_sql VARCHAR2(3000);
        ckn varchar2(100):=crud.ckn_hientai();
    BEGIN
       IF i_type_print = 2 THEN
            l_sql:='SELECT ROWNUM,a.mst,a.ten_nnt,a.mobile,a.mota_diachi,b.kythue,b.nocuoi,a.ma_nv
                     FROM tax.nnts_'||ckn||' a,
                    (select mst,kythue, sum(tienno) nocuoi from tax.phieu_offline where 1=1';
            IF i_chuky IS NOT NULL THEN
                 l_sql:=l_sql||' and kythue='''||i_chuky||''' ';
            END IF;
            IF i_manv IS NOT NULL THEN
                l_sql:=l_sql||' and ma_nv='''||i_manv||'''';
            ELSIF i_mst IS NOT null THEN
                l_sql:=l_sql||' and mst='''||i_mst||'''';
            ELSE
                l_sql:=l_sql||' and ma_tmuc='''||i_tieumuc||'''';
            END IF;
            l_sql:=l_sql||' GROUP BY mst,kythue ) b WHERE a.mst =b.mst ';
       ELSE
           IF i_manv IS NOT NULL THEN
            l_sql:='SELECT ROWNUM,a.mst,a.ten_nnt,a.mobile,a.mota_diachi,b.kythue,b.nocuoi,'''||i_manv||''' ma_nv  FROM tax.nnts_'||ckn||' a, (
                    SELECT mst,kythue, sum(nocuoi) nocuoi FROM (
                    SELECT mst,kythue,(no_cuoi_ky) nocuoi FROM tax.ct_no_'||ckn||' a
                    WHERE EXISTS (SELECT 1 FROM tax.nnts_'||ckn||' b WHERE a.mst=b.mst AND b.ma_nv='''||i_manv||''')
                    and not EXISTS (select 1 from tax.phieu_offline o where a.mst=o.mst and a.kythue=o.kythue and a.chuky = o.chuky and a.ma_tmuc=o.ma_tmuc) ';
                    IF i_chuky IS NOT NULL THEN
                        l_sql:=l_sql||' and a.kythue='''||i_chuky||''' ';
                    END IF;
                    l_sql:=l_sql||'
                    UNION ALL
                    SELECT mst,kythue,- (tientra) nocuoi FROM tax.ct_tra_'||ckn||' c WHERE
                    EXISTS (SELECT 1 FROM tax.nnts_'||ckn||' d WHERE c.mst=d.mst AND d.ma_nv='''||i_manv||''')
                    and not EXISTS (select 1 from tax.phieu_offline o where c.mst=o.mst and c.kythue=o.kythue and c.chuky = o.chuky and c.ma_tmuc=o.ma_tmuc) ';
                    IF i_chuky IS NOT NULL THEN
                        l_sql:=l_sql||' and c.kythue='''||i_chuky||''' ';
                    END IF;
                     l_sql:=l_sql||' )
                    GROUP BY mst,kythue HAVING sum(nocuoi) >0) b WHERE a.mst =b.mst';
            ELSIF i_mst IS NOT null THEN
                l_sql:='SELECT ROWNUM,a.mst,a.ten_nnt,a.mobile,a.mota_diachi,b.kythue,b.nocuoi,a.ma_nv  FROM tax.nnts_'||ckn||' a, (
                    SELECT mst,kythue, sum(nocuoi) nocuoi FROM (
                    SELECT mst,kythue,no_cuoi_ky nocuoi FROM tax.ct_no_'||ckn||' a
                    WHERE a.mst='''||i_mst||'''
                    and not EXISTS (select 1 from tax.phieu_offline o where a.mst=o.mst and a.kythue=o.kythue and a.chuky = o.chuky  and a.ma_tmuc=o.ma_tmuc) ';
                    IF i_chuky IS NOT NULL THEN
                        l_sql:=l_sql||' and kythue='''||i_chuky||''' ';
                    END IF;
                    l_sql:=l_sql||'
                    UNION ALL
                    SELECT mst,kythue,- tientra nocuoi FROM tax.ct_tra_'||ckn||' c WHERE c.mst='''||i_mst||'''
                    and not EXISTS (select 1 from tax.phieu_offline o where c.mst=o.mst and c.kythue=o.kythue and c.chuky = o.chuky and c.ma_tmuc=o.ma_tmuc) ';
                    IF i_chuky IS NOT NULL THEN
                        l_sql:=l_sql||' and kythue='''||i_chuky||''' ';
                    END IF;
                     l_sql:=l_sql||' )
                    GROUP BY mst,kythue HAVING sum(nocuoi) >0) b WHERE a.mst =b.mst';
            ELSE
                l_sql:='SELECT ROWNUM,a.mst,a.ten_nnt,a.mobile,a.mota_diachi,b.kythue,b.nocuoi,a.ma_nv  FROM tax.nnts_'||ckn||' a, (
                    SELECT mst,kythue, sum(nocuoi) nocuoi FROM (
                    SELECT mst,kythue,no_cuoi_ky nocuoi FROM tax.ct_no_'||ckn||' a
                    WHERE a.ma_tmuc='''||i_tieumuc||'''
                    and not EXISTS (select 1 from tax.phieu_offline o where a.mst=o.mst and a.kythue=o.kythue and a.chuky = o.chuky and c.chuky = o.chuky and a.ma_tmuc=o.ma_tmuc) ';
                    IF i_chuky IS NOT NULL THEN
                        l_sql:=l_sql||' and a.kythue='''||i_chuky||''' ';
                    END IF;
                    l_sql:=l_sql||'
                    UNION ALL
                    SELECT mst,kythue,- tientra nocuoi FROM tax.ct_tra_'||ckn||' c WHERE
                     c.ma_tmuc='''||i_tieumuc||'''
                     and not EXISTS (select 1 from tax.phieu_offline o where c.mst=o.mst and c.kythue=o.kythue and c.ma_tmuc=o.ma_tmuc) ';
                    IF i_chuky IS NOT NULL THEN
                        l_sql:=l_sql||' and c.kythue='''||i_chuky||''' ';
                    END IF;
                     l_sql:=l_sql||' )
                    GROUP BY mst,kythue HAVING sum(nocuoi) >0) b WHERE a.mst =b.mst';
            END IF;
        END IF;

        if(i_typePage=2) then
            l_sql:='select ceil(count(*)/:1) nop,count(1) nor from ('||l_sql||')';
            open l_cur for l_sql using  i_pageRec;
        ELSIF (i_typePage=1) THEN

          open l_cur for util.xuly_phantrang(l_sql,i_pageNum,i_pageRec);
        end if;
        return l_cur;
        EXCEPTION WHEN OTHERS THEN
           open l_cur FOR SELECT  '' mst,'' ten_nnt,'' mota_diachi,'' kythue,'' nocuoi FROM dual;
            return l_cur;

    END;

    PROCEDURE print_data_receipt_offline(i_manv IN VARCHAR2,
                                      i_mst IN  VARCHAR2,
                                      i_tieumuc IN VARCHAR2,
                                      i_chuky IN VARCHAR2,
                                      i_matinh IN VARCHAR2,
                                      i_type IN VARCHAR2,
                                      i_userId IN VARCHAR2,
                                      i_userIp IN  VARCHAR2,
                                      o_cur OUT sys_refcursor)
    IS
        l_cur sys_refcursor;
        l_sql VARCHAR2(32000);
        l_s VARCHAR2(32000);
        l_pattern varchar2(50);
        l_serial varchar2(50);
        l_count NUMBER;
        l_flag NUMBER;
        ckn varchar2(100):=crud.ckn_hientai();
        l_ten_dv varchar2(200);
        l_diachi_dv varchar2(500);
        l_mst_dv varchar2(100);
    BEGIN
        begin
            l_s:='select a.ten_dv,a.diachi diachi_dv,a.mst mst_dv
                    from donvi_qls a where ma_tinh =:1 and ID=0 and rownum=1';
            execute immediate l_s into l_ten_dv,l_diachi_dv,l_mst_dv using i_matinh;
            exception when others then
                l_ten_dv :='';l_diachi_dv :='';l_mst_dv :='';
        end;
    IF i_type = 1 THEN
        IF (i_matinh='01TTT') then
           IF (i_manv IS NOT NULL) AND (i_manv!='null') THEN
             l_sql:='SELECT ROWNUM,a.mst,a.ten_nnt,a.mota_diachi,a.mobile,a.ma_tinh,a.ma_nv,b.ma_tmuc,b.kythue,b.nocuoi,c.tentieumuc,b.chuky,d.ky ky_view
                     ,'''' pattern,'''' serial,'''||l_ten_dv||''' ten_dv, '''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv FROM tax.nnts_'||ckn||' a, (
                    SELECT mst,kythue,ma_tmuc, sum(nocuoi) nocuoi,chuky FROM (
                    SELECT mst,kythue,ma_tmuc,(no_cuoi_ky) nocuoi,chuky FROM tax.ct_no_'||ckn||' a
                    WHERE EXISTS (SELECT 1 FROM tax.nnts_'||ckn||' b WHERE a.mst=b.mst AND b.ma_nv='''||i_manv||''')
                     and not EXISTS (select 1 from tax.phieu_offline o where a.mst=o.mst and a.kythue=o.kythue and a.ma_tmuc=o.ma_tmuc and a.chuky=o.chuky) ';
                    IF (i_chuky IS NOT NULL) AND (i_chuky!='null') THEN
                        l_sql:=l_sql||' and a.kythue='''||i_chuky||''' ';
                    END IF;
                    l_sql:=l_sql||' UNION ALL
                    SELECT mst,kythue,ma_tmuc,- (tientra) nocuoi,chuky FROM tax.ct_tra_'||ckn||' c WHERE
                    EXISTS (SELECT 1 FROM tax.nnts_'||ckn||' d WHERE c.mst=d.mst AND d.ma_nv='''||i_manv||''')
                     and not EXISTS (select 1 from tax.phieu_offline o where c.mst=o.mst and c.kythue=o.kythue and c.ma_tmuc=o.ma_tmuc and c.chuky=o.chuky) ';
                    IF (i_chuky IS NOT NULL) AND (i_chuky!='null') THEN
                        l_sql:=l_sql||' and c.kythue='''||i_chuky||''' ';
                    END IF;
                     l_sql:=l_sql||')
                    GROUP BY mst,kythue,ma_tmuc,chuky HAVING sum(nocuoi) >0) b,tax.tieu_mucs c,tax.ck_thue d
                    WHERE a.mst =b.mst and b.ma_tmuc=c.id and a.ma_tinh='''||i_matinh||'''  and b.chuky=d.chuky order by a.mst,b.kythue';
            ELSIF (i_mst IS NOT null) AND (i_mst!='null') THEN
                l_sql:='SELECT ROWNUM,a.mst,a.ten_nnt,a.mota_diachi,a.mobile,a.ma_tinh,a.ma_nv,b.ma_tmuc,b.kythue,b.nocuoi,c.tentieumuc,b.chuky,d.ky ky_view
                    ,'''' pattern,'''' serial,'''||l_ten_dv||''' ten_dv, '''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv FROM tax.nnts_'||ckn||' a, (
                    SELECT mst,kythue,ma_tmuc, sum(nocuoi) nocuoi,chuky FROM (
                    SELECT mst,kythue,ma_tmuc,no_cuoi_ky nocuoi,chuky FROM tax.ct_no_'||ckn||' a
                    WHERE a.mst='''||i_mst||'''  and not EXISTS (select 1 from tax.phieu_offline o where a.mst=o.mst and a.kythue=o.kythue and a.ma_tmuc=o.ma_tmuc and a.chuky=o.chuky) ';
                    IF (i_chuky IS NOT NULL) AND (i_chuky!='null') THEN
                        l_sql:=l_sql||' and kythue='''||i_chuky||''' ';
                    END IF;
                    l_sql:=l_sql||' UNION ALL
                    SELECT mst,kythue,ma_tmuc,- (tientra) nocuoi,chuky FROM tax.ct_tra_'||ckn||' c WHERE c.mst='''||i_mst||'''
                    and not EXISTS (select 1 from tax.phieu_offline o where c.mst=o.mst and c.kythue=o.kythue and c.ma_tmuc=o.ma_tmuc and c.chuky=o.chuky) ';
                    IF (i_chuky IS NOT NULL) AND (i_chuky!='null') THEN
                        l_sql:=l_sql||' and kythue='''||i_chuky||''' ';
                    END IF;
                     l_sql:=l_sql||' )
                    GROUP BY mst,kythue,ma_tmuc,chuky HAVING sum(nocuoi) >0) b,tax.tieu_mucs c,tax.ck_thue d
                    WHERE a.mst =b.mst and b.ma_tmuc=c.id and a.ma_tinh='''||i_matinh||''' and b.chuky=d.chuky order by a.mst,b.kythue';
            ELSE
                 l_sql:='SELECT ROWNUM,a.mst,a.ten_nnt,a.mota_diachi,a.mobile,a.ma_tinh,a.ma_nv,b.ma_tmuc,b.kythue,b.nocuoi,c.tentieumuc,b.chuky,d.ky ky_view
                    ,'''' pattern,'''' serial,'''||l_ten_dv||''' ten_dv, '''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv FROM tax.nnts_'||ckn||' a, (
                    SELECT mst,kythue,ma_tmuc, sum(nocuoi) nocuoi,chuky FROM (
                    SELECT mst,kythue,ma_tmuc,(no_cuoi_ky) nocuoi,chuky FROM tax.ct_no_'||ckn||' a
                    WHERE a.ma_tmuc='''||i_tieumuc||'''  and not EXISTS (select 1 from tax.phieu_offline o where a.mst=o.mst and a.kythue=o.kythue and a.ma_tmuc=o.ma_tmuc and a.chuky=o.chuky) ';
                    IF (i_chuky IS NOT NULL) AND (i_chuky!='null') THEN
                        l_sql:=l_sql||' and a.kythue='''||i_chuky||''' ';
                    END IF;
                    l_sql:=l_sql||'
                    UNION ALL
                    SELECT mst,kythue,ma_tmuc,- (tientra) nocuoi,chuky FROM tax.ct_tra_'||ckn||' c WHERE
                     c.ma_tmuc='''||i_tieumuc||''' and not EXISTS (select 1 from tax.phieu_offline o where c.mst=o.mst and c.kythue=o.kythue and c.ma_tmuc=o.ma_tmuc and c.chuky=o.chuky) ';
                    IF (i_chuky IS NOT NULL) AND (i_chuky!='null') THEN
                        l_sql:=l_sql||' and c.kythue='''||i_chuky||''' ';
                    END IF;
                     l_sql:=l_sql||' )
                    GROUP BY mst,kythue,chuky,ma_tmuc HAVING sum(nocuoi) >0) b,tax.tieu_mucs c,tax.ck_thue d
                    WHERE a.mst =b.mst and b.ma_tmuc=c.id  and a.ma_tinh='''||i_matinh||''' and b.chuky=d.chuky order by a.mst,b.kythue';
            END IF;

        ELSE
             l_s :='select replace(replace(b.ky_hieu,''MM'',to_char(sysdate,''MM'')),''YYYY'',to_char(sysdate,''YYYY'')) pattern
                    from nguoigachnos a, quaythus b where a.id =:1 and a.quaythu_id = b.id
                    and a.ma_tinh = b.ma_tinh and a.ma_tinh =:2 and rownum =1';

            execute immediate l_s into l_pattern using i_userId,i_matinh;


            Execute immediate ' Select count(1) from quaythus a
             where a.ma_tinh =:1 and exists (select 1 from nguoigachnos b where b.id =:2 and a.id = b.quaythu_id)
             and nvl(a.tg_gach,''MM-YYYY'')=to_char(SYSDATE,''MM-YYYY'')'
             into l_flag using i_matinh,i_userId;


            IF (i_manv IS NOT NULL) AND (i_manv!='null') THEN
             l_sql:='SELECT a.mst,a.ten_nnt,a.mota_diachi,a.mobile,a.ma_tinh,a.ma_nv,b.ma_tmuc,b.kythue,b.chuky,d.ky ky_view
                ,b.nocuoi,c.tentieumuc,'''||l_ten_dv||''' ten_dv, '''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv
                     FROM tax.nnts_'||ckn||' a, (
                    SELECT mst,kythue,ma_tmuc, sum(nocuoi) nocuoi,chuky FROM (
                    SELECT mst,kythue,ma_tmuc,(no_cuoi_ky) nocuoi,chuky FROM tax.ct_no_'||ckn||' a
                    WHERE EXISTS (SELECT 1 FROM tax.nnts_'||ckn||' b WHERE a.mst=b.mst AND b.ma_nv='''||i_manv||''')
                     and not EXISTS (select 1 from tax.phieu_offline o where a.mst=o.mst and a.kythue=o.kythue and a.ma_tmuc=o.ma_tmuc) ';
                    IF (i_chuky IS NOT NULL) AND (i_chuky!='null') THEN
                        l_sql:=l_sql||' and a.kythue='''||i_chuky||''' ';
                    END IF;
                    l_sql:=l_sql||'
                    UNION ALL
                    SELECT mst,kythue,ma_tmuc,- (tientra) nocuoi,chuky FROM tax.ct_tra_'||ckn||' c WHERE
                    EXISTS (SELECT 1 FROM tax.nnts_'||ckn||' d WHERE c.mst=d.mst AND d.ma_nv='''||i_manv||''')
                     and not EXISTS (select 1 from tax.phieu_offline o where c.mst=o.mst and c.kythue=o.kythue and c.ma_tmuc=o.ma_tmuc) ';
                    IF (i_chuky IS NOT NULL) AND (i_chuky!='null') THEN
                        l_sql:=l_sql||' and c.kythue='''||i_chuky||''' ';
                    END IF;
                     l_sql:=l_sql||' )
                    GROUP BY mst,kythue,chuky,ma_tmuc HAVING sum(nocuoi) >0) b,tax.tieu_mucs c ,tax.ck_thue d
                    WHERE a.mst =b.mst and b.ma_tmuc=c.id and a.ma_tinh='''||i_matinh||'''  and b.chuky=d.chuky  order by a.mst,b.kythue';
            ELSIF (i_mst IS NOT NULL) AND (i_mst!='null') THEN
                l_sql:='SELECT a.mst,a.ten_nnt,a.mota_diachi,a.mobile,a.ma_tinh,a.ma_nv,b.ma_tmuc,b.kythue,b.chuky,d.ky ky_view,
                    b.nocuoi,c.tentieumuc,'''||l_ten_dv||''' ten_dv, '''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv  FROM tax.nnts_'||ckn||' a, (
                    SELECT mst,kythue,ma_tmuc, sum(nocuoi) nocuoi,chuky FROM (
                    SELECT mst,kythue,ma_tmuc,(no_cuoi_ky) nocuoi,chuky FROM tax.ct_no_'||ckn||' a
                    WHERE a.mst='''||i_mst||'''  and not EXISTS (select 1 from tax.phieu_offline o where a.mst=o.mst and a.kythue=o.kythue and a.ma_tmuc=o.ma_tmuc) ';
                    IF (i_chuky IS NOT NULL) AND (i_chuky!='null') THEN
                        l_sql:=l_sql||' and kythue='''||i_chuky||''' ';
                    END IF;
                    l_sql:=l_sql||'
                    UNION ALL
                    SELECT mst,kythue,ma_tmuc,- (tientra) nocuoi,chuky FROM tax.ct_tra_'||ckn||' c
                    WHERE c.mst='''||i_mst||'''  and not EXISTS (select 1 from tax.phieu_offline o where c.mst=o.mst and c.kythue=o.kythue and c.ma_tmuc=o.ma_tmuc) ';
                    IF (i_chuky IS NOT NULL) AND (i_chuky!='null') THEN
                        l_sql:=l_sql||' and kythue='''||i_chuky||''' ';
                    END IF;
                     l_sql:=l_sql||' )
                    GROUP BY mst,kythue,chuky,ma_tmuc HAVING sum(nocuoi) >0) b ,tax.tieu_mucs c ,tax.ck_thue d WHERE a.mst =b.mst
                     and b.ma_tmuc=c.id and a.ma_tinh='''||i_matinh||'''  and b.chuky=d.chuky  order by a.mst,b.kythue';
            ELSE
                 l_sql:='SELECT a.mst,a.ten_nnt,a.mota_diachi,a.mobile,a.ma_tinh,a.ma_nv,b.ma_tmuc,b.chuky,d.ky ky_view
                 ,b.kythue,b.nocuoi,c.tentieumuc,'''||l_ten_dv||''' ten_dv, '''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv  FROM tax.nnts_'||ckn||' a, (
                    SELECT mst,kythue,ma_tmuc, sum(nocuoi) nocuoi,chuky FROM (
                    SELECT mst,kythue,ma_tmuc,(no_cuoi_ky) nocuoi,chuky FROM tax.ct_no_'||ckn||' a
                    WHERE a.ma_tmuc='''||i_tieumuc||'''  and not EXISTS (select 1 from tax.phieu_offline o where a.mst=o.mst and a.kythue=o.kythue and a.ma_tmuc=o.ma_tmuc) ';
                    IF (i_chuky IS NOT NULL) AND (i_chuky!='null') THEN
                        l_sql:=l_sql||' and a.kythue='''||i_chuky||''' ';
                    END IF;
                    l_sql:=l_sql||'
                    UNION ALL
                    SELECT mst,kythue,ma_tmuc,- (tientra) nocuoi,chuky FROM tax.ct_tra_'||ckn||' c WHERE
                     c.ma_tmuc='''||i_tieumuc||'''  and not EXISTS (select 1 from tax.phieu_offline o where c.mst=o.mst and c.kythue=o.kythue and c.ma_tmuc=o.ma_tmuc) ';
                    IF (i_chuky IS NOT NULL) AND (i_chuky!='null') THEN
                        l_sql:=l_sql||' and c.kythue='''||i_chuky||''' ';
                    END IF;
                     l_sql:=l_sql||' )
                    GROUP BY mst,kythue,chuky,ma_tmuc HAVING sum(nocuoi) >0) b,tax.tieu_mucs c,tax.ck_thue d WHERE a.mst =b.mst
                    and b.ma_tmuc=c.id and a.ma_tinh='''||i_matinh||'''  and b.chuky=d.chuky  order by a.mst,b.kythue';
            END IF;
            l_sql:='select aa.*,'''||l_pattern||''' pattern ,bb.serial
                     FROM ('||l_sql||') aa, (select (select CASE WHEN '||l_flag||' =0 THEN x.row_num ELSE to_number(nvl(b.seri,''0'')) +x.row_num END serial
                      from nguoigachnos a, quaythus b where a.id ='''||i_userId||''' and a.quaythu_id = b.id
                      and a.ma_tinh = b.ma_tinh and a.ma_tinh ='''||i_matinh||''' and rownum =1) serial,x.kythue,x.mst
                      from (select ROWNUM row_num,mm.* from (select mst,kythue from ('||l_sql||') group by mst,kythue order by mst,kythue) mm ) x ) bb where aa.mst=bb.mst and aa.kythue=bb.kythue
                    ';

        END IF;

         OPEN l_cur FOR l_sql;
         IF (i_matinh != '01TTT') THEN
             l_s:= 'select max(serial) dem from ('||l_sql||')';
             EXECUTE IMMEDIATE l_s into l_count;
         END IF;
         /*Dang insert theo a.kythue, a.ma_tmuc,a.tentieumuc can kiem tra lai co luu theo chu ky khong */
         l_s:='INSERT INTO tax.phieu_offline(id, ma_tinh, mst, tienno, ngay_in,
                           nguoi_in,kythue,ma_tmuc,tentieumuc, ten_nnt,mota_diachi,ma_nv,mobile,seri,ky_hieu,chuky)
               select getseq(''PHIEU_OFFLINE_SEQ'') id, a.ma_tinh,a.mst,a.nocuoi,sysdate,
               '''||i_userId||''',a.kythue, a.ma_tmuc,a.tentieumuc, a.ten_nnt, a.mota_diachi,a.ma_nv,a.mobile,a.serial,a.pattern,a.chuky
               from ('||l_sql||') a';
         dbms_output.put_line(l_s);

         EXECUTE IMMEDIATE l_s;

         IF (i_matinh != '01TTT') THEN
             Execute immediate 'Update quaythus a set a.seri=:1, a.flag=:2,a.tg_gach= to_char(SYSDATE,''MM-YYYY'')
                                 where a.ma_tinh =:3
                                 and exists (select 1 from nguoigachnos b where b.id =:4 and a.id = b.quaythu_id)
                                 and rownum=1' Using l_count,l_flag,i_matinh,i_userid;
         END IF;
     ELSE
        l_sql:='SELECT  a.id, ma_tinh, a.mst, a.ma_nv, a.solan_in, a.tienno nocuoi, a.ngay_in,
                   a.nguoi_in, a.trang_thai, a.seri serial, a.ky_hieu pattern, a.kythue, a.ma_tmuc,
                   a.tentieumuc, a.ten_nnt, a.mota_diachi,a.mobile,d.ky ky_view,
                   '''||l_ten_dv||''' ten_dv, '''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv
                   FROM tax.phieu_offline a,tax.ck_thue d where  a.chuky=d.chuky';
        IF (i_chuky IS NOT NULL) AND (i_chuky!='null') THEN
             l_sql:=l_sql||' and a.kythue='''||i_chuky||''' ';
        END IF;
        IF (i_manv IS NOT NULL) AND (i_manv!='null') THEN
            l_sql:=l_sql||' and a.ma_nv='''||i_manv||'''';
        ELSIF (i_mst IS NOT NULL) AND (i_mst!='null') THEN
            l_sql:=l_sql||' and a.mst='''||i_mst||'''';
        ELSE
            l_sql:=l_sql||' and a.ma_tmuc='''||i_tieumuc||'''';
        END IF;
            l_sql:=l_sql||' order by a.mst,a.kythue,a.ma_tmuc';
        OPEN l_cur FOR l_sql;

        /*update so lan in*/
        l_sql:='update tax.phieu_offline a set a.solan_in=nvl(a.solan_in,0)+1 where 1=1';
        IF (i_chuky IS NOT NULL) AND (i_chuky!='null') THEN
             l_sql:=l_sql||' and a.kythue='''||i_chuky||''' ';
        END IF;
        IF (i_manv IS NOT NULL) AND (i_manv!='null') THEN
            l_sql:=l_sql||' and a.ma_nv='''||i_manv||'''';
        ELSIF (i_mst IS NOT NULL) AND (i_mst!='null') THEN
            l_sql:=l_sql||' and a.mst='''||i_mst||'''';
        ELSE
            l_sql:=l_sql||' and a.ma_tmuc='''||i_tieumuc||'''';
        END IF;
        EXECUTE IMMEDIATE l_sql;

     END if;
     o_cur:=l_cur;

        EXCEPTION WHEN OTHERS THEN
           ROLLBACK;
           open l_cur FOR SELECT  '' mst,'' ten_nnt,'' mota_diachi,'' kythue,'' nocuoi FROM dual;
            o_cur:=l_cur;

    END;
    FUNCTION get_data_pay(i_manv VARCHAR2,
                          i_mst VARCHAR2,
                          i_tieumuc VARCHAR2,
                          i_chuky VARCHAR2,
                          i_kyhieu VARCHAR2,
                          i_seri VARCHAR2,
                          i_tinh VARCHAR2,
                          i_typePage VARCHAR2,
                          i_pageNum VARCHAR2,
                          i_pageRec VARCHAR2,
                          i_userId VARCHAR2,
                          i_userIp VARCHAR2)
    RETURN sys_refcursor
    IS
        l_cur sys_refcursor;
        l_sql VARCHAR2(3000);
        ckn varchar2(100):=crud.ckn_hientai();
    BEGIN
        l_sql:='SELECT a.mst,a.ten_nnt,a.mobile,a.mota_diachi,b.kythue,b.nocuoi,b.trang_thai from tax.nnts_'||ckn||' a,
         (SELECT a.mst, a.kythue,a.trang_thai, sum(a.tienno) nocuoi FROM tax.phieu_offline a where 1=1';
        IF i_tinh IS NOT NULL THEN
            l_sql:= l_sql||' and a.ma_tinh='''||i_tinh||'''';
        END IF;
        IF i_manv IS NOT NULL THEN
            l_sql:= l_sql||' and a.ma_nv='''||i_manv||'''';
        END IF;
        IF i_mst IS NOT NULL THEN
            l_sql:= l_sql||' and a.mst='''||i_mst||'''';
        END IF;
        IF i_tieumuc IS NOT NULL THEN
            l_sql:= l_sql||' and exists (selec 1 from tax.phieu_offline b where a.mst=b.mst and b.ma_tmuc='''||i_tieumuc||''')';
        END IF;
        IF i_chuky IS NOT NULL THEN
            l_sql:= l_sql||' and a.kythue='''||i_chuky||'''';
        END IF;
        IF i_kyhieu IS NOT NULL THEN
            l_sql:= l_sql||' and a.ky_hieu='''||i_kyhieu||'''';
        END IF;
        IF i_seri IS NOT NULL THEN
            l_sql:= l_sql||' and a.seri='''||i_seri||'''';
        END IF;
        l_sql:= l_sql||' GROUP BY a.mst, a.kythue,a.trang_thai) b where a.mst=b.mst order by a.mst,b.kythue';
        dbms_output.put_line(l_sql);
        open l_cur FOR l_sql;
        /*if(i_typePage=2) then
            l_sql:='select ceil(count(*)/:1) nop,count(1) nor from ('||l_sql||')';
            open l_cur for l_sql using  i_pageRec;
        ELSIF (i_typePage=1) THEN
          open l_cur for util.xuly_phantrang(l_sql,i_pageNum,i_pageRec);
        end if;*/
        return l_cur;
        EXCEPTION WHEN OTHERS THEN
           open l_cur FOR SELECT  '' mst,'' ten_nnt,'' mota_diachi,'' kythue,'' nocuoi FROM dual;
            return l_cur;
    END;
    FUNCTION get_serial_value(i_userid VARCHAR2,
                              i_province VARCHAR2,
                              i_mst VARCHAR2)
    RETURN NUMBER
    IS
        l_serial NUMBER:=0;
        l_flag NUMBER;
        l_sql VARCHAR2(1000);
    BEGIN
        l_sql:='select b.seri +1,b.flag
                from nguoigachnos a, quaythus b where a.id =:1 and a.quaythu_id = b.id
                and a.ma_tinh = b.ma_tinh and a.ma_tinh =:2 and rownum =1';
        execute immediate l_sql into l_serial,l_flag using i_userid,i_province;
        If (l_flag =0) then
                l_serial := 1;
        End if;
        --Cap nhat du lieu seri theo to
        Execute immediate ' Update quaythus a set a.seri =:1, a.flag =:2
                                where a.ma_tinh =:3
                                and exists (select 1 from nguoigachnos b where b.id =:4 and a.id = b.quaythu_id)
                                and rownum=1' Using l_serial,l_flag,i_province,i_userid;
        RETURN l_serial;

    END ;
    FUNCTION del_off_bangphieutra(
        pId varchar2,
        pUserId varchar2,
        pUserIp varchar2)
    return varchar2
    IS
    l_sql VARCHAR2(30000);
    l_s VARCHAR2(30000);
    BEGIN
        l_sql:=crud.del_bangphieutra(pId,pUserId,pUserIp);
        IF l_sql='1' THEN
            l_s:='UPDATE tax.phieu_offline
            SET trang_thai =0, phieu_id=0
            WHERE phieu_id =:pId';
            EXECUTE IMMEDIATE l_s USING pId;
            commit;

        END IF;
         RETURN l_sql;
    END;
    FUNCTION check_data_pay(i_listData VARCHAR2,
                            i_province VARCHAR2,
                            i_UserId varchar2,
                            i_UserIp varchar2)
    RETURN VARCHAR2
    IS
       l_sql VARCHAR2(30000);
       l_tra_cn util.StringArray;
       l_str VARCHAR2(1000);
       l_stt NUMBER;
       l_cur sys_refcursor;
       l_sum NUMBER;
       l_sum_now NUMBER;
       l_err_list VARCHAR2(32000);
    BEGIN
        l_cur:=util.FSTR_TO_DROWS(i_listData,'|');
        LOOP
            FETCH l_cur INTO l_stt,l_str;
            EXIT WHEN l_cur%notfound;
            l_tra_cn:=util.str_to_array(l_str,',');
            l_sql:='SELECT sum(tienno) nocuoi FROM tax.phieu_offline WHERE mst=:1 AND kythue=:2';
            EXECUTE IMMEDIATE l_sql INTO l_sum USING l_tra_cn(1), l_tra_cn(2);
            l_sql:='SELECT nvl(SUM (nocuoi),0) nocuoi FROM (
                    SELECT no_cuoi_ky nocuoi FROM tax.ct_no_2016 WHERE mst=:1 AND kythue=:2
                    UNION ALL
                    SELECT  -tientra nocuoi FROM tax.ct_tra_2016 WHERE mst=:3 AND kythue=:4)';
            EXECUTE IMMEDIATE l_sql INTO l_sum_now USING l_tra_cn(1), l_tra_cn(2),l_tra_cn(1), l_tra_cn(2);

            IF l_sum <> l_sum_now THEN
                l_err_list:=l_str||'|';
            END IF;
        END LOOP;
        IF LENGTH(l_err_list) > 1 THEN
            l_err_list:=substr(l_err_list,1,LENGTH(l_err_list)-1);
            RETURN l_err_list;
        ELSE
            RETURN '1';
        END IF;

        EXCEPTION WHEN OTHERS THEN
        RETURN '0';
    END;
    FUNCTION pay_offline(i_listData VARCHAR2,
                         i_ma_tinh VARCHAR2,
                         i_ma_bc VARCHAR2,
                         i_quaythu VARCHAR2,
                         i_UserId varchar2,
                         i_UserIp varchar2)
    RETURN VARCHAR2
    IS
       l_sql VARCHAR2(30000);
       l_tra_cn util.StringArray;
       l_str VARCHAR2(1000);
       l_stt NUMBER;
       l_cur sys_refcursor;
       l_cur_ins sys_refcursor;
       l_ins_list VARCHAR2(32000);
       l_re VARCHAR2(32000):='1';
       l_httt VARCHAR2(10):='7';
       ckn varchar2(100):=crud.ckn_hientai();
       l_sum NUMBER;
       l_sum_now NUMBER;
       l_err_list VARCHAR2(32000);
    BEGIN
        l_cur:=util.FSTR_TO_DROWS(i_listData,'|');
        LOOP
            FETCH l_cur INTO l_stt,l_str;
            EXIT WHEN l_cur%notfound;
            l_tra_cn:=util.str_to_array(l_str,',');
            l_sql:='SELECT sum(tienno) nocuoi FROM tax.phieu_offline WHERE mst=:1 AND kythue=:2';
            EXECUTE IMMEDIATE l_sql INTO l_sum USING l_tra_cn(1), l_tra_cn(2);
            l_sql:='SELECT nvl(SUM (nocuoi),0) nocuoi FROM (
                    SELECT no_cuoi_ky nocuoi FROM tax.ct_no_2016 WHERE mst=:1 AND kythue=:2
                    UNION ALL
                    SELECT  -tientra nocuoi FROM tax.ct_tra_2016 WHERE mst=:3 AND kythue=:4)';
            EXECUTE IMMEDIATE l_sql INTO l_sum_now USING l_tra_cn(1), l_tra_cn(2),l_tra_cn(1), l_tra_cn(2);
            IF l_sum = l_sum_now THEN
                l_ins_list:=util.rows_to_str('SELECT a.mst||'',''||a.kythue||'',''||a.ma_tinh||'',''||a.tienno||'',''||b.ma_chuong||'',''||b.ma_cq_thu||'',''||b.ma_tmuc||'',''||b.so_taikhoan_co||'',''||
                            b.so_qdinh||'',''||b.ngay_qdinh||'',''||b.loai_tien||'',''||b.ti_gia||'',''||b.loai_thue||'',''||a.chuky ins_data
                            FROM tax.phieu_offline a,(SELECT DISTINCT ma_chuong,ma_cq_thu,ma_tmuc,so_taikhoan_co,
                            so_qdinh,ngay_qdinh,loai_tien,ti_gia,loai_thue,chuky,mst,kythue,ma_tinh
                            FROM tax.ct_no_'||ckn||' WHERE mst='''||l_tra_cn(1)||''' AND kythue='''||l_tra_cn(2)||''') b
                            WHERE a.mst=b.mst AND a.kythue=b.kythue AND a.chuky=b.chuky
                            AND a.ma_tmuc=b.ma_tmuc','|');

                l_re:= crud.thanh_toan(l_tra_cn(1), i_ma_tinh,i_ma_bc, l_httt,i_UserId, '', i_quaythu, l_ins_list);
            END IF;
        END LOOP;
        RETURN '1';
    END;

   -- Enter further code below as specified in the Package spec.
END;

/
