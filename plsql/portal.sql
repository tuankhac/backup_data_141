--------------------------------------------------------
--  File created - Tuesday-January-10-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body PORTAL
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "TAX"."PORTAL" 
IS

FUNCTION insert_transactions_ipn(
    id     VARCHAR2,
    partner_id     NUMBER,
    trans_vnp     VARCHAR2,
    trans_id     VARCHAR2,
    respcode     VARCHAR2,
    taxcode     VARCHAR2,
    amount     VARCHAR2,
    merchant_code     VARCHAR2,
    secretkey     VARCHAR2,
    ip     VARCHAR2,
    date_create     DATE,
    cmd     VARCHAR2,
    secure_code     VARCHAR2,
    merchant_trans_ref     NUMBER,
    type_id     NUMBER,
    send_status NUMBER,
    send_amount NUMBER,
    send_date DATE,
    receive_status NUMBER,
    receive_amount NUMBER,
    receive_logs VARCHAR2,
    receive_date DATE,
    process_status NUMBER,
    process_amount NUMBER,
    process_logs VARCHAR2,
    process_date DATE,
    success_status NUMBER,
    success_amount NUMBER,
    success_logs VARCHAR2,
    success_date DATE,
    succ_card_number VARCHAR2,
    succ_card_hoder_name VARCHAR2,
    succ_transaction_id VARCHAR2,
    log_ip VARCHAR2,
    log_user_id VARCHAR2,
    comments VARCHAR2)
RETURN VARCHAR2
IS
    s VARCHAR2(10000);
BEGIN

    s:= 'insert into tax.transactions (id,taxcode,type_id,send_status,send_amount,send_date,receive_status,receive_amount,receive_logs,receive_date,process_status,process_amount,
    process_logs,process_date,success_status,success_amount,success_logs,success_date,succ_card_number,succ_card_hoder_name,succ_transaction_id,log_ip,log_user_id,comments)
         values (:id,:taxcode,:type_id,:send_status,:send_amount,:send_date,:receive_status,:receive_amount,:receive_logs,:receive_date,:process_status,:process_amount,
    :process_logs,:process_date,:success_status,:success_amount,:success_logs,:success_date,:succ_card_number,:succ_card_hoder_name,:succ_transaction_id,:log_ip,:log_user_id,:comments)';
    execute IMMEDIATE s using id,taxcode,type_id,send_status,send_amount,sysdate,receive_status,receive_amount,receive_logs,sysdate,process_status,process_amount,
    process_logs,sysdate,success_status,success_amount,success_logs,sysdate,succ_card_number,succ_card_hoder_name,succ_transaction_id,log_ip,log_user_id,comments;

    s:= 'insert into tax.transactions_ipn (id,partner_id,trans_vnp,trans_id,respcode,taxcode,amount,merchant_code,secretkey,ip,date_create,cmd,secure_code,merchant_trans_ref)
         values (:id,:partner_id,:trans_vnp,:trans_id,:respcode,:taxcode,:amount,:merchant_code,:secretkey,:ip,:date_create,:cmd,:secure_code,:merchant_trans_ref)';
    execute IMMEDIATE s using TAX.TRANSACTION_IPN_SEQ.NEXTVAL,partner_id,trans_vnp,trans_id,respcode,taxcode,amount,merchant_code,secretkey,ip,sysdate,cmd,secure_code,merchant_trans_ref;

    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
FUNCTION insert_transactions_log(
    id varchar2,
    taxcode     VARCHAR2,
    type_id     NUMBER,
    send_status NUMBER,
    send_amount NUMBER,
    send_date DATE,
    receive_status NUMBER,
    receive_amount NUMBER,
    receive_logs VARCHAR2,
    receive_date DATE,
    process_status NUMBER,
    process_amount NUMBER,
    process_logs VARCHAR2,
    process_date DATE,
    success_status NUMBER,
    success_amount NUMBER,
    success_logs VARCHAR2,
    success_date DATE,
    succ_card_number VARCHAR2,
    succ_card_hoder_name VARCHAR2,
    succ_transaction_id VARCHAR2,
    log_ip VARCHAR2,
    log_user_id VARCHAR2,
    comments VARCHAR2)
RETURN VARCHAR2
IS
    s VARCHAR2(10000);
