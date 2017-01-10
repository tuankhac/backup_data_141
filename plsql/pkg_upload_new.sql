--------------------------------------------------------
--  File created - Tuesday-January-10-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body PKG_UPLOAD_NEW
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "TAX"."PKG_UPLOAD_NEW" 
as
   msg0 varchar2(700) := 'Insert tu excel';
   msg1 VARCHAR2 (700) := 'OK';

   msg varchar2(700);

   msg2 VARCHAR2 (700) := 'MST khong ton tai UNT';
   msg3 VARCHAR2 (700) := 'MA_NV khong ton tai';
   msg8 VARCHAR2 (700) := 'MA_CQT khong ton tai';

   msg4 varchar2 (700) := 'MST sai thong tin MA_CQT';
   msg5 varchar2 (700) := 'MST , MA_NV khong thuoc tinh quan ly';
   msg6 varchar2(700) := '1 MST,1 MCQ ko the ton tai hon 1 MA_NV';
   msg9 VARCHAR2 (700) := 'MST co MA_NV khong null';
   msg7 varchar2(700) := 'Ban ghi nay da duoc chon';
  function Insert2DB(
    pID_Table varchar2,
    pma_tinh varchar2,
    ptype varchar2)
  return varchar2
  as
    s varchar2(1000);
    ref_ sys_refcursor;
    ma_cqt varchar2(100);
    mst varchar2(50);
    ma_nv varchar2(50);
    count_record number := 0;
  begin
    s:= 'select MST,MA_NV,ma_cqt from UPLOAD_MST_MANV_TEMP where Log_msg = :1 and status = 1 and id_table = :2 and ma_tinh = :3';
    msg := msg1;
    open ref_ for s using msg,pID_Table,pma_tinh;
      loop
        fetch ref_ into mst,ma_nv,ma_cqt;
        if ref_%notfound then exit; end if;
        s:= 'update nnts_2016 n set n.ma_nv =:1 where n.mst =:2 and n.ma_cqt_ql=:3 and n.ma_tinh=:4';
        execute immediate s using ma_nv,mst,ma_cqt,pma_tinh;
        count_record  := count_record + 1;
      end loop;
      commit;
      return to_char(count_record);
      exception when value_error then
        declare
          err varchar2 (500);
        begin
          err := 'Loi thuc hien , ma loi:' || TO_CHAR (SQLERRM);
          logger.access ('nnts_2016|update|ERR', err);
          return err;
        end;
  end;

  function UpdateLog(
      pid_table  varchar2,
      pma_tinh  varchar2,
      ptype  varchar2)
    return varchar2
  as
    s varchar2 (4000);
    s1 varchar2(1000);
    val sys_refcursor;

    mst varchar2(30);
    ma_nv varchar2(30);
    ma_cqt varchar2(30);
    id_ varchar2(30);
    count_ number;
    dem number := 0;

  begin
  --update bang UPLOAD_MST_MANV_TEMP voi msg5 varchar2 (700) := 'MST , MA_NV khong thuoc 1 tinh';
  update UPLOAD_MST_MANV_TEMP t set log_msg = msg5 where ((select n.ma_tinh from nnts_2016 n where n.mst = t.mst) <> t.ma_tinh
                        or (select nv.ma_tinh from nhanvien_tcs nv where nv.id = t.ma_nv) <> t.ma_tinh)
                        and id_table = ''||pID_Table||'' and t.ma_tinh = ''|| pma_tinh || '';
  --update bang UPLOAD_MST_MANV_TEMP voi msg2 VARCHAR2 (700) := 'MST ko ton tai trong bang NNTS_2016';
    update UPLOAD_MST_MANV_TEMP t SET log_msg = msg2
      where (select count(mst) from nnts_2016 where mst = t.mst) = 0
      and id_table = ''||pID_Table||'' and t.ma_tinh = ''|| pma_tinh || '';

    --update bang UPLOAD_MST_MANV_TEMP voi msg3 VARCHAR2 (700) := 'MA_NV ko ton tai trong bang NHANVIEN_TCS';
    update UPLOAD_MST_MANV_TEMP t  SET log_msg = msg3
      where (select count(id) from nhanvien_tcs where id = t.ma_nv) = 0
        and id_table = ''||pID_Table||'' and t.ma_tinh = ''|| pma_tinh || '' ;

     --update bang UPLOAD_MST_MANV_TEMP voi msg8 VARCHAR2 (700) := 'MA_CQT ko ton tai trong bang COQUANTHUS';
    update UPLOAD_MST_MANV_TEMP t  SET log_msg = msg8
      where (select count(id) from coquanthus where cqt_tms = t.ma_cqt) = 0
        and id_table = ''||pID_Table||''  and t.ma_tinh = ''|| pma_tinh || '';

     msg := msg1;
    --chon cac row trong bang UPLOAD_MST_MANV_TEMP thoa man la mst, ma_nv, mcq ton tai trong cac bang tuong ung
    -- va chi ton tai 1 row kho trung nhau
    s := 'select t.mst, t.ma_cqt  from UPLOAD_MST_MANV_TEMP t,nnts_2016 n,Nhanvien_Tcs nv,Coquanthus cq where
         n.mst = t.mst and n.MA_CQT_QL = t.ma_cqt and Nv.Id = t.ma_nv and  cq.cqt_tms = t.Ma_Cqt and
        t.id_table = :1 and t.ma_tinh = :2 and log_msg= :3';
      if ptype = '1' then s := s || ' and n.ma_nv is null ';
      end if;
    s:= s || ' group by t.mst, t.ma_cqt having count(*) = 1';
    open val for s using pid_table, pma_tinh,msg0;
    loop
      fetch val into mst,ma_cqt;
      if val%notfound then exit; end if;
      s := 'update UPLOAD_MST_MANV_TEMP tt set tt.log_msg = :1, tt.status = 1
                where tt.mst = :2 and tt.ma_cqt = :3 and log_msg = :4
                and tt.id_table = :5 and tt.ma_tinh = :6';
      execute immediate s using msg,mst,ma_cqt,msg0,pID_Table,pma_tinh;
    end loop;

    --chon cac row trong bang UPLOAD_MST_MANV_TEMP thoa man la mst, ma_nv, mcq ton tai trong cac bang tuong ung
    -- va chi ton tai hon 1 row  trung nhau
    s := 'select t.mst, t.ma_cqt  from UPLOAD_MST_MANV_TEMP t,nnts_2016 n,Nhanvien_Tcs nv,Coquanthus cq where
         n.mst = t.mst and n.MA_CQT_QL = t.ma_cqt and Nv.Id = t.ma_nv and  cq.cqt_tms = t.Ma_Cqt and
        t.id_table = :1 and t.ma_tinh = :2 and log_msg= :3 ';
      if ptype = '1' then s := s || ' and n.ma_nv is null ';
      end if;
        s:= s || ' group by t.mst, t.ma_cqt having count(*) > 1';
    open val for s using pid_table, pma_tinh,msg0;
    loop
      fetch val into mst,ma_cqt;
      if val%notfound then exit; end if;
      dem := dem + 1;
      s := 'select count(distinct tt.ma_nv) from UPLOAD_MST_MANV_TEMP tt
                where tt.mst = :1 and tt.ma_cqt = :2
                and ma_tinh = :3 and id_table = :4';
      execute immediate s into count_ using mst,ma_cqt,pma_tinh,pid_table;
      if count_ > 1 then
        s := 'update UPLOAD_MST_MANV_TEMP tt set tt.log_msg = :1, tt.status = 0
                where tt.mst = :2 and tt.ma_cqt = :3
                  and tt.id_table = :4 and tt.ma_tinh = :5 and tt.log_msg = :6';
        execute immediate s using msg6,mst,ma_cqt,pID_Table,pma_tinh,msg0;
      else
            s := 'update UPLOAD_MST_MANV_TEMP tt set tt.log_msg = :1, tt.status = 1
                    where tt.mst = :2 and tt.ma_cqt = :3
                    and tt.id_table = :4 and tt.ma_tinh = :5 and tt.log_msg = :6';
         execute immediate s using msg,mst,ma_cqt,pID_Table,pma_tinh,msg0;
      end if;
    end loop;

    --update bang UPLOAD_MST_MANV_TEMP voi msg4 VARCHAR2 (700) := 'MST sai thong tin MA_CQT';
    s := 'update UPLOAD_MST_MANV_TEMP t  SET log_msg = :1
      where (select count(1) from nnts_2016 nnt where nnt.mst = t.mst) = 1
        and (select count(1) from coquanthus where cqt_tms = t.ma_cqt) = 1
          and (select nnt.ma_cqt_ql from nnts_2016 nnt where nnt.mst = t.mst) <> t.ma_cqt
            and log_msg = :2
            and id_table = :3  and t.ma_tinh = :4';
    execute immediate s using msg4,msg0,pid_table, pma_tinh;

    if ptype = '1' then
        s := 'update upload_mst_manv_temp set log_msg = :1  where log_msg = :2';
        execute immediate s using msg9,msg0;
    end if;
    commit;
    return 'sucesss';
  exception  when value_error then
    declare
      err varchar2 (500);
    begin
      err := 'Loi thuc hien , ma loi:' || TO_CHAR (SQLERRM);
      logger.access ('nnts_2016|update|ERR', err);
      return err;
    end;
  end UpdateLog;

  function count_Records(
      table_name in varchar2,
      sqlwhere   in varchar2,
      pid_table  in varchar2,
      pma_tinh varchar2,
      ptype varchar2)
    return number
  as
    count_ number ;
    s varchar2(1000) ;
  begin
    s := 'SELECT COUNT(1) FROM ' || table_name || ' where 1=1';
    if sqlwhere is not null then s := s || ' and status = ' || sqlwhere;  end if;
    if pid_table is not null then s := s || ' and ID_TABLE = ''' || pid_table || '''';  end if;
    if pma_tinh is not null then  s:= s|| ' and ma_tinh = ''' || pma_tinh || '''';  end if;
    execute immediate s into count_;
    return count_;
    exception when value_error then
      declare
        err VARCHAR2 (1000);
      begin
        err := 'Loi thuc hien , ma loi:' || TO_CHAR (SQLERRM);
        logger.access ('nnts_2016|update|ERR', err);
        return err;
      end;
  end;

  function getrecords(
      table_name in varchar2,
      sqlwhere   in varchar2,
      id_table   in varchar2,
      precordperpage in varchar2,
      ppageindex in varchar2,
      pma_tinh varchar2,
      ptype varchar2)
    return sys_refcursor
  as
    s varchar2 (32000);
    ref_ sys_refcursor;
  begin
    s  := 'select id,mst,ma_nv,ma_cqt,log_msg from ' || table_name || ' where 1=1';
    if sqlwhere is not null then
      s := s || ' and status = ' || sqlwhere;
    end if;
    if id_table is not null then
      s := s || ' and ID_TABLE = ' || id_table;
    end if;
    if pma_tinh is not null then
        s:= s|| ' and ma_tinh = ''' || pma_tinh || '''';
    end if;
    s := s || ' order by id';

    open ref_ for util.xuly_phantrang (s, ppageindex, precordperpage);
    return ref_;
  exception when value_error then
    declare
      err varchar2 (1000);
    begin
      err := 'Loi thuc hien, ma loi:' || TO_CHAR (SQLERRM);
      open ref_ for 'select :1 err from dual' using err;
      return ref_;
    end;
  end;
  
  function is_number( p_str in varchar2 )
    return varchar2 
  is
    l_num number;
  begin
    l_num := to_number( p_str );
    if l_num < 0 then
      return 'N';
    end if;
    return 'Y';
  exception
    when value_error then
      return 'N';
  end is_number;
  
  function is_date(p_str in varchar2)
    return varchar2
  as
    l_date date;
  begin
      select to_date(p_str,'dd/mm/yyyy') into l_date from dual;
     if to_char(l_date,'dd/mm/yyyy') = p_str then
        return 'Y';
      end if;
    return 'N';
    exception
    when Others  then
      return 'N';
  end;
    
  function CheckDataNV(
      pid_table  varchar2,
      pma_tinh  varchar2,
      ptype  varchar2)
      return varchar2
  as
    msg varchar2(1000) ;
    
    vn_lower varchar2(1000) := 'à,á,ả,ã,ạ,â,ầ,ấ,ẩ,ẫ,ậ,ă,ằ,ắ,ẳ,ẵ,f,è,é,ẻ,ẽ,ẹ,ê,ề,ế,ể,ễ,ệ,ì,í,ỉ,ĩ,ị,ò,ó,ỏ,õ,ọ,ô,ồ,ố,ổ,ỗ,ộ,ơ,ờ,ớ,ở,ỡ,ợ,ù,ú,ủ,ũ,ụ,ư,ừ,ứ,ử,ữ,ự,ỳ,ý,ỷ,ỹ,ỵ,đ';
    vn_upper varchar2(1000) := 'À,Á,Ả,Ã,Ạ,Â,Ầ,Ấ,Ẩ,Ẫ,Ậ,Ă,Ằ,Ắ,Ẳ,Ẵ,Ặ,È,É,Ẻ,Ẽ,Ẹ,Ê,Ề,Ế,Ể,Ễ,Ệ,Ì,Í,Ỉ,Ĩ,Ị,Ò,Ó,Ỏ,Õ,Ọ,Ô,Ồ,Ố,Ổ,Ỗ,Ộ,Ơ,Ờ,Ớ,Ở,Ỡ,Ợ,Ù,Ú,Ủ,Ũ,Ụ,Ư,Ừ,Ứ,Ử,Ữ,Ự,Ỳ,Ý,Ỷ,Ỹ,Ỵ,Đ';
  begin
    -- update row ma nhan vien do da ton tai
    msg := 'Nhan vien nay da ton tai';
    update tax.upload_nhanvientcs_temp nv_temp set log_msg = msg where 
      (select count(1) from tax.nhanvien_tcs nv where nv.id = nv_temp.id) = 1 and
      log_msg = msg0 and id_table = ''||pID_Table||'' and nv_temp.ma_tinh = ''|| pma_tinh || '';
    -- update row ma truong cmtnd ko thoa man
    msg := 'CMTND can du tu 10 toi 12 so';
    update tax.upload_nhanvientcs_temp nv_temp set log_msg = msg where 
      not REGEXP_LIKE(cmtnd,'^[0-9]{10}') and  not REGEXP_LIKE(cmtnd,'^[0-9]{11}') and not REGEXP_LIKE(cmtnd,'^[0-9]{12}') and
      log_msg = msg0 and id_table = ''||pID_Table||'' and nv_temp.ma_tinh = ''|| pma_tinh || '';
     
    -- update row ma ten ko thoa man 
    msg := 'Ten khong duoc trong';
    update tax.upload_nhanvientcs_temp nv_temp set log_msg = msg where nv_temp.ten is null 
      and log_msg = msg0 and  id_table = ''||pID_Table||'' and nv_temp.ma_tinh = ''|| pma_tinh || '';
    -- update row ma dia chi ko thoa man 
    msg := 'Dia chi khong duoc trong';
    update tax.upload_nhanvientcs_temp nv_temp set log_msg = msg where nv_temp.dia_chi is null
      and log_msg = msg0 and  id_table = ''||pID_Table||'' and nv_temp.ma_tinh = ''|| pma_tinh || '';
    
    --update row ma tien dat coc ko dung
    msg := 'Tien dat coc phai la so khong am';
    update tax.upload_nhanvientcs_temp nv_temp set log_msg = msg where (nv_temp.tien_dcoc is null 
      or is_number(nv_temp.tien_dcoc) = 'N')
      and log_msg = msg0 and  id_table = ''||pID_Table||'' and nv_temp.ma_tinh = ''|| pma_tinh || '';
    -- update row ma ngay ko dung
    msg := 'Ngay phai dung dinh dang';
    update tax.upload_nhanvientcs_temp nv_temp set log_msg = msg where is_date(ngay_hd) = 'N'
      and log_msg = msg0 and  id_table = ''||pID_Table||'' and nv_temp.ma_tinh = ''|| pma_tinh || '';
    
    --update row ma ma buu cuc ko ton tai
    msg := 'Ma buu cuc khong ton tai';
    update tax.upload_nhanvientcs_temp nv_temp set log_msg = msg where 
      (select count(1) from tax.buucucthus bc where bc.id = nv_temp.ma_bc)  = 0
      and log_msg = msg0 and  id_table = ''||pID_Table||'' and nv_temp.ma_tinh = ''|| pma_tinh || '';
    commit;
    
    --update row ma so dien thoai sai
    msg := 'SDT can du tu 10 toi 12 so';
    update tax.upload_nhanvientcs_temp nv_temp set log_msg = msg where 
      not REGEXP_LIKE(sdt,'\d{10}') and  not REGEXP_LIKE(sdt,'\d{11}') and not REGEXP_LIKE(sdt,'\d{12}') and
      log_msg = msg0 and id_table = ''||pID_Table||'' and nv_temp.ma_tinh = ''|| pma_tinh || '';
    
    -- update row ma tien bo sung ko dung
     msg := 'Tien bo sung phai la so khong am';
    update tax.upload_nhanvientcs_temp nv_temp set log_msg = msg where (nv_temp.tien_bs is null 
      or is_number(nv_temp.tien_bs) = 'N')
      and log_msg = msg0 and  id_table = ''||pID_Table||'' and nv_temp.ma_tinh = ''|| pma_tinh || '';
      
    -- update row con lai la ok
     msg := 'OK';
    update tax.upload_nhanvientcs_temp nv_temp set log_msg = msg,status=1 where 
      log_msg = msg0 and  id_table = ''||pID_Table||'' and nv_temp.ma_tinh = ''|| pma_tinh || '';
    return '1';
  end;
  function getrecords_nv(
      table_name in varchar2,
      sqlwhere   in varchar2,
      id_table   in varchar2,
      precordperpage in varchar2,
      ppageindex in varchar2,
      pma_tinh varchar2,
      ptype varchar2)
    return sys_refcursor
  as
    s varchar2 (32000);
    ref_ sys_refcursor;
  begin
    s  := 'select id,cmtnd,ten,log_msg from ' || table_name || ' where 1=1';
    if sqlwhere is not null then
      s := s || ' and status = ' || sqlwhere;
    end if;
    if id_table is not null then
      s := s || ' and ID_TABLE = ' || id_table;
    end if;
    if pma_tinh is not null then
        s:= s|| ' and ma_tinh = ''' || pma_tinh || '''';
    end if;
    s := s || ' order by id';

    open ref_ for util.xuly_phantrang (s, ppageindex, precordperpage);
    return ref_;
  exception when value_error then
    declare
      err varchar2 (1000);
    begin
      err := 'Loi thuc hien, ma loi:' || TO_CHAR (SQLERRM);
      open ref_ for 'select :1 err from dual' using err;
      return ref_;
    end;
  end;
END PKG_UPLOAD_NEW;

/
