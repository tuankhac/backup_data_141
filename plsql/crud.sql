--------------------------------------------------------
--  File created - Tuesday-January-10-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body CRUD
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "TAX"."CRUD" 
IS
function new_user_info(
    pid varchar2,
    ppassword varchar2,
    pfirst_name varchar2,
    plast_name varchar2,
    pmobile varchar2,
    pdepartment varchar2,
    pemail varchar2,
    pgender varchar2,
    pstatus_id varchar2,
    pstaff varchar2,
    pserial_pos varchar2,
    pserial_card varchar2,
    pcreated_date varchar2,
    pmodified_date varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    l_agent varchar2(20);
begin
    l_agent := get_agent_user(PUSER=>pUserId);

    logger.access('user_info|NEW',pid||'|'||ppassword||'|'||pfirst_name||'|'||plast_name||'|'||pmobile||'|'||pdepartment||'|'||pemail||'|'||pgender||'|'||pstatus_id||'|'||pcreated_date||'|'||pmodified_date);
     s:='insert into user_info(id,password,first_name,last_name,mobile,department,email,gender,status_id,agent,staff,serial_pos,serial_card,created_date,cqt_tms)
     values (:id,:password,:first_name,:last_name,:mobile,:department,:email,:gender,:status_id,:agent,:staff,:serial_pos,:serial_card,:created_date,:cqt_tms)';
    execute immediate s using pid,util.getMd5(ppassword),pfirst_name,plast_name,tax.chuanhoa_somay(pmobile),pdepartment,pemail,pgender,pstatus_id,l_agent,pstaff,pserial_pos,pserial_card,SYSDATE,pmodified_date;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin
            err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
            logger.access('user_info|NEW|ERR',err);
            return err;

    end;
end;
function search_user_info(
    pid varchar2,
    ppassword varchar2,
    pfirst_name varchar2,
    plast_name varchar2,
    pmobile varchar2,
    pdepartment varchar2,
    pemail varchar2,
    pgender varchar2,
    pstatus_id varchar2,
    pstaff varchar2,
    pcreated_date varchar2,
    pmodified_date varchar2,
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
    l_agent := crud.search_agent_info(pUserId);

    s:='select * from user_info where agent ='''||l_agent||'''';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if ppassword is not null then s:=s||' and password like '''||replace(ppassword,'*','%')||''''; end if;
    if pfirst_name is not null then s:=s||' and first_name like '''||replace(pfirst_name,'*','%')||''''; end if;
    if plast_name is not null then s:=s||' and last_name like '''||replace(plast_name,'*','%')||''''; end if;
    if pmobile is not null then s:=s||' and mobile like '''||replace(pmobile,'*','%')||''''; end if;
    if pdepartment is not null then s:=s||' and department like '''||replace(pdepartment,'*','%')||''''; end if;
    if pemail is not null then s:=s||' and email like '''||replace(pemail,'*','%')||''''; end if;
    if pgender is not null then s:=s||' and gender like '''||replace(pgender,'*','%')||''''; end if;
    if pstaff is not null then s:=s||' and STAFF like '''||replace(pstaff,'*','%')||''''; end if;
    if pstatus_id is not null then s:=s||' and status_id like '''||replace(pstatus_id,'*','%')||''''; end if;
    if pcreated_date is not null then s:=s||' and created_date=to_date('''||pcreated_date||''',''dd/mm/yyyy'')'; end if;
    if pmodified_date is not null then s:=s||' and CQT_TMS='||pmodified_date||''; end if;
    s:=s||' order by id';
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
function edit_user_info(
    pid varchar2,
    ppassword varchar2,
    pfirst_name varchar2,
    plast_name varchar2,
    pmobile varchar2,
    pdepartment varchar2,
    pemail varchar2,
    pgender varchar2,
    pstatus_id varchar2,
    pstaff varchar2,
    pserial_pos varchar2,
    pserial_card varchar2,
    pcreated_date varchar2,
    pmodified_date varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('user_info|EDIT',pid||'|'||ppassword||'|'||pfirst_name||'|'||plast_name||'|'||pmobile||'|'||pdepartment||'|'||pemail||'|'||pgender||'|'||pstatus_id||'|'||pcreated_date||'|'||pmodified_date);
     s:='update user_info set first_name=:first_name,last_name=:last_name,mobile=:mobile,department=:department,email=:email,gender=:gender,status_id=:status_id,modified_date=:modified_date,staff=:staff,serial_pos=:serial_pos,serial_card=:serial_card,cqt_tms=:cqt_tms where id=:id';
    execute immediate s using pfirst_name,plast_name,tax.chuanhoa_somay(pmobile),pdepartment,pemail,pgender,pstatus_id,sysdate,pstaff,pserial_pos,pserial_card,pmodified_date,pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin
            err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
            logger.access('user_info|EDIT|ERR',err);
            return err;
    end;
end;
function del_user_info(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    l_exists number;
    ckn varchar2(100):=ckn_hientai();
begin
    logger.access('user_info|DEL',pId);
    execute immediate 'select count(1) from bangphieutra_'||ckn||' where nguoigachno_id =:1 and rownum=1' into l_exists using pId;
    if l_exists >0 then
        return 'USER DA THUC HIEN THU THUE -> KHONG DUOC PHEP XOA';
    end if;

    s:='delete from user_info where id=:id';
    execute immediate s using pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin
            err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
            logger.access('user_info|DEL|ERR',err);
        return err;
    end;
end;

function change_pass_user_info(
    pPassOld varchar2,
    pPassNew varchar2,
    pPassConfirm varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    l_count number;
begin
    s:= 'select count(1) from tax.user_info where id = '''||pUserId||''' and password = '''||util.getMd5(pPassOld)||'''';
    dbms_output.put_line(s);
    execute immediate s into l_count;
    if l_count=0 then
        return 'Mat khau cu khong dung -> vui long kiem tra lai';
    end if;

    logger.access('user_info|change_pass_user_info',pUserId);
    s:='update user_info set password=:1 where id=:2 and password =:3';

    execute immediate s using util.getMd5(pPassNew),pUserId,util.getMd5(pPassOld);
    dbms_output.put_line(s);
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('user_info|PASS|ERR',err);
        return err;
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
    s:='insert into role(id,role_name,description,agent)
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
function search_role(
    pid varchar2,
    prole_name varchar2,
    pdescription varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    l_agent varchar2(10);
    l_lever number;
begin
    select role_lever into l_lever  from user_info where id = pUserId and rownum=1;
    s:='select * from role where 1=1';
    if (l_lever < 5) then
        l_agent := tax.get_agent_user(puser=> pUserId);
        s:=s||' and agent = '''||l_agent||'''';
    end if;
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
    s:='update role set role_name=:role_name,description=:description where id=:id';
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
    s:='delete from role where id=:id';
    execute immediate s using pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('del_role|ERR',err);
        return err;
    end;
end;
function edit_user_role(
    pUser varchar2,
    proles varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    rs_ util.stringarray;
    n number;
begin
    logger.access('edit_user_role|edit_user_role',puser||'|'||proles||'|'||puserid);
    s:='delete from user_role where user_id=:1';
    execute immediate s using pUser;

    rs_:=util.str_to_array(proles);
       for n in rs_.first..rs_.last loop
          s:='insert into user_role values (:1,:2,:3)';
          execute immediate s using util.GETSEQ('USER_ROLE_SEQ'),rs_(n),pUser;
       end loop;

    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('edit_user_role|ERR',err);
        return err;
    end;
end;
function edit_menu_access(
    pRole varchar2,
    pMenus varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    rs_ util.stringarray;
    n number;
begin
    logger.access('edit_menu_access|edit_user_role',prole||'|'||pmenus||'|'||puserid);
    s:='delete from menu_access where role_id=:1';
    execute immediate s using pRole;

    rs_:=util.str_to_array(pMenus);
       for n in rs_.first..rs_.last loop
          s:='insert into menu_access values (:1,:2,:3)';
          execute immediate s using util.GETSEQ('MENU_ACCESS_SEQ'),pRole,rs_(n);
       end loop;

    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('edit_menu_access|ERR',err);
        return err;
    end;
end;

function new_menu(
    pid varchar2,
    pname varchar2,
    pdisplay_order varchar2,
    ppicture_file varchar2,
    pdetail_file varchar2,
    pmenu_level varchar2,
    pparent_id varchar2,
    ppublish varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('menu|NEW',pid||'|'||pname||'|'||pdisplay_order||'|'||ppicture_file||'|'||pdetail_file||'|'||pmenu_level||'|'||pparent_id||'|'||ppublish);
    s:='insert into menu(id,name,display_order,picture_file,detail_file,menu_level,parent_id,publish)
     values (:id,:name,:display_order,:picture_file,:detail_file,:menu_level,:parent_id,:publish)';
    execute immediate s using pid,pname,pdisplay_order,ppicture_file,pdetail_file,pmenu_level,pparent_id,ppublish;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('new_menu|ERR',err);
        return err;
    end;
end;
function search_menu(
    pid varchar2,
    pname varchar2,
    pdisplay_order varchar2,
    ppicture_file varchar2,
    pdetail_file varchar2,
    pmenu_level varchar2,
    pparent_id varchar2,
    ppublish varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    s:='select a.*,lpad(name,(menu_level-1)*24+length(name),''&nbsp;'') name_lpad from menu a where 1=1 ';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if pname is not null then s:=s||' and name like '''||replace(pname,'*','%')||''''; end if;
    if pdisplay_order is not null then s:=s||' and display_order like '''||replace(pdisplay_order,'*','%')||''''; end if;
    if ppicture_file is not null then s:=s||' and picture_file like '''||replace(ppicture_file,'*','%')||''''; end if;
    if pdetail_file is not null then s:=s||' and detail_file like '''||replace(pdetail_file,'*','%')||''''; end if;
    if pmenu_level is not null then s:=s||' and menu_level like '''||replace(pmenu_level,'*','%')||''''; end if;
    if pparent_id is not null then s:=s||' and parent_id like '''||replace(pparent_id,'*','%')||''''; end if;
    if ppublish is not null then s:=s||' and publish like '''||replace(ppublish,'*','%')||''''; end if;
    s:=s||' order by decode(parent_id,0,id,parent_id),display_order';
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
function edit_menu(
    pid varchar2,
    pname varchar2,
    pdisplay_order varchar2,
    ppicture_file varchar2,
    pdetail_file varchar2,
    pmenu_level varchar2,
    pparent_id varchar2,
    ppublish varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('menu|EDIT',pid||'|'||pname||'|'||pdisplay_order||'|'||ppicture_file||'|'||pdetail_file||'|'||pmenu_level||'|'||pparent_id||'|'||ppublish);
    s:='update menu set  id=:id,name=:name,display_order=:display_order,picture_file=:picture_file,detail_file=:detail_file,menu_level=:menu_level,parent_id=:parent_id,publish=:publish where id=:id';
    execute immediate s using pid,pname,pdisplay_order,ppicture_file,pdetail_file,pmenu_level,pparent_id,ppublish,pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('edit_menu|ERR',err);
        return err;
    end;
end;
function del_menu(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('menu|DEL',pId);
    s:='delete from menu where id=:id';
    execute immediate s using pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('del_menu|ERR',err);
        return err;
    end;
end;
function new_user_status(
    pid varchar2,
    pstatus_name varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    s:='insert into user_status(id,status_name)
     values (:id,:status_name)';
    execute immediate s using pid,pstatus_name;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('new_user_status|ERR',err);
        return err;
    end;
end;
function search_user_status(
    pid varchar2,
    pstatus_name varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin

    s:='select * from user_status where 1=1';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if pstatus_name is not null then s:=s||' and status_name like '''||replace(pstatus_name,'*','%')||''''; end if;
    s:=s||' order by id';
    open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function search_info_bill(pphieu varchar2,
    pma_tinh varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ckn varchar2(100):=ckn_hientai();
    ref_ sys_refcursor;
begin
    s:='select a.mst,a.ma_tmuc,to_char(a.tientra,''fm999,999,999,999'') tientra,(select TEN_CHUONG from  tax.chuongs where a.ma_chuong = id) ten_chuong,
        (select TENTIEUMUC from  tax.tieu_mucs where a.ma_tmuc = id) ten_muc, a.phieu_id, to_char(b.ngay_tt,''dd/mm/yyyy hh24:mi:ss'') ngay_tt
         from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b
        where a.phieu_id = b.id
        and a.phieu_id =:1
        and a.ma_tinh =:2';
    open ref_ for s using pphieu,pma_tinh;
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function search_info_bill_his(pmst varchar2,
    pma_tinh varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ckn varchar2(100):=ckn_hientai();
    ref_ sys_refcursor;
    l_agent varchar2(20);
begin

    If pma_tinh is null then
        Execute immediate 'Select ma_tinh from nnts_'||ckn||' where mst =:1' into l_agent using pmst;
    Else
        l_agent := pma_tinh;
    End if;

    s:='select a.mst,a.kythue,a.chuky,to_char(a.tientra,''fm999,999,999,999'') tientra,(select TEN_CHUONG from  tax.chuongs where a.ma_chuong = id) ten_chuong,
        (select TENTIEUMUC from  tax.tieu_mucs where a.ma_tmuc = id) ten_muc, a.phieu_id, to_char(b.ngay_tt,''dd/mm/yyyy hh24:mi:ss'') ngay_tt, b.nguoigachno_id nguoi_tt
         from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b
        where a.phieu_id = b.id
        and a.mst =:1
        and a.ma_tinh =:2';
    open ref_ for s using pmst,l_agent;
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function edit_user_status(
    pid varchar2,
    pstatus_name varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('user_status|EDIT',pid||'|'||pstatus_name);
    s:='update user_status set  id=:id,status_name=:status_name where id=:id';
    execute immediate s using pid,pstatus_name,pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('edit_user_status|ERR',err);
        return err;
    end;
end;
function del_user_status(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('user_status|DEL',pId);
    s:='delete from user_status where id=:id';
    execute immediate s using pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('del_user_status|ERR',err);
        return err;
    end;
end;
function new_user_role(
    pid varchar2,
    prole_id varchar2,
    puser_id varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('user_role|NEW',pid||'|'||prole_id||'|'||puser_id);
    s:='insert into user_role(id,role_id,user_id)
     values (:id,:role_id,:user_id)';
    execute immediate s using pid,prole_id,puser_id;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('new_user_role|ERR',err);
        return err;
    end;
end;
function search_user_role(
    pid varchar2,
    prole_id varchar2,
    puser_id varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin

    s:='select * from user_role where 1=1';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if prole_id is not null then s:=s||' and role_id like '''||replace(prole_id,'*','%')||''''; end if;
    if puser_id is not null then s:=s||' and user_id like '''||replace(puser_id,'*','%')||''''; end if;
    s:=s||' order by id';
    open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
function search_agent_info(pid varchar2) return varchar2
is
    l_agent varchar2(100);
    s varchar2(1000);
begin
    s:='select agent from tax.user_info where id =:1 and rownum =1';
    Execute immediate s into l_agent using pid;
    Return l_agent;
    Exception when others then
        Return '0';
end;

function edit_user_role(
    pid varchar2,
    prole_id varchar2,
    puser_id varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('user_role|EDIT',pid||'|'||prole_id||'|'||puser_id);
    s:='update user_role set  id=:id,role_id=:role_id,user_id=:user_id where id=:id';
    execute immediate s using pid,prole_id,puser_id,pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('edit_user_role|ERR',err);
        return err;
    end;
end;
function del_user_role(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('user_role|DEL',pId);
    s:='delete from user_role where id=:id';
    execute immediate s using pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('del_user_role|ERR',err);
        return err;
    end;
end;
function getcolor(id number) return varchar2
is
begin
    if mod(id,6)=0 then return '#f56954'; end if;
    if mod(id,6)=1 then return '#f39c12'; end if;
    if mod(id,6)=2 then return '#0073b7'; end if;
    if mod(id,6)=3 then return '#00c0ef'; end if;
    if mod(id,6)=4 then return '#00a65a'; end if;
    if mod(id,6)=5 then return '#3c8dbc'; end if;
end;
function new_tieu_mucs(
    pid varchar2,
    ptentieumuc varchar2,
    pma_muc varchar2,
    phieu_luc_tu varchar2,
    phieu_luc_den varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    --logger.access('tax.tieu_mucs|NEW',pid||'|'||ptentieumuc||'|'||pma_muc||'|'||phieu_luc_tu||'|'||phieu_luc_den);
    s:='insert into tax.tieu_mucs(id,tentieumuc,ma_muc,hieu_luc_tu,hieu_luc_den)
     values (:id,:tentieumuc,:ma_muc,:hieu_luc_tu,:hieu_luc_den)';
    execute immediate s using pid,ptentieumuc,pma_muc,phieu_luc_tu,phieu_luc_den;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('new_tieu_mucs|ERR',err);
        return err;
    end;
end;
function search_tieu_mucs(
    pid varchar2,
    ptentieumuc varchar2,
    pma_muc varchar2,
    phieu_luc_tu varchar2,
    phieu_luc_den varchar2,
    pType varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin

    s:='select * from tax.tieu_mucs where 1=1';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if ptentieumuc is not null then s:=s||' and tentieumuc like '''||replace(ptentieumuc,'*','%')||''''; end if;
    if pma_muc is not null then s:=s||' and ma_muc like '''||replace(pma_muc,'*','%')||''''; end if;
    if phieu_luc_tu is not null then s:=s||' and hieu_luc_tu like '''||replace(phieu_luc_tu,'*','%')||''''; end if;
    if phieu_luc_den is not null then s:=s||' and hieu_luc_den like '''||replace(phieu_luc_den,'*','%')||''''; end if;
    s:=s||' order by id';
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
function edit_tieu_mucs(
    pid varchar2,
    ptentieumuc varchar2,
    pma_muc varchar2,
    phieu_luc_tu varchar2,
    phieu_luc_den varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    s:='update tax.tieu_mucs set  id=:id,tentieumuc=:tentieumuc,ma_muc=:ma_muc,hieu_luc_tu=:hieu_luc_tu,hieu_luc_den=:hieu_luc_den where id=:id';
    execute immediate s using pid,ptentieumuc,pma_muc,phieu_luc_tu,phieu_luc_den,pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('edit_tieu_mucs|ERR',err);
        return err;
    end;
end;
function del_tieu_mucs(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin

    s:='delete from tax.tieu_mucs where id=:id';
    execute immediate s using pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('del_tieu_mucs|ERR',err);
        return err;
    end;
end;
function new_quaythus(
    pid varchar2,
    pma_tinh varchar2,
    ptenquay varchar2,
    pdiachi varchar2,
    ptel varchar2,
    pfax varchar2,
    ptruongquay varchar2,
    pmabc_id varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    --logger.access('tax.quaythus|NEW',pid||'|'||pma_tinh||'|'||ptenquay||'|'||pdiachi||'|'||ptel||'|'||pfax||'|'||ptruongquay||'|'||pmabc_id);
    s:='insert into tax.quaythus(id,ma_tinh,tenquay,diachi,tel,fax,truongquay,mabc_id)
     values (:id,:ma_tinh,:tenquay,:diachi,:tel,:fax,:truongquay,:mabc_id)';
    execute immediate s using pid,pma_tinh,ptenquay,pdiachi,ptel,pfax,ptruongquay,pmabc_id;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('new_quaythus|ERR',err);
        return err;
    end;
end;
function search_quaythus(
    pid varchar2,
    pma_tinh varchar2,
    ptenquay varchar2,
    pdiachi varchar2,
    ptel varchar2,
    pfax varchar2,
    ptruongquay varchar2,
    pmabc_id varchar2,
    pType varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin

    s:='select * from tax.quaythus where 1=1';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
    if ptenquay is not null then s:=s||' and tenquay like '''||replace(ptenquay,'*','%')||''''; end if;
    if pdiachi is not null then s:=s||' and diachi like '''||replace(pdiachi,'*','%')||''''; end if;
    if ptel is not null then s:=s||' and tel like '''||replace(ptel,'*','%')||''''; end if;
    if pfax is not null then s:=s||' and fax like '''||replace(pfax,'*','%')||''''; end if;
    if ptruongquay is not null then s:=s||' and truongquay like '''||replace(ptruongquay,'*','%')||''''; end if;
    if pmabc_id is not null then s:=s||' and mabc_id like '''||replace(pmabc_id,'*','%')||''''; end if;
    s:=s||' order by id';

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
function edit_quaythus(
    pid varchar2,
    pma_tinh varchar2,
    ptenquay varchar2,
    pdiachi varchar2,
    ptel varchar2,
    pfax varchar2,
    ptruongquay varchar2,
    pmabc_id varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.quaythus|EDIT',pid||'|'||pma_tinh||'|'||ptenquay||'|'||pdiachi||'|'||ptel||'|'||pfax||'|'||ptruongquay||'|'||pmabc_id);
    s:='update tax.quaythus set tenquay=:tenquay,diachi=:diachi,tel=:tel,fax=:fax,truongquay=:truongquay,mabc_id=:mabc_id where id=:id and ma_tinh=:ma_tinh';
    execute immediate s using ptenquay,pdiachi,ptel,pfax,ptruongquay,pmabc_id,pid,pma_tinh;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_quaythus(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    l_agent varchar2(50);
begin
    --logger.access('tax.quaythus|DEL',pId);
    l_agent := get_agent_user(PUSER=>pUserId);
    s:='delete from tax.quaythus where id=:id and ma_tinh=:ma_tinh';
    execute immediate s using pid,l_agent;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function new_nhanvien_tcs(
    pid varchar2,
    pma_tinh varchar2,
    pso_cmnd varchar2,
    pten_nv varchar2,
    pdiachi varchar2,
    pnguoi_bl varchar2,
    ptien_dc varchar2,
    ptien_bs varchar2,
    pso_hd varchar2,
    pngay_hd varchar2,
    pmabc_id varchar2,
    pmobile varchar2,
    pemail varchar2,
    ptitle varchar2, psource varchar2, pdescription varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(3000);
    n number;
begin
    SAVEPOINT p1;
    s:='select count(*) from tax.nhanvien_tcs where id=:id ';
    execute IMMEDIATE s into n using pid;
    if n>0 then
        return 'EXIST';
    end if;

    --logger.access('tax.nhanvien_tcs|NEW',pid||'|'||pma_tinh||'|'||pso_cmnd||'|'||pten_nv||'|'||pdiachi||'|'||pnguoi_bl||'|'||ptien_dc||'|'||pso_hd||'|'||pngay_hd||'|'||pmabc_id||'|'||pmobile||'|'||pemail);
    s:='insert into tax.nhanvien_tcs(id,ma_tinh,so_cmnd,ten_nv,diachi,nguoi_bl,tien_dc,tien_bs,so_hd,ngay_hd,mabc_id,mobile,email)
     values (:id,:ma_tinh,:so_cmnd,:ten_nv,:diachi,:nguoi_bl,:tien_dc,:tien_bs,:so_hd,:ngay_hd,:mabc_id,:mobile,:email)';

    execute immediate s using pid,pma_tinh,pso_cmnd,pten_nv,pdiachi,pnguoi_bl,ptien_dc,ptien_bs,pso_hd,to_date(pngay_hd,'dd/mm/yyyy'),pmabc_id,pmobile,pemail;
    --create new image util.GETSEQ('IMAGE_SEQ')
    if(psource is not null) then
        logger.access('tax.image|NEW',pid||'|'||ptitle||'|'||psource||'|'||pdescription||'|'||sysdate||'|'||sysdate||'|'||pUserId||'|'||pUserId||'|'||pid);
        s:='insert into tax.image(id,title,source,description,created_date,modified_date,created_user,modified_user,nhanvien_tcs_id)
         values (:id,:title,:source,:description,:created_date,:modified_date,:created_user,:modified_user,:nhanvien_tcs_id)';
         dbms_output.put_line(s);
        execute immediate s using to_char(util.GETSEQ('IMAGE_SEQ')),ptitle,psource,pdescription,sysdate,sysdate,pUserId,pUserId,pid;
    end if;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin ROLLBACK TO p1; err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;

end;
function search_nhanvien_tcs(
    pid varchar2,
    pma_tinh varchar2,
    pso_cmnd varchar2,
    pten_nv varchar2,
    pdiachi varchar2,
    pnguoi_bl varchar2,
    ptien_dc varchar2,
    pso_hd varchar2,
    pngay_hd varchar2,
    pmabc_id varchar2,
    pmobile varchar2,
    pemail varchar2,
    pType varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    s:='select * from tax.nhanvien_tcs where 1=1';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
    if pso_cmnd is not null then s:=s||' and so_cmnd like '''||replace(pso_cmnd,'*','%')||''''; end if;
    if pten_nv is not null then s:=s||' and ten_nv like '''||replace(pten_nv,'*','%')||''''; end if;
    if pdiachi is not null then s:=s||' and diachi like '''||replace(pdiachi,'*','%')||''''; end if;
    if pnguoi_bl is not null then s:=s||' and nguoi_bl like '''||replace(pnguoi_bl,'*','%')||''''; end if;
    if ptien_dc is not null then s:=s||' and tien_dc like '''||replace(ptien_dc,'*','%')||''''; end if;
    if pso_hd is not null then s:=s||' and so_hd like '''||replace(pso_hd,'*','%')||''''; end if;
    if pngay_hd is not null then s:=s||' and ngay_hd=to_date('''||pngay_hd||''',''dd/mm/yyyy'')'; end if;
    if pmabc_id is not null then s:=s||' and mabc_id like '''||replace(pmabc_id,'*','%')||''''; end if;
    if pmobile is not null then s:=s||' and mobile like '''||replace(pmobile,'*','%')||''''; end if;
    if pemail is not null then s:=s||' and email like '''||replace(pemail,'*','%')||''''; end if;
    s:=s||' order by id';

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
function edit_nhanvien_tcs(
    pid varchar2,
    pma_tinh varchar2,
    pso_cmnd varchar2,
    pten_nv varchar2,
    pdiachi varchar2,
    pnguoi_bl varchar2,
    ptien_dc varchar2,
    ptien_bs varchar2,
    pso_hd varchar2,
    pngay_hd varchar2,
    pmabc_id varchar2,
    pmobile varchar2,
    pemail varchar2,
    ptitle varchar2, psource varchar2, pdescription varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    n number;
begin

    --logger.access('tax.nhanvien_tcs|EDIT',pid||'|'||pma_tinh||'|'||pso_cmnd||'|'||pten_nv||'|'||pdiachi||'|'||pnguoi_bl||'|'||ptien_dc||'|'||pso_hd||'|'||pngay_hd||'|'||pmabc_id||'|'||pmobile||'|'||pemail);
    s:='update tax.nhanvien_tcs set  so_cmnd=:so_cmnd,ten_nv=:ten_nv,diachi=:diachi,nguoi_bl=:nguoi_bl,tien_dc=:tien_dc,tien_bs=:tien_bs,so_hd=:so_hd,ngay_hd=:ngay_hd,mabc_id=:mabc_id,mobile=:mobile,email=:email
            where id=:id and ma_tinh=:ma_tinh';
    execute immediate s using pso_cmnd,pten_nv,pdiachi,pnguoi_bl,ptien_dc,ptien_bs,pso_hd,to_date(pngay_hd,'dd/mm/yyyy'),pmabc_id,pmobile,pemail,pid,pma_tinh;
    --update image
    if(psource is not null) then
        --xoa link image cu
        s:='select count(*) from tax.image where nhanvien_tcs_id=:id';
        execute immediate s into n using pid;
        if n > 0 then
            s:= 'delete from tax.image where nhanvien_tcs_id=:id';
            execute immediate s using pid;
        end if;
        --insert link image moi
        logger.access('tax.image|NEW',pid||'|'||ptitle||'|'||psource||'|'||pdescription||'|'||sysdate||'|'||sysdate||'|'||pUserId||'|'||pUserId||'|'||pid);
        s:='insert into tax.image(id,title,source,description,created_date,modified_date,created_user,modified_user,nhanvien_tcs_id)
         values (:id,:title,:source,:description,:created_date,:modified_date,:created_user,:modified_user,:nhanvien_tcs_id)';
         dbms_output.put_line(s);
        execute immediate s using to_char(util.GETSEQ('IMAGE_SEQ')),ptitle,psource,pdescription,sysdate,sysdate,pUserId,pUserId,pid;
    end if;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_nhanvien_tcs(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    n number;
    l_agent varchar2(50);
begin
    SAVEPOINT p1;
    l_agent := get_agent_user(PUSER=>pUserId);
    s:='delete from tax.nhanvien_tcs where id=:id and ma_tinh=:ma_tinh';
    execute immediate s using pid,l_agent;
    s:='select count(*) from tax.image where nhanvien_tcs_id=:id';
    execute immediate s into n using pid;
    if n>0 then
        logger.access('tax.nhanvien_tcs|DEL',pId);
        s:='delete from tax.image where nhanvien_tcs_id=:id';
        execute immediate s using pid;
    end if;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function search_image(
    pid varchar2,
    ptitle varchar2,
    psource varchar2,
    pdescription varchar2,
    pcreated_date varchar2,
    pmodified_date varchar2,
    pcreated_user varchar2,
    pmodified_user varchar2,
    pnhanvien_tcs_id varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    s:='select * from tax.image where 1=1';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if ptitle is not null then s:=s||' and title like '''||replace(ptitle,'*','%')||''''; end if;
    if psource is not null then s:=s||' and source like '''||replace(psource,'*','%')||''''; end if;
    if pdescription is not null then s:=s||' and description like '''||replace(pdescription,'*','%')||''''; end if;
    if pcreated_date is not null then s:=s||' and created_date=to_date('''||pcreated_date||''',''dd/mm/yyyy'')'; end if;
    if pmodified_date is not null then s:=s||' and modified_date=to_date('''||pmodified_date||''',''dd/mm/yyyy'')'; end if;
    if pcreated_user is not null then s:=s||' and created_user like '''||replace(pcreated_user,'*','%')||''''; end if;
    if pmodified_user is not null then s:=s||' and modified_user like '''||replace(pmodified_user,'*','%')||''''; end if;
    if pnhanvien_tcs_id is not null then s:=s||' and nhanvien_tcs_id like '''||replace(pnhanvien_tcs_id,'*','%')||''''; end if;
    s:=s||' order by id';
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
function new_nguoigachnos(
    pid varchar2,
    pma_tinh varchar2,
    phovaten varchar2,
    pmabc_id varchar2,
    pquaythu_id varchar2,
    pgn_luingay varchar2,
    pxp_luingay varchar2,
    pseri varchar2,
    pkyhieu varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    --logger.access('tax.nguoigachnos|NEW',pid||'|'||pma_tinh||'|'||phovaten||'|'||pmabc_id||'|'||pquaythu_id||'|'||pgn_luingay||'|'||pxp_luingay);
    s:='insert into tax.nguoigachnos(id,ma_tinh,hovaten,mabc_id,quaythu_id,gn_luingay,xp_luingay,seri,ky_hieu)
     values (:id,:ma_tinh,:hovaten,:mabc_id,:quaythu_id,:gn_luingay,:xp_luingay,:seri,:ky_hieu)';
    execute immediate s using pid,pma_tinh,phovaten,pmabc_id,pquaythu_id,pgn_luingay,pxp_luingay,pseri,pkyhieu;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function search_nguoigachnos(
    pid varchar2,
    pma_tinh varchar2,
    phovaten varchar2,
    pmabc_id varchar2,
    pquaythu_id varchar2,
    pgn_luingay varchar2,
    pxp_luingay varchar2,
    pType varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    s:='select id, ma_tinh, hovaten, mabc_id, quaythu_id,
       gn_luingay, xp_luingay, seri, ky_hieu, vnpt from tax.nguoigachnos where 1=1';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
    if phovaten is not null then s:=s||' and hovaten like '''||replace(phovaten,'*','%')||''''; end if;
    if pmabc_id is not null then s:=s||' and mabc_id like '''||replace(pmabc_id,'*','%')||''''; end if;
    if pquaythu_id is not null then s:=s||' and quaythu_id like '''||replace(pquaythu_id,'*','%')||''''; end if;
    if pgn_luingay is not null then s:=s||' and gn_luingay like '''||replace(pgn_luingay,'*','%')||''''; end if;
    if pxp_luingay is not null then s:=s||' and xp_luingay like '''||replace(pxp_luingay,'*','%')||''''; end if;
    s:=s||' order by id';
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
function edit_nguoigachnos(
    pid varchar2,
    pma_tinh varchar2,
    phovaten varchar2,
    pmabc_id varchar2,
    pquaythu_id varchar2,
    pgn_luingay varchar2,
    pxp_luingay varchar2,
    pseri varchar2,
    pkyhieu varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.nguoigachnos|EDIT',pid||'|'||pma_tinh||'|'||phovaten||'|'||pmabc_id||'|'||pquaythu_id||'|'||pgn_luingay||'|'||pxp_luingay||'|'||pseri||'|'||pkyhieu);
    s:='update tax.nguoigachnos set hovaten=:hovaten,mabc_id=:mabc_id,quaythu_id=:quaythu_id,gn_luingay=:gn_luingay,xp_luingay=:xp_luingay,seri=:seri,ky_hieu=:kyhieu
            where id=:id and ma_tinh=:ma_tinh';
    execute immediate s using phovaten,pmabc_id,pquaythu_id,pgn_luingay,pxp_luingay,pseri,pkyhieu,pid,pma_tinh;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_nguoigachnos(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    l_agent varchar2(50);
begin
    logger.access('tax.nguoigachnos|DEL',pId);
    l_agent := get_agent_user(PUSER=>pUserId);
    s:='delete from tax.nguoigachnos where id=:id and ma_tinh=:ma_tinh';
    execute immediate s using pid,l_agent;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function search_khobacs(
    pid varchar2,
    pten_kho_bac varchar2,
    pma_tructiep varchar2,
    phieu_luc_tu varchar2,
    phieu_luc_den varchar2,
    pType varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    s:='select * from tax.khobacs where 1=1';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if pten_kho_bac is not null then s:=s||' and ten_kho_bac like '''||replace(pten_kho_bac,'*','%')||''''; end if;
    if pma_tructiep is not null then s:=s||' and ma_tructiep like '''||replace(pma_tructiep,'*','%')||''''; end if;
    if phieu_luc_tu is not null then s:=s||' and hieu_luc_tu like '''||replace(phieu_luc_tu,'*','%')||''''; end if;
    if phieu_luc_den is not null then s:=s||' and hieu_luc_den like '''||replace(phieu_luc_den,'*','%')||''''; end if;
    s:=s||' order by id';
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
function search_khoans(
    pid varchar2,
    ptenkhoan varchar2,
    pma_loai varchar2,
    phieu_luc_tu varchar2,
    phieu_luc_den varchar2,
    pType varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    s:='select * from tax.khoans where 1=1';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if ptenkhoan is not null then s:=s||' and tenkhoan like '''||replace(ptenkhoan,'*','%')||''''; end if;
    if pma_loai is not null then s:=s||' and ma_loai like '''||replace(pma_loai,'*','%')||''''; end if;
    if phieu_luc_tu is not null then s:=s||' and hieu_luc_tu like '''||replace(phieu_luc_tu,'*','%')||''''; end if;
    if phieu_luc_den is not null then s:=s||' and hieu_luc_den like '''||replace(phieu_luc_den,'*','%')||''''; end if;
    s:=s||' order by id';
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
function new_hinhthuc_tts(
    pid varchar2,
    pname varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.hinhthuc_tts|NEW',pid||'|'||pname);
    s:='insert into tax.hinhthuc_tts(id,name)
     values (:id,:name)';
    execute immediate s using pid,pname;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function search_hinhthuc_tts(
    pid varchar2,
    pname varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin

    s:='select * from tax.hinhthuc_tts where 1=1';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if pname is not null then s:=s||' and name like '''||replace(pname,'*','%')||''''; end if;
    s:=s||' order by id';
    open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
function edit_hinhthuc_tts(
    pid varchar2,
    pname varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin

    s:='update tax.hinhthuc_tts set  id=:id,name=:name where id=:id';
    execute immediate s using pid,pname,pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_hinhthuc_tts(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin

    s:='delete from tax.hinhthuc_tts where id=:id';
    execute immediate s using pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function search_districts(
    pid varchar2,
    pdistrict_name varchar2,
    pprovince_id varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    s:='select * from tax.districts where 1=1';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if pdistrict_name is not null then s:=s||' and district_name like '''||replace(pdistrict_name,'*','%')||''''; end if;
    if pprovince_id is not null then s:=s||' and province_id like '''||replace(pprovince_id,'*','%')||''''; end if;
    s:=s||' order by id';
    open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
function search_coquanthus(
    pid varchar2,
    pcqt_qlt varchar2,
    pcqt_tms varchar2,
    pten_cqt varchar2,
    pma_tinh varchar2,
    pma_huyen varchar2,
    pma_quoc_gia varchar2,
    phieu_luc_tu varchar2,
    phieu_luc_den varchar2,
    pshkb varchar2,
    pType varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    --logger.access('tax.coquanthus|SEARCH',pid||'|'||pcqt_qlt||'|'||pcqt_tms||'|'||pten_cqt||'|'||pma_tinh||'|'||pma_huyen||'|'||pma_quoc_gia||'|'||phieu_luc_tu||'|'||phieu_luc_den||'|'||pshkb);
    s:='select * from tax.coquanthus where 1=1';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if pcqt_qlt is not null then s:=s||' and cqt_qlt like '''||replace(pcqt_qlt,'*','%')||''''; end if;
    if pcqt_tms is not null then s:=s||' and cqt_tms like '''||replace(pcqt_tms,'*','%')||''''; end if;
    if pten_cqt is not null then s:=s||' and ten_cqt like '''||replace(pten_cqt,'*','%')||''''; end if;
    if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
    if pma_huyen is not null then s:=s||' and ma_huyen like '''||replace(pma_huyen,'*','%')||''''; end if;
    if pma_quoc_gia is not null then s:=s||' and ma_quoc_gia like '''||replace(pma_quoc_gia,'*','%')||''''; end if;
    if phieu_luc_tu is not null then s:=s||' and hieu_luc_tu like '''||replace(phieu_luc_tu,'*','%')||''''; end if;
    if phieu_luc_den is not null then s:=s||' and hieu_luc_den like '''||replace(phieu_luc_den,'*','%')||''''; end if;
    if pshkb is not null then s:=s||' and shkb like '''||replace(pshkb,'*','%')||''''; end if;
    s:=s||' order by id';
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
function search_chuongs(
    pid varchar2,
    pma_cap varchar2,
    pten_chuong varchar2,
    phieu_luc_tu varchar2,
    phieu_luc_den varchar2,
    pType varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    s:='select * from tax.chuongs where 1=1';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if pma_cap is not null then s:=s||' and ma_cap like '''||replace(pma_cap,'*','%')||''''; end if;
    if pten_chuong is not null then s:=s||' and ten_chuong like '''||replace(pten_chuong,'*','%')||''''; end if;
    if phieu_luc_tu is not null then s:=s||' and hieu_luc_tu like '''||replace(phieu_luc_tu,'*','%')||''''; end if;
    if phieu_luc_den is not null then s:=s||' and hieu_luc_den like '''||replace(phieu_luc_den,'*','%')||''''; end if;
    s:=s||' order by id';
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
function new_chukynos(
    pid varchar2,
    pten_chukyno varchar2,
    pis_active varchar2,
    pstatus varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    --logger.access('tax.chukynos|NEW',pid||'|'||pten_chukyno||'|'||pis_active||'|'||pstatus);
    s:='insert into tax.chukynos(id,ten_chukyno,is_active,status)
     values (:id,:ten_chukyno,:is_active,:status)';
    execute immediate s using pid,pten_chukyno,pis_active,pstatus;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function search_chukynos(
    pid varchar2,
    pten_chukyno varchar2,
    pis_active varchar2,
    pstatus varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    s:='select * from tax.chukynos where 1=1';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if pten_chukyno is not null then s:=s||' and ten_chukyno like '''||replace(pten_chukyno,'*','%')||''''; end if;
    if pis_active is not null then s:=s||' and is_active like '''||replace(pis_active,'*','%')||''''; end if;
    if pstatus is not null then s:=s||' and status like '''||replace(pstatus,'*','%')||''''; end if;
    s:=s||' order by id';
    open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
function edit_chukynos(
    pid varchar2,
    pten_chukyno varchar2,
    pis_active varchar2,
    pstatus varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.chukynos|EDIT',pid||'|'||pten_chukyno||'|'||pis_active||'|'||pstatus);
    s:='update tax.chukynos set  id=:id,ten_chukyno=:ten_chukyno,is_active=:is_active,status=:status where id=:id';
    execute immediate s using pid,pten_chukyno,pis_active,pstatus,pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_chukynos(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.chukynos|DEL',pId);
    s:='delete from tax.chukynos where id=:id';
    execute immediate s using pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function new_location(pmst varchar2,
                        plat varchar2,
                        plong varchar2,
                        plocation varchar2,
                        pUserId varchar2,
                        pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('new_location|INS',pmst);
    s:= 'Insert into tax.locations(id, latitude, longitude, location, userid , ip) values(:1,:2,:3,:4,:5,:6)';
    execute immediate s using pmst,plat,plong,plocation,pUserId,pUserIp;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function new_buucucthus(
    pid varchar2,
    pma_tinh varchar2,
    ptenbuucuc varchar2,
    pdiachi varchar2,
    ptel varchar2,
    pfax varchar2,
    pdonviql_id varchar2,
    pnotes varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.buucucthus|NEW',pid||'|'||pma_tinh||'|'||ptenbuucuc||'|'||pdiachi||'|'||ptel||'|'||pfax||'|'||pdonviql_id||'|'||pnotes);
    s:='insert into tax.buucucthus(id,ma_tinh,tenbuucuc,diachi,tel,fax,donviql_id,notes)
     values (:id,:ma_tinh,:tenbuucuc,:diachi,:tel,:fax,:donviql_id,:notes)';
    execute immediate s using pid,pma_tinh,ptenbuucuc,pdiachi,ptel,pfax,pdonviql_id,pnotes;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function search_buucucthus(
    pid varchar2,
    pma_tinh varchar2,
    ptenbuucuc varchar2,
    pdiachi varchar2,
    ptel varchar2,
    pfax varchar2,
    pdonviql_id varchar2,
    pnotes varchar2,
    pType varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    s:='select * from tax.buucucthus where 1=1';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
    if ptenbuucuc is not null then s:=s||' and tenbuucuc like '''||replace(ptenbuucuc,'*','%')||''''; end if;
    if pdiachi is not null then s:=s||' and diachi like '''||replace(pdiachi,'*','%')||''''; end if;
    if ptel is not null then s:=s||' and tel like '''||replace(ptel,'*','%')||''''; end if;
    if pfax is not null then s:=s||' and fax like '''||replace(pfax,'*','%')||''''; end if;
    if pdonviql_id is not null then s:=s||' and donviql_id like '''||replace(pdonviql_id,'*','%')||''''; end if;
    if pnotes is not null then s:=s||' and notes like '''||replace(pnotes,'*','%')||''''; end if;
    s:=s||' order by id';
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
function edit_buucucthus(
    pid varchar2,
    pma_tinh varchar2,
    ptenbuucuc varchar2,
    pdiachi varchar2,
    ptel varchar2,
    pfax varchar2,
    pdonviql_id varchar2,
    pnotes varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.buucucthus|EDIT',pid||'|'||pma_tinh||'|'||ptenbuucuc||'|'||pdiachi||'|'||ptel||'|'||pfax||'|'||pdonviql_id||'|'||pnotes);
    s:='update tax.buucucthus set tenbuucuc=:tenbuucuc,diachi=:diachi,tel=:tel,fax=:fax,donviql_id=:donviql_id,notes=:notes where id=:id and ma_tinh=:ma_tinh';
    execute immediate s using ptenbuucuc,pdiachi,ptel,pfax,pdonviql_id,pnotes,pid,pma_tinh;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_buucucthus(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    l_agent varchar2(50);
begin
    logger.access('tax.buucucthus|DEL',pId);
    l_agent := get_agent_user(PUSER=>pUserId);
    s:='delete from tax.buucucthus where id=:id and ma_tinh=:ma_tinh';
    execute immediate s using pid,l_agent;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function new_donvi_qls(
    pid varchar2,
    pma_tinh varchar2,
    pten_dv varchar2,
    ptel varchar2,
    pfax varchar2,
    pnotes varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.donvi_qls|NEW',pid||'|'||pma_tinh||'|'||pten_dv||'|'||ptel||'|'||pfax||'|'||pnotes);
    s:='insert into tax.donvi_qls(id,ma_tinh,ten_dv,tel,fax,notes)
     values (:id,:ma_tinh,:ten_dv,:tel,:fax,:notes)';
    execute immediate s using pid,pma_tinh,pten_dv,ptel,pfax,pnotes;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function search_donvi_qls(
    pid varchar2,
    pma_tinh varchar2,
    pten_dv varchar2,
    ptel varchar2,
    pfax varchar2,
    pnotes varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    s:='select * from tax.donvi_qls where 1=1';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
    if pten_dv is not null then s:=s||' and ten_dv like '''||replace(pten_dv,'*','%')||''''; end if;
    if ptel is not null then s:=s||' and tel like '''||replace(ptel,'*','%')||''''; end if;
    if pfax is not null then s:=s||' and fax like '''||replace(pfax,'*','%')||''''; end if;
    if pnotes is not null then s:=s||' and notes like '''||replace(pnotes,'*','%')||''''; end if;
    s:=s||' order by id';
    open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
function edit_donvi_qls(
    pid varchar2,
    pma_tinh varchar2,
    pten_dv varchar2,
    ptel varchar2,
    pfax varchar2,
    pnotes varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.donvi_qls|EDIT',pid||'|'||pma_tinh||'|'||pten_dv||'|'||ptel||'|'||pfax||'|'||pnotes);
    s:='update tax.donvi_qls set ten_dv=:ten_dv,tel=:tel,fax=:fax,notes=:notes where id=:id and ma_tinh=:ma_tinh';
    execute immediate s using pten_dv,ptel,pfax,pnotes,pid,pma_tinh;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_donvi_qls(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    l_agent varchar2(20);
begin
    logger.access('tax.donvi_qls|DEL',pId);
    l_agent := get_agent_user(PUSER=>pUserId);

    s:='delete from tax.donvi_qls where id=:id and ma_tinh=:ma_tinh';
    execute immediate s using pid,l_agent;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function search_provinces(
    pid varchar2,
    pprovince_name varchar2,
    pcountry_id varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    logger.access('tax.provinces|SEARCH',pid||'|'||pprovince_name||'|'||pcountry_id);
    s:='select * from tax.provinces where 1=1';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if pprovince_name is not null then s:=s||' and province_name like '''||replace(pprovince_name,'*','%')||''''; end if;
    if pcountry_id is not null then s:=s||' and country_id like '''||replace(pcountry_id,'*','%')||''''; end if;
    s:=s||' order by id';
    open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
function new_nnts(
    pmst varchar2,
    pten_nnt varchar2,
    ploai_nnt varchar2,
    pso varchar2,
    pchuong varchar2,
    pma_cqt_ql varchar2,
    pmota_diachi varchar2,
    pma_tinh varchar2,
    pma_huyen varchar2,
    pma_xa varchar2,
    pmobile varchar2,
    pemail varchar2,
    pma_nv varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    --logger.access('tax.nnts|NEW',pmst||'|'||pten_nnt||'|'||ploai_nnt||'|'||pso||'|'||pchuong||'|'||pma_cqt_ql||'|'||pmota_diachi||'|'||pma_tinh||'|'||pma_huyen||'|'||pma_xa||'|'||pmobile||'|'||pemail||'|'||pma_nv);
    s:='insert into tax.nnts(mst,ten_nnt,loai_nnt,so,chuong,ma_cqt_ql,mota_diachi,ma_tinh,ma_huyen,ma_xa,mobile,email,ma_nv)
     values (:mst,:ten_nnt,:loai_nnt,:so,:chuong,:ma_cqt_ql,:mota_diachi,:ma_tinh,:ma_huyen,:ma_xa,:mobile,:email,:ma_nv)';
    execute immediate s using pmst,pten_nnt,ploai_nnt,pso,pchuong,pma_cqt_ql,pmota_diachi,pma_tinh,pma_huyen,pma_xa,pmobile,pemail,pma_nv;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function search_nnts(
    pmst varchar2,
    pten_nnt varchar2,
    ploai_nnt varchar2,
    pso varchar2,
    pchuong varchar2,
    pma_cqt_ql varchar2,
    pmota_diachi varchar2,
    pma_tinh varchar2,
    pma_huyen varchar2,
    pma_xa varchar2,
    pmobile varchar2,
    pemail varchar2,
    pma_nv varchar2,
    pType varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    --logger.access('tax.nnts|SEARCH',pmst||'|'||pten_nnt||'|'||ploai_nnt||'|'||pso||'|'||pchuong||'|'||pma_cqt_ql||'|'||pmota_diachi||'|'||pma_tinh||'|'||pma_huyen||'|'||pma_xa||'|'||pmobile||'|'||pemail||'|'||pma_nv);
    s:='select * from tax.nnts where 1=1';
    if pmst is not null then s:=s||' and mst like '''||replace(pmst,'*','%')||''''; end if;
    if pten_nnt is not null then s:=s||' and ten_nnt like '''||replace(pten_nnt,'*','%')||''''; end if;
    if ploai_nnt is not null then s:=s||' and loai_nnt like '''||replace(ploai_nnt,'*','%')||''''; end if;
    if pso is not null then s:=s||' and so like '''||replace(pso,'*','%')||''''; end if;
    if pchuong is not null then s:=s||' and chuong like '''||replace(pchuong,'*','%')||''''; end if;
    if pma_cqt_ql is not null then s:=s||' and ma_cqt_ql like '''||replace(pma_cqt_ql,'*','%')||''''; end if;
    if pmota_diachi is not null then s:=s||' and mota_diachi like '''||replace(pmota_diachi,'*','%')||''''; end if;
    if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
    if pma_huyen is not null then s:=s||' and ma_huyen like '''||replace(pma_huyen,'*','%')||''''; end if;
    if pma_xa is not null then s:=s||' and ma_xa like '''||replace(pma_xa,'*','%')||''''; end if;
    if pmobile is not null then s:=s||' and mobile like '''||replace(pmobile,'*','%')||''''; end if;
    if pemail is not null then s:=s||' and email like '''||replace(pemail,'*','%')||''''; end if;
    if pma_nv is not null then s:=s||' and ma_nv like '''||replace(pma_nv,'*','%')||''''; end if;
    s:=s||' order by mst';

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

function search_nnt_giao_phieu(
    pma_nv varchar2,
    PMA_TINH VARCHAR2,
    psearch_key VARCHAR2,
    pType VARCHAR2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):=ckn_hientai();
begin
    s:='select a.*,to_char(nvl(c.tien_giao,0),''fm999,999,999,999,999'') da_giao,
        to_char(b.sotien-nvl(c.tien_giao,0),''fm999,999,999,999,999'') sotien from tax.nnts a,
        (select sum(no_cuoi_ky) sotien, mst from ct_no_'||ckn||' group by mst) b,
        (select sum(tien_giao) tien_giao, mst from phieu_'||ckn||' group by mst) c
        where a.mst=b.mst and a.mst=c.mst(+) and b.sotien-nvl(c.tien_giao,0)>0';
    if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
    if pma_nv is not null then s:=s||' and ma_nv like '''||replace(pma_nv,'*','%')||''''; end if;
    if psearch_key is not null then s:=s||' and (a.mst like ''%'||(psearch_key)||'%'' or tax.uto_khongdau(upper(a.mota_diachi)) like ''%'||tax.uto_khongdau(upper(psearch_key))||'%'' or tax.uto_khongdau(upper(a.ten_nnt)) like ''%'||tax.uto_khongdau(upper(psearch_key))||'%'')'; end if;
    s:=s||' order by a.mst';

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
function get_nnt_info(
    pmst varchar2,
    pma_tinh VARCHAR2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):=ckn_hientai();
    l_agent varchar2(15);
    l_inv varchar2(15);
    l_pattern varchar2(15);
    l_serial varchar2(15);
    l_ma_cqt VARCHAR2(20);
begin
    if pMa_tinh is null then
        begin
            l_agent := crud.search_agent_info(pUserId);
        end;
    else
        l_agent := pMa_tinh;
    end if;
    s:='select nvl(cqt_tms,''0'') from  user_info WHERE id=:id';
    EXECUTE IMMEDIATE s INTO l_ma_cqt USING pUserId;

    if (l_agent='01TTT') then
        s:='select a.*,to_char(b.sotien,''fm999,999,999,999,999'') sotien,to_char(nvl(c.tientra,0),''fm999,999,999,999,999'') tien_tra,
            d.pattern,d.numb_bill,d.serial,e.id id_nv, e.ten_nv, e.mobile dt_nv from tax.nnts_'||ckn||' a,
                (select sum(no_cuoi_ky) sotien, mst,ma_cq_thu from ct_no_'||ckn||' group by mst,ma_cq_thu) b,
                (select sum(tientra) tientra, mst,ma_cq_thu from ct_tra_'||ckn||' group by mst,ma_cq_thu) c, tax.hddts d, tax.nhanvien_tcs e
            where a.mst=b.mst and a.ma_cqt_ql=b.ma_cq_thu and a.ma_cqt_ql=c.ma_cq_thu(+) and a.mst=c.mst(+) and a.mst =:1 and a.mst = d.TAXCODE(+) and a.ma_nv =e.id(+)
            and a.ma_tinh =:2';
            IF l_ma_cqt<>'0' THEN
                s:=s|| '  and a.ma_cqt_ql='''||l_ma_cqt||'''';
            END IF;
             s:=s|| ' and rownum =1';
    else
        begin
            s :='select ma_so,replace(replace(b.ky_hieu,''MM'',to_char(sysdate,''MM'')),''YYYY'',to_char(sysdate,''YYYY''))
                    from nguoigachnos a, quaythus b where a.id =:1 and a.quaythu_id = b.id
                    and a.ma_tinh = b.ma_tinh and a.ma_tinh =:2 and rownum =1';
            execute immediate s into l_inv,l_pattern using pUserId,l_agent;
            exception when others then
            l_inv:='';l_pattern:='';
        end;

        l_serial:='';
        s:='select a.*,to_char(b.sotien,''fm999,999,999,999,999'') sotien,to_char(nvl(c.tientra,0),''fm999,999,999,999,999'') tien_tra,
            '''||l_inv||''' pattern,'''||l_pattern||''' numb_bill,'''||l_serial||''' serial, e.id id_nv, e.ten_nv, e.mobile dt_nv
             from tax.nnts_'||ckn||' a,
                (select sum(no_cuoi_ky) sotien, mst,ma_cq_thu from ct_no_'||ckn||' group by mst,ma_cq_thu) b,
                (select sum(tientra) tientra, mst,ma_cq_thu from ct_tra_'||ckn||' group by mst,ma_cq_thu) c, tax.nhanvien_tcs e
            where a.mst=b.mst and a.ma_cqt_ql=b.ma_cq_thu and a.ma_cqt_ql=c.ma_cq_thu(+) and a.mst=c.mst(+) and a.mst =:1 and a.ma_nv =e.id(+)
            and a.ma_tinh =:2';
            IF l_ma_cqt<>'0' THEN
                s:=s|| '  and a.ma_cqt_ql='''||l_ma_cqt||'''';
            END IF;
             s:=s|| ' and rownum =1';
    end if;
    open ref_ for s using pmst,l_agent;
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function get_nnt_info_search(
    pmst varchar2,
    psogt varchar2,
    PMA_TINH VARCHAR2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):=ckn_hientai();
    l_mst varchar2(50);
begin
    if pmst is not null then
        if instr(pmst,'|')>0 then
            l_mst := substr(pmst,1,instr(pmst,'|')-1);
        else
            l_mst := pmst;
        end if;
        s:='select a.*,to_char(b.sotien,''fm999,999,999,999,999'') sotien,to_char(C.tientra,''fm999,999,999,999,999'') tien_tra
            from tax.nnts_'||ckn||' a,
                (select sum(no_cuoi_ky) sotien, mst from ct_no_'||ckn||' group by mst) b,
                (select sum(tientra) tientra, mst from ct_tra_'||ckn||' group by mst) c
            where
                a.mst=b.mst and a.mst=c.mst(+) and a.mst='''||l_mst||'''';
    else
        s:='select a.*,to_char(b.sotien,''fm999,999,999,999,999'') sotien,to_char(C.tientra,''fm999,999,999,999,999'') tien_tra
            from tax.nnts_'||ckn||' a,
                (select sum(no_cuoi_ky) sotien, mst from ct_no_'||ckn||' group by mst) b,
                (select sum(tientra) tientra, mst from ct_tra_'||ckn||' group by mst) c
            where
                a.mst=b.mst and a.mst=c.mst(+) and a.so='''||psogt||'''';
    end if;
    open ref_ for s;
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function edit_nnts(
    pmst varchar2,
    pten_nnt varchar2,
    ploai_nnt varchar2,
    pso varchar2,
    pchuong varchar2,
    pma_cqt_ql varchar2,
    pmota_diachi varchar2,
    pma_tinh varchar2,
    pma_huyen varchar2,
    pma_xa varchar2,
    pmobile varchar2,
    pemail varchar2,
    pma_nv varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    --logger.access('tax.nnts|EDIT',pmst||'|'||pten_nnt||'|'||ploai_nnt||'|'||pso||'|'||pchuong||'|'||pma_cqt_ql||'|'||pmota_diachi||'|'||pma_tinh||'|'||pma_huyen||'|'||pma_xa||'|'||pmobile||'|'||pemail||'|'||pma_nv);
    s:='update tax.nnts set  mst=:mst,ten_nnt=:ten_nnt,loai_nnt=:loai_nnt,so=:so,chuong=:chuong,ma_cqt_ql=:ma_cqt_ql,mota_diachi=:mota_diachi,ma_tinh=:ma_tinh,ma_huyen=:ma_huyen,ma_xa=:ma_xa,mobile=:mobile,email=:email,ma_nv=:ma_nv where id=:id';
    execute immediate s using pmst,pten_nnt,ploai_nnt,pso,pchuong,pma_cqt_ql,pmota_diachi,pma_tinh,pma_huyen,pma_xa,pmobile,pemail,pma_nv,pmst;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_nnts(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.nnts|DEL',pId);
    s:='delete from tax.nnts where id=:id';
    execute immediate s using pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function phan_tuyen(
    pManv varchar2,
    pMaT varchar2,
    pMsts varchar2)
return varchar2
is
    s varchar2(1000);
begin
    --luu log
    execute immediate 'insert into log_phantuyen(mst, ma_nv, ma_t)
    select mst,ma_nv,ma_t from nnts where mst in ('''||replace(pmsts,',',''',''')||''')';

    --cap nhat thong tin phan tuyen
    s:='update nnts set ma_nv='''||pManv||''', ma_t='''||pMaT||''' where mst in ('''||replace(pmsts,',',''',''')||''')';
    execute immediate s;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
FUNCTION ckn_hientai RETURN VARCHAR2
AS
    s VARCHAR2(2000);
BEGIN
    select id into s from chukynos where is_active=1 and rownum<=1;

    return s;
end;
function giao_phieu(
    pManv varchar2,
    pMsts varchar2,
    puserid varchar2)
return varchar2
is
    s varchar2(32000);
    id_ number:=util.getseq('GIAO_PHIEU_SEQ');
    ckn varchar2(100):=ckn_hientai();
    kythue varchar2(100):= to_char(sysdate,'mmyyyy');
    pmst_ util.StringArray:=util.str_to_array(pMsts,',');
    l_mst util.StringArray;
    l_mcq_ql VARCHAR2(100);
    l_mst_list VARCHAR2(30000):='';
    l_count NUMBER;
BEGIN
    FOR i in pmst_.first..pmst_.last LOOP
        l_mst_list:=l_mst_list||','||SUBSTR(pmst_(i),0,length(pmst_(i))-7);
    END LOOP;
    IF LENGTH(l_mst_list) > 0 THEN
        l_mst_list:=SUBSTR(l_mst_list,2,LENGTH(l_mst_list)-1);
    END IF;
    s:='SELECT nvl(cqt_tms,''0'') mcq  FROM  user_info WHERE id=:id';
    EXECUTE IMMEDIATE s INTO l_mcq_ql USING pUserId;
    IF l_mcq_ql <> '0' THEN
        s:='SELECT count(1)  FROM nnts_2016 a WHERE a.mst IN ('''||replace(l_mst_list,',',''',''')||''') and a.ma_cqt_ql<>:1';
        EXECUTE IMMEDIATE s INTO l_count USING l_mcq_ql;
        IF l_count > 0 THEN
            RETURN 'Khong duoc phep giao phieu don vi khong quan ly';
        END IF;
    END IF;

    FOR n in pmst_.first..pmst_.last LOOP
        l_mst:=util.str_to_array(pmst_(n),':');
        s:='insert into phieu_'||ckn||'(id,mst,tien_giao,ma_nv,ngay_giao,nguoi_giao,kythue,ma_tinh)
         select '||id_||',a.mst,/*b.sotien-nvl(c.tien_giao,0)*/ b.sotien,'''||pmanv||''',sysdate,'''||puserid||''',b.kythue,a.ma_tinh from tax.nnts_'||ckn||' a,
         (select sum(no_cuoi_ky) sotien, mst, kythue,ma_cq_thu from ct_no_'||ckn||' group by mst,kythue,ma_cq_thu) b/*,
         (select sum(tien_giao) tien_giao, mst, kythue from phieu_'||ckn||' group by mst,kythue) c*/
         where a.mst=b.mst and a.ma_cqt_ql=b.ma_cq_thu /*and a.mst=c.mst(+) and b.kythue = c.kythue*/
         and a.mst ='''||l_mst(l_mst.first)||''' and b.kythue='''||l_mst(l_mst.last)||'''';
        execute immediate s;
        commit;
    END LOOP;
    return id_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function get_nnt_ct_no(
    pmst varchar2,
    pMa_tinh varchar2)
return sys_refcursor
is
    ckn varchar2(100):=ckn_hientai();
    ref_ sys_refcursor;
    s varchar2(10000);
    l_agent varchar2(15);
begin
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
                a.MA_CHUONG,a.MA_CQ_THU,
                a.MA_TMUC,a.SO_TAIKHOAN_CO,a.SO_QDINH,a.NGAY_QDINH,a.LOAI_TIEN,a.TI_GIA,a.LOAI_THUE,
                C.ten_chuong,nvl(D.tentieumuc,A.ma_tmuc) tentieumuc from
        (
            SELECT mst,ma_tinh,sum(no_cuoi_ky) no_cuoi_ky,ma_chuong,ma_cq_thu,
                  ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh,
                  loai_tien,ti_gia,loai_thue
              FROM ct_no_'||ckn||'  group by mst,ma_tinh,ma_chuong,ma_cq_thu,
                  ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh,
                  loai_tien,ti_gia,loai_thue) a,
        (
            SELECT mst,ma_tinh,sum(tientra) TIENTRA,ma_chuong,ma_cq_thu,
                  ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh,
                  loai_tien,ti_gia,loai_thue
              FROM ct_tra_'||ckn||' group by mst,ma_tinh,ma_chuong,ma_cq_thu,
                  ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh,
                  loai_tien,ti_gia,loai_thue
        ) b, chuongs c, tieu_mucs d
        where a.mst=b.mst(+) and a.ma_chuong=b.ma_chuong(+) and a.ma_tmuc=b.ma_tmuc(+)
            and a.ma_chuong=C.id(+) and a.ma_tmuc=d.id(+)
            AND a.no_cuoi_ky-nvl(b.tientra,0) >0 and A.MST =:1 and a.ma_tinh =:2';
    OPEN REF_ for s Using pmst,l_agent;
    return ref_;
end;
function thanh_toan(
    pmst varchar2,
    pma_tinh varchar2,
    pma_bc varchar2,
    phttt varchar2,
    pnguoigachno varchar2,
    pngay_tt varchar2,
    pquaythu varchar2,
    ptra varchar2
) return varchar2
is
    id_ varchar2(100):=util.getseq('PHIEUTRA_SEQ');
    s varchar2(30000);
    ckn varchar2(100):=ckn_hientai();
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
    l_payment number:=0;
    l_tmuc_list VARCHAR2(5000):='';
    l_chuky_list VARCHAR2(5000):='';
begin
    logger.access('crud.thanh_toan',pmst||'|'||pma_tinh||'|'||pma_bc||'|'||phttt||'|'||pnguoigachno||'|'||pngay_tt||'|'||pquaythu||'|'||substr(ptra,1,2000));
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
        IF (phttt =7) THEN
            l_kythue:=ptra_cn(2);
            l_tmuc_list:=l_tmuc_list||','||ptra_cn(7);
            l_chuky_list:=l_chuky_list||','||ptra_cn(14);
        END IF;


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
        BEGIN

            s :='select replace(replace(b.ky_hieu,''MM'',to_char(sysdate,''MM'')),''YYYY'',to_char(sysdate,''YYYY'')),to_number(nvl(b.seri,''0'')) +1,b.flag
                    from nguoigachnos a, quaythus b where a.id =:1 and a.quaythu_id = b.id
                    and a.ma_tinh = b.ma_tinh and a.ma_tinh =:2 and rownum =1';
            execute immediate s into l_pattern,l_serial,l_flag using pnguoigachno,pma_tinh;
            exception when others then
            rollback;
            return 'CAU HINH THAM SO HOA DON SAI!';
        end;

        begin
            --Check KY_HIEU de reset lai SERI
            --luu y doan nay cho dau thang
             Execute immediate ' Select count(1) from quaythus a
             where a.ma_tinh =:1 and exists (select 1 from nguoigachnos b where b.id =:2 and a.id = b.quaythu_id)
             and nvl(a.tg_gach,''MM-YYYY'')=to_char(SYSDATE,''MM-YYYY'')'
             into l_flag using pma_tinh,pnguoigachno;
             If (l_flag =0) then
                l_serial := 1;
             End if;

            --Cap nhat du lieu bang phieu tra
            Execute immediate ' Update bangphieutra_'||ckn||' set ky_hieu =:1, seri =:2 where id=:3 and mst=:4'
                    Using l_pattern,l_serial,id_,pmst;

            --Cap nhat du lieu seri theo to
            Execute immediate ' Update quaythus a set a.seri =:1, a.flag =:2,a.tg_gach= to_char(SYSDATE,''MM-YYYY'')
                                    where a.ma_tinh =:3
                                    and exists (select 1 from nguoigachnos b where b.id =:4 and a.id = b.quaythu_id)
                                    and rownum=1' Using l_serial,l_flag,pma_tinh,pnguoigachno;

            exception when others then
            rollback;
            return 'LOI CAP NHAT BANG PHIEU TRA !';
        end;
    End if;

    -- Update:21/08/2016 cho hinh thuc thanh toan Offline
    if (phttt =7) THEN
        --Cap nhat du lieu bang phieu tra
        l_tmuc_list:=SUBSTR(l_tmuc_list,2,LENGTH(l_tmuc_list));
        l_chuky_list:=SUBSTR(l_chuky_list,2,LENGTH(l_chuky_list));
        IF pma_tinh='79TTT' THEN
            EXECUTE IMMEDIATE 'select seri,ky_hieu from tax.phieu_offline where ma_tinh=:1 and mst=:2 and kythue=:3 and rownum=1'
            INTO l_serial,l_pattern USING pma_tinh,pmst,l_kythue;

            Execute immediate ' Update bangphieutra_'||ckn||' set ky_hieu =:1, seri =:2 where id=:3 and mst=:4'
            Using l_pattern,l_serial,id_,pmst;
        END IF;
        EXECUTE IMMEDIATE 'UPDATE  tax.phieu_offline SET trang_thai=1,phieu_id=:phieuid WHERE ma_tinh=:1 and mst=:2
        and kythue =:3 and ma_tmuc in ('||l_tmuc_list||') and chuky in ('''||REPLACE(l_chuky_list,',',''',''')||''')'
            USING id_,pma_tinh,pmst,l_kythue;
    END if;

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
        s:= 'update tax.phieu_'||ckn||' a set a.trangthai_tt = nvl((select (case when b.tientra < a.tien_giao then 1
                                                when b.tientra = a.tien_giao then 2
                                                else 0 end) from (
                                                 select sum(tientra) tientra,mst,kythue
                                                 from ct_tra_'||ckn||' where mst =:1 group by mst,kythue)b
                                                    where a.mst=b.mst and a.kythue=b.kythue),0)
        where a.mst =:2';
        execute immediate s using pmst,pmst;
    end if;

    --Lay tong tien tra theo luot thanh toan
    /*s:='select sum(tientra) from tax.ct_tra_'||ckn||' where mst =:1 and phieu_id =:2';
    execute immediate s into tientra1_  using pmst,id_;

    l_message :='VNPT xin thong bao: Ho kinh doanh '||pmst||' vua nop thue so tien '||tientra1_||'d ngay '||l_ngaytra||'. Tran trong';
    --Sms cho khach hang nop thue
    s:= tax.ws_sms.SEND_SMS(pmst,l_message);*/

    --Lay thong ky thue thuc hien thanh toan
    s:='select max(kythue) from tax.ct_tra_'||ckn||' where mst =:1 and phieu_id =:2 and rownum=1';
    execute immediate s into l_kythue  using pmst,id_;

    --Send request HDDT
    select count(1) into l_payment from nguoigachnos where id=pnguoigachno and vnpt =1;
    If l_payment >0 then
        If (pma_tinh ='79TTT') then
            --Tao HDDT
            enqueue_publish_inv(i_agent=> pma_tinh, i_taxcode=> pmst, i_month=> l_kythue, i_bill=> id_, i_cashier_code=> pnguoigachno);
        Else
            l_check := check_info_dept(i_taxcode=> pmst, i_kythue=> l_kythue);
            If l_check >0 then
                enqueue_el_bill(i_agent=> pma_tinh,i_taxcode => pmst,i_month => l_kythue,i_bill => id_,i_cashier_code => pnguoigachno,i_type => 1);
            End if;
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

function thanh_toan2(
    pmst varchar2,
    pma_tinh varchar2,
    pma_bc varchar2,
    phttt varchar2,
    pnguoigachno varchar2,
    pngay_tt varchar2,
    pquaythu varchar2,
    ptra varchar2
) return varchar2
is
    id_ varchar2(100):=util.getseq('PHIEUTRA_TAINHA_SEQ');
    id_phieu_ number;
    s varchar2(30000);
    ckn varchar2(100):=ckn_hientai();
    ptra_ util.StringArray:=util.str_to_array(ptra,'|');
    pmst_ util.StringArray:=util.str_to_array(pmst,',');
    n number;
    lres varchar2(32000);
    lres_ number;
begin
    logger.access('crud.thanh_toan2',pmst||'|'||pma_tinh||'|'||pma_bc||'|'||phttt||'|'||pnguoigachno||'|'||pngay_tt||'|'||pquaythu||'|'||substr(ptra,1,2000));
    for n in ptra_.first..ptra_.last loop
        lres := thanh_toan(pmst_(n), pma_tinh, pma_bc,phttt, pnguoigachno, pngay_tt, pquaythu,ptra_(n));
        /*Begin
            If (lres*1 = lres_) then
                execute immediate 'update bangphieutra_'||ckn||' set group_id='''||id_||''' where id='||id_phieu_;
            End if;
            Exception when others then
                rollback;
                return lres;
        End;*/
        commit;
    end loop;
    return lres;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi0:'||to_char(sqlerrm);
        logger.access('tax.than_toan2|ERR',err);
        return err;
    end;
end;


function new_bangphieutra(
    pid varchar2,
    pma_tinh varchar2,
    pmst varchar2,
    pma_bc varchar2,
    phttt_id varchar2,
    pnguoigachno_id varchar2,
    pngay_tt varchar2,
    pngay_thuc varchar2,
    pquaythu_id varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    ckn varchar2(100):=ckn_hientai;
begin
    logger.access('tax.bangphieutra|NEW',pid||'|'||pma_tinh||'|'||pmst||'|'||pma_bc||'|'||phttt_id||'|'||pnguoigachno_id||'|'||pngay_tt||'|'||pngay_thuc||'|'||pquaythu_id);
    s:='insert into tax.bangphieutra_'||ckn||'(id,ma_tinh,mst,ma_bc,httt_id,nguoigachno_id,ngay_tt,ngay_thuc,quaythu_id)
     values (:id,:ma_tinh,:mst,:ma_bc,:httt_id,:nguoigachno_id,:ngay_tt,:ngay_thuc,:quaythu_id)';
    execute immediate s using pid,pma_tinh,pmst,pma_bc,phttt_id,pnguoigachno_id,to_date(pngay_tt,'dd/mm/yyyy'),to_date(pngay_thuc,'dd/mm/yyyy'),pquaythu_id;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('tax.bangphieutra|ERR',err);
        return err;
    end;
end;
function search_bangphieutra(
    pid varchar2,
    pma_tinh varchar2,
    pmst varchar2,
    pma_bc varchar2,
    phttt_id varchar2,
    pnguoigachno_id varchar2,
    pngay_tt varchar2,
    pngay_thuc varchar2,
    pquaythu_id varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):=ckn_hientai;
begin
    s:='select a.*,to_char(ngay_tt,''dd/mm/yyyy hh24:mi'') ngay_tt1,to_char(ngay_thuc,''dd/mm/yyyy hh24:mi'') ngay_thuc1,to_char(b.tien_tra,''fm999,999,999,999,999'') tien_tra from tax.bangphieutra_'||ckn||' a,
        (select sum(tientra) tien_tra,phieu_id from ct_tra_'||ckn||' group by phieu_id) b where a.id=b.phieu_id';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
    if pmst is not null then s:=s||' and mst like '''||replace(pmst,'*','%')||''''; end if;
    if pma_bc is not null then s:=s||' and ma_bc like '''||replace(pma_bc,'*','%')||''''; end if;
    if phttt_id is not null then s:=s||' and httt_id like '''||replace(phttt_id,'*','%')||''''; end if;
    if pnguoigachno_id is not null then s:=s||' and nguoigachno_id like '''||replace(pnguoigachno_id,'*','%')||''''; end if;
    if pngay_tt is not null then s:=s||' and ngay_tt=to_date('''||pngay_tt||''',''dd/mm/yyyy'')'; end if;
    if pngay_thuc is not null then s:=s||' and ngay_thuc=to_date('''||pngay_thuc||''',''dd/mm/yyyy'')'; end if;
    if pquaythu_id is not null then s:=s||' and quaythu_id like '''||replace(pquaythu_id,'*','%')||''''; end if;
    s:=s||' order by id';

    open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function edit_bangphieutra(
    pid varchar2,
    pma_tinh varchar2,
    pmst varchar2,
    pma_bc varchar2,
    phttt_id varchar2,
    pnguoigachno_id varchar2,
    pngay_tt varchar2,
    pngay_thuc varchar2,
    pquaythu_id varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    ckn varchar2(100):=ckn_hientai;
begin
    logger.access('tax.bangphieutra|EDIT',pid||'|'||pma_tinh||'|'||pmst||'|'||pma_bc||'|'||phttt_id||'|'||pnguoigachno_id||'|'||pngay_tt||'|'||pngay_thuc||'|'||pquaythu_id);
    s:='update tax.bangphieutra_2016 set  id=:id,ma_tinh=:ma_tinh,mst=:mst,ma_bc=:ma_bc,httt_id=:httt_id,nguoigachno_id=:nguoigachno_id,ngay_tt=:ngay_tt,ngay_thuc=:ngay_thuc,quaythu_id=:quaythu_id where id=:id';
    execute immediate s using pid,pma_tinh,pmst,pma_bc,phttt_id,pnguoigachno_id,to_date(pngay_tt,'dd/mm/yyyy'),to_date(pngay_thuc,'dd/mm/yyyy'),pquaythu_id,pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_bangphieutra(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):=ckn_hientai;
    l_count number;
    l_role number;
    l_check number;
    l_mst varchar2(100);
    l_kythue varchar2(100);
    l_agent varchar2(20);
    i_giao number;
begin
    logger.access('tax.bangphieutra|DEL',pId);

    l_count := tax.check_time_del_bill(PPHIEUID=>pId);
    If l_count =0 then
        Return 'THONG TIN NO DA KHOA -> BAN KHONG CO QUYEN XOA PHIEU';
    End if;
    Execute immediate 'Select count(1) from tax.bangphieutra_'||ckn||' where id=:id' into l_count using pId;
    If l_count =0 then
        Return 'BILL NOT EXISTING';
    Else
        Execute immediate 'Select count(1) from tax.bangphieutra_'||ckn||' where id=:id and nguoigachno_id=:nguoigachno_id' into l_count using pId,pUserId;
        If l_count =0 then
            Select count(1) into l_role from tax.user_role where user_id = pUserId and role_id='ADMIN';
            If l_role = 0 then
                Return 'BAN KHONG CO QUYEN XOA PHIEU CUA THU NGAN KHAC';
            End if;
        End if;
    End if;

    --Cap nhat log huy phieu
    execute immediate 'insert into tax.phieuhuys(id,ma_tinh,mst,ma_bc,httt_id,sotien,ngay_huy,nguoi_huy,may_huy,
        quaythu_id,group_id,seri,ky_hieu,ma_chuong,ma_cq_thu,ma_tmuc,ngay_tt,nguoi_tt,kythue,chuky,ma_chuan_chi,so_tham_chieu,loai_the)
    select a.id,a.ma_tinh,a.mst,a.ma_bc,a.httt_id,b.tientra,sysdate,:1,:2,a.quaythu_id,a.group_id,a.seri,a.ky_hieu,
        b.ma_chuong,b.ma_cq_thu,b.ma_tmuc,a.ngay_thuc,a.nguoigachno_id,b.kythue,b.chuky,a.ma_chuan_chi,a.so_tham_chieu,a.loai_the
    from tax.bangphieutra_'||ckn||' a,tax.ct_tra_'||ckn||' b
    where a.id = b.phieu_id
    and a.mst = b.mst
    and a.id = :3' Using pUserId,pUserIp,pId;

    s:='select distinct mst,kythue,ma_tinh  from tax.ct_tra_'||ckn||' where phieu_id =:1';
    open ref_ for s using pId;
    loop fetch ref_ into l_mst,l_kythue,l_agent;
    exit when ref_%notfound;
    begin
        --Xoa du lieu tra
        s:='delete from tax.ct_tra_'||ckn||' where phieu_id =:1 and mst=:2';
        execute immediate s using pid,l_mst;

        --Huy thanh toan/xoa hoa BLDT
        enqueue_el_bill(i_agent=> l_agent,i_taxcode => l_mst,i_month => l_kythue,i_bill => pId,i_cashier_code => pUserId,i_type => 2);

        --Cap nhat trang thai thanh toan phieu giao
        s:='select count(1) from tax.phieu_'||ckn||'  where mst =:1 and kythue =:2';
        execute immediate s into i_giao  using l_mst,l_kythue;
        if i_giao >0 then
            s:= 'update tax.phieu_'||ckn||' a set a.trangthai_tt = nvl((select (case when b.tientra < a.tien_giao then 1
                                                when b.tientra = a.tien_giao then 2
                                                else 0 end) from (
                                                 select sum(tientra) tientra,mst,kythue
                                                 from ct_tra_'||ckn||' where mst =:1 and kythue =:2 group by mst,kythue)b
                                                    where a.mst=b.mst and a.kythue=b.kythue),0)
                where a.mst =:3 and a.kythue =:4';
            execute immediate s using l_mst,l_kythue,l_mst,l_kythue;
        end if;
    end;
    end loop;
    close ref_;

    --Xoa du lieu bang phieu tra
    s:='delete from tax.bangphieutra_'||ckn||' where id=:id';
    execute immediate s using pid;

    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        logger.access('tax.del_bangphieutra|ERR',err);
        rollback;
        return err;
    end;
end;
function search_gachno_tainha(
    pma_nv varchar2,
    pma_tinh varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2)
return sys_refcursor
is
    s varchar2(10000);
    ref_ sys_refcursor;
    ckn varchar2(100):=ckn_hientai;
begin
    s:='select distinct a.mst, b.ten_nnt,to_char(a.no_cuoi_ky,''fm999,999,999,999'') no_cuoi_ky,
            to_char(a.no_cuoi_ky-nvl(f.tientra,0),''fm999,999,999,999'') so_tien,
            to_char(nvl(f.tientra,0),''fm999,999,999,999'') tientra, d.ten_chuong,e.tentieumuc||''|''||a.chuky tentieumuc,
             a.ma_chuong,a.ma_tmuc,b.ma_tinh,a.kythue,a.ma_cq_thu,a.loai_tien,a.loai_thue,a.so_taikhoan_co,a.chuky
        from (select sum(no_cuoi_ky) no_cuoi_ky,mst,kythue,ma_chuong,ma_tmuc,ma_cq_thu,loai_tien,loai_thue,so_taikhoan_co,chuky
                from ct_no_'||ckn||' group by mst,kythue,ma_chuong,ma_tmuc,ma_cq_thu,loai_tien,loai_thue,so_taikhoan_co,chuky) a,
                nnts_'||ckn||' b, phieu_'||ckn||' c, chuongs d, tieu_mucs e,
            (select sum(tientra) tientra,mst,kythue,ma_chuong,ma_tmuc,chuky from ct_tra_'||ckn||' group by mst,kythue,ma_chuong,ma_tmuc,chuky) f
        where a.mst=b.mst and a.mst=c.mst and a.ma_chuong=d.id and a.ma_tmuc=e.id(+) and a.mst=f.mst(+)
            and a.ma_chuong=f.ma_chuong(+) and a.ma_tmuc=f.ma_tmuc(+) and a.kythue = f.kythue(+) and a.chuky=f.chuky(+)
            and b.ma_nv='''||pma_nv||''' AND B.ma_tinh='''||pma_tinh||'''
            and a.no_cuoi_ky-nvl(f.tientra,0)>0
        order by a.kythue,a.mst,a.ma_tmuc';
    dbms_output.put_line(s);
    open ref_ for s;

    return ref_;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;



function search_phieu_giao(
    pid varchar2,
    pmst varchar2,
    ptien_giao varchar2,
    pma_nv varchar2,
    pngay_giao varchar2,
    pnguoi_giao varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):=ckn_hientai();
    l_agent varchar2(20);
begin
    l_agent := get_agent_user(PUSER=>pUserId);

    s:='select b.* from tax.phieu_'||ckn||' b, tax.nnts_'||ckn||' a where b.mst = a.mst
        and b.trangthai_tt =0 and a.ma_tinh ='''||l_agent||'''';
    if pid is not null then s:=s||' and b.id like '''||replace(pid,'*','%')||''''; end if;
    if pmst is not null then s:=s||' and b.mst like '''||replace(pmst,'*','%')||''''; end if;
    if ptien_giao is not null then s:=s||' and b.tien_giao like '''||replace(ptien_giao,'*','%')||''''; end if;
    if pma_nv is not null then s:=s||' and b.ma_nv like '''||replace(pma_nv,'*','%')||''''; end if;
    if pngay_giao is not null then s:=s||' and b.ngay_giao=to_date('''||pngay_giao||''',''dd/mm/yyyy'')'; end if;
    if pnguoi_giao is not null then s:=s||' and b.nguoi_giao like '''||replace(pnguoi_giao,'*','%')||''''; end if;
    s:=s||' order by b.id';

    open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function del_phieu_giao(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    ckn varchar2(100):=ckn_hientai();
    l_mst varchar2(50);
    l_id varchar2(50);
begin
    logger.access('tax.del_phieu_giao|DEL',pId);

    if instr(pId,'|') >0 then
        l_mst := substr(pId,instr(pId,'|')+1);
        l_id := substr(pId,1,instr(pId,'|')-1);
        s:='delete from tax.phieu_'||ckn||' where id=:id and mst =:mst';
        execute immediate s using l_id,l_mst;
    else
        s:='delete from tax.phieu_'||ckn||' where id=:id';
        execute immediate s using pid;
    end if;

    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function new_nganhangs(
    pid varchar2,
    pmaso varchar2,
    pten varchar2,
    pdiachi varchar2,
    ptaikhoan varchar2,
    pdienthoai varchar2,
    psofax varchar2,
    planhdao varchar2,
    pma_tinh varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    s:='insert into tax.nganhangs(id,maso,ten,diachi,taikhoan,dienthoai,sofax,lanhdao,ma_tinh)
     values (:id,:maso,:ten,:diachi,:taikhoan,:dienthoai,:sofax,:lanhdao,:ma_tinh)';
    execute immediate s using pid,pmaso,pten,pdiachi,ptaikhoan,pdienthoai,psofax,planhdao,pma_tinh;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function search_nganhangs(
    pid varchar2,
    pmaso varchar2,
    pten varchar2,
    pdiachi varchar2,
    ptaikhoan varchar2,
    pdienthoai varchar2,
    psofax varchar2,
    planhdao varchar2,
    pma_tinh varchar2,
    pType varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin

    s:='select * from tax.nganhangs where 1=1';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if pmaso is not null then s:=s||' and maso like '''||replace(pmaso,'*','%')||''''; end if;
    if pten is not null then s:=s||' and ten like '''||replace(pten,'*','%')||''''; end if;
    if pdiachi is not null then s:=s||' and diachi like '''||replace(pdiachi,'*','%')||''''; end if;
    if ptaikhoan is not null then s:=s||' and taikhoan like '''||replace(ptaikhoan,'*','%')||''''; end if;
    if pdienthoai is not null then s:=s||' and dienthoai like '''||replace(pdienthoai,'*','%')||''''; end if;
    if psofax is not null then s:=s||' and sofax like '''||replace(psofax,'*','%')||''''; end if;
    if planhdao is not null then s:=s||' and lanhdao like '''||replace(planhdao,'*','%')||''''; end if;
    if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
    s:=s||' order by id';
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
function edit_nganhangs(
    pid varchar2,
    pmaso varchar2,
    pten varchar2,
    pdiachi varchar2,
    ptaikhoan varchar2,
    pdienthoai varchar2,
    psofax varchar2,
    planhdao varchar2,
    pma_tinh varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    s:='update tax.nganhangs set  id=:id,maso=:maso,ten=:ten,diachi=:diachi,taikhoan=:taikhoan,dienthoai=:dienthoai,sofax=:sofax,lanhdao=:lanhdao
        where id=:id and ma_tinh=:ma_tinh';
    execute immediate s using pid,pmaso,pten,pdiachi,ptaikhoan,pdienthoai,psofax,planhdao,pma_tinh,pid,pma_tinh;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_nganhangs(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    l_agent varchar2(50);
begin
    logger.access('tax.nganhangs|DEL',pId);
    l_agent := get_agent_user(PUSER=>pUserId);
    s:='delete from tax.nganhangs where id=: and ma_tinh=:ma_tinh';
    execute immediate s using pid,l_agent;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function new_nnt_cks(
    pmst varchar2,
    phinhthuctt varchar2,
    pnganhang_id varchar2,
    pmobile varchar2,
    pemail varchar2,
    pngay_bd varchar2,
    pngay_kt varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin

    s:='insert into tax.nnt_cks(mst,hinhthuctt_id,nganhang_id,mobile,email,ngay_bd,ngay_kt,loguser)
     values (:mst,:hinhthuctt_id,:nganhang_id,:mobile,:email,:ngay_bd,:ngay_kt,:loguser)';
    execute immediate s using pmst,phinhthuctt,pnganhang_id,pmobile,pemail,to_date(pngay_bd,'dd/mm/yyyy'),to_date(pngay_kt,'dd/mm/yyyy'),pUserId;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function search_nnt_cks(
    pmst varchar2,
    phinhthuctt varchar2,
    pnganhang_id varchar2,
    pngay_bd varchar2,
    pngay_kt varchar2,
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
    ckn varchar2(100):=ckn_hientai();
begin
    l_agent := get_agent_user(PUSER=>pUserId);

    s:='select a.mst,c.name hinhthuc,a.hinhthuctt_id,a.nganhang_id, to_char(a.ngay_bd,''dd/mm/yyyy hh24:mi:ss'') ngay_bd,
    to_char(a.ngay_kt,''dd/mm/yyyy hh24:mi:ss'') ngay_kt,b.ten,a.email,a.mobile
    from tax.nnt_cks a, tax.nganhangs b, tax.hinhthuc_tts c, tax.nnts_'||ckn||' d
        where a.mst =d.mst and nvl(a.nganhang_id,0) = b.id(+) and a.hinhthuctt_id=c.id and d.ma_tinh ='''||l_agent||'''';

    if pmst is not null then s:=s||' and a.mst like '''||replace(pmst,'*','%')||''''; end if;
    if phinhthuctt is not null then s:=s||' and a.hinhthuctt_id like '''||replace(phinhthuctt,'*','%')||''''; end if;
    if pnganhang_id is not null then s:=s||' and a.nganhang_id = '''||replace(pnganhang_id,'*','%')||''''; end if;
    if pngay_bd is not null then s:=s||' and a.ngay_bd=to_date('''||pngay_bd||''',''dd/mm/yyyy'')'; end if;
    if pngay_kt is not null then s:=s||' and a.ngay_kt=to_date('''||pngay_kt||''',''dd/mm/yyyy'')'; end if;
    s:=s||' order by mst';

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
function edit_nnt_cks(
    pmst varchar2,
    phinhthuctt varchar2,
    pnganhang_id varchar2,
    pmobile varchar2,
    pemail varchar2,
    pngay_bd varchar2,
    pngay_kt varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.nnt_cks|EDIT',pmst||'|'||pnganhang_id||'|'||pngay_bd||'|'||pngay_kt);
    s:='update tax.nnt_cks set hinhthuctt_id=:hinhthuctt_id,nganhang_id=:nganhang_id,mobile=:mobile,email=:email,ngay_bd=:ngay_bd,ngay_kt=:ngay_kt,loguser=:loguser where mst=:mst';
    execute immediate s using phinhthuctt,pnganhang_id,pmobile,pemail,to_date(pngay_bd,'dd/mm/yyyy hh24:mi:ss'),to_date(pngay_kt,'dd/mm/yyyy hh24:mi:ss'),pUserId,pmst;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_nnt_cks(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.nnt_cks|DEL',pId);
    s:='delete from tax.nnt_cks where mst=:id';
    execute immediate s using pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function new_chuyenkhoans(
    pmst varchar2,
    pso_bl varchar2,
    pso_ct varchar2,
    ptien varchar2,
    pthue varchar2,
    ploaitien_id varchar2,
    pchukyno varchar2,
    phinhthuctt_id varchar2,
    pnganhang_ph varchar2,
    pnganhang_dvh varchar2,
    pngaynhan varchar2,
    ptamthu varchar2,
    pphat varchar2,
    plephinganhang varchar2,
    pghichu varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    id_ varchar2(100):=util.getseq('CHUNGTU_SEQ');
    l_agent varchar2(20);
    l_agent1 varchar2(20);
begin
    l_agent := get_agent_taxcode(pmst);
    l_agent1 := crud.search_agent_info(pUserId);
    if l_agent <> l_agent1 then
        return 'BAN KHONG DUOC THAO TAC VOI DU LIEU CUA TINH KHAC';
    end if;

    logger.access('tax.chuyenkhoans|NEW',pmst||'|'||pso_bl||'|'||pso_ct||'|'||ptien||'|'||pthue||'|'||ploaitien_id||'|'||pchukyno||'|'||phinhthuctt_id||'|'||pnganhang_ph||'|'||pnganhang_dvh||'|'||pngaynhan||'|'||ptamthu||'|'||pphat||'|'||plephinganhang||'|'||pghichu);
    s:='insert into tax.chuyenkhoans(mst,so_bl,so_ct,tien,thue,loaitien_id,chukyno,phieu_id,hinhthuctt_id,nganhang_ph,nganhang_dvh,ngaynhan,nguoi_th,may_th,ngay_th,tamthu,trangthai,phat,lephinganhang,ghichu)
     values (:mst,:so_bl,:so_ct,:tien,:thue,:loaitien_id,:chukyno,:phieu_id,:hinhthuctt_id,:nganhang_ph,:nganhang_dvh,:ngaynhan,:nguoi_th,:may_th,:ngay_th,:tamthu,:trangthai,:phat,:lephinganhang,:ghichu)';
    execute immediate s using pmst,nvl(pso_bl,0),nvl(pso_ct,0),nvl(ptien,0),nvl(pthue,0),ploaitien_id,pchukyno,id_,phinhthuctt_id,pnganhang_ph,pnganhang_dvh,to_date(pngaynhan,'dd/mm/yyyy'),pUserId,pUserIp,to_date(sysdate,'dd/mm/yyyy'),ptamthu,0,pphat,plephinganhang,pghichu;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function search_chuyenkhoans(
    pmst varchar2,
    pphieu varchar2,
    pso_bl varchar2,
    pso_ct varchar2,
    ptien varchar2,
    pthue varchar2,
    ploaitien_id varchar2,
    pchukyno varchar2,
    phinhthuctt_id varchar2,
    pnganhang_ph varchar2,
    pnganhang_dvh varchar2,
    pngaynhan varchar2,
    ptamthu varchar2,
    pphat varchar2,
    plephinganhang varchar2,
    pghichu varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    l_agent varchar2(20);
    ckn varchar2(100):=ckn_hientai();
begin
    l_agent := get_agent_user(PUSER=>pUserId);
    s:='select a.mst, a.so_bl, a.so_ct, a.tien, a.thue, a.loaitien_id,
       a.chukyno, a.phieu_id, a.hinhthuctt_id, a.nganhang_ph,
       a.nganhang_dvh, to_char(a.ngaynhan,''dd/mm/yyyy hh24:mi:ss'') ngaynhan, a.ngay_tt, a.nguoi_th, a.may_th,
       a.ngay_th, a.tamthu, a.trangthai, a.phat, a.lephinganhang,a.ghichu
       from tax.chuyenkhoans a, tax.nnts_'||ckn||' b where a.mst=b.mst and b.ma_tinh='''||l_agent||'''';

    if pmst is not null then s:=s||' and mst like '''||replace(pmst,'*','%')||''''; end if;
    if pso_bl is not null then s:=s||' and so_bl like '''||replace(pso_bl,'*','%')||''''; end if;
    if pso_ct is not null then s:=s||' and so_ct like '''||replace(pso_ct,'*','%')||''''; end if;
    if ptien is not null then s:=s||' and tien like '''||replace(ptien,'*','%')||''''; end if;
    if pthue is not null then s:=s||' and thue like '''||replace(pthue,'*','%')||''''; end if;
    if pphieu is not null then s:=s||' and phieu_id like '''||replace(pphieu,'*','%')||''''; end if;
    if ploaitien_id is not null then s:=s||' and loaitien_id like '''||replace(ploaitien_id,'*','%')||''''; end if;
    if pchukyno is not null then s:=s||' and chukyno like '''||replace(pchukyno,'*','%')||''''; end if;

    if phinhthuctt_id is not null then s:=s||' and hinhthuctt_id like '''||replace(phinhthuctt_id,'*','%')||''''; end if;
    if pnganhang_ph is not null then s:=s||' and nganhang_ph like '''||replace(pnganhang_ph,'*','%')||''''; end if;
    if pnganhang_dvh is not null then s:=s||' and nganhang_dvh like '''||replace(pnganhang_dvh,'*','%')||''''; end if;
    if pngaynhan is not null then s:=s||' and ngaynhan=to_date('''||pngaynhan||''',''dd/mm/yyyy'')'; end if;
    if ptamthu is not null then s:=s||' and tamthu like '''||replace(ptamthu,'*','%')||''''; end if;

    if pphat is not null then s:=s||' and phat like '''||replace(pphat,'*','%')||''''; end if;
    if plephinganhang is not null then s:=s||' and lephinganhang like '''||replace(plephinganhang,'*','%')||''''; end if;
    if pghichu is not null then s:=s||' and ghichu like '''||replace(pghichu,'*','%')||''''; end if;
    s:=s||' order by phieu_id';

    open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
function edit_chuyenkhoans(
    pmst varchar2,
    pphieu varchar2,
    pso_bl varchar2,
    pso_ct varchar2,
    ptien varchar2,
    pthue varchar2,
    ploaitien_id varchar2,
    pchukyno varchar2,
    phinhthuctt_id varchar2,
    pnganhang_ph varchar2,
    pnganhang_dvh varchar2,
    pngaynhan varchar2,
    ptamthu varchar2,
    pphat varchar2,
    plephinganhang varchar2,
    pghichu varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    s:='update tax.chuyenkhoans set mst=:mst,so_bl=:so_bl,so_ct=:so_ct,tien=:tien,thue=:thue,loaitien_id=:loaitien_id,
                        chukyno=:chukyno,hinhthuctt_id=:hinhthuctt_id,nganhang_ph=:nganhang_ph,
                        nganhang_dvh=:nganhang_dvh,ngaynhan=:ngaynhan,tamthu=:tamthu,phat=:phat,
                        lephinganhang=:lephinganhang,ghichu=:ghichu where phieu_id=:phieu_id';
    execute immediate s using pmst,pso_bl,pso_ct,ptien,pthue,ploaitien_id,pchukyno,phinhthuctt_id,pnganhang_ph,
                pnganhang_dvh,to_date(pngaynhan,'dd/mm/yyyy hh24:mi:ss'),ptamthu,pphat,plephinganhang,pghichu,pphieu;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_chuyenkhoans(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.chuyenkhoans|DEL',pId);
    s:='delete from tax.chuyenkhoans where phieu_id=:id';
    execute immediate s using pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function edit_khoans(
    pid varchar2,
    ptenkhoan varchar2,
    pma_loai varchar2,
    phieu_luc_tu varchar2,
    phieu_luc_den varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.khoans|EDIT',pid||'|'||ptenkhoan||'|'||pma_loai||'|'||phieu_luc_tu||'|'||phieu_luc_den);
    s:='update tax.khoans set  id=:id,tenkhoan=:tenkhoan,ma_loai=:ma_loai,hieu_luc_tu=:hieu_luc_tu,hieu_luc_den=:hieu_luc_den where id=:id';
    execute immediate s using pid,ptenkhoan,pma_loai,phieu_luc_tu,phieu_luc_den,pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_khoans(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.khoans|DEL',pId);
    s:='delete from tax.khoans where id=:id';
    execute immediate s using pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function new_khoans(
    pid varchar2,
    ptenkhoan varchar2,
    pma_loai varchar2,
    phieu_luc_tu varchar2,
    phieu_luc_den varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.khoans|NEW',pid||'|'||ptenkhoan||'|'||pma_loai||'|'||phieu_luc_tu||'|'||phieu_luc_den);
    s:='insert into tax.khoans(id,tenkhoan,ma_loai,hieu_luc_tu,hieu_luc_den)
     values (:id,:tenkhoan,:ma_loai,:hieu_luc_tu,:hieu_luc_den)';
    execute immediate s using pid,ptenkhoan,pma_loai,phieu_luc_tu,phieu_luc_den;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function new_chuongs(
    pid varchar2,
    pma_cap varchar2,
    pten_chuong varchar2,
    phieu_luc_tu varchar2,
    phieu_luc_den varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.chuongs|NEW',pid||'|'||pma_cap||'|'||pten_chuong||'|'||phieu_luc_tu||'|'||phieu_luc_den);
    s:='insert into tax.chuongs(id,ma_cap,ten_chuong,hieu_luc_tu,hieu_luc_den)
     values (:id,:ma_cap,:ten_chuong,:hieu_luc_tu,:hieu_luc_den)';
    execute immediate s using pid,pma_cap,pten_chuong,phieu_luc_tu,phieu_luc_den;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function edit_chuongs(
    pid varchar2,
    pma_cap varchar2,
    pten_chuong varchar2,
    phieu_luc_tu varchar2,
    phieu_luc_den varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.chuongs|EDIT',pid||'|'||pma_cap||'|'||pten_chuong||'|'||phieu_luc_tu||'|'||phieu_luc_den);
    s:='update tax.chuongs set  id=:id,ma_cap=:ma_cap,ten_chuong=:ten_chuong,hieu_luc_tu=:hieu_luc_tu,hieu_luc_den=:hieu_luc_den where id=:id';
    execute immediate s using pid,pma_cap,pten_chuong,phieu_luc_tu,phieu_luc_den,pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_chuongs(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.chuongs|DEL',pId);
    s:='delete from tax.chuongs where id=:id';
    execute immediate s using pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function new_coquanthus(
    pid varchar2,
    pcqt_qlt varchar2,
    pcqt_tms varchar2,
    pten_cqt varchar2,
    pma_tinh varchar2,
    pma_huyen varchar2,
    pma_quoc_gia varchar2,
    phieu_luc_tu varchar2,
    phieu_luc_den varchar2,
    pshkb varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.coquanthus|NEW',pid||'|'||pcqt_qlt||'|'||pcqt_tms||'|'||pten_cqt||'|'||pma_tinh||'|'||pma_huyen||'|'||pma_quoc_gia||'|'||phieu_luc_tu||'|'||phieu_luc_den||'|'||pshkb);
    s:='insert into tax.coquanthus(id,cqt_qlt,cqt_tms,ten_cqt,ma_tinh,ma_huyen,ma_quoc_gia,hieu_luc_tu,hieu_luc_den,shkb)
     values (:id,:cqt_qlt,:cqt_tms,:ten_cqt,:ma_tinh,:ma_huyen,:ma_quoc_gia,:hieu_luc_tu,:hieu_luc_den,:shkb)';
    execute immediate s using pid,pcqt_qlt,pcqt_tms,pten_cqt,pma_tinh,pma_huyen,pma_quoc_gia,phieu_luc_tu,phieu_luc_den,pshkb;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function edit_coquanthus(
    pid varchar2,
    pcqt_qlt varchar2,
    pcqt_tms varchar2,
    pten_cqt varchar2,
    pma_tinh varchar2,
    pma_huyen varchar2,
    pma_quoc_gia varchar2,
    phieu_luc_tu varchar2,
    phieu_luc_den varchar2,
    pshkb varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.coquanthus|EDIT',pid||'|'||pcqt_qlt||'|'||pcqt_tms||'|'||pten_cqt||'|'||pma_tinh||'|'||pma_huyen||'|'||pma_quoc_gia||'|'||phieu_luc_tu||'|'||phieu_luc_den||'|'||pshkb);
    s:='update tax.coquanthus set  id=:id,cqt_qlt=:cqt_qlt,cqt_tms=:cqt_tms,ten_cqt=:ten_cqt,ma_tinh=:ma_tinh,ma_huyen=:ma_huyen,ma_quoc_gia=:ma_quoc_gia,hieu_luc_tu=:hieu_luc_tu,hieu_luc_den=:hieu_luc_den,shkb=:shkb where id=:id';
    execute immediate s using pid,pcqt_qlt,pcqt_tms,pten_cqt,pma_tinh,pma_huyen,pma_quoc_gia,phieu_luc_tu,phieu_luc_den,pshkb,pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_coquanthus(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.coquanthus|DEL',pId);
    s:='delete from tax.coquanthus where id=:id';
    execute immediate s using pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function new_khobacs(
    pid varchar2,
    pten_kho_bac varchar2,
    pma_tructiep varchar2,
    phieu_luc_tu varchar2,
    phieu_luc_den varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.khobacs|NEW',pid||'|'||pten_kho_bac||'|'||pma_tructiep||'|'||phieu_luc_tu||'|'||phieu_luc_den);
    s:='insert into tax.khobacs(id,ten_kho_bac,ma_tructiep,hieu_luc_tu,hieu_luc_den)
     values (:id,:ten_kho_bac,:ma_tructiep,:hieu_luc_tu,:hieu_luc_den)';
    execute immediate s using pid,pten_kho_bac,pma_tructiep,phieu_luc_tu,phieu_luc_den;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function edit_khobacs(
    pid varchar2,
    pten_kho_bac varchar2,
    pma_tructiep varchar2,
    phieu_luc_tu varchar2,
    phieu_luc_den varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.khobacs|EDIT',pid||'|'||pten_kho_bac||'|'||pma_tructiep||'|'||phieu_luc_tu||'|'||phieu_luc_den);
    s:='update tax.khobacs set  id=:id,ten_kho_bac=:ten_kho_bac,ma_tructiep=:ma_tructiep,hieu_luc_tu=:hieu_luc_tu,hieu_luc_den=:hieu_luc_den where id=:id';
    execute immediate s using pid,pten_kho_bac,pma_tructiep,phieu_luc_tu,phieu_luc_den,pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_khobacs(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.khobacs|DEL',pId);
    s:='delete from tax.khobacs where id=:id';
    execute immediate s using pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function search_gachno_cks(
    pma_nh varchar2,
    pma_tinh varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2)
return sys_refcursor
is
    s varchar2(10000);
    ref_ sys_refcursor;
    ckn varchar2(100):=ckn_hientai;
begin
    s:='select a.phieu_id,a.mst,b.ten_nnt,b.mota_diachi, tien+thue tien,nganhang_dvh nganhang_id,
        to_char(ngaynhan,''dd/mm/yyyy'') ngaynhan from tax.chuyenkhoans a, tax.nnts_'||ckn||' b
        where a.mst = b.mst and a.nganhang_dvh =:1 and b.ma_tinh =:2';
    open ref_ for s using pma_nh,pma_tinh;

    return ref_;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function get_info_dept(
    pma_tinh varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):=ckn_hientai;
    l_tongno number;
    l_tongtra number;
    l_conno number;
    l_tile_no number;
    l_tile_tra number;
begin

    execute immediate 'select sum(no_cuoi_ky) tongno from tax.ct_no_'||ckn||' where ma_tinh =:1' into l_tongno using pma_tinh;
    execute immediate 'select sum(tientra) tongtra from tax.ct_tra_'||ckn||' where ma_tinh =:1' into l_tongtra using pma_tinh;

    l_conno := l_tongno -  l_tongtra;
    l_tile_tra := round(l_tongtra/l_tongno,2)*100;
    l_tile_no := round(l_conno/l_tongno,2)*100;

    s:='select to_char(:1,''fm999,999,999,999'') tongno, to_char(:2,''fm999,999,999,999'') tongtra,
        to_char(:3,''fm999,999,999,999'') conno, :4 ti_le_tra,:5 ti_le_no
         from dual';

    open ref_ for s using l_tongno,l_tongtra,l_conno,l_tile_tra,l_tile_no;
    return ref_;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select 0 tongno, 0 tongtra,
        0 conno, 0 ti_le_tra,0 ti_le_no from dual' using err; return ref_;
    end;
end;

function get_info_staff(
    pma_tinh varchar2,
    ptu_ngay varchar2,
    pden_ngay varchar2)
return sys_refcursor
is
    s varchar2(3000);
    ref_ sys_refcursor;
    ckn varchar2(100):=ckn_hientai;
begin

    s:='select a.ma_nv,to_char(a.tien_giao,''fm999,999,999,999'') tien_giao,a.nguoi_giao,to_char(b.tientra,''fm999,999,999,999'') tien_tra
    from (
            select sum(a.tien_giao) tien_giao,a.ma_nv,a.nguoi_giao from tax.phieu_'||ckn||' a
            where exists (select 1 from tax.nhanvien_tcs b where a.ma_nv=b.id and b.ma_tinh =:1)';
            if ptu_ngay is not null then
                s:=s||' and a.ngay_giao >= to_date('''||ptu_ngay||''',''dd/mm/yyyy'')';
            end if;
            if pden_ngay is not null then
                s:=s||' and a.ngay_giao < to_date('''||pden_ngay||''',''dd/mm/yyyy'') +1';
            end if;

            s:=s||'group by a.ma_nv,a.nguoi_giao) a, (select sum(b.tientra) tientra,c.staff from tax.bangphieutra_'||ckn||' a,
                tax.ct_tra_'||ckn||' b, tax.user_info c
            where a.id = b.phieu_id
            and a.nguoigachno_id = c.id
            and a.ma_tinh =:2';

            if ptu_ngay is not null then
                s:=s||' and a.ngay_tt >= to_date('''||ptu_ngay||''',''dd/mm/yyyy'')';
            end if;
            if pden_ngay is not null then
                s:=s||' and a.ngay_tt < to_date('''||pden_ngay||''',''dd/mm/yyyy'') +1';
            end if;

            s:=s||'group by c.staff) b';
    open ref_ for s using pma_tinh,pma_tinh;
    return ref_;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function get_info_dept_type(
    pma_tinh varchar2,
    ptu_ngay varchar2,
    pden_ngay varchar2)
return sys_refcursor
is
    s varchar2(3000);
    ref_ sys_refcursor;
    ckn varchar2(100):=ckn_hientai;
begin

    s:='select to_char(sum(b.tientra),''fm999,999,999,999'') tientra, (select name from tax.hinhthuc_tts where id = a.httt_id) hinhthuc_tt
            from tax.bangphieutra_'||ckn||' a, tax.ct_tra_'||ckn||' b
            where a.id = b.phieu_id and a.ma_tinh = b.ma_tinh and a.ma_tinh =:1';
            if ptu_ngay is not null then
                s:=s||' and a.ngay_tt >= to_date('''||ptu_ngay||''',''dd/mm/yyyy'')';
            end if;
            if pden_ngay is not null then
                s:=s||' and a.ngay_tt < to_date('''||pden_ngay||''',''dd/mm/yyyy'') +1';
            end if;
            s:=s||'group by a.httt_id';

    open ref_ for s using pma_tinh;
    return ref_;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function new_nhatky_thus(
    pmst varchar2,
    pluotnhac varchar2,
    plydos varchar2,
    pngayhen_tt varchar2,
    phinhthuc varchar2,
    pnganhang varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    ckn varchar2(100):=ckn_hientai;
    l_agent varchar2(15);
    l_agent1 varchar2(15);
begin
    l_agent := get_agent_taxcode(pmst);
    l_agent1 := crud.search_agent_info(pUserId);
    if l_agent <> l_agent1 then
        return 'BAN KHONG DUOC THAO TAC VOI DU LIEU CUA TINH KHAC';
    end if;

    logger.access('tax.nhatky_thus|NEW',pmst||'|'||plydos||'|'||pngayhen_tt);
    s:='insert into tax.nhatky_thus(mst,lydos,ngayhen_tt,luot_nhacno,ckt,hinhthuc_id,nganhang_id,loguser)
     values (:mst,:lydos,:ngayhen_tt,:luot_nhacno,:ckt,:hinhthuc_id,:nganhang_id,:loguser)';
    execute immediate s using pmst,plydos,to_date(pngayhen_tt,'dd/mm/yyyy'),pluotnhac,ckn,phinhthuc,pnganhang,pUserId;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function search_nhatky_thus(
    pmst varchar2,
    pluotnhac varchar2,
    plydos varchar2,
    pngayhen_tt varchar2,
    phinhthuc varchar2,
    pnganhang varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    l_agent varchar2(20);
    ckn varchar2(100):=ckn_hientai;
begin
    select agent into l_agent  from tax.user_info where id=pUserId;
    --logger.access('tax.nhatky_thus|SEARCH',pmst||'|'||plydos||'|'||pngayhen_tt);
    s:='select mst,lydos,to_char(ngayhen_tt,''dd/mm/yyyy hh24:mi:ss'') ngayhen_tt,luot_nhacno,hinhthuc_id, nganhang_id from tax.nhatky_thus
    where exists (select 1 from tax.nnts_'||ckn||' a where mst=a.mst and a.ma_tinh ='''||l_agent||''')';
    if pmst is not null then s:=s||' and mst like '''||replace(pmst,'*','%')||''''; end if;
    if plydos is not null then s:=s||' and lydos like '''||replace(plydos,'*','%')||''''; end if;
    if pngayhen_tt is not null then s:=s||' and ngayhen_tt=to_date('''||pngayhen_tt||''',''dd/mm/yyyy'')'; end if;
    if pluotnhac is not null then s:=s||' and luot_nhacno like '''||replace(pluotnhac,'*','%')||''''; end if;
    if phinhthuc is not null then s:=s||' and hinhthuc_id like '''||replace(phinhthuc,'*','%')||''''; end if;
    if pnganhang is not null then s:=s||' and nganhang_id like '''||replace(pnganhang,'*','%')||''''; end if;

    open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function search_location(
    pid varchar2,
    platitude varchar2,
    plongitude varchar2,
    plocation varchar2,
    pstaff varchar2,
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
    s:='select a.* from tax.locations a, tax.nnts b where a.id=b.mst and b.ma_tinh ='''||l_agent||'''';

    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if platitude is not null then s:=s||' and latitude like '''||replace(platitude,'*','%')||''''; end if;
    if plongitude is not null then s:=s||' and longitude like '''||replace(plongitude,'*','%')||''''; end if;
    if plocation is not null then s:=s||' and location like '''||replace(plocation,'*','%')||''''; end if;
    if pstaff is not null then s:=s||' and staff like '''||replace(pstaff,'*','%')||''''; end if;
    s:=s||' order by id';
    open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function edit_nhatky_thus(
    pmst varchar2,
    pluotnhac varchar2,
    plydos varchar2,
    pngayhen_tt varchar2,
    phinhthuc varchar2,
    pnganhang varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    ckn varchar2(100):=ckn_hientai;
begin
    logger.access('tax.nhatky_thus|EDIT',pmst||'|'||plydos||'|'||pngayhen_tt);
    s:='update tax.nhatky_thus set lydos=:lydos,ngayhen_tt=:ngayhen_tt,luot_nhacno=:luot_nhacno,hinhthuc_id=:hinhthuc_id,nganhang_id=:nganhang_id,loguser=:loguser
            where mst=:mst and ckt=:ckt';
    execute immediate s using plydos,to_date(pngayhen_tt,'dd/mm/yyyy hh24:mi:ss'),pluotnhac,phinhthuc,pnganhang,pUserId,pmst,ckn;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_nhatky_thus(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    ckn varchar2(100):=ckn_hientai;
begin
    logger.access('tax.nhatky_thus|DEL',pId);
    s:='delete from tax.nhatky_thus where mst=:mst and ckt=:ckt';
    execute immediate s using pid,ckn;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function put_file_ftp_unc(pma_tinh varchar2,
                          pngay_tt varchar2,
                          pmakhobac varchar2,
                          pkhobac varchar2,
                          puserid varchar2,
                          puserip varchar2 )
return varchar2
is
begin
    logger.access('tax.put_file_ftp_unc',pma_tinh||'|'||pngay_tt||'|'||pmakhobac);
    create_and_put_file_ftp(i_agent=>pma_tinh, i_ma_khobac=>pmakhobac, i_khobac=>pkhobac, i_ngay_tt=>pngay_tt);
    return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

PROCEDURE report_list_mention_dept(
    pagent varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(1000);
    ckn varchar2(100):=ckn_hientai();
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
          from tax.nhatky_thus b, tax.nnts a,(select sum(no_cuoi_ky) tien_no,mst from tax.ct_no_'||ckn||'
                                                where ma_tinh =:1 group by mst)c
            where b.mst = a.mst and a.mst = c.mst
            and a.ma_tinh =:2';
    open report_out for s using pagent,pagent;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;

PROCEDURE report_payment_order(
    pma_tinh varchar2,
    pkhobac varchar2,
    pngay_tt varchar2,
    ptype varchar2,
    report_out OUT SYS_REFCURSOR)

is
    s varchar2(10000);
    ref_ sys_refcursor;
    ckn varchar2(100):=ckn_hientai;
    l_tien_tra number;
    l_tien_chu varchar(200);
    l_khobac varchar(200);
    l_ten_dv varchar(200);
    l_diachi_dv varchar(500);
    l_mst_dv varchar(50);
    l_monbai number :=0;
    l_gtgt number :=0;
    l_tncn number :=0;
    l_ttdb number :=0;
    l_tainguyen number :=0;
    l_bvmt number :=0;
    l_vat_bvmt number :=0;
    l_thuphat number :=0;
    l_chamnop number :=0;
    l_time number;
begin
    --Lay thong tin cau hinh thoi gian cho du lieu
    Execute immediate' SELECT expire_time FROM tax.config_special_days WHERE agent =:1 and status=1 and rownum =1'
        into l_time Using pma_tinh;

    if ptype=1 then
        s:='select sum(a.tientra) tong_tien, tax.util.doisosangchu(sum(a.tientra))
              from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f
              where a.mst=b.mst and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+) and a.ma_tmuc=e.id(+) and a.phieu_id=f.id
        and c.shkb =:1
        and f.ngay_tt between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24 and  trunc(sysdate)+ '||l_time||'/24 -1/86400
        and f.ma_tinh =:2';
        execute immediate s into l_tien_tra,l_tien_chu using pkhobac,pma_tinh;

        s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
        execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;

        s:='select rownum stt,'||l_tien_tra||' tong_tien,'''||l_tien_chu||''' tong_tien_chu, tientra tien_tra,
            ma_chuong,ten_chuong,quan,tinh,'''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv
          from (
          select sum(tientra) tientra,ten_chuong,ma_chuong,quan,tinh from
          (
              select a.tientra,d.ten_chuong,e.tentieumuc,a.ma_chuong,
              (select district_name from districts where id =b.ma_huyen and rownum=1) quan,
              (select province_name from provinces where id =b.ma_tinh and rownum=1) tinh
              from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f
              where a.mst=b.mst and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+) and a.ma_tmuc=e.id(+) and a.phieu_id=f.id';

        s:=s||' and c.shkb='''||pkhobac||'''';
        s:=s||' and f.ngay_tt between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24 and  trunc(sysdate)+ '||l_time||'/24 -1/86400';

        s:=s||' and f.ma_tinh='''||pma_tinh||'''
              ) group by ma_chuong,ten_chuong,quan,tinh)';

    else
        s:='select ten_dv,diachi diachi_dv, mst mst_dv from donvi_qls where ma_tinh =:1 and ID=0 and rownum=1';
        execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv using pma_tinh;

        s:='select sum(a.tientra) tong_tien, tax.util.doisosangchu(sum(a.tientra))
              from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f
              where a.mst=b.mst and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+) and a.ma_tmuc=e.id(+) and a.phieu_id=f.id
        and c.shkb =:1
        and f.ngay_tt between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24 and  trunc(sysdate)+ '||l_time||'/24 -1/86400
        and f.ma_tinh =:2';
        execute immediate s into l_tien_tra,l_tien_chu using pkhobac,pma_tinh;

        s:='select rownum stt,'||l_tien_tra||' tong_tien,'''||l_tien_chu||''' tong_tien_chu,
            tientra monbai, '||l_gtgt||' gtgt, '||l_tncn||' tncn, '||l_ttdb||' ttdb, '||l_tainguyen||' tainguyen,
            '||l_bvmt||' bvmt, '||l_vat_bvmt||' vat_bvmt, '||l_thuphat||' thuphat,'||l_chamnop||' chamnop,
            tientra tien_tra,ma_chuong,ma_tmuc,ten_nnt,mst,so,to_char(ngay,''dd/mm/yyyy'') ngay,
            '''||l_ten_dv||''' ten_dv,'''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv
          from (
          select mst,sum(tientra) tientra,ma_chuong,ma_tmuc,ten_nnt,so,ngay from
          (
              select b.mst,a.tientra,d.ten_chuong,e.tentieumuc,a.ma_chuong,a.ma_tmuc,b.ten_nnt,f.id so, f.ngay_tt ngay
              from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f
              where a.mst=b.mst and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+) and a.ma_tmuc=e.id(+) and a.phieu_id=f.id';

        s:=s||' and c.shkb='''||pkhobac||'''';
        s:=s||' and f.ngay_tt between to_date('''||pngay_tt||''',''dd/mm/yyyy'') + '||l_time||'/24 and  trunc(sysdate)+ '||l_time||'/24 -1/86400';

        s:=s||' and f.ma_tinh='''||pma_tinh||'''
              ) group by mst,ma_chuong,ma_tmuc,ten_nnt,so,ngay)';

        --Tao file & put file len FTP server
        /*Begin
            select ten_kho_bac into l_khobac from tax.khobacs where id = pkhobac;
            Exception when others then
            l_khobac := pkhobac;
        End;
        create_and_put_file_ftp(i_agent=>pma_tinh, i_ma_khobac=>pkhobac, i_khobac=>l_khobac, i_ngay_tt=>pngay_tt);*/
    end if;

    open report_out for s;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;

PROCEDURE report_receipts(pphieu varchar2,
    pma_tinh varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(1000);
    ckn varchar2(100):=ckn_hientai();
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
        s:='select a.ten_dv,a.diachi diachi_dv,a.mst mst_dv,(select province_name from provinces where id = a.ma_tinh and rownum =1)
                from donvi_qls a where ma_tinh =:1 and ID=0 and rownum=1';
        execute immediate s into l_ten_dv,l_diachi_dv,l_mst_dv,l_tinh using pma_tinh;
        exception when others then
            l_ten_dv :='';l_diachi_dv :='';l_mst_dv :='';l_tinh :='';
    end;

    s:='select rownum stt,a.kythue kythu, '''||l_lanthu||''' lanthu, '||nvl(l_tieno,0)||' tien_no,
        '''||l_ten_dv||''' ten_dv, '''||l_diachi_dv||''' diachi_dv, '''||l_mst_dv||''' mst_dv, '''||l_tinh||''' tinh,
        '||l_tien_tra||' tong_tien,'''||l_tien_chu||''' tong_tien_chu,a.mst,a.ma_tmuc tieumuc_id,
        a.tientra tien_tieu_muc,'||nvl(l_tienps,0)||' tien_muc,(select TEN_CHUONG from  tax.chuongs where a.ma_chuong = id) ten_chuong,
        (select TENTIEUMUC from  tax.tieu_mucs where a.ma_tmuc = id) tieu_muc, c.ma_nv||'':''||c.ma_t ma_nv, b.quaythu_id quaythu,
         a.phieu_id, to_char(b.ngay_tt,''dd/mm/yyyy'') ngay_tt, c.mobile, c.mst||'''||l_lanthu||''' barcode
         from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b, nnts_'||ckn||' c
        where a.phieu_id = b.id
        and a.phieu_id =:1
        and a.mst = c.mst
        and a.ma_tinh =:2';
    open report_out for s using pphieu,pma_tinh;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;

PROCEDURE report_staff_invoice(
    pma_tinh varchar2,
    pdonvi varchar2,
    pbuucuc varchar2,
    pmanv varchar2,
    ptungay varchar2,
    pdenngay varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(1000);
    ckn varchar2(100):=ckn_hientai();
begin

    s:='select rownum stt,d.ten_dv,c.tenbuucuc,a.ma_nv,a.mst,a.tien_giao,to_char(a.ngay_giao,''dd/mm/yyyy hh24:mi:ss'') ngay_giao,a.nguoi_giao,a.trangthai_tt,e.ten_nnt,e.mota_diachi diachi
            from tax.phieu_'||ckn||' a, tax.nhanvien_tcs b, tax.buucucthus c, (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') d,tax.nnts_'||ckn||' e
            where a.ma_nv = b.id
            and b.mabc_id = c.id
            and c.donviql_id = d.id
            and a.mst = e.mst
            and b.ma_tinh =:1';

    if pdonvi is not null then s:=s||' and c.donviql_id like '''||replace(pdonvi,'*','%')||''''; end if;
    if pbuucuc is not null then s:=s||' and b.mabc_id like '''||replace(pbuucuc,'*','%')||''''; end if;
    if pmanv is not null then s:=s||' and a.ma_nv like '''||replace(pmanv,'*','%')||''''; end if;
    if ptungay is not null then s:=s||' and a.ngay_giao >= to_date('''||ptungay||''',''dd/mm/yyyy'')'; end if;
    if pdenngay is not null then s:=s||' and a.ngay_giao < to_date('''||pdenngay||''',''dd/mm/yyyy'') +1'; end if;

    s:=s||' order by d.ten_dv,c.tenbuucuc,a.ma_nv,a.ngay_giao';


    open report_out for s using pma_tinh;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;

PROCEDURE report_staff_invoice_retail(
    pma_tinh varchar2,
    pphieu varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(1000);
    ckn varchar2(100):=ckn_hientai();
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

    s:='select rownum stt,'''||l_ten_dv||''' ten_dv,c.tenbuucuc,a.ma_nv,a.mst,a.tien_giao,to_char(a.ngay_giao,''dd/mm/yyyy hh24:mi:ss'') ngay_giao,a.nguoi_giao,a.trangthai_tt,e.ten_nnt,e.mota_diachi diachi
            from tax.phieu_'||ckn||' a, tax.nhanvien_tcs b, tax.buucucthus c,tax.nnts_'||ckn||' e
            where a.ma_nv = b.id
            and b.mabc_id = c.id
            and a.mst = e.mst
            and b.ma_tinh =:1 and a.id =:2
            order by c.tenbuucuc,a.ma_nv,a.ngay_giao';

    open report_out for s using pma_tinh,pphieu;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;

Function list_staff_invoice(
    ptungay varchar2,
    pdenngay varchar2,
    pma_tinh varchar2,
    pdonvi varchar2,
    pbuucuc varchar2,
    pmanv varchar2,
    pType varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(3000);
    ref_ sys_refcursor;
    ckn varchar2(100):=ckn_hientai();
begin

    s:='select rownum stt,d.ten_dv,c.tenbuucuc,a.ma_nv,a.mst,a.tien_giao,to_char(a.ngay_giao,''dd/mm/yyyy hh24:mi:ss'') ngay_giao,a.nguoi_giao,a.trangthai_tt,e.ten_nnt,e.mota_diachi diachi
            from tax.phieu_'||ckn||' a, tax.nhanvien_tcs b, tax.buucucthus c, (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') d,tax.nnts_'||ckn||' e
            where a.ma_nv = b.id
            and b.mabc_id = c.id
            and c.donviql_id = d.id
            and a.mst = e.mst
            and b.ma_tinh ='''||pma_tinh||'''';

    if pdonvi is not null then s:=s||' and c.donviql_id like '''||replace(pdonvi,'*','%')||''''; end if;
    if pbuucuc is not null then s:=s||' and b.mabc_id like '''||replace(pbuucuc,'*','%')||''''; end if;
    if pmanv is not null then s:=s||' and a.ma_nv like '''||replace(pmanv,'*','%')||''''; end if;
    if ptungay is not null then s:=s||' and a.ngay_giao >= to_date('''||ptungay||''',''dd/mm/yyyy'')'; end if;
    if pdenngay is not null then s:=s||' and a.ngay_giao < to_date('''||pdenngay||''',''dd/mm/yyyy'') +1'; end if;

    s:=s||' order by d.ten_dv,c.tenbuucuc,a.ma_nv,a.ngay_giao';

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

Function list_info_debt(
    ptungay varchar2,
    pdenngay varchar2,
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
    ckn varchar2(100):=ckn_hientai();
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
    if ptungay is not null then s:=s||' and b.ngay_tt >= to_date('''||ptungay||''',''dd/mm/yyyy'')'; end if;
    if pdenngay is not null then s:=s||' and b.ngay_tt < to_date('''||pdenngay||''',''dd/mm/yyyy'') +1'; end if;

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

PROCEDURE report_info_debt(
    pma_tinh varchar2,
    pdonvi varchar2,
    pbuucuc varchar2,
    pquaythu varchar2,
    pnguoigachno varchar2,
    ptungay varchar2,
    pdenngay varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(1000);
    ckn varchar2(100):=ckn_hientai();
begin

    s:='select rownum stt,a.mst,a.tientra,(select TEN_CHUONG from  tax.chuongs where a.ma_chuong = id) ten_chuong,
        (select TENTIEUMUC from  tax.tieu_mucs where a.ma_tmuc = id) ten_muc, a.phieu_id,
        to_char(b.ngay_tt,''dd/mm/yyyy hh24:mi:ss'') ngay_tt, b.nguoigachno_id,d.tenquay,
        e.tenbuucuc,f.ten_dv, g.ten_nnt, g.mota_diachi diachi, h.name hinhthuc_tt
         from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b,
         tax.nguoigachnos c, tax.quaythus d, tax.buucucthus e, (select * from tax.donvi_qls where ma_tinh='''||pma_tinh||''') f, tax.nnts_'||ckn||' g, tax.hinhthuc_tts h
        where a.phieu_id = b.id and b.nguoigachno_id = c.id
        and c.quaythu_id = d.id and d.mabc_id = e.id
        and e.donviql_id = f.id and a.mst = g.mst
        and a.ma_tinh = g.ma_tinh and b.httt_id = h.id
        and a.ma_tinh ='''||pma_tinh||'''';

    if pdonvi is not null then s:=s||' and f.id like '''||replace(pdonvi,'*','%')||''''; end if;
    if pbuucuc is not null then s:=s||' and e.id like '''||replace(pbuucuc,'*','%')||''''; end if;
    if pquaythu is not null then s:=s||' and d.id like '''||replace(pquaythu,'*','%')||''''; end if;
    if pnguoigachno is not null then s:=s||' and b.nguoigachno_id like '''||replace(pnguoigachno,'*','%')||''''; end if;
    if ptungay is not null then s:=s||' and b.ngay_tt >= to_date('''||ptungay||''',''dd/mm/yyyy'')'; end if;
    if pdenngay is not null then s:=s||' and b.ngay_tt < to_date('''||pdenngay||''',''dd/mm/yyyy'') +1'; end if;

    s:=s||' order by f.ten_dv,e.tenbuucuc,d.tenquay,a.mst,b.ngay_tt,b.nguoigachno_id';


    open report_out for s;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;

PROCEDURE report_debt_local(
    pma_tinh varchar2,
    pluot varchar2,
    report_out OUT SYS_REFCURSOR)
is
    s varchar2(1000);
    ckn varchar2(100):=ckn_hientai();
begin

    s:='select rownum stt,a.mst,a.tientra,(select TEN_CHUONG from  tax.chuongs where a.ma_chuong = id) ten_chuong,
        (select TENTIEUMUC from  tax.tieu_mucs where a.ma_tmuc = id) ten_muc, a.phieu_id,
        to_char(b.ngay_tt,''dd/mm/yyyy hh24:mi:ss'') ngay_tt, b.nguoigachno_id,c.ten_nnt, c.mota_diachi diachi
         from tax.ct_tra_'||ckn||' a, tax.bangphieutra_'||ckn||' b, tax.nnts_'||ckn||' c
        where a.phieu_id = b.id  and a.mst = c.mst
        and a.ma_tinh = c.ma_tinh
        and a.ma_tinh ='''||pma_tinh||'''
        and b.group_id ='||pluot||'';

    s:=s||' order by a.mst';


    open report_out for s;

    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open report_out for 'select :1 err from dual' using err;
    end;
end;
function new_notification_log(
    pid varchar2,
    preceiver varchar2,
    pcontent varchar2,
    psubject varchar2,
    pprovince_id varchar2,
    ptype varchar2,
    pcreated_user varchar2,
    pcreated_date varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
    l_id number := util.getseq('NOTIFICATION_LOG_SEQ');
    l_receiver varchar2(3000);
    l_content varchar2(3000);
    l_subject varchar2(200);
    l_mst   tax.util.StringArray;
    l_exe varchar2(3000);
begin
    s:='insert into tax.notification_log(id,receiver,subject,content,province_id, type,created_user,created_date)
     values (:id,:receiver,:subject,:content,:province_id,:type,:created_user,:created_date)';
    execute immediate s using l_id,preceiver,psubject,pcontent,pprovince_id, ptype,pcreated_user,sysdate;

    --Send SMS
    Begin
        Execute immediate 'select receiver,content from tax.notification_log where id =:1 and type =:2'
            into l_receiver,l_content using l_id,1;
        l_mst:= tax.util.str_to_array(l_receiver,',');
        For n in l_mst.first..l_mst.last loop
            l_exe := ws_sms.SEND_SMS(I_TAXCODE=> l_mst(n), I_MESSAGE=> l_content);
        End loop;
        Exception when others then
            null;
    End;

    --Send Email
    Begin
        Execute immediate 'select receiver,subject,content from tax.notification_log where id =:1 and type =:2'
            into l_receiver,l_content,l_subject using l_id,2;
        l_mst:= tax.util.str_to_array(l_receiver,',');
        For n in l_mst.first..l_mst.last loop
            l_exe := ws_sms.SEND_EMAIL(I_TAXCODE=> l_mst(n), I_SUBJECT=> l_subject, I_CONTENT=> l_content);
        End loop;
        Exception when others then
            null;
    End;

    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function export_user_info(
    pfrom_date varchar2,
    pto_date varchar2,
    pagent varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
begin
    logger.access('user_info|EXPORT',pfrom_date||'|'||pto_date||'|'||pagent);
    s:='select * from tax.user_info where created_date >=to_date('''||pfrom_date||''',''dd/MM/yyyy'')
        and created_date <=to_date('''||pto_date||''',''dd/MM/yyyy'') and agent='''||pagent||'''';

    open ref_ for s;
    return ref_;
    exception when others then
        declare err varchar2(500); begin err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

procedure create_and_put_file_ftp(i_agent varchar2,
                                    i_ma_khobac varchar2,
                                    i_khobac varchar2,
                                    i_ngay_tt varchar2)
is
    text        varchar2(32767);
    agent       sys.aq$_agent   := sys.aq$_agent(' ', null, 0);
    message     sys.aq$_jms_text_message;

    enqueue_options    dbms_aq.enqueue_options_t;
    message_properties dbms_aq.message_properties_t;
    msgid               raw(16);

BEGIN

    message := sys.aq$_jms_text_message.construct;
    message.set_string_property('invoiceType', 'payment_order_detail');
    message.set_string_property('exportType', 'pdf');
    message.set_string_property('AGENT', i_agent);
    message.set_string_property('PATH', to_char(sysdate,'yyyymmdd'));
    message.set_string_property('SUB_FILE', to_char(sysdate,'hh24miss'));
    message.set_string_property('MA_KHOBAC', i_ma_khobac);
    message.set_string_property('KHO_BAC', i_khobac);
    message.set_string_property('NGAY_TT', i_ngay_tt);


    message.set_text('1');

    dbms_aq.enqueue(queue_name => 'invoice_queue',
                       enqueue_options => enqueue_options,
                       message_properties => message_properties,
                       payload => message,
                       msgid => msgid);
    commit;
END;

procedure enqueue_el_bill(i_agent varchar2,
                            i_taxcode varchar2,
                            i_month varchar2,
                            i_bill varchar2,
                            i_cashier_code varchar2,
                            i_type varchar2)
is
    text        varchar2(32767);
    agent       sys.aq$_agent   := sys.aq$_agent(' ', null, 0);
    msg_printbill     sys.aq$_jms_text_message;
    mess_camel        varchar2(5000);
    enqueue_options   dbms_aq.enqueue_options_t;
    message_properties dbms_aq.message_properties_t;
    msgid               raw(16);

BEGIN
    mess_camel := i_taxcode||';'||i_month||';'||i_agent||';'||i_bill||';'||i_cashier_code||';'||i_type||';'||chr(13);
    logger.access('enqueue_el_bill',mess_camel);

    msg_printbill := SYS.AQ$_JMS_TEXT_MESSAGE.construct;
             msg_printbill.set_text(mess_camel);
             msg_printbill.set_string_property('AGENT',i_agent);
             msg_printbill.set_string_property('TAXCODE',i_taxcode);
             msg_printbill.set_string_property('MONTH',i_month);
             msg_printbill.set_string_property('TYPE_BILL',i_type);

             DBMS_AQ.enqueue(queue_name          => 'TAX.EL_BILL_QUEUE',
                                   enqueue_options     => enqueue_options,
                                   message_properties  => message_properties,
                                   payload             => msg_printbill,
                                   msgid               => msgid);
    COMMIT;
    Exception when others then
        logger.access('enqueue_el_bill_error',mess_camel||'-'||to_char(sqlerrm));
END;

procedure enqueue_publish_inv(i_agent varchar2,
                            i_taxcode varchar2,
                            i_month varchar2,
                            i_bill varchar2,
                            i_cashier_code varchar2)
is
    text        varchar2(32767);
    agent       sys.aq$_agent   := sys.aq$_agent(' ', null, 0);
    msg_printbill     sys.aq$_jms_text_message;
    mess_camel        varchar2(5000);
    enqueue_options   dbms_aq.enqueue_options_t;
    message_properties dbms_aq.message_properties_t;
    msgid               raw(16);

BEGIN
    mess_camel := i_taxcode||';'||i_month||';'||i_agent||';'||i_bill||';'||i_cashier_code||';'||chr(13);
    logger.access('enqueue_publish_inv',mess_camel);
    msg_printbill := SYS.AQ$_JMS_TEXT_MESSAGE.construct;
             msg_printbill.set_text(mess_camel);
             msg_printbill.set_string_property('AGENT',i_agent);
             msg_printbill.set_string_property('TAXCODE',i_taxcode);
             msg_printbill.set_string_property('MONTH',i_month);

             DBMS_AQ.enqueue(queue_name          => 'TAX.PUBLISH_INV',
                                   enqueue_options     => enqueue_options,
                                   message_properties  => message_properties,
                                   payload             => msg_printbill,
                                   msgid               => msgid);
    COMMIT;
    Exception when others then
        logger.access('enqueue_publish_inv_error',mess_camel||'-'||to_char(sqlerrm));
END;

function check_info_dept(i_taxcode varchar2)
return number
is
    l_count number;
    l_s varchar2(1000);
    ckn varchar2(100):= ckn_hientai();
    l_tienno number;
    l_tientra number;
Begin
    l_s:= 'select sum(no_cuoi_ky) from tax.ct_no_'||ckn||' where mst =:1';
    execute immediate l_s into l_tienno  using i_taxcode;

    l_s:='select sum(tientra) from tax.ct_tra_'||ckn||' where mst =:1';
    execute immediate l_s into l_tientra  using i_taxcode;
    If l_tientra >= l_tienno then
        Return 1;
    Else
        Return 0;
    End if;
    Exception when others THEN
        Return 0;
End;

function check_info_dept(i_taxcode varchar2, i_kythue varchar2)
return number
is
    l_count number;
    l_s varchar2(1000);
    ckn varchar2(100):= ckn_hientai();
    l_tienno number;
    l_tientra number;
Begin
    l_s:= 'select sum(no_cuoi_ky) from tax.ct_no_'||ckn||' where mst =:1 and kythue =:2';
    execute immediate l_s into l_tienno  using i_taxcode,i_kythue;

    l_s:='select sum(tientra) from tax.ct_tra_'||ckn||' where mst =:1 and kythue =:2';
    execute immediate l_s into l_tientra  using i_taxcode,i_kythue;
    If l_tientra >= l_tienno then
        Return 1;
    Else
        Return 0;
    End if;
    Exception when others THEN
        Return 0;
End;

function new_hddts(
    pid varchar2,
    pstatus varchar2,
    ppattern varchar2,
    pfkey varchar2,
    pnumb_bill varchar2,
    pserial varchar2,
    prelease_date varchar2,
    plog_date varchar2)
return varchar2
is
    s varchar2(1000);
    l_kythue varchar2(20):= to_char(sysdate,'mmyyyy');
begin
    s:='insert into tax.hddts(id,status,pattern,fkey,numb_bill,serial,release_date,log_date, taxcode, MONTH)
     values (:id,:status,:pattern,:fkey,:numb_bill,:serial,:release_date,:log_date,:taxcode,:month)';
    execute immediate s using to_char(util.GETSEQ('HDDTS_SEQ')),pstatus,ppattern,pfkey,pnumb_bill,pserial,
        to_date(prelease_date,'dd/MM/yyyy HH24miss'),sysdate,substr(pfkey,1,instr(pfkey,l_kythue)-1),l_kythue;

    --Cap nhat SUB- MST
    update hddts set taxcode=substr(taxcode,1,10)||'-'||substr(taxcode,-3)
    where fkey = pfkey and length(taxcode)>10 ;

    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm);
        return err;
    end;
end;

function new_ketquaphats(
    pid varchar2,
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
    l_agent := get_agent_taxcode(pmst);
    l_agent1 := crud.search_agent_info(pUserId);
    if l_agent <> l_agent1 then
        return 'BAN KHONG DUOC THAO TAC VOI DU LIEU CUA TINH KHAC';
    end if;

    select count(1) into l_exists from ketquaphats where mst = pmst and chuky = pchuky;
    if l_exists >0 then
        return 'HOA DON '||pmst||' DA DUOC NHAP !';
    end if;

    logger.access('tax.ketquaphats|NEW',pid||'|'||pmst||'|'||pchungtu_id||'|'||pma_nv||'|'||pbill||'|'||pngay_phat||'|'||pngay_nhap||'|'||pnguoi_nhan||'|'||plan_phat||'|'||plan_thu||'|'||ptrang_thai||'|'||pma_daily||'|'||pdiem_thu||'|'||pghichu);
    s:='insert into tax.ketquaphats(id,mst,ma_tinh,chuky,chungtu_id,ma_nv,bill,ngay_phat,ngay_nhap,nguoi_nhan,lan_phat,lan_thu,trang_thai,ma_daily,diem_thu,ghichu,loguser)
     values (:id,:mst,:ma_tinh,:chuky,:chungtu_id,:ma_nv,:bill,:ngay_phat,:ngay_nhap,:nguoi_nhan,:lan_phat,:lan_thu,:trang_thai,:ma_daily,:diem_thu,:ghichu,:loguser)';
    execute immediate s using l_id,pmst,l_agent1,pchuky,pchungtu_id,pma_nv,pbill,to_date(pngay_phat,'dd/mm/yyyy'),to_date(pngay_nhap,'dd/mm/yyyy'),pnguoi_nhan,plan_phat,plan_thu,ptrang_thai,pma_daily,pdiem_thu,pghichu,pUserId;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function search_ketquaphats(
    pid varchar2,
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
    ckn varchar2(100):=crud.ckn_hientai;
begin
    l_agent := crud.search_agent_info(pUserId);

    s:='select id, mst, chuky, (select name from chungtu where id =chungtu_id and status=1) chungtu_id, ma_nv, bill, to_char(ngay_phat,''dd/mm/yyyy'') ngay_phat,
                                    to_char(ngay_nhap,''dd/mm/yyyy'') ngay_nhap,nguoi_nhan, lan_phat, lan_thu, (select name from ketqua_cts where id = trang_thai and status=1) trang_thai ,
                                    ma_daily, diem_thu, ghichu, loguser nguoi_nhap from tax.ketquaphats
                                    where exists (select 1 from nnts_'||ckn||' a where mst = a.mst and a.ma_tinh ='''||l_agent||''')';
    if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
    if pmst is not null then s:=s||' and mst like '''||replace(pmst,'*','%')||''''; end if;
    if pchuky is not null then s:=s||' and chuky like '''||replace(pchuky,'*','%')||''''; end if;
    if pchungtu_id is not null then s:=s||' and chungtu_id like '''||replace(pchungtu_id,'*','%')||''''; end if;
    if pma_nv is not null then s:=s||' and ma_nv like '''||replace(pma_nv,'*','%')||''''; end if;
    if pbill is not null then s:=s||' and bill like '''||replace(pbill,'*','%')||''''; end if;
    if pngay_phat is not null then s:=s||' and ngay_phat=to_date('''||pngay_phat||''',''dd/mm/yyyy'')'; end if;
    if pngay_nhap is not null then s:=s||' and ngay_nhap=to_date('''||pngay_nhap||''',''dd/mm/yyyy'')'; end if;
    if pnguoi_nhan is not null then s:=s||' and nguoi_nhan like '''||replace(pnguoi_nhan,'*','%')||''''; end if;
    if plan_phat is not null then s:=s||' and lan_phat like '''||replace(plan_phat,'*','%')||''''; end if;
    if plan_thu is not null then s:=s||' and lan_thu like '''||replace(plan_thu,'*','%')||''''; end if;
    if ptrang_thai is not null then s:=s||' and trang_thai like '''||replace(ptrang_thai,'*','%')||''''; end if;
    if pma_daily is not null then s:=s||' and ma_daily like '''||replace(pma_daily,'*','%')||''''; end if;
    if pdiem_thu is not null then s:=s||' and diem_thu like '''||replace(pdiem_thu,'*','%')||''''; end if;
    if pghichu is not null then s:=s||' and ghichu like '''||replace(pghichu,'*','%')||''''; end if;
    s:=s||' order by id';

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
function edit_ketquaphats(
    pid varchar2,
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
begin
    logger.access('tax.ketquaphats|EDIT',pid||'|'||pmst||'|'||pchungtu_id||'|'||pma_nv||'|'||pbill||'|'||pngay_phat||'|'||pngay_nhap||'|'||pnguoi_nhan||'|'||plan_phat||'|'||plan_thu||'|'||ptrang_thai||'|'||pma_daily||'|'||pdiem_thu||'|'||pghichu);
    s:='update tax.ketquaphats set chuky=:chuky,chungtu_id=:chungtu_id,ma_nv=:ma_nv,bill=:bill,ngay_phat=:ngay_phat,ngay_nhap=:ngay_nhap,nguoi_nhan=:nguoi_nhan,lan_phat=:lan_phat,lan_thu=:lan_thu,trang_thai=:trang_thai,ma_daily=:ma_daily,diem_thu=:diem_thu,ghichu=:ghichu where id=:id';
    execute immediate s using pchuky,pchungtu_id,pma_nv,pbill,to_date(pngay_phat,'dd/mm/yyyy'),to_date(pngay_nhap,'dd/mm/yyyy'),pnguoi_nhan,plan_phat,plan_thu,ptrang_thai,pma_daily,pdiem_thu,pghichu,pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
function del_ketquaphats(
    pId varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(1000);
begin
    logger.access('tax.ketquaphats|DEL',pId);
    s:='delete from tax.ketquaphats where id=:id';
    execute immediate s using pid;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function search_kythue(
    pmst VARCHAR2,
    pmatinh VARCHAR2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):=ckn_hientai();
begin
    s:='select distinct kythue id,kythue name from ct_no_'||ckn||' where mst =:1 and ma_tinh =:2';
    open ref_ for s using pmst,pmatinh;
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
function search_kythue_cqt(
    pmst VARCHAR2,
    pmatinh VARCHAR2,
    pmacqthu VARCHAR2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):=ckn_hientai();
begin
    s:='select distinct kythue id,kythue name from ct_no_'||ckn||' where mst =:1 and ma_tinh =:2 and ma_cq_thu=:3';
    open ref_ for s using pmst,pmatinh,pmacqthu;
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function get_nnt_ct_no_kythue(
    pmst varchar2,
    pMa_tinh varchar2,
    pkythue varchar2)
return sys_refcursor
is
    ckn varchar2(100):=ckn_hientai();
    ref_ sys_refcursor;
    s varchar2(10000);
    l_agent varchar2(15);
begin
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
            SELECT mst,ma_tinh,sum(tientra) TIENTRA,ma_chuong,ma_cq_thu,ma_tmuc,kythue,chuky
              FROM ct_tra_'||ckn||' where 1=1';

                If pkythue is not null then
                    s:=s||' and kythue ='''||pkythue||'''';
                End if;

              s:=s||' group by mst,ma_tinh,ma_chuong,ma_cq_thu,
                  ma_tmuc,kythue,chuky
        ) b, chuongs c, tieu_mucs d
        where a.mst=b.mst(+) and a.ma_chuong=b.ma_chuong(+) and a.ma_tmuc=b.ma_tmuc(+)
            and a.ma_chuong=C.id(+) and a.ma_tmuc=d.id(+)
            and a.kythue = b.kythue(+) and  a.chuky = b.chuky(+)
            AND a.no_cuoi_ky-nvl(b.tientra,0) >0 and A.MST =:1 and a.ma_tinh =:2
            ORDER by a.kythue,a.ma_tmuc';

    OPEN REF_ for s Using pmst,l_agent;
    return ref_;
end;


function search_nnt_kythue_giaophieu(
    pma_nv varchar2,
    PMA_TINH VARCHAR2,
    psearch_key VARCHAR2,
    pType VARCHAR2,
    pRecordPerPage varchar2 default 1000,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):=ckn_hientai();
begin
    s:='select a.mst,a.ten_nnt,a.ma_cqt_ql,a.mota_diachi,to_char(nvl(c.tien_giao,0),''fm999,999,999,999,999'') da_giao,
        to_char(b.sotien-nvl(c.tien_giao,0),''fm999,999,999,999,999'') sotien, b.kythue from tax.nnts_'||ckn||' a,
        (select sum(no_cuoi_ky) sotien,mst,kythue from ct_no_'||ckn||' group by mst,kythue) b,
        (select sum(tien_giao) tien_giao,mst,kythue from phieu_'||ckn||' group by mst,kythue) c
        where a.mst=b.mst and b.mst=c.mst(+) and b.kythue= c.kythue(+) and b.sotien-nvl(c.tien_giao,0)>0
        and not exists (select 1 from ct_tra_'||ckn||' ct where a.mst = ct.mst and b.kythue = ct.kythue)';
    if pma_tinh is not null then s:=s||' and ma_tinh = '''||pma_tinh||''''; end if;
    if pma_nv is not null then s:=s||' and ma_nv like '''||replace(pma_nv,'*','%')||''''; end if;
    if psearch_key is not null then s:=s||' and (a.mst like ''%'||(psearch_key)||'%'' or tax.uto_khongdau(upper(a.mota_diachi)) like ''%'||tax.uto_khongdau(upper(psearch_key))||'%'' or tax.uto_khongdau(upper(a.ten_nnt)) like ''%'||tax.uto_khongdau(upper(psearch_key))||'%'')'; end if;
    s:=s||' order by a.mst,b.kythue';

    /*if(pPageIndex=-1) then
        s:='select ceil(count(*)/:1) nop,count(1) nor from ('||s||')';
        open ref_ for s using  pRecordPerPage;
    else
        open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
    end if;*/

    open ref_ for s;
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function search_nnts_kythue(
    pmst varchar2,
    pten_nnt varchar2,
    ploai_nnt varchar2,
    pso varchar2,
    pchuong varchar2,
    pma_cqt_ql varchar2,
    pmota_diachi varchar2,
    pma_tinh varchar2,
    pma_huyen varchar2,
    pma_xa varchar2,
    pmobile varchar2,
    pemail varchar2,
    pma_nv varchar2,
    pType varchar2,
    pRecordPerPage varchar2,
    pPageIndex varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    ckn varchar2(100):=ckn_hientai();
begin
    s:='select * from tax.nnts_'||ckn||' where 1=1';
    if pmst is not null then s:=s||' and mst like '''||replace(pmst,'*','%')||''''; end if;
    if pten_nnt is not null then s:=s||' and ten_nnt like '''||replace(pten_nnt,'*','%')||''''; end if;
    if ploai_nnt is not null then s:=s||' and loai_nnt like '''||replace(ploai_nnt,'*','%')||''''; end if;
    if pso is not null then s:=s||' and so like '''||replace(pso,'*','%')||''''; end if;
    if pchuong is not null then s:=s||' and chuong like '''||replace(pchuong,'*','%')||''''; end if;
    if pma_cqt_ql is not null then s:=s||' and ma_cqt_ql like '''||replace(pma_cqt_ql,'*','%')||''''; end if;
    if pmota_diachi is not null then s:=s||' and mota_diachi like '''||replace(pmota_diachi,'*','%')||''''; end if;
    if pma_tinh is not null then s:=s||' and ma_tinh like '''||replace(pma_tinh,'*','%')||''''; end if;
    if pma_huyen is not null then s:=s||' and ma_huyen like '''||replace(pma_huyen,'*','%')||''''; end if;
    if pma_xa is not null then s:=s||' and ma_xa like '''||replace(pma_xa,'*','%')||''''; end if;
    if pmobile is not null then s:=s||' and mobile like '''||replace(pmobile,'*','%')||''''; end if;
    if pemail is not null then s:=s||' and email like '''||replace(pemail,'*','%')||''''; end if;
    if pma_nv is not null then s:=s||' and ma_nv like '''||replace(pma_nv,'*','%')||''''; end if;
    s:=s||' order by ma_nv';

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
function phan_tuyen_kythue(
    pManv varchar2,
    pMaT varchar2,
    pMsts varchar2,
    pUserId varchar2,
    pUserIp varchar2)
return varchar2
is
    s varchar2(32000);
    ckn varchar2(100):=ckn_hientai();
    l_mcq_ql VARCHAR2(20);
    l_count NUMBER;
BEGIN
    if (pManv is null) or (length(pManv)=0) then
        return 'Yeu cau nhap thong tin duong thu !';
    end if;
    s:='SELECT nvl(cqt_tms,''0'') mcq  FROM  user_info WHERE id=:id';
    EXECUTE IMMEDIATE s INTO l_mcq_ql USING pUserId;
    IF l_mcq_ql <> '0' THEN
        s:='SELECT count(1)  FROM nnts_2016 a WHERE a.mst IN ('''||replace(pmsts,',',''',''')||''') and a.ma_cqt_ql<>:1';
        EXECUTE IMMEDIATE s INTO l_count USING l_mcq_ql;
        IF l_count > 0 THEN
            RETURN '2';
        END IF;
    END IF;
    --luu log
    execute immediate 'insert into log_phantuyen(mst, ma_nv, ma_t, loguser, logip)
    select mst,ma_nv,nvl(ma_t,''00''),:1,:2 from nnts_'||ckn||' where mst in ('''||replace(pmsts,',',''',''')||''')' using pUserId,pUserIp;

    s:='update nnts_'||ckn||' set ma_nv='''||pManv||''', ma_t='''||pMaT||''' where mst in ('''||replace(pmsts,',',''',''')||''')';
    execute immediate s;
    commit;return '1';
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;

function check_sum_dept(
    pma_tinh varchar2,
    pkhobac varchar2,
    pngay_tt varchar2)
return number
is
    s varchar2(1000);
    l_tra number;
    ckn varchar2(100):=ckn_hientai;
    l_time number;
begin
    --Lay thong tin cau hinh thoi gian cho du lieu
    Execute immediate' SELECT expire_time FROM tax.config_special_days WHERE agent =:1 and status=1 and rownum =1'
        into l_time Using pma_tinh;

    s:='select sum(tientra) tientra from (select a.tientra,a.ma_chuong||''|''||d.ten_chuong ten_chuong,a.ma_tmuc||''|''||e.tentieumuc tentieumuc
            from ct_tra_'||ckn||' a, nnts_'||ckn||' b, coquanthus c,chuongs d, tieu_mucs e, bangphieutra_'||CKN||' f
            where a.mst=b.mst and b.ma_cqt_ql=c.cqt_tms and a.ma_chuong=d.id(+) and a.ma_tmuc=e.id(+) and a.phieu_id=f.id
             and c.shkb = '''||pkhobac||''' and f.ngay_tt between to_date('''||pngay_tt||''',''dd/mm/yyyy'') /*+ '||l_time||'/24*/ and  to_date('''||pngay_tt||''',''dd/mm/yyyy'') + 1 + '||l_time||'/24 -1/86400
             and f.ma_tinh='''||pma_tinh||''')';
    execute immediate s into l_tra;

    return l_tra;
    exception when others then
        return 0;
end;


function list_role(
    pprovince varchar2,
    pUserId varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    l_lever number;
    l_count NUMBER;
begin
   select role_lever into l_lever  from user_info where id = pUserId and rownum=1;
    if l_lever =5 THEN
        s:='select id,role_name from tax.role';
    ELSE
        s:='select count(1) from tax.user_role where user_id ='''||pUserId||''' and instr(upper(role_id),''ADMIN'') >0';
        EXECUTE IMMEDIATE s into l_count;
        IF l_count > 0 THEN
            s:='select id,role_name from role where agent ='''||pprovince||'''';
        ELSE
            s:='select id,role_name from role where agent ='''||pprovince||'''
                    and id in (select role_id from tax.user_role where user_id ='''||pUserId||''')';
        END IF;
    end if;
    open ref_ for s;
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;

function get_menu_of_role(
    pprovince varchar2,
    pUserId varchar2)
return sys_refcursor
is
    s varchar2(1000);
    ref_ sys_refcursor;
    l_lever number;
begin
    select role_lever into l_lever  from user_info where id = pUserId and rownum=1;
    if l_lever =5 then
        s:='select id,lpad(name,(menu_level-1)*24+length(name),''&nbsp;'') name_lpad,display_order
            from menu order by decode(parent_id,0,id,parent_id),display_order';
    else
        s:='select id,lpad(name,(menu_level-1)*24+length(name),''&nbsp;'') name_lpad,display_order
            from menu where id in (select menu_id from menu_access where role_id in (
                select role_id from tax.user_role a, tax.role b where a.role_id = b.id
                    and b.agent ='''||pprovince||''' and a.user_id ='''||pUserId||'''))
            order by decode(parent_id,0,id,parent_id),display_order';
    end if;
    open ref_ for s;
    return ref_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
    end;
end;
function giao_phieu_clob(
    pManv varchar2,
    pMsts clob,
    puserid varchar2)
return varchar2
is
    s varchar2(32000);
    id_ number:=util.getseq('GIAO_PHIEU_SEQ');
    ckn varchar2(100):=ckn_hientai();
    kythue varchar2(100):= to_char(sysdate,'mmyyyy');
    pmst_ util.StringArray:=str_to_array(pMsts,',');
    l_mst util.StringArray;
    l_mcq_ql VARCHAR2(100);
    l_mst_list VARCHAR2(30000):='';
    l_count NUMBER;
BEGIN
    FOR i in pmst_.first..pmst_.last LOOP
        l_mst_list:=l_mst_list||','||SUBSTR(pmst_(i),0,length(pmst_(i))-7);
    END LOOP;
    IF LENGTH(l_mst_list) > 0 THEN
        l_mst_list:=SUBSTR(l_mst_list,2,LENGTH(l_mst_list)-1);
    END IF;
    if LENGTH(pMsts) = 0 THEN
        RETURN 'Khong co du lieu';
    END IF;
    s:='SELECT nvl(cqt_tms,''0'') mcq  FROM  user_info WHERE id=:id';
    EXECUTE IMMEDIATE s INTO l_mcq_ql USING pUserId;
    IF l_mcq_ql <> '0' THEN
        s:='SELECT count(1)  FROM nnts_2016 a WHERE a.mst IN ('''||replace(l_mst_list,',',''',''')||''') and a.ma_cqt_ql<>:1';
        EXECUTE IMMEDIATE s INTO l_count USING l_mcq_ql;
        IF l_count > 0 THEN
            RETURN 'Khong duoc phep giao phieu don vi khong quan ly';
        END IF;
    END IF;

    FOR n in pmst_.first..pmst_.last LOOP
        l_mst:=util.str_to_array(pmst_(n),':');
        s:='insert into phieu_'||ckn||'(id,mst,tien_giao,ma_nv,ngay_giao,nguoi_giao,kythue,ma_tinh)
         select '||id_||',a.mst,/*b.sotien-nvl(c.tien_giao,0)*/ b.sotien,'''||pmanv||''',sysdate,'''||puserid||''',b.kythue,a.ma_tinh from tax.nnts_'||ckn||' a,
         (select sum(no_cuoi_ky) sotien, mst, kythue,ma_cq_thu from ct_no_'||ckn||' group by mst,kythue,ma_cq_thu) b/*,
         (select sum(tien_giao) tien_giao, mst, kythue from phieu_'||ckn||' group by mst,kythue) c*/
         where a.mst=b.mst and a.ma_cqt_ql=b.ma_cq_thu /*and a.mst=c.mst(+) and b.kythue = c.kythue*/
         and a.mst ='''||l_mst(l_mst.first)||''' and b.kythue='''||l_mst(l_mst.last)||'''';
        execute immediate s;
        commit;
    END LOOP;
    return id_;
    exception when others then
        declare err varchar2(500); begin    err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
    end;
end;
FUNCTION str_to_array (string_ clob, separator varchar2)
   RETURN util.stringarray
IS
   ref_   sys_refcursor;
   out_   util.stringarray;
   n      NUMBER;
   i      NUMBER;
   s      clob;
BEGIN
   if string_ is null then return out_; end if;
   s:=' '||replace(trim(string_),separator||separator,separator||' '||separator)||' ';
   n:=1;
   loop
       exit when instr(s,separator)=0;
       if substr(s,1,instr(s,separator)-1)!=' ' then
           out_(n):=trim(substr(s,1,instr(s,separator)-1));
       end if;
       n:=n+1;
       s:=substr(s,instr(s,separator)+1);
   end loop;
   if trim(s) is not null then
       out_(n):=trim(s);
   end if;
   RETURN out_;
exception
    when others then
        return out_;
END;
END;

/