BEGIN
    s:= 'insert into tax.transactions (id,taxcode,type_id,send_status,send_amount,send_date,receive_status,receive_amount,receive_logs,receive_date,process_status,process_amount,
    process_logs,process_date,success_status,success_amount,success_logs,success_date,succ_card_number,succ_card_hoder_name,succ_transaction_id,log_ip,log_user_id,comments)
         values (:id,:taxcode,:type_id,:send_status,:send_amount,:send_date,:receive_status,:receive_amount,:receive_logs,:receive_date,:process_status,:process_amount,
    :process_logs,:process_date,:success_status,:success_amount,:success_logs,:success_date,:succ_card_number,:succ_card_hoder_name,:succ_transaction_id,:log_ip,:log_user_id,:comments)';
    execute IMMEDIATE s using id,taxcode,type_id,send_status,send_amount,to_date(send_date,'dd/mm/yyyy'),receive_status,receive_amount,receive_logs,to_date(receive_date,'dd/mm/yyyy'),process_status,process_amount,
    process_logs,to_date(process_date,'dd/mm/yyyy'),success_status,success_amount,success_logs,to_date(success_date,'dd/mm/yyyy'),succ_card_number,succ_card_hoder_name,succ_transaction_id,log_ip,log_user_id,comments;

    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
FUNCTION update_transactions_log(
    id varchar2,
    receive_status NUMBER,
    receive_amount NUMBER,
    receive_logs VARCHAR2,
    receive_date DATE,
    process_status NUMBER,
    process_amount NUMBER,
    process_logs VARCHAR2,
    process_date DATE,
    success_status NUMBER,
    success_amount NUMBER,
    success_logs VARCHAR2,
    success_date DATE,
    succ_card_number VARCHAR2,
    succ_card_hoder_name VARCHAR2,
    succ_transaction_id VARCHAR2)
RETURN VARCHAR2
IS
    s VARCHAR2(10000);
BEGIN
    if (process_logs is null) then
      s:= 'update tax.transactions set receive_status=:receive_status,receive_amount=:receive_amount,receive_logs=:receive_logs,
      receive_date=:receive_date,process_status=:process_status,process_amount=:process_amount,
      process_date=:process_date,success_status=:success_status,success_amount=:success_amount,success_logs=:success_logs,
      success_date=:success_date,succ_card_number=:succ_card_number,succ_card_hoder_name=:succ_card_hoder_name,succ_transaction_id=:succ_transaction_id
      where id=:id';
      execute IMMEDIATE s using receive_status,receive_amount,receive_logs,to_date(receive_date,'dd/mm/yyyy'),process_status,process_amount,
      to_date(process_date,'dd/mm/yyyy'),success_status,success_amount,success_logs,to_date(success_date,'dd/mm/yyyy'),succ_card_number,
      succ_card_hoder_name,succ_transaction_id,'trans_id_'||id;
    else
      s:= 'update tax.transactions set receive_status=:receive_status,receive_amount=:receive_amount,receive_logs=:receive_logs,
      receive_date=:receive_date,process_status=:process_status,process_amount=:process_amount,
      process_logs=:process_logs,process_date=:process_date,success_status=:success_status,success_amount=:success_amount,success_logs=:success_logs,
      success_date=:success_date,succ_card_number=:succ_card_number,succ_card_hoder_name=:succ_card_hoder_name,succ_transaction_id=:succ_transaction_id
      where id=:id';
      execute IMMEDIATE s using receive_status,receive_amount,receive_logs,to_date(receive_date,'dd/mm/yyyy'),process_status,process_amount,
      process_logs,to_date(process_date,'dd/mm/yyyy'),success_status,success_amount,success_logs,to_date(success_date,'dd/mm/yyyy'),succ_card_number,
      succ_card_hoder_name,succ_transaction_id,'trans_id_'||id;
    end if;

    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

FUNCTION insert_transactions_ipn_log(
    partner_id     NUMBER,
    trans_vnp     VARCHAR2,
    trans_id     VARCHAR2,
    respcode     VARCHAR2,
    taxcode     VARCHAR2,
    amount     VARCHAR2,
    merchant_code     VARCHAR2,
    secretkey     VARCHAR2,
    ip     VARCHAR2,
    date_create     DATE,
    cmd     VARCHAR2,
    secure_code     VARCHAR2,
    merchant_trans_ref     NUMBER,
    bank_code varchar2)
