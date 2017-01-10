--------------------------------------------------------
--  File created - Tuesday-January-10-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body EXPORT_DATA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "TAX"."EXPORT_DATA" 
IS
FUNCTION get_staff_by_user(i_agent VARCHAR2,
                               i_userid VARCHAR2,
                               i_userip VARCHAR2 )
    return sys_refcursor
    IS
        c_cur sys_refcursor;
        l_sql VARCHAR2(1000);
        l_cqt_tms VARCHAR2(20);
    BEGIN
        l_sql:='SELECT nvl(cqt_tms,''0'') cqt_tms FROM  user_info WHERE id=:1 ';
        EXECUTE IMMEDIATE l_sql INTO l_cqt_tms USING i_userid;
        IF l_cqt_tms='0' THEN
            l_sql:='SELECT id,hovaten name FROM nguoigachnos WHERE ma_tinh=:2';
            OPEN c_cur FOR l_sql USING i_agent;
        ELSE
            l_sql:='SELECT id,hovaten name FROM nguoigachnos a WHERE ma_tinh=:1 and EXISTS (SELECT 1 FROM user_info b WHERE a.id=b.id AND b.cqt_tms=:2)';
            OPEN c_cur FOR l_sql USING i_agent,l_cqt_tms;
        END IF;
        RETURN c_cur;
        EXCEPTION WHEN OTHERS THEN
            OPEN c_cur FOR 'select '''' id, '''' name from dual where 0>1';
            RETURN c_cur;


    END;
    FUNCTION export_data_fkey(i_dateFrom VARCHAR2,
                              i_dateTo VARCHAR2,
                              i_month VARCHAR2,
                              i_unit VARCHAR2,
                              i_agent VARCHAR2,
                              i_staff VARCHAR2,
                              i_userid VARCHAR2,
                              i_userip VARCHAR2)
    RETURN sys_refcursor
    IS
        c_cur sys_refcursor;
        l_sql VARCHAR2(1000);
        l_cqt_tms VARCHAR2(20);
        ckn varchar2(100):=crud.ckn_hientai();
    BEGIN
        l_sql:='SELECT taxcode,fkey,numb_bill,log_date,b.ma_nv
                FROM tax.hddts a, tax.bangphieutra_'||ckn||' tra,tax.nnts_'||ckn||' b WHERE
                a.bill = tra.id and a.taxcode=tra.mst
                and exists (select 1 from tax.ct_tra_2016 xx where tra.id= xx.phieu_id and b.ma_cqt_ql=xx.ma_cq_thu)
                and a.taxcode=b.mst AND b.ma_tinh='''||i_agent||'''
                and not EXISTS (SELECT 1 FROM tax.phieuhuys ph WHERE a.bill=ph.id and a.taxcode=ph.mst)';
        IF i_dateFrom IS NOT NULL THEN
            l_sql:= l_sql||' and a.log_date  >= to_date('''||i_dateFrom||''',''DD/MM/YYYY'')';
        END IF;
        IF i_dateTo IS NOT NULL THEN
            l_sql:= l_sql||' and a.log_date  < to_date('''||i_dateTo||''',''DD/MM/YYYY'') +1';
        END IF;
        IF i_month IS NOT NULL THEN
            l_sql:= l_sql||' AND EXISTS (SELECT 1 FROM tax.bangphieutra_'||ckn||' h WHERE a.taxcode=h.mst AND a.bill=h.id
            and exists (select 1 from tax.ct_tra_'||ckn||' x where h.mst=x.mst and h.id=x.phieu_id and x.kythue ='''||i_month||''' ))';
        END IF;
        IF i_unit IS NOT NULL THEN
            l_sql:= l_sql||' AND EXISTS(SELECT 1 FROM tax.nnts_'||ckn||' g WHERE a.taxcode=g.mst AND EXISTS(SELECT 1 FROM tax.coquanthus d WHERE g.ma_cqt_ql=d.cqt_tms AND d.shkb='''||i_unit||'''))';
        END IF;
        IF i_staff IS NOT NULL THEN
            l_sql:= l_sql||' AND EXISTS (SELECT 1 FROM tax.bangphieutra_'||ckn||' c WHERE a.taxcode=c.mst AND a.bill=c.id AND c.nguoigachno_id='''||i_staff||''')';
        END IF;
            l_sql:= l_sql || ' order by taxcode,log_date';
        OPEN c_cur FOR l_sql;
        RETURN c_cur;
        EXCEPTION WHEN OTHERS THEN
            OPEN c_cur FOR 'SELECT '''' taxcode,'''' fkey,'''' numb_bill,'''' log_date from dual';
            RETURN c_cur;
    END;

   -- Enter further code below as specified in the Package spec.
END;

/
