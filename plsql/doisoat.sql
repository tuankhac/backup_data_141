--------------------------------------------------------
--  File created - Tuesday-January-10-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body DOISOAT
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "TAX"."DOISOAT" 
IS
PROCEDURE ds_doisoat_monbai(i_quy IN  VARCHAR2,
                            i_nam IN VARCHAR2,
                            i_donvi IN VARCHAR2,
                            i_tinh IN VARCHAR2,
                            o_ds OUT SYS_REFCURSOR)
IS
l_sql VARCHAR2(1000);
c_cur SYS_REFCURSOR;

BEGIN
    l_sql:='select nam,thang,ho_ps, ho_thang_truoc, ho_quy_truoc , (ho_ps+ho_thang_truoc) ho_no,
    ((ho_ps+ho_thang_truoc) - ho_quy_truoc) ho_thu,
    decode(ho_ps+ho_thang_truoc,0,0,ROUND((((ho_ps+ho_thang_truoc) - ho_quy_truoc)*100/(ho_ps+ho_thang_truoc)),2)) ty_le FROM (
    SELECT nam,thang,ma_kb,sum(ho_ps) ho_ps, sum(ho_thang_truoc) ho_thang_truoc, SUM(ho_quy_truoc) ho_quy_truoc, sum(ho_cuoi_thang) ho_cuoi_thang
    FROM bc_doisoat_monbai WHERE quy=:1 AND nam=:2 AND ma_tinh =:3';
    IF i_donvi IS NOT NULL THEN
         l_sql:=l_sql|| ' and ma_kb='||i_donvi;
    END IF;
     l_sql:=l_sql|| ' GROUP BY nam,thang,ma_kb) ORDER BY thang';

    OPEN c_cur FOR l_sql USING i_quy, i_nam,i_tinh;
    o_ds:=c_cur;
    EXCEPTION WHEN OTHERS THEN
        OPEN c_cur FOR 'select '''||SQLERRM||''' err from dual';
        o_ds:=c_cur;

END;
PROCEDURE ds_doisoat_thuekhoan(i_quy IN  VARCHAR2,
                            i_nam IN VARCHAR2,
                            i_donvi IN VARCHAR2,
                            i_tinh IN VARCHAR2,
                            o_ds OUT SYS_REFCURSOR)
IS
l_sql VARCHAR2(1000);
c_cur SYS_REFCURSOR;

BEGIN
    l_sql:='SELECT b.nam,b.quy,b.ma_kb,b.ho_ps, b.ho_quy_truoc ho_no,
            (b.ho_ps - b.ho_quy_truoc) ho_thu,
            decode(b.ho_ps,0,0, ROUND(((b.ho_ps - b.ho_quy_truoc)*100/b.ho_ps),2)) ty_le FROM
            (SELECT nam,quy,ma_kb, sum(ho_ps) ho_ps, SUM (ho_quy_truoc) ho_quy_truoc, sum(ho_cuoi_quy) ho_cuoi_quy
            FROM bc_doisoat_thuekhoan where quy=:1 and nam=:2 and ma_tinh=:3';
    IF i_donvi IS NOT NULL THEN
         l_sql:=l_sql|| ' and ma_kb='||i_donvi;
    END IF;
     l_sql:=l_sql|| ' GROUP BY nam,quy,ma_kb) b';

    OPEN c_cur FOR l_sql USING i_quy, i_nam,i_tinh;
    o_ds:=c_cur;
    EXCEPTION WHEN OTHERS THEN
        OPEN c_cur FOR 'select '''||SQLERRM||''' err from dual';
        o_ds:=c_cur;

END;
PROCEDURE ds_doisoat_thuetroi(i_quy IN  VARCHAR2,
                            i_nam IN VARCHAR2,
                            i_donvi IN VARCHAR2,
                            i_tinh IN VARCHAR2,
                            o_ds OUT SYS_REFCURSOR)
IS
l_sql VARCHAR2(1000);
c_cur SYS_REFCURSOR;

BEGIN
    l_sql:='select nam,thang,ho_ps, ho_thang_truoc,(ho_ps+ho_thang_truoc) ho_no,ho_cuoi_thang,
    ((ho_ps+ho_thang_truoc) - ho_cuoi_thang) ho_thu,
    decode((ho_ps+ho_thang_truoc),0,0,round((((ho_ps+ho_thang_truoc) - ho_cuoi_thang)*100/(ho_ps+ho_thang_truoc)),2)) ty_le FROM (
    SELECT nam,thang,ma_kb,sum(ho_ps) ho_ps, sum(ho_thang_truoc) ho_thang_truoc, SUM(ho_cuoi_thang) ho_cuoi_thang
    FROM bc_doisoat_thuetroi WHERE quy=:1 AND nam=:2 AND ma_tinh =:3';
    IF i_donvi IS NOT NULL THEN
         l_sql:=l_sql|| ' and ma_kb='||i_donvi;
    END IF;
     l_sql:=l_sql|| ' GROUP BY nam,thang,ma_kb) ORDER BY thang';

    OPEN c_cur FOR l_sql USING i_quy, i_nam,i_tinh;
    o_ds:=c_cur;
    EXCEPTION WHEN OTHERS THEN
        OPEN c_cur FOR 'select '''||SQLERRM||''' err from dual';
        o_ds:=c_cur;

END;
FUNCTION set_data_monbai(i_quy IN  VARCHAR2,
                         i_nam IN VARCHAR2,
                         i_matinh IN VARCHAR2)
RETURN VARCHAR2
IS
l_sql VARCHAR2(5000);
c_cur SYS_REFCURSOR;
l_count NUMBER;
l_s VARCHAR2(5000);

BEGIN
    l_sql:='select count(1) from bc_doisoat_monbai where quy=:1 and nam=:2';
    EXECUTE IMMEDIATE l_sql INTO l_count USING i_quy,i_nam;
    IF l_count > 0 THEN
        l_sql:='delete from bc_doisoat_monbai where quy=:1 and nam=:2';
        EXECUTE IMMEDIATE l_sql  USING i_quy,i_nam;
    END IF;
    l_sql:=set_data_monbai_quytruoc(i_quy,i_nam,i_matinh);
    IF l_sql ='1' THEN
        l_s:=set_data_monbai_ps(i_quy,i_nam,i_matinh);
        l_s:=set_data_monbai_thangtruoc(i_quy,i_nam,i_matinh);
        RETURN '1';
    ELSE
        RETURN 'ERR:'||l_sql;
    END IF;
    EXCEPTION WHEN OTHERS THEN
        RETURN '0:'||SQLERRM;

END ;


FUNCTION set_data_monbai_quytruoc(i_quy IN  VARCHAR2,
                         i_nam IN VARCHAR2,
                         i_matinh IN VARCHAR2)
RETURN VARCHAR2
IS
l_sql VARCHAR2(1000);
l_count NUMBER;
l_thang_1 NUMBER:=get_month_from_quarter(1,i_quy);
l_thang_2 NUMBER:=get_month_from_quarter(2,i_quy);
l_thang_3 NUMBER:=get_month_from_quarter(3,i_quy);
l_quy_previous NUMBER;
l_nam_previous NUMBER;
l_kythue_1 VARCHAR2(20);
l_kythue_2 VARCHAR2(20);
l_kythue_3 VARCHAR2(20);
ckn varchar2(100):= crud.ckn_hientai;
BEGIN
   -- get_quarter_previous(i_quy=>i_quy, i_nam=>i_nam, o_quy=>l_quy_previous, o_nam=>l_nam_previous);
    IF LENGTH(l_thang_1) =1 THEN l_kythue_1:='0'||TO_CHAR(l_thang_1)||i_nam; ELSE l_kythue_1:=TO_CHAR(l_thang_1)||i_nam; END IF;
    IF LENGTH(l_thang_2) =1 THEN l_kythue_2:='0'||TO_CHAR(l_thang_2)||i_nam; ELSE l_kythue_2:=TO_CHAR(l_thang_2)||i_nam; END IF;
    IF LENGTH(l_thang_3) =1 THEN l_kythue_3:='0'||TO_CHAR(l_thang_3)||i_nam; ELSE l_kythue_3:=TO_CHAR(l_thang_3)||i_nam; END IF;
    l_sql:='truncate table bc_doisoat_tmp';
    EXECUTE IMMEDIATE l_sql;
    l_sql:='INSERT INTO bc_doisoat_tmp(mst,no_cuoi,type_id,ky_thue)
    SELECT mst, sum(no_cuoi) no_cuoi,1,:1  FROM (
    SELECT a.mst,a.ma_tmuc,a.no_cuoi_ky no_cuoi FROM ct_no_'||ckn||' a  WHERE a.kythue=:2 AND a.ma_tinh=:3 AND a.ma_tmuc IN (1801, 1802,1803,1804,1805,1806)
    AND mst NOT IN ( SELECT b.mst FROM ct_tra_'||ckn||' b WHERE b.kythue=:4 AND b.ma_tinh=:5 AND a.ma_tmuc IN (1801, 1802,1803,1804,1805,1806)
    and EXISTS (SELECT 1 FROM bangphieutra_'||ckn||' c
    WHERE b.phieu_id =c.id AND c.ngay_tt < LAST_DAY(to_Date(:6,''MMYYYY''))+1))
    UNION ALL
    SELECT a.mst,a.ma_tmuc,-a.tientra no_cuoi FROM ct_tra_'||ckn||' a  WHERE a.kythue=:7 AND a.ma_tinh=:8 AND a.ma_tmuc IN (1801, 1802,1803,1804,1805,1806)
    AND mst NOT IN ( SELECT b.mst FROM ct_tra_'||ckn||' b WHERE b.kythue=:9 AND b.ma_tinh=:10 AND a.ma_tmuc IN (1801, 1802,1803,1804,1805,1806)
    and EXISTS (SELECT 1 FROM bangphieutra_'||ckn||' c
    WHERE b.phieu_id =c.id AND c.ngay_tt < LAST_DAY(to_Date(:11,''MMYYYY''))+1))) group BY mst';
    EXECUTE IMMEDIATE l_sql USING l_kythue_1,l_kythue_1,i_matinh,l_kythue_1,i_matinh,l_kythue_1,l_kythue_1,i_matinh,l_kythue_1,i_matinh,l_kythue_1;
    EXECUTE IMMEDIATE l_sql USING l_kythue_2,l_kythue_2,i_matinh,l_kythue_2,i_matinh,l_kythue_2,l_kythue_2,i_matinh,l_kythue_2,i_matinh,l_kythue_2;
    EXECUTE IMMEDIATE l_sql USING l_kythue_3,l_kythue_3,i_matinh,l_kythue_3,i_matinh,l_kythue_3,l_kythue_3,i_matinh,l_kythue_3,i_matinh,l_kythue_3;
     l_sql:='insert into bc_doisoat_monbai(thang,quy,nam,ma_kb,ma_tinh)
     SELECT :1 thang,:2 quy,:3 nam,shkb,:4 tinh from (select distinct b.shkb
     FROM nnts_'||ckn||' a,  coquanthus b where a.ma_cqt_ql =b.cqt_tms
            AND a.ma_tinh=b.ma_tinh AND b.ma_tinh=:5)';

    EXECUTE IMMEDIATE l_sql USING l_thang_1,i_quy,i_nam,i_matinh,i_matinh;
    EXECUTE IMMEDIATE l_sql USING l_thang_2,i_quy,i_nam,i_matinh,i_matinh;
    EXECUTE IMMEDIATE l_sql USING l_thang_3,i_quy,i_nam,i_matinh,i_matinh;

    l_sql:='update bc_doisoat_monbai a set a.ho_quy_truoc = nvl((select dem from (
            SELECT count(1) dem,c.shkb FROM bc_doisoat_tmp a,(SELECT mst,sum(no_cuoi) no_cuoi FROM
        conver_debt_quarter WHERE  ma_tmuc IN (1801,1802,1803,1804,1805,1806) and quy=:1 and nam=:2 GROUP BY mst )  b,
        (SELECT a.mst,b.shkb FROM nnts_'||ckn||' a,  coquanthus b where a.ma_cqt_ql =b.cqt_tms
            AND a.ma_tinh=b.ma_tinh AND b.ma_tinh=:3) c
         WHERE a.mst=b.mst AND a.mst=c.mst and a.type_id=1 and ky_thue=:4 AND (a.no_cuoi - b.no_cuoi) >0 GROUP BY c.shkb)
         where a.ma_kb=shkb),0)
         where thang=:5 and quy=:6 and nam=:7';

    EXECUTE IMMEDIATE l_sql USING TO_NUMBER(i_quy),TO_NUMBER(i_nam),i_matinh,l_kythue_1,TO_NUMBER(i_quy),l_thang_1,TO_NUMBER(i_nam);
    EXECUTE IMMEDIATE l_sql USING TO_NUMBER(i_quy),TO_NUMBER(i_nam),i_matinh,l_kythue_1,TO_NUMBER(i_quy),l_thang_1,TO_NUMBER(i_nam);
    EXECUTE IMMEDIATE l_sql USING TO_NUMBER(i_quy),TO_NUMBER(i_nam),i_matinh,l_kythue_1,TO_NUMBER(i_quy),l_thang_1,TO_NUMBER(i_nam);
    COMMIT;
    RETURN '1';
    EXCEPTION WHEN OTHERS THEN
        RETURN '0:'||SQLERRM;
END;
FUNCTION set_data_monbai_ps(i_quy IN  VARCHAR2,
                         i_nam IN VARCHAR2,
                         i_matinh IN VARCHAR2)
RETURN VARCHAR2
IS
l_sql VARCHAR2(1000);
l_count NUMBER;
l_thang_1 NUMBER:=get_month_from_quarter(1,i_quy);
l_thang_2 NUMBER:=get_month_from_quarter(2,i_quy);
l_thang_3 NUMBER:=get_month_from_quarter(3,i_quy);
l_kythue_1 VARCHAR2(20);
l_kythue_2 VARCHAR2(20);
l_kythue_3 VARCHAR2(20);
l_quy_previous NUMBER;
l_nam_previous NUMBER;
ckn varchar2(100):= crud.ckn_hientai;
BEGIN
    IF LENGTH(l_thang_1) =1 THEN l_kythue_1:='0'||TO_CHAR(l_thang_1)||i_nam; ELSE l_kythue_1:=TO_CHAR(l_thang_1)||i_nam; END IF;
    IF LENGTH(l_thang_2) =1 THEN l_kythue_2:='0'||TO_CHAR(l_thang_2)||i_nam; ELSE l_kythue_2:=TO_CHAR(l_thang_2)||i_nam; END IF;
    IF LENGTH(l_thang_3) =1 THEN l_kythue_3:='0'||TO_CHAR(l_thang_3)||i_nam; ELSE l_kythue_3:=TO_CHAR(l_thang_3)||i_nam; END IF;
    l_sql:='UPDATE bc_doisoat_monbai a SET ho_ps= nvl((SELECT dem FROM (
            SELECT shkb, count(1) dem FROM (
            SELECT DISTINCT a.mst, nvl(b.shkb,''0'') shkb FROM ct_no_'||ckn||' a,
            (SELECT a.mst,b.shkb,a.ma_tinh FROM nnts_'||ckn||' a,  coquanthus b
            WHERE a.ma_cqt_ql =b.cqt_tms AND a.ma_tinh=b.ma_tinh AND b.ma_tinh=:1) b WHERE a.mst=b.mst(+)
            AND a.ma_tinh=b.ma_tinh AND a.ma_tmuc IN (1801, 1802,1803,1804,1805,1806)
            AND a.kythue=:2) GROUP BY shkb) WHERE a.ma_kb=shkb),0)
            WHERE  thang=:3 AND nam=:4 and ma_tinh=:5';

    EXECUTE IMMEDIATE l_sql USING i_matinh,l_kythue_1,l_thang_1,i_nam,i_matinh;
    EXECUTE IMMEDIATE l_sql USING i_matinh,l_kythue_2,l_thang_2,i_nam,i_matinh;
    EXECUTE IMMEDIATE l_sql USING i_matinh,l_kythue_3,l_thang_3,i_nam,i_matinh;
    COMMIT;
    RETURN '1';
    EXCEPTION WHEN OTHERS THEN
         RETURN '0:'||SQLERRM;
END;
FUNCTION set_data_monbai_cuoithang(i_quy IN  VARCHAR2,
                                 i_nam IN VARCHAR2,
                                 i_matinh IN VARCHAR2)
RETURN VARCHAR2
IS
l_sql VARCHAR2(1000);
l_count NUMBER;
l_thang_1 NUMBER:=get_month_from_quarter(1,i_quy);
l_thang_2 NUMBER:=get_month_from_quarter(2,i_quy);
l_thang_3 NUMBER:=get_month_from_quarter(3,i_quy);
l_kythue_1 VARCHAR2(20);
l_kythue_2 VARCHAR2(20);
l_kythue_3 VARCHAR2(20);
l_quy_previous NUMBER;
l_nam_previous NUMBER;
ckn varchar2(100):= crud.ckn_hientai;
BEGIN
    IF LENGTH(l_thang_1) =1 THEN l_kythue_1:='0'||TO_CHAR(l_thang_1)||i_nam; ELSE l_kythue_1:=TO_CHAR(l_thang_1)||i_nam; END IF;
    IF LENGTH(l_thang_2) =1 THEN l_kythue_2:='0'||TO_CHAR(l_thang_2)||i_nam; ELSE l_kythue_2:=TO_CHAR(l_thang_2)||i_nam; END IF;
    IF LENGTH(l_thang_3) =1 THEN l_kythue_3:='0'||TO_CHAR(l_thang_3)||i_nam; ELSE l_kythue_3:=TO_CHAR(l_thang_3)||i_nam; END IF;
    l_sql:='UPDATE bc_doisoat_monbai a SET ho_cuoi_thang= nvl((SELECT dem FROM (
        SELECT shkb, count(1) dem FROM (
        SELECT DISTINCT a.mst, nvl(b.shkb,''0'') shkb FROM (SELECT a.* FROM ct_no_'||ckn||' a  WHERE a.kythue=:1 AND a.ma_tinh=:2
        AND mst NOT IN ( SELECT b.mst FROM ct_tra_'||ckn||' b WHERE b.kythue=:3 AND b.ma_tinh=:4
        and EXISTS (SELECT 1 FROM bangphieutra_'||ckn||' c WHERE b.phieu_id =c.id AND c.ngay_tt < LAST_DAY(to_Date(:5,''MMYYYY''))+1))
        ) a,
        (SELECT a.mst,b.shkb FROM nnts_'||ckn||' a,  coquanthus b
        WHERE a.ma_cqt_ql =b.cqt_tms AND a.ma_tinh=b.ma_tinh AND b.ma_tinh=:6 ) b WHERE a.mst=b.mst(+) AND a.ma_tmuc IN (1801, 1802,1803,1804,1805,1806)
        AND a.kythue=:7) GROUP BY shkb) WHERE a.ma_kb=shkb),0)
        WHERE thang=:8 AND nam=:9 and ma_tinh=:10';

    EXECUTE IMMEDIATE l_sql USING l_kythue_1,i_matinh,l_kythue_1,i_matinh,l_kythue_1,i_matinh,l_kythue_1,l_thang_1,i_nam,i_matinh;
    EXECUTE IMMEDIATE l_sql USING l_kythue_2,i_matinh,l_kythue_2,i_matinh,l_kythue_2,i_matinh,l_kythue_2,l_thang_2,i_nam,i_matinh;
    EXECUTE IMMEDIATE l_sql USING l_kythue_3,i_matinh,l_kythue_3,i_matinh,l_kythue_3,i_matinh,l_kythue_3,l_thang_3,i_nam,i_matinh;
    COMMIT;
    RETURN '1';
    EXCEPTION WHEN OTHERS THEN
         RETURN '0:'||SQLERRM;
END;
FUNCTION set_data_monbai_thangtruoc(i_quy IN  VARCHAR2,
                                 i_nam IN VARCHAR2,
                                 i_matinh IN VARCHAR2)
RETURN VARCHAR2
IS
l_sql VARCHAR2(1000);
l_count NUMBER;
l_thang_1 NUMBER:=get_month_from_quarter(1,i_quy);
l_thang_2 NUMBER:=get_month_from_quarter(2,i_quy);
l_thang_3 NUMBER:=get_month_from_quarter(3,i_quy);
l_thang_1_pre NUMBER;
l_thang_2_pre NUMBER;
l_thang_3_pre NUMBER;
l_nam_1_pre NUMBER;
l_nam_2_pre NUMBER;
l_nam_3_pre NUMBER;
l_quy_previous NUMBER;
l_nam_previous NUMBER;
ckn varchar2(100):= crud.ckn_hientai;
BEGIN
    get_month_previous(l_thang_1,TO_NUMBER(i_nam),l_thang_1_pre,l_nam_1_pre);
    get_month_previous(l_thang_2,TO_NUMBER(i_nam),l_thang_2_pre,l_nam_2_pre);
    get_month_previous(l_thang_3,TO_NUMBER(i_nam),l_thang_3_pre,l_nam_3_pre);

     l_sql:='update bc_doisoat_monbai a set ho_thang_truoc =0
    where a.thang=:3 and a.nam=:4 and a.ma_tinh=:5';
    EXECUTE IMMEDIATE l_sql USING l_thang_1,TO_NUMBER(i_nam),i_matinh;

    l_sql:='update bc_doisoat_monbai a set ho_thang_truoc =nvl((select ho_quy_truoc thangtruoc from bc_doisoat_monbai b
    where a.ma_tinh=b.ma_tinh and a.ma_kb=b.ma_kb and b.thang=:1 and b.nam=:2),0)
    where a.thang=:3 and a.nam=:4 and a.ma_tinh=:5';

    EXECUTE IMMEDIATE l_sql USING l_thang_2_pre,l_nam_2_pre,l_thang_2,TO_NUMBER(i_nam),i_matinh;
    EXECUTE IMMEDIATE l_sql USING l_thang_3_pre,l_nam_3_pre,l_thang_3,TO_NUMBER(i_nam),i_matinh;

    COMMIT;
    RETURN '1';
    EXCEPTION WHEN OTHERS THEN
         RETURN '0:'||SQLERRM;
END;
PROCEDURE get_quarter_previous(i_quy IN  VARCHAR2,
                               i_nam IN VARCHAR2,
                               o_quy OUT NUMBER,
                               o_nam OUT NUMBER)
IS
BEGIN
    IF TO_NUMBER(i_quy) <=1 THEN
        o_quy:= 4;
        o_nam:= TO_NUMBER(i_nam) -1;
    ELSE
        o_quy:= TO_NUMBER(i_quy) -1;
        o_nam:= TO_NUMBER(i_nam);
    END IF;
END;
PROCEDURE get_month_previous(i_thang IN  NUMBER,
                             i_nam IN NUMBER,
                             o_thang OUT NUMBER,
                             o_nam OUT NUMBER)
IS
BEGIN
    IF i_thang <=1 THEN
        o_thang:= 12;
        o_nam:= i_nam -1;
    ELSE
        o_thang:= i_thang -1;
        o_nam:= i_nam;
    END IF;
END;
FUNCTION get_month_from_quarter(i_location NUMBER, i_quarter NUMBER)
RETURN NUMBER
IS
BEGIN
    IF i_quarter =1 THEN
        IF i_location = 1 THEN
            RETURN 1;
        ELSIF i_location =2 THEN
            RETURN 2;
        ELSIF i_location =3 THEN
            RETURN 3;
        ELSE
            RETURN 0;
        END IF;
    ELSIF i_quarter =2 THEN
        IF i_location = 1 THEN
            RETURN 4;
        ELSIF i_location =2 THEN
            RETURN 5;
        ELSIF i_location =3 THEN
            RETURN 6;
        ELSE
            RETURN 0;
        END IF;
    ELSIF i_quarter =3 THEN
        IF i_location = 1 THEN
            RETURN 7;
        ELSIF i_location =2 THEN
            RETURN 8;
        ELSIF i_location =3 THEN
            RETURN 9;
        ELSE
            RETURN 0;
        END IF;
    ELSIF i_quarter =4 THEN
        IF i_location = 1 THEN
            RETURN 10;
        ELSIF i_location =2 THEN
            RETURN 11;
        ELSIF i_location =3 THEN
            RETURN 12;
        ELSE
            RETURN 0;
        END IF;
    ELSE
        RETURN 0;
    END IF;
END;
FUNCTION set_data_thuekhoan(i_quy IN  VARCHAR2,
                         i_nam IN VARCHAR2,
                         i_matinh IN VARCHAR2)
RETURN VARCHAR2
IS
l_sql VARCHAR2(5000);
c_cur SYS_REFCURSOR;
l_count NUMBER;
l_s VARCHAR2(5000);
BEGIN
     l_sql:='select count(1) from bc_doisoat_thuekhoan where quy=:1 and nam=:2';
    EXECUTE IMMEDIATE l_sql INTO l_count USING i_quy,i_nam;
    IF l_count > 0 THEN
        l_sql:='delete from bc_doisoat_thuekhoan where quy=:1 and nam=:2';
        EXECUTE IMMEDIATE l_sql  USING i_quy,i_nam;
    END IF;
    l_sql:=set_data_thuekhoan_quytruoc(i_quy,i_nam,i_matinh);
    IF l_sql ='1' THEN
        l_s:=set_data_thuekhoan_ps(i_quy,i_nam,i_matinh);

        RETURN '1';
    ELSE
        RETURN 'ERR:'||l_sql;
    END IF;
    EXCEPTION WHEN OTHERS THEN
        RETURN '0:'||SQLERRM;
END;
FUNCTION set_data_thuekhoan_quytruoc(i_quy IN  VARCHAR2,
                         i_nam IN VARCHAR2,
                         i_matinh IN VARCHAR2)
RETURN VARCHAR2
IS
l_sql VARCHAR2(5000);
l_dskythue  VARCHAR2(5000):=get_cricle_debt(i_quy,i_nam);
l_kycuoi VARCHAR2(5000);
ckn varchar2(100):= crud.ckn_hientai;
BEGIN
    if i_quy ='1' THEN l_kycuoi:='03'||i_nam;
    ELSIF i_quy ='2' THEN l_kycuoi:='06'||i_nam;
    ELSIF i_quy ='3' THEN l_kycuoi:='09'||i_nam;
    ELSIF i_quy ='4' THEN l_kycuoi:='12'||i_nam; END IF;
    l_dskythue:=REPLACE(l_dskythue,',',''',''');
    l_sql:='insert into bc_doisoat_thuekhoan(quy,nam,ma_kb,ma_tinh)
    SELECT :2 quy,:3 nam,shkb,:4 tinh from (select distinct b.shkb
    FROM nnts_'||ckn||' a,  coquanthus b where a.ma_cqt_ql =b.cqt_tms
            AND a.ma_tinh=b.ma_tinh AND b.ma_tinh=:5)';
    EXECUTE IMMEDIATE l_sql USING i_quy,i_nam,i_matinh,i_matinh;

     l_sql:='truncate table bc_doisoat_tmp';
    EXECUTE IMMEDIATE l_sql;
    l_sql:='INSERT INTO bc_doisoat_tmp(mst,no_cuoi,type_id,ky_thue)
            SELECT mst, sum(nocuoi) no_cuoi,2,:1 FROM (
            SELECT kythue,mst, no_cuoi_ky nocuoi FROM ct_no_'||ckn||' WHERE kythue in ('''||l_dskythue||''') AND ma_tinh=:2
            AND ma_tmuc not IN (1801, 1802,1803,1804,1805,1806)
            UNION ALL
            SELECT kythue,mst, -tientra nocuoi FROM ct_tra_'||ckn||' a WHERE a.kythue in ('''||l_dskythue||''') AND a.ma_tinh=:3
            AND a.ma_tmuc not IN (1801, 1802,1803,1804,1805,1806)
            AND EXISTS (SELECT 1 FROM bangphieutra_'||ckn||' b
            WHERE a.phieu_id =b.id AND b.ngay_tt < LAST_DAY(to_Date(:4,''MMYYYY''))+1)
            ) GROUP BY mst HAVING sum(nocuoi) >0';
    EXECUTE IMMEDIATE l_sql USING 'Q'||i_quy,i_matinh,i_matinh,l_kycuoi;

    l_sql:='update bc_doisoat_thuekhoan a set a.ho_quy_truoc = nvl((select dem from (
        SELECT count(1) dem,c.shkb FROM bc_doisoat_tmp a,(SELECT mst,sum(no_cuoi) no_cuoi FROM
        conver_debt_quarter WHERE  ma_tmuc NOT IN (1801, 1802,1803,1804,1805,1806) and quy=:1 and nam=:2 GROUP BY mst )  b,
        (SELECT a.mst,b.shkb FROM nnts_'||ckn||' a,  coquanthus b where a.ma_cqt_ql =b.cqt_tms
            AND a.ma_tinh=b.ma_tinh AND b.ma_tinh=:3) c
         WHERE a.mst=b.mst AND a.mst=c.mst and a.type_id=2 and a.ky_thue=:4 AND (a.no_cuoi - b.no_cuoi) >0 GROUP BY c.shkb)
         where a.ma_kb=shkb),0)
         where  quy=:5 and nam=:6';

    EXECUTE IMMEDIATE l_sql USING TO_NUMBER(i_quy),TO_NUMBER(i_nam),i_matinh,'Q'||i_quy,TO_NUMBER(i_quy),TO_NUMBER(i_nam);
    RETURN '1';
    EXCEPTION WHEN OTHERS THEN
        RETURN '0:'||SQLERRM;
END;
FUNCTION set_data_thuekhoan_ps(i_quy IN  VARCHAR2,
                         i_nam IN VARCHAR2,
                         i_matinh IN VARCHAR2)
RETURN VARCHAR2
IS
l_sql VARCHAR2(5000);
l_dskythue  VARCHAR2(5000):=get_cricle_debt(i_quy,i_nam);
ckn varchar2(100):= crud.ckn_hientai;
BEGIN
    l_dskythue:=REPLACE(l_dskythue,',',''',''');
    l_sql:='UPDATE bc_doisoat_thuekhoan a SET ho_ps= nvl((SELECT dem FROM (
            SELECT shkb, count(1) dem FROM (
            SELECT DISTINCT a.mst, nvl(b.shkb,''0'') shkb FROM ct_no_'||ckn||' a,
            (SELECT a.mst,b.shkb,a.ma_tinh FROM nnts_'||ckn||' a,  coquanthus b
            WHERE a.ma_cqt_ql =b.cqt_tms AND a.ma_tinh=b.ma_tinh AND b.ma_tinh=:1) b WHERE a.mst=b.mst(+)
            AND a.ma_tinh=b.ma_tinh AND a.ma_tmuc not IN (1801, 1802,1803,1804,1805,1806)
            AND a.kythue in ('''||l_dskythue||''')) GROUP BY shkb) WHERE a.ma_kb=shkb ),0)
            WHERE  quy=:3 AND nam=:4 and ma_tinh=:5';


    EXECUTE IMMEDIATE l_sql USING i_matinh,TO_NUMBER(i_quy),TO_NUMBER(i_nam),i_matinh;
    RETURN '1';
    EXCEPTION WHEN OTHERS THEN
        RETURN '0:'||SQLERRM;
END;
FUNCTION set_data_thuekhoan_cuoiquy(i_quy IN  VARCHAR2,
                         i_nam IN VARCHAR2,
                         i_matinh IN VARCHAR2)
RETURN VARCHAR2
IS
l_sql VARCHAR2(5000);
l_dskythue  VARCHAR2(5000):=get_cricle_debt(i_quy,i_nam);
l_kycuoi VARCHAR2(5000);
ckn varchar2(100):= crud.ckn_hientai;
BEGIN
    if i_quy ='1' THEN l_kycuoi:='03'||i_nam;
    ELSIF i_quy ='2' THEN l_kycuoi:='06'||i_nam;
    ELSIF i_quy ='3' THEN l_kycuoi:='09'||i_nam;
    ELSIF i_quy ='4' THEN l_kycuoi:='12'||i_nam; END IF;
    l_dskythue:=REPLACE(l_dskythue,',',''',''');

     l_sql:='UPDATE bc_doisoat_thuekhoan a SET ho_cuoi_quy= nvl((SELECT dem FROM (
        SELECT shkb, count(1) dem FROM (
        SELECT DISTINCT a.mst, nvl(b.shkb,''0'') shkb FROM (SELECT kythue,mst, sum(nocuoi) dem FROM (
        SELECT kythue,mst, no_cuoi_ky nocuoi FROM ct_no_'||ckn||' WHERE kythue in ('''||l_dskythue||''') AND ma_tinh=:1
        AND ma_tmuc not IN (1801, 1802,1803,1804,1805,1806)
        UNION ALL
        SELECT kythue,mst, -tientra nocuoi FROM ct_tra_'||ckn||' a WHERE a.kythue in ('''||l_dskythue||''') AND a.ma_tinh=:2
        AND a.ma_tmuc not IN (1801, 1802,1803,1804,1805,1806)
        AND EXISTS (SELECT 1 FROM bangphieutra_'||ckn||' b
        WHERE a.phieu_id =b.id AND b.ngay_tt < LAST_DAY(to_Date(:3,''MMYYYY''))+1)
        ) GROUP BY kythue,mst HAVING sum(nocuoi) >0
        ) a,
        (SELECT a.mst,b.shkb FROM nnts_'||ckn||' a,  coquanthus b
        WHERE a.ma_cqt_ql =b.cqt_tms AND a.ma_tinh=b.ma_tinh AND b.ma_tinh=:4 ) b WHERE a.mst=b.mst(+)
        AND a.kythue in ('''||l_dskythue||''')) GROUP BY shkb) WHERE a.ma_kb=shkb ),0)
        WHERE quy=:5 AND nam=:6 and ma_tinh=:7';
        EXECUTE IMMEDIATE l_sql USING i_matinh,i_matinh,l_kycuoi,i_matinh,TO_NUMBER(i_quy),TO_NUMBER(i_nam),i_matinh;
        RETURN '1';
        EXCEPTION WHEN OTHERS THEN
            RETURN '0:'||SQLERRM;
END;
FUNCTION get_cricle_debt(i_quy IN  VARCHAR2,
                         i_nam IN VARCHAR2)
RETURN VARCHAR2
IS
l_return VARCHAR2(5000);
BEGIN
    IF i_quy='1' THEN
        l_return:='01'||i_nam||','||'02'||i_nam||','||'03'||i_nam;
    ELSIF i_quy='2' THEN
        l_return:='04'||i_nam||','||'05'||i_nam||','||'06'||i_nam;
    ELSIF i_quy='3' THEN
        l_return:='07'||i_nam||','||'08'||i_nam||','||'09'||i_nam;
    ELSIF i_quy='4' THEN
        l_return:='10'||i_nam||','||'11'||i_nam||','||'12'||i_nam;
    ELSE
        l_return:= '0';
    END IF;
    RETURN l_return;
    EXCEPTION WHEN OTHERS THEN
        RETURN   '0:'||SQLERRM;
END;
FUNCTION set_data_thuetroi(i_quy IN  VARCHAR2,
                         i_nam IN VARCHAR2,
                         i_matinh IN VARCHAR2)
RETURN VARCHAR2
IS
l_sql VARCHAR2(5000);
c_cur SYS_REFCURSOR;
l_count NUMBER;
l_s VARCHAR2(5000);
BEGIN
    l_sql:='select count(1) from bc_doisoat_thuetroi where quy=:1 and nam=:2';
    EXECUTE IMMEDIATE l_sql INTO l_count USING i_quy,i_nam;
    IF l_count > 0 THEN
        l_sql:='delete from bc_doisoat_thuetroi where quy=:1 and nam=:2';
        EXECUTE IMMEDIATE l_sql  USING i_quy,i_nam;
    END IF;
   l_sql:=set_data_thuetroi_ps(i_quy,i_nam,i_matinh);
    IF l_sql ='1' THEN
        l_s:=set_data_thuetroi_cuoithang(i_quy,i_nam,i_matinh);
        l_s:=set_data_thuetroi_thangtruoc(i_quy,i_nam,i_matinh);
        RETURN '1';
    ELSE
        RETURN 'ERR:'||l_sql;
    END IF;
    EXCEPTION WHEN OTHERS THEN
        RETURN '0:'||SQLERRM;

END ;
FUNCTION set_data_thuetroi_ps(i_quy IN  VARCHAR2,
                         i_nam IN VARCHAR2,
                         i_matinh IN VARCHAR2)
RETURN VARCHAR2
IS
l_sql VARCHAR2(1000);
l_count NUMBER;
l_thang_1 NUMBER:=get_month_from_quarter(1,i_quy);
l_thang_2 NUMBER:=get_month_from_quarter(2,i_quy);
l_thang_3 NUMBER:=get_month_from_quarter(3,i_quy);
l_kythue_1 VARCHAR2(20);
l_kythue_2 VARCHAR2(20);
l_kythue_3 VARCHAR2(20);
l_kythuetroi VARCHAR2(20):='1512';
ckn varchar2(100):= crud.ckn_hientai;

BEGIN
    IF LENGTH(l_thang_1) =1 THEN l_kythue_1:='0'||TO_CHAR(l_thang_1)||i_nam; ELSE l_kythue_1:=TO_CHAR(l_thang_1)||i_nam; END IF;
    IF LENGTH(l_thang_2) =1 THEN l_kythue_2:='0'||TO_CHAR(l_thang_2)||i_nam; ELSE l_kythue_2:=TO_CHAR(l_thang_2)||i_nam; END IF;
    IF LENGTH(l_thang_3) =1 THEN l_kythue_3:='0'||TO_CHAR(l_thang_3)||i_nam; ELSE l_kythue_3:=TO_CHAR(l_thang_3)||i_nam; END IF;
    l_sql:='insert into bc_doisoat_thuetroi(thang,quy,nam,ma_kb,ma_tinh)
     SELECT :1 thang,:2 quy,:3 nam,shkb,:4 tinh from (select distinct b.shkb
     FROM nnts_'||ckn||' a,  coquanthus b where a.ma_cqt_ql =b.cqt_tms
            AND a.ma_tinh=b.ma_tinh AND b.ma_tinh=:5)';

    EXECUTE IMMEDIATE l_sql USING l_thang_1,i_quy,i_nam,i_matinh,i_matinh;
    EXECUTE IMMEDIATE l_sql USING l_thang_2,i_quy,i_nam,i_matinh,i_matinh;
    EXECUTE IMMEDIATE l_sql USING l_thang_3,i_quy,i_nam,i_matinh,i_matinh;

    l_sql:='update  bc_doisoat_thuetroi a set a.ho_ps = nvl((select dem from (
            select count(1) dem, shkb
            FROM (SELECT DISTINCT a.mst, nvl(b.shkb,''0'') shkb FROM ct_no_'||ckn||' a,
            (SELECT a.mst,b.shkb,a.ma_tinh FROM nnts_'||ckn||' a,  coquanthus b
            WHERE a.ma_cqt_ql =b.cqt_tms AND a.ma_tinh=b.ma_tinh AND b.ma_tinh=:1) b WHERE a.mst=b.mst
            AND a.ma_tinh=b.ma_tinh AND a.kythue=:2 AND chuky=:3) GROUP BY shkb) where a.ma_kb=shkb),0)
            where a.thang=:4 and a.quy=:5 and a.nam=:6';

    EXECUTE IMMEDIATE l_sql USING i_matinh,l_kythue_1,l_kythuetroi,l_thang_1,i_quy,i_nam;
    EXECUTE IMMEDIATE l_sql USING i_matinh,l_kythue_2,l_kythuetroi,l_thang_2,i_quy,i_nam;
    EXECUTE IMMEDIATE l_sql USING i_matinh,l_kythue_3,l_kythuetroi,l_thang_3,i_quy,i_nam;
    COMMIT;
    RETURN '1';
    EXCEPTION WHEN OTHERS THEN
         RETURN '0:'||SQLERRM;
END;
FUNCTION set_data_thuetroi_cuoithang(i_quy IN  VARCHAR2,
                                 i_nam IN VARCHAR2,
                                 i_matinh IN VARCHAR2)
RETURN VARCHAR2
IS
l_sql VARCHAR2(1000);
l_count NUMBER;
l_thang_1 NUMBER:=get_month_from_quarter(1,i_quy);
l_thang_2 NUMBER:=get_month_from_quarter(2,i_quy);
l_thang_3 NUMBER:=get_month_from_quarter(3,i_quy);
l_kythue_1 VARCHAR2(20);
l_kythue_2 VARCHAR2(20);
l_kythue_3 VARCHAR2(20);
l_quy_previous NUMBER;
l_nam_previous NUMBER;
l_kythuetroi VARCHAR2(20):='1512';
ckn varchar2(100):= crud.ckn_hientai;
BEGIN
    IF LENGTH(l_thang_1) =1 THEN l_kythue_1:='0'||TO_CHAR(l_thang_1)||i_nam; ELSE l_kythue_1:=TO_CHAR(l_thang_1)||i_nam; END IF;
    IF LENGTH(l_thang_2) =1 THEN l_kythue_2:='0'||TO_CHAR(l_thang_2)||i_nam; ELSE l_kythue_2:=TO_CHAR(l_thang_2)||i_nam; END IF;
    IF LENGTH(l_thang_3) =1 THEN l_kythue_3:='0'||TO_CHAR(l_thang_3)||i_nam; ELSE l_kythue_3:=TO_CHAR(l_thang_3)||i_nam; END IF;
    l_sql:='UPDATE bc_doisoat_thuetroi a SET ho_cuoi_thang= nvl((SELECT dem FROM (
        SELECT shkb, count(1) dem FROM (
        SELECT DISTINCT a.mst, nvl(b.shkb,''0'') shkb FROM (SELECT kythue,mst, sum(nocuoi) dem FROM (
        SELECT kythue,mst, no_cuoi_ky nocuoi FROM ct_no_'||ckn||' WHERE kythue=:1 AND ma_tinh=:2 and chuky=:ck1
        UNION ALL
        SELECT kythue,mst, -tientra nocuoi FROM ct_tra_'||ckn||' a WHERE a.kythue =:3 AND a.ma_tinh=:4 and chuky=:ck2
        AND EXISTS (SELECT 1 FROM bangphieutra_'||ckn||' b
        WHERE a.phieu_id =b.id AND b.ngay_tt < LAST_DAY(to_Date(:5,''MMYYYY''))+1)
        ) GROUP BY kythue,mst HAVING sum(nocuoi) >0
        ) a,
        (SELECT a.mst,b.shkb FROM nnts_'||ckn||' a,  coquanthus b
        WHERE a.ma_cqt_ql =b.cqt_tms AND a.ma_tinh=b.ma_tinh AND b.ma_tinh=:6 ) b WHERE a.mst=b.mst(+)
        AND a.kythue =:7) GROUP BY shkb) WHERE a.ma_kb=shkb ),0)
        WHERE thang=:8 AND nam=:9 and ma_tinh=:10';

    EXECUTE IMMEDIATE l_sql USING l_kythue_1,i_matinh,l_kythuetroi,l_kythue_1,i_matinh,l_kythuetroi,l_kythue_1,i_matinh,l_kythue_1,l_thang_1,i_nam,i_matinh;
    EXECUTE IMMEDIATE l_sql USING l_kythue_2,i_matinh,l_kythuetroi,l_kythue_2,i_matinh,l_kythuetroi,l_kythue_2,i_matinh,l_kythue_2,l_thang_2,i_nam,i_matinh;
    EXECUTE IMMEDIATE l_sql USING l_kythue_3,i_matinh,l_kythuetroi,l_kythue_3,i_matinh,l_kythuetroi,l_kythue_3,i_matinh,l_kythue_3,l_thang_3,i_nam,i_matinh;
    COMMIT;
    RETURN '1';
    EXCEPTION WHEN OTHERS THEN
         RETURN '0:'||SQLERRM;
END;
FUNCTION set_data_thuetroi_thangtruoc(i_quy IN  VARCHAR2,
                                 i_nam IN VARCHAR2,
                                 i_matinh IN VARCHAR2)
RETURN VARCHAR2
IS
l_sql VARCHAR2(1000);
l_count NUMBER;
l_thang_1 NUMBER:=get_month_from_quarter(1,i_quy);
l_thang_2 NUMBER:=get_month_from_quarter(2,i_quy);
l_thang_3 NUMBER:=get_month_from_quarter(3,i_quy);
l_thang_1_pre NUMBER;
l_thang_2_pre NUMBER;
l_thang_3_pre NUMBER;
l_nam_1_pre NUMBER;
l_nam_2_pre NUMBER;
l_nam_3_pre NUMBER;
l_quy_previous NUMBER;
l_nam_previous NUMBER;

BEGIN
    get_month_previous(l_thang_1,TO_NUMBER(i_nam),l_thang_1_pre,l_nam_1_pre);
    get_month_previous(l_thang_2,TO_NUMBER(i_nam),l_thang_2_pre,l_nam_2_pre);
    get_month_previous(l_thang_3,TO_NUMBER(i_nam),l_thang_3_pre,l_nam_3_pre);

    l_sql:='update bc_doisoat_thuetroi a set ho_thang_truoc =0
    where a.thang=:3 and a.nam=:4 and a.ma_tinh=:5';
     EXECUTE IMMEDIATE l_sql USING l_thang_1,TO_NUMBER(i_nam),i_matinh;

    l_sql:='update bc_doisoat_thuetroi a set ho_thang_truoc =nvl((select ho_cuoi_thang thangtruoc from bc_doisoat_thuetroi b
    where a.ma_tinh=b.ma_tinh and a.ma_kb=b.ma_kb and b.thang=:1 and b.nam=:2),0)
    where a.thang=:3 and a.nam=:4 and a.ma_tinh=:5';

    EXECUTE IMMEDIATE l_sql USING l_thang_2_pre,l_nam_2_pre,l_thang_2,TO_NUMBER(i_nam),i_matinh;
    EXECUTE IMMEDIATE l_sql USING l_thang_3_pre,l_nam_3_pre,l_thang_3,TO_NUMBER(i_nam),i_matinh;

    COMMIT;
    RETURN '1';
    EXCEPTION WHEN OTHERS THEN
         RETURN '0:'||SQLERRM;
END;

   -- Enter further code below as specified in the Package spec.
END;

/