RETURN VARCHAR2
IS
    s VARCHAR2(10000);
BEGIN
    s:= 'insert into tax.transactions_ipn (id,partner_id,trans_vnp,trans_id,respcode,taxcode,amount,merchant_code,secretkey,ip,date_create,cmd,secure_code,merchant_trans_ref,bank_code)
         values (:id,:partner_id,:trans_vnp,:trans_id,:respcode,:taxcode,:amount,:merchant_code,:secretkey,:ip,:date_create,:cmd,:secure_code,:merchant_trans_ref,:bank_code)';
    execute IMMEDIATE s using TAX.TRANSACTION_IPN_SEQ.NEXTVAL,partner_id,trans_vnp,trans_id,respcode,taxcode,amount,merchant_code,secretkey,ip,sysdate,cmd,secure_code,merchant_trans_ref,bank_code;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
FUNCTION insert_trans_info_log(
    tran_id varchar2,
    mst     varchar2,
    ma_tinh     varchar2,
    ma_bc     varchar2,
    httt     varchar2,
    ngay_tt     date,
    quay     varchar2,
    kythue     varchar2,
    tien_tra     varchar2,
    ma_chuong     varchar2,
    ma_cq_thu     varchar2,
    ma_tmuc     varchar2,
    so_taikhoan_co     varchar2,
    so_qdinh     varchar2,
    ngay_qdinh     date,
    loai_tien     varchar2,
    ti_gia     varchar2,
    loai_thue     varchar2,
    chuky     varchar2,
    user_id     varchar2,
    ip     varchar2,
    res_success varchar2,
    id_thanhtoan_unt varchar2)
RETURN VARCHAR2
IS
    s VARCHAR2(10000);
BEGIN
    s:= 'insert into tax.trans_info (tran_id,mst,ma_tinh,ma_bc,httt,ngay_tt,quay,kythue,tien_tra,ma_chuong,ma_cq_thu,ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh,loai_tien,ti_gia,loai_thue,chuky,user_id,ip,res_success,id_thanhtoan_unt)
         values (:tran_id, :mst, :ma_tinh, :ma_bc, :httt, :ngay_tt, :quay, :kythue, :tien_tra, :ma_chuong, :ma_cq_thu, :ma_tmuc, :so_taikhoan_co, :so_qdinh, :ngay_qdinh, :loai_tien, :ti_gia, :loai_thue, :chuky, :user_id, :ip, :res_success, :id_thanhtoan_unt)';
    execute IMMEDIATE s using tran_id,mst,ma_tinh,ma_bc,httt,to_date(ngay_tt,'dd/mm/yyyy'),quay,kythue,tien_tra,ma_chuong,ma_cq_thu,ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh,loai_tien,ti_gia,loai_thue,chuky,user_id,ip,res_success,id_thanhtoan_unt;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
FUNCTION get_transactions_log(
    id     varchar2)
RETURN sys_refcursor
IS
    s VARCHAR2(10000);
    ref_ sys_refcursor;
BEGIN
    s:= 'select * from tax.transactions where id=:id';
    open ref_ for s using  'trans_id_'||id;
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
function get_info_chart(
    ptu_ngay varchar2,
    pden_ngay varchar2,
    pma_tinh varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):=crud.ckn_hientai;
    l_tonghd number;
begin
    execute immediate 'select sum(count(b.httt_id)) gia_tri from ct_tra_2016 a
    left join bangphieutra_2016 b on (a.phieu_id = b.id) where a.ma_tinh=:1 group by b.httt_id ' into l_tonghd using pma_tinh;

    s:='select b.id, nvl(a.gia_tri,0) gia_tri, b.name, round(nvl(((a.gia_tri/:1)*100),0),2) ty_le
        from (select b.httt_id, count(b.httt_id) gia_tri from ct_tra_'||ckn||' a
        left join bangphieutra_'||ckn||' b on (a.phieu_id = b.id)
        where (a.ma_tinh=:2 and b.ngay_tt >= :3 and b.ngay_tt <= :4) group by b.httt_id) a
        right join hinhthuc_tts b on (a.httt_id = b.id) ';
    open ref_ for s using l_tonghd,pma_tinh,to_date(ptu_ngay,'dd/mm/yyyy'),to_date(pden_ngay,'dd/mm/yyyy');
    return ref_;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
