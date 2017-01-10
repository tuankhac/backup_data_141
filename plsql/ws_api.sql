--------------------------------------------------------
--  File created - Tuesday-January-10-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body WS_API
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "TAX"."WS_API" 
IS
function get_nnt_info_search(
    pmst varchar2,
    psogt varchar2,
    PMA_TINH VARCHAR2,
    pUserId varchar2,
    pPass varchar2,
    pFKey varchar2,
    pSerial varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai();
    l_count number;
begin
    l_count := authentication_api(pUser=>pUserId, pPass=>pPass, pFKey=>pFKey, pSerial=>pSerial, pIP=>pUserIp);
    If l_count =0 then
        open ref_ for 'select :1 err from dual' using '2|INF not exists in system';
        return ref_;
    Else
        if pmst is not null then
            s:='select a.*,to_char(b.sotien,''fm999,999,999,999,999'') sotien,to_char(C.tientra,''fm999,999,999,999,999'') tien_tra,
                    (select ten_nv||'' - ''||mobile from nhanvien_tcs where ma_tinh ='''||PMA_TINH||''' and id = a.ma_nv and rownum=1) ten_nv
                from tax.nnts_'||ckn||' a,
                    (select sum(no_cuoi_ky) sotien, mst from ct_no_'||ckn||' group by mst) b,
                    (select sum(tientra) tientra, mst from ct_tra_'||ckn||' group by mst) c
                where
                    a.mst=b.mst and a.mst=c.mst(+) and a.mst='''||pmst||'''';
        else
            s:='select a.*,to_char(b.sotien,''fm999,999,999,999,999'') sotien,to_char(C.tientra,''fm999,999,999,999,999'') tien_tra,
                    (select ten_nv||'' - ''||mobile from nhanvien_tcs where ma_tinh ='''||PMA_TINH||''' and id = a.ma_nv and rownum=1) ten_nv
                 from tax.nnts_'||ckn||' a,
                    (select sum(no_cuoi_ky) sotien, mst from ct_no_'||ckn||' group by mst) b,
                    (select sum(tientra) tientra, mst from ct_tra_'||ckn||' group by mst) c
                where
                    a.mst=b.mst and a.mst=c.mst(+) and a.so='''||psogt||'''';
        end if;
        open ref_ for s;
        return ref_;
    End if;
    exception when others then
        declare err varchar2(500); begin    err:='3|Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function get_nnt_ct_no(
    pmst varchar2,
    pMa_tinh varchar2,
    pkythue varchar2,
    pUserId varchar2,
    pPass varchar2,
    pFKey varchar2,
    pSerial varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    ckn varchar2(100):= crud.ckn_hientai();
    ref_ sys_refcursor;
    s varchar2(10000);
    l_agent varchar2(15);
    l_count number;
begin
    l_count := authentication_api(pUser=>pUserId, pPass=>pPass, pFKey=>pFKey, pSerial=>pSerial, pIP=>pUserIp);
    If l_count =0 then
        open ref_ for 'select :1 err from dual' using '2|INF not exists in system';
        return ref_;
    Else
        if pMa_tinh is null then
            begin
                l_agent := get_agent_taxcode(pmst);
            end;
        else
            l_agent := pMa_tinh;
        end if;
        s := 'select to_char(a.no_cuoi_ky,''fm999,999,999,999,999'') no_cuoi_ky,
                    to_char(nvl(b.tientra,0),''fm999,999,999,999,999'') tien_tra,
                    to_char(a.no_cuoi_ky-nvl(b.tientra,0),''fm999,999,999,999,999'') sotien,
                    a.MA_CHUONG,a.MA_CQ_THU,a.MA_TMUC,a.SO_TAIKHOAN_CO,a.SO_QDINH,a.NGAY_QDINH,
                    a.LOAI_TIEN,a.TI_GIA,a.LOAI_THUE,C.ten_chuong,nvl(D.tentieumuc,A.ma_tmuc) tentieumuc, a.kythue, a.chuky
             from
                (
                SELECT mst,ma_tinh,sum(no_cuoi_ky) no_cuoi_ky,ma_chuong,ma_cq_thu,
                      ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh,
                      loai_tien,ti_gia,loai_thue,kythue,chuky
                  FROM ct_no_'||ckn||' where 1=1';

                    If pkythue is not null then
                        s:=s||' and kythue ='''||pkythue||'''';
                    End if;

                    s:=s||' group by mst,ma_tinh,ma_chuong,ma_cq_thu,
                      ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh,
                      loai_tien,ti_gia,loai_thue,kythue,chuky) a,
                (
                SELECT mst,ma_tinh,sum(tientra) TIENTRA,ma_chuong,ma_cq_thu,
                      ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh,
                      loai_tien,ti_gia,loai_thue,kythue,chuky
                  FROM ct_tra_'||ckn||' where 1=1';

                    If pkythue is not null then
                        s:=s||' and kythue ='''||pkythue||'''';
                    End if;

                  s:=s||' group by mst,ma_tinh,ma_chuong,ma_cq_thu,
                      ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh,
                      loai_tien,ti_gia,loai_thue,kythue,chuky
            ) b, chuongs c, tieu_mucs d
            where a.mst=b.mst(+) and a.ma_chuong=b.ma_chuong(+) and a.ma_tmuc=b.ma_tmuc(+)
                and a.ma_chuong=C.id(+) and a.ma_tmuc=d.id(+)
                and a.kythue = b.kythue(+) and  a.chuky = b.chuky(+)
                AND a.no_cuoi_ky-nvl(b.tientra,0) >0 and A.MST =:1 and a.ma_tinh =:2
                ORDER by a.kythue,a.ma_tmuc';

        OPEN REF_ for s Using pmst,l_agent;
        return ref_;
    End if;
    exception when others then
        declare err varchar2(500); begin    err:='3|Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function search_info_bill_his(pmst varchar2,
    pma_tinh varchar2,
    pUserId varchar2,
    pPass varchar2,
    pFKey varchar2,
    pSerial varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ckn varchar2(100):= crud.ckn_hientai();
    ref_ sys_refcursor;
    l_count number;
    l_agent varchar2(10);
begin
    l_count := authentication_api(pUser=>pUserId, pPass=>pPass, pFKey=>pFKey, pSerial=>pSerial, pIP=>pUserIp);
    If l_count =0 then
        open ref_ for 'select :1 err from dual' using '2|INF not exists in system';
        return ref_;
    Else
        If pma_tinh is null then
            execute immediate 'Select ma_tinh from nnts_'||ckn||' where mst = :1' into l_agent using pmst;
        Else
            l_agent := pma_tinh;
        End if;

        s:='select a.mst,a.kythue,a.chuky,to_char(a.tientra,''fm999,999,999,999'') tientra,(select TEN_CHUONG from  tax.chuongs where a.ma_chuong = id) ten_chuong,
            (select TENTIEUMUC from  tax.tieu_mucs where a.ma_tmuc = id) ten_muc, a.phieu_id, to_char(b.ngay_tt,''dd/mm/yyyy hh24:mi:ss'') ngay_tt
             from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b
            where a.phieu_id = b.id
            and a.mst =:1
            and a.ma_tinh =:2';
        open ref_ for s using pmst,l_agent;
        return ref_;
    End if;

    exception when others then
        declare err varchar2(500); begin    err:='3|Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function search_agent_info(pUserId varchar2,
    pPass varchar2,
    pFKey varchar2,
    pSerial varchar2,
    pUserIp varchar2) return varchar2
is
    l_agent varchar2(100);
    s varchar2(1000);
    l_count number;
    l_staff varchar2(100);
    ckn varchar2(100):=crud.ckn_hientai();
begin
    l_count := authentication_api(pUser=>pUserId, pPass=>pPass, pFKey=>pFKey, pSerial=>pSerial, pIP=>pUserIp);
    If l_count =0 then
        Return '2|INF not exists in system';
    Else
        l_agent := crud.search_agent_info(pUserId);
        Begin
            Select staff into l_staff from user_info where id =pUserId;
            Exception when others then
                l_staff :='0';
        End;

        Return '0|'||l_agent||'|'||l_staff||'|'||ckn;
    End if;


    Exception when others then
        declare err varchar2(500);
            begin    err:='3|Loi thuc hien, ma loi:'||to_char(sqlerrm);
            return err;
    end;
end;

function thanh_toan(
    pmst varchar2,
    pma_tinh varchar2,
    pma_bc varchar2,
    phttt varchar2,
    pnguoigachno varchar2,
    pPass varchar2,
    pFKey varchar2,
    pSerial varchar2,
    pIP varchar2,
    pquaythu varchar2,
    ptra varchar2
) return varchar2
is
    id_ varchar2(5000);
    ckn varchar2(100):=crud.ckn_hientai();
    l_count number;
    l_return number;
    fkey   tax.util.StringArray;
    fcard   tax.util.StringArray;
    l_fkey varchar2(50); -- Token
    l_card varchar2(20);
    l_type_card number;  --1: The khach hang, 0: the dai ly
    l_ref varchar2(20);
    l_phieuid number;
    l_pattern varchar2(50);
    l_seri varchar2(20);
begin
    logger.access('ws_api.thanh_toan',pmst||'|'||pma_tinh||'|'||pma_bc||'|'||phttt||'|'||pnguoigachno||'|'||pPass||'|'||pFKey||'|'||pSerial||'|'||pIP||'|'||pquaythu||'|'||ptra);
    l_count := authentication_api(pUser=>pnguoigachno, pPass=>pPass, pFKey=>pFKey, pSerial=>pSerial, pIP=>pIP);
    If l_count =0 then
        Return '2|INF not exists in system';
    Else
        Begin
            fkey := tax.util.str_to_array(pIP,'|');
            --Token cua may POS
            l_fkey := fkey(fkey.LAST-1);
            l_type_card := fkey(fkey.LAST);
            fcard := tax.util.str_to_array(l_fkey,'-');
            --Ma chuan chi ben ngan hang (6 ky tu)
            l_card := fcard(fcard.FIRST);
            --So tham chieu (12 ky tu)
            l_ref := fcard(fcard.LAST);

            l_fkey := replace(l_fkey,'-','');
            Exception when others then
            Return '2|Token wrong format';
        End;

        --Check fkey existsing
        Select count(1) into l_count from tax.log_pos where id = l_fkey and taxcode = pmst;
        If l_count >0 then
            Begin
                Select ORDER_ID into l_phieuid from tax.log_pos where id = l_fkey and taxcode = pmst;

                --Lay thong tin KY_HIEU & SERI de in phieu bien nhan tren POS
                Execute immediate 'Select ky_hieu,seri from bangphieutra_'||ckn||' where id=:1 and mst=:2'
                    into l_pattern,l_seri using l_phieuid,pmst;

                Return '1|TOKEN EXISTING '||l_fkey||'|'||l_phieuid||'|'||l_pattern||'|'||l_seri;
                Exception when others then
                    Return '3|BILL NOT EXISTING';
            End;
        End if;

        id_ := crud.thanh_toan(pmst,pma_tinh,pma_bc,phttt,pnguoigachno,null,pquaythu,ptra);
        l_return := tax.is_number(id_);
        If (l_return = 1) then
            Execute immediate 'Insert into tax.log_pos(id,content,taxcode,order_id,type_card,loguser) values(:1,:2,:3,:4,:5,:6)'
                Using l_fkey,pIP,pmst,id_,l_type_card,pnguoigachno;

            --Cap nhat thong tin the thanh toan qua POS
            Execute immediate ' Update bangphieutra_'||ckn||' set ma_chuan_chi=:1,so_tham_chieu=:2,loai_the=:3 where id=:4 and mst=:5'
                Using l_card,l_ref,l_type_card,id_,pmst;

            --Lay thong tin KY_HIEU & SERI de in phieu bien nhan tren POS
            Execute immediate 'Select ky_hieu,seri from bangphieutra_'||ckn||' where id=:1 and mst=:2'
                into l_pattern,l_seri using id_,pmst;

            Return '0|'||id_||'|'||l_pattern||'|'||l_seri;
        Else
            Return '2|'||id_;
        End if;
    End if;
    Commit;
    exception when others then
        declare err varchar2(5000);
            begin
                err:='3|Loi thuc hien, ma loi:'||TO_CHAR(SQLCODE)||': '||SQLERRM || ', Detail:'|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
                logger.access('ws_api.thanh_toan',pmst||'|'||err);
                return err;
    end;
end;

function del_bangphieutra(
    pId varchar2,
    pUserId varchar2,
    pPass varchar2,
    pFKey varchar2,
    pSerial varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    l_check number;
    ckn varchar2(100):= crud.ckn_hientai;
    l_count number;
begin
	logger.access('ws_api.del_bangphieutra',pId||'|'||pUserId||'|'||pPass||'|'||pFKey||'|'||pSerial||'|'||pUserIp);
    l_count := authentication_api(pUser=>pUserId, pPass=>pPass, pFKey=>pFKey, pSerial=>pSerial, pIP=>pUserIp);
    If l_count =0 then
        Return '2|INF not exists in system';
    Else
        Execute immediate 'Select count(1) from tax.bangphieutra_'||ckn||' where id=:id' into l_count using pId;
        If l_count =0 then
            Return '2|BILL NOT EXISTING';
        Else
            Execute immediate 'Select count(1) from tax.bangphieutra_'||ckn||' where id=:id and nguoigachno_id=:nguoigachno_id' into l_count using pId,pUserId;
            If l_count =0 then
                Return '2|BAN KHONG CO QUYEN XOA PHIEU CUA THU NGAN KHAC';
            End if;
        End if;

        s := crud.del_bangphieutra(pId,pUserId,pUserIp);
        If s='1' then
            return '0|1';
        Else
            return '2|'||s;
        End if;
    End if;

    exception when others then
        declare err varchar2(500); begin    err:='3|Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function new_nhatky_thus(
    pmst varchar2,
    pluotnhac varchar2,
    plydos varchar2,
    pngayhen_tt varchar2,
    pUserId varchar2,
    pPass varchar2,
    pFKey varchar2,
    pSerial varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    l_count number;
begin
    l_count := authentication_api(pUser=>pUserId, pPass=>pPass, pFKey=>pFKey, pSerial=>pSerial, pIP=>pUserIp);
    If l_count =0 then
        Return '2|INF not exists in system';
    Else
        s:= crud.new_nhatky_thus(pmst,pluotnhac,plydos,pngayhen_tt,null,null,pUserId,pUserIp);
        If s='1' then
            return '0|1';
        Else
            return '2|'||s;
        End if;
    End if;


    exception when others then
        declare err varchar2(500); begin    err:='3|Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function edit_nhatky_thus(
    pmst varchar2,
    pluotnhac varchar2,
    plydos varchar2,
    pngayhen_tt varchar2,
    pUserId varchar2,
    pPass varchar2,
    pFKey varchar2,
    pSerial varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    l_count number;
begin
    l_count := authentication_api(pUser=>pUserId, pPass=>pPass, pFKey=>pFKey, pSerial=>pSerial, pIP=>pUserIp);
    If l_count =0 then
        Return '2|INF not exists in system';
    Else
        s:= crud.edit_nhatky_thus(pmst,pluotnhac,plydos,pngayhen_tt,null,null,pUserId,pUserIp);
        If s='1' then
            return '0|1';
        Else
            return '2|'||s;
        End if;
    End if;

    exception when others then
        declare err varchar2(500); begin    err:='3|Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function del_nhatky_thus(
    pId varchar2,
    pUserId varchar2,
    pPass varchar2,
    pFKey varchar2,
    pSerial varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    l_count number;
begin
    l_count := authentication_api(pUser=>pUserId, pPass=>pPass, pFKey=>pFKey, pSerial=>pSerial, pIP=>pUserIp);
    If l_count =0 then
        Return '2|INF not exists in system';
    Else
        s:= crud.del_nhatky_thus(pId,pUserId,pUserIp);
        If s='1' then
            return '0|1';
        Else
            return '2|'||s;
        End if;
    End if;

    exception when others then
        declare err varchar2(500); begin    err:='3|Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function checkpass (pUser varchar2, pPass varchar2)
return number
is
    l_count number;
Begin
    Select count(1) into l_count from user_info where id = pUser and PASSWORD = pPass and status_id =1 and rownum=1;
    Return l_count;
End;

function get_pass_from_user (pUser varchar2, pPass varchar2, pFkey varchar2, pUserIp varchar2)
return varchar2
is
    l_count number;
    l_serial varchar2(100);
    l_user varchar2(100);
    l_array   tax.util.StringArray;
Begin
    l_array := tax.util.str_to_array(pUserIp,'|');
    l_user := l_array(l_array.first+1);
    Select count(1) into l_count from user_info where id= trim(l_user) and fkey = pFkey;
    If (l_count >0 ) then
        Select count(1) into l_count from user_info where id = pUser and password = pPass  and  status_id =1 and rownum=1;
        If l_count >0 then
            Select serial_pos into l_serial from user_info where id = pUser and password = pPass  and  status_id =1 and rownum=1;
            Return '0|'||l_serial;
        Else
            Return '2|User not exists in system';
        End if;
    Else
        Return '2|Fkey not exists in system';
    End if;
    Exception when others then
        Return '3|User not exists in system';
End;

function search_nnt_giao_phieu(
    pma_nv varchar2,
    pma_tinh VARCHAR2,
    pType VARCHAR2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pPass varchar2,
    pFKey varchar2,
    pSerial varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai();
    l_count number;
begin
    l_count := authentication_api(pUser=>pUserId, pPass=>pPass, pFKey=>pFKey, pSerial=>pSerial, pIP=>pUserIp);
    If l_count =0 then
        open ref_ for 'select :1 err from dual' using '2|INF not exists in system';
        return ref_;
    Else
        s:='select a.mst, a.ten_nnt, a.so, a.ma_cqt_ql, a.mota_diachi, a.ma_tinh,
            a.ma_huyen, a.ma_xa, a.so_nha, a.diachi_tt, a.ma_tinh_tt,
            a.ma_huyen_tt, a.ma_xa_tt, a.so_nha_tt, a.mobile, a.email,
            a.ma_nv, a.ma_t, a.ma_unt,a.dia_ban, a.kbnn,
            to_char(nvl(c.tien_giao,0),''fm999,999,999,999,999'') da_giao,
        to_char(b.sotien-nvl(c.tien_giao,0),''fm999,999,999,999,999'') sotien from tax.nnts_'||ckn||' a,
        (select sum(no_cuoi_ky) sotien, mst from ct_no_'||ckn||' group by mst) b,
        (select sum(tien_giao) tien_giao, mst from phieu_'||ckn||' group by mst) c
        where a.mst=b.mst and a.mst=c.mst(+) /*and b.sotien-nvl(c.tien_giao,0)>0*/';
        if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
        if pma_nv is not null then s:=s||' and ma_nv like '''||replace(pma_nv,'*','%')||''''; end if;
        s:=s||' order by a.mst';

        if pType='1' then
           open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
           return ref_;
        end if;

        if pType='2' then
           return util.GetTotalRecord(s,pPageIndex,pRecordPerPage);
        end if;

    End if;
    exception when others then
        declare err varchar2(500); begin    err:='3|Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

Function report_info_debt_pos(
    pma_tinh varchar2,
    ptungay varchar2,
    pdenngay varchar2,
    pUserId varchar2,
    pPass varchar2,
    pFKey varchar2,
    pSerial varchar2,
    pUserIp varchar2)
    return sys_refcursor
is
    s varchar2(5000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai();
    l_count number;
begin
    l_count := authentication_api(pUser=>pUserId, pPass=>pPass, pFKey=>pFKey, pSerial=>pSerial, pIP=>pUserIp);
    If l_count =0 then
        open ref_ for 'select :1 err from dual' using '2|INF not exists in system';
        return ref_;
    Else
        s:='select rownum stt,a.mst,a.tientra,b.nguoigachno_id nguoi_gach,a.phieu_id
             from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b
            where a.phieu_id = b.id
            and a.ma_tinh ='''||pma_tinh||'''
            and b.nguoigachno_id ='''||pUserId||'''
            and b.ngay_tt >= to_date('''||ptungay||''',''dd/mm/yyyy'')
            and b.ngay_tt < to_date('''||pdenngay||''',''dd/mm/yyyy'') +1
            order by b.ngay_tt,b.nguoigachno_id';
            open ref_ for s;
            return ref_;
    End if;

    exception when others then
        declare err varchar2(500); begin    err:='3|Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function lay_thongtin_nnt(
    pmsisdn varchar2,
    pUserId varchar2,
    pPass varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai();
    l_check number;
    l_mst varchar2(20);
    l_message varchar2(500);
begin
    --Check thong tin user/pass dang nhap he thong
    l_check := checkpass(pUser =>pUserId, pPass=>pPass);
    If l_check =0 then
        return '2|User/pass invalid';
    End if;

    Begin
        Execute immediate 'Select mst from tax.nnts_'||ckn||' where mobile =:1 and rownum=1' into l_mst using pmsisdn;
        Exception when others then
        Return '1|MSISDN not existing';
    End;
    s:='select a.mst||'' - ''||a.ten_nnt||'' - ''||a.mota_diachi from tax.nnts_'||ckn||' a where a.mst =:1';
    execute immediate s into l_message using l_mst;
    return l_message;
    exception when others then
        declare err varchar2(500); begin err:='3|Loi thuc hien, ma loi:'||to_char(sqlerrm);
        return err;
    end;
end;

function lay_thongtin_no(
    pmst varchar2,
    pUserId varchar2,
    pPass varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai();
    l_check number;
    l_tongno number;
    l_mst varchar2(20);
    l_tienno number;
    l_tientra number;
    l_conno number;
    l_han_tt varchar2(500);
    l_nam VARCHAR2(10):= to_char(sysdate,'yyyy');
    l_message varchar2(500);
begin
    --Check thong tin user/pass dang nhap he thong
    l_check := checkpass(pUser =>pUserId, pPass=>pPass);
    If l_check =0 then
        return '2|User/pass invalid';
    End if;

    --Check thong tin ton tai
    Execute immediate'Select count(1) from tax.nnts_'||ckn||' where mst =:1' into l_check using pmst;
    If l_check =0 then
        return '2|MST not existing';
    End if;

    --Lay thong tin tong no
    s:= 'select sum(no_cuoi_ky) from tax.ct_no_'||ckn||' where mst =:1';
    execute immediate s into l_tienno  using pmst;

    --Lay tong tien tra theo MST
    s:='select sum(tientra) from tax.ct_tra_'||ckn||' where mst =:1';
    execute immediate s into l_tientra  using pmst;

    l_conno := l_tienno - l_tientra;

    If TO_CHAR(sysdate,'Q') =1 then
        l_han_tt := '25/03/'||l_nam;
    Elsif TO_CHAR(sysdate,'Q') =2 then
        l_han_tt := '25/06/'||l_nam;
    Elsif TO_CHAR(sysdate,'Q') =3 then
        l_han_tt := '25/09/'||l_nam;
    Elsif TO_CHAR(sysdate,'Q') =4 then
        l_han_tt := '25/12/'||l_nam;
    End if;

    l_message :=''||pmst||' - so thue con phai nop quy Q'||TO_CHAR(sysdate,'Q')||' la '||nvl(l_conno,0)||'d. Thoi han nop: truoc ngay '||l_han_tt||'. Goi (08) 800126 de y/c thu tan noi.';

    return l_message;

    exception when others then
        declare err varchar2(500); begin    err:='3|Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function lay_thongtin_tra(
    pmst varchar2,
    pthang varchar2,
    pnam varchar2,
    pUserId varchar2,
    pPass varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai();
    ckn1 varchar2(100);
    l_check number;
    l_tongno number;
    l_mst varchar2(20);
    l_tienno number;
    l_tientra varchar2(3000);
    l_conno number;
    l_han_tt varchar2(500);
    l_nam VARCHAR2(10):= to_char(sysdate,'yyyy');
    l_message varchar2(500);
    l_count number;
begin
    --Check thong tin user/pass dang nhap he thong
    l_check := checkpass(pUser =>pUserId, pPass=>pPass);
    If l_check =0 then
        return '2|User/pass invalid';
    End if;

    --Check thong tin ton tai
    Execute immediate'Select count(1) from tax.nnts_'||ckn||' where mst =:1' into l_check using pmst;
    If l_check =0 then
        return '2|MST not existing';
    End if;

    If (pthang is not null) and (pnam is not null) then
        ckn1 := trim(pthang)||trim(pnam);

        Execute immediate 'select count(1) from  tax.bangphieutra_'||ckn||' a where a.mst =:1' into l_count using pmst;
        If l_count >0 then
            Begin
                --Lay thong tin tra
                select util.rows_to_str('select b.tentieumuc||'':''||sum(tientra)||'' ngay ''||to_char(c.ngay_tt,''dd/mm/yyyy'')
                    from tax.ct_tra_'||ckn||' a, tax.tieu_mucs b , tax.bangphieutra_'||ckn||' c
                        where a.mst='''||pmst||''' and a.ma_tmuc = b.id(+) and a.phieu_id = c.id
                        and a.kythue= '''||ckn1||'''
                        group by b.tentieumuc,c.ngay_tt',',') into l_tientra from dual;
                Exception when others then
                    l_message :=''||pmst||' – khong ton tai thong tin tra cua khach hang';
                    return l_message;
            End;
        Else
            l_message :=''||pmst||' – khong ton tai thong tin tra cua khach hang';
            return l_message;
        End if;

    Else
        Execute immediate 'select count(1) from  tax.bangphieutra_'||ckn||' a where a.mst =:1' into l_count using pmst;
        If l_count >0 then
            --Lay thong tin tra
            Begin
                select util.rows_to_str('select b.tentieumuc||'':''||sum(tientra)||'' ngay ''||to_char(c.ngay_tt,''dd/mm/yyyy'')
                from tax.ct_tra_'||ckn||' a, tax.tieu_mucs b , tax.bangphieutra_'||ckn||' c
                    where a.mst='''||pmst||''' and a.ma_tmuc = b.id(+) and a.phieu_id = c.id
                    group by b.tentieumuc,c.ngay_tt',',') into l_tientra from dual;
                Exception when others then
                    l_message :=''||pmst||' – quy khach chua thuc hien thanh toan thue. Goi (08) 800126 de y/c thu tan noi.';
                    return l_message;
            End;
        Else
            l_message :=''||pmst||' – khong ton tai thong tin tra cua khach hang';
            return l_message;
        End if;
    End if;

    l_message :=''||pmst||' – '||tax.uto_khongdau(l_tientra);
    return l_message;

    exception when others then
        declare err varchar2(500); begin    err:='3|Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function laytt_bldt(pid varchar2,
    pUserId varchar2,
    pPass varchar2,
    pUserIp varchar2) return sys_refcursor
is
    l_agent varchar2(100);
    s varchar2(1000);
    l_check number;
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai();
begin
    --Check thong tin user/pass dang nhap he thong
    l_check := checkpass(pUser =>pUserId, pPass=>pPass);
    If l_check =0 then
        open ref_ for 'select :1 err from dual' using '2|User/pass invalid';
        return ref_;
    End if;
    s := 'select max(serial) serial,max(numb_bill) numb_bill from tax.hddts where FKEY =:1';
    OPEN ref_ for s using pid;
    return ref_;
    declare err varchar2(500); begin    err:='3|Loi thuc hien, ma loi:'||to_char(sqlerrm);
        open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function authentication_api (pUser varchar2, pPass varchar2, pFKey varchar2, pSerial varchar2, pIP varchar2)
return number
is
    l_count number;
    l_user varchar2(100);
    l_array   tax.util.StringArray;
Begin
    l_array := tax.util.str_to_array(pIP,'|');
    l_user := l_array(l_array.first+1);
    Select count(1) into l_count from user_info where id= trim(l_user) and fkey = pFKey;
    If (l_count >0 ) then
        Select count(1) into l_count from user_info where id = pUser and PASSWORD = pPass
        and status_id =1 and serial_pos = pSerial
        and rownum=1;
        Return l_count;
    Else
        Return 0;
    End if;

    Exception when others then
        Return 0;
End;

function change_pass_user_info(
    pPassNew varchar2,
    pUserId varchar2,
    pPassOld varchar2,
    pFKey varchar2,
    pSerial varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    l_count number;
begin
    l_count := authentication_api(pUser=>pUserId, pPass=>pPassOld, pFKey=>pFKey, pSerial=>pSerial, pIP=>pUserIp);
    If l_count =0 then
        Return '2|INF not exists in system';
    Else
        logger.access('user_info_ws|change_pass_user_info',pUserId);
        s:='update user_info set password=:1 where id=:2 and password =:3';
        execute immediate s using util.getMd5(pPassNew),pUserId,pPassOld;
    End if;
    commit;
    return '0|1';
    exception when others then
        declare err varchar2(500); begin    err:='3|Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function search_kythue(
    pmst VARCHAR2,
    pmatinh VARCHAR2,
    pUserId varchar2,
    pPass varchar2,
    pFKey varchar2,
    pSerial varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai();
    l_count number;
begin
    l_count := authentication_api(pUser=>pUserId, pPass=>pPass, pFKey=>pFKey, pSerial=>pSerial, pIP=>pUserIp);
    If l_count =0 then
        open ref_ for 'select :1 err from dual' using '2|INF not exists in system';
        return ref_;
    Else
        s:='select distinct kythue id,kythue name from ct_no_'||ckn||' where mst =:1 and ma_tinh =:2';
        open ref_ for s using pmst,pmatinh;
        return ref_;
    End if;
    exception when others then
        declare err varchar2(500); begin    err:='3|Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

END;

/