function thanh_toan(
    pmst varchar2,
    pma_tinh varchar2,
    pma_bc varchar2,
    phttt varchar2,
    pnguoigachno varchar2,
    pngay_tt varchar2,
    pquaythu varchar2,
    ptra varchar2,
    ptien_thuc varchar2
) return varchar2
is
    id_ varchar2(100):=util.getseq('PHIEUTRA_SEQ');
    s varchar2(30000);
    ckn varchar2(100):=crud.ckn_hientai();
    ptra_ util.StringArray;
    ptra_cn util.StringArray;
    n number;
    ref_ sys_refcursor;

    tientra_ NUMBER;
    tientra0_ NUMBER;
    tientra1_ NUMBER;
    tienno_ NUMBER;
    tiengiao_ NUMBER;
    ma_chuong_ VARCHAR2(100);
    ma_cq_thu_ VARCHAR2(100);
    ma_tmuc_ VARCHAR2(100);
    so_taikhoan_co_ VARCHAR2(100);
    so_qdinh_ VARCHAR2(100);
    ngay_qdinh_ VARCHAR2(100);
    loai_tien_ VARCHAR2(100);
    ti_gia_ VARCHAR2(100);
    loai_thue_ VARCHAR2(100);
    i_giao NUMBER;
    l_check number;
    l_message VARCHAR2(1000);
    l_ngaytra VARCHAR2(100):= to_char(sysdate,'dd/mm/yyyy');
    l_agent VARCHAR2(100);
    l_res number :=0;
    l_kythue varchar2(20);
    l_pattern varchar2(20);
    l_serial varchar2(20);
    l_flag number;
begin
    return 'BAN KHONG DUOC THAO TAC VOI DU LIEU CUA TINH KHAC';
    logger.access('portal.thanh_toan',pmst||'|'||pma_tinh||'|'||pma_bc||'|'||phttt||'|'||pnguoigachno||'|'||pngay_tt||'|'||pquaythu||'|'||substr(ptra,1,2000)||'|MONEY:'||ptien_thuc);
    l_agent := get_agent_taxcode(pmst);
    if l_agent <> pma_tinh then
        return 'BAN KHONG DUOC THAO TAC VOI DU LIEU CUA TINH KHAC';
    end if;

    SAVEPOINT sp1;
    s:='insert into bangphieutra_'||ckn||'(id,ma_tinh,mst,ma_bc,httt_id,nguoigachno_id,ngay_tt,ngay_thuc,quaythu_id) values (:id,:ma_tinh,:mst,:ma_bc,:httt_id,:nguoigachno,:ngay_tt,:ngay_thuc,:quaythu_id)';
    execute immediate s using id_,pma_tinh,pmst,pma_bc,phttt,pnguoigachno,nvl(to_date(pngay_tt,'dd/mm/yyyy'),sysdate),sysdate,pquaythu;
    ptra_ := util.str_to_array(ptra,'|');
    for n in ptra_.first..ptra_.last loop
        ptra_cn := util.str_to_array(ptra_(n),',');
        if (ptra_cn(4) <> 0) then
            begin
                s:='insert into ct_tra_'||ckn||' values ('''||id_||''','''||replace(ptra_(n),',',''',''')||''')';
                execute immediate s;
                l_res :=1;
                    exception when others then
                        rollback;
                        return to_char(sqlerrm);
            end;

            --Luu log du lieu thanh toan
            s:= ws_sms.CAMEL_PAYMENT(i_message=> ptra_(n));
        end if;

        --Lay tong tien tra theo luot thanh toan
        s:='select sum(tientra) from tax.ct_tra_'||ckn||' where mst =:1 and phieu_id =:2';
        execute immediate s into tientra0_  using pmst,id_;
        if tientra0_ = 0 then
            rollback;
            return 'SO TIEN THANH TOAN PHAI > 0';
        end if;
    end loop;

    --Cap nhat thong tin pattern, serial
    if ((phttt in (1,5)) and (pma_tinh='79TTT')) then
        begin
            s :='select replace(replace(b.ky_hieu,''MM'',to_char(sysdate,''MM'')),''YYYY'',to_char(sysdate,''YYYY'')),b.seri +1,b.flag
                    from nguoigachnos a, quaythus b where a.id =:1 and a.quaythu_id = b.id
                    and a.ma_tinh = b.ma_tinh and a.ma_tinh =:2 and rownum =1';
            execute immediate s into l_pattern,l_serial,l_flag using pnguoigachno,pma_tinh;
            exception when others then
            rollback;
            return 'CAU HINH THAM SO HOA DON SAI!';
        end;

        begin
            --Check KY_HIEU de reset lai SERI
            Execute immediate ' Select count(1) from bangphieutra_'||ckn||' where ma_tinh =:1 and ky_hieu =:2'
                into l_flag using pma_tinh,l_pattern;
            If (l_flag =0) then
                l_serial := 1;
            End if;

            --Cap nhat du lieu bang phieu tra
            Execute immediate ' Update bangphieutra_'||ckn||' set ky_hieu =:1, seri =:2 where id=:3 and mst=:4'
                    Using l_pattern,l_serial,id_,pmst;

            --Cap nhat du lieu seri theo to
            Execute immediate ' Update quaythus a set a.seri =:1, a.flag =:2
                                    where a.ma_tinh =:3
                                    and exists (select 1 from nguoigachnos b where b.id =:4 and a.id = b.quaythu_id)
                                    and rownum=1' Using l_serial,l_flag,pma_tinh,pnguoigachno;

            exception when others then
            rollback;
            return 'LOI CAP NHAT BANG PHIEU TRA !';
        end;
    End if;

    --Check tien thanh toan
    If (l_res =0) then
        rollback;
        return 'BAN KHONG DUOC PHEP THANH TOAN SO TIEN =0';
    End if;

    --Lay thong tin tong no
    s:= 'select sum(no_cuoi_ky) from tax.ct_no_'||ckn||' where mst =:1';
    execute immediate s into tienno_  using pmst;

    --Lay tong tien tra theo MST
    s:='select sum(tientra) from tax.ct_tra_'||ckn||' where mst =:1';
    execute immediate s into tientra_  using pmst;

    if ((tientra_ > tienno_) and (pma_tinh !='79TTT')) then
        rollback;
        return 'BAN KHONG DUOC PHEP THANH TOAN SO TIEN > TONG PHAI NOP';
    end if;

    s:='select count(1) from tax.phieu_'||ckn||'  where mst =:1';
    execute immediate s into i_giao  using pmst;

    if i_giao >0 then
        s:='select sum(tien_giao) from tax.phieu_'||ckn||'  where mst =:1';
        execute immediate s into tiengiao_  using pmst;

        s:='update tax.phieu_'||ckn||' set trangthai_tt = (case when '||tientra_||' < '||tiengiao_||' then 1
                                                            when '||tientra_||' = '||tiengiao_||' then 2
                                                            else 0 end) where mst =:1';
        execute immediate s using pmst;
    end if;


    --Lay tong tien tra theo luot thanh toan
    s:='select sum(tientra) from tax.ct_tra_'||ckn||' where mst =:1 and phieu_id =:2';
    execute immediate s into tientra1_  using pmst,id_;

    --Lay thong ky thue thuc hien thanh toan
    s:='select max(kythue) from tax.ct_tra_'||ckn||' where mst =:1 and phieu_id =:2 and rownum=1';
    execute immediate s into l_kythue  using pmst,id_;

    --Send request HDDT
    If (pma_tinh ='79TTT') then
        --Tao HDDT
        crud.enqueue_publish_inv(i_agent=> pma_tinh, i_taxcode=> pmst, i_month=> l_kythue, i_bill=> id_, i_cashier_code=> pnguoigachno);
    Else
        l_check := crud.check_info_dept(i_taxcode=> pmst, i_kythue=> l_kythue);
        If l_check >0 then
            crud.enqueue_el_bill(i_agent=> pma_tinh,i_taxcode => pmst,i_month => l_kythue,i_bill => id_,i_cashier_code => pnguoigachno,i_type => 1);
        End if;
    End if;

    commit;
    return id_;
    exception when others then
        declare err varchar2(500);
            begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); rollback;
            logger.access('tax.thanh_toan|ERR',err);
            return err;
    end;
end;
END;

/
