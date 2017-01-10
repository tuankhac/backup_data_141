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
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('admin.menu|NEW',pid||'|'||pname||'|'||pdisplay_order||'|'||ppicture_file||'|'||pdetail_file||'|'||pmenu_level||'|'||pparent_id||'|'||ppublish);
	s:='insert into admin.menu(id,name,display_order,picture_file,detail_file,menu_level,parent_id,publish)
	 values (:id,:name,:display_order,:picture_file,:detail_file,:menu_level,:parent_id,:publish)';
	execute immediate s using pid,pname,pdisplay_order,ppicture_file,pdetail_file,pmenu_level,pparent_id,ppublish;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
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
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('admin.menu|SEARCH',pid||'|'||pname||'|'||pdisplay_order||'|'||ppicture_file||'|'||pdetail_file||'|'||pmenu_level||'|'||pparent_id||'|'||ppublish);
	s:='select * from admin.menu where 1=1';
 	if pid is not null then s:=s||' and id like '''||replace(pid,'*','%')||''''; end if;
	if pname is not null then s:=s||' and name like '''||replace(pname,'*','%')||''''; end if;
	if pdisplay_order is not null then s:=s||' and display_order like '''||replace(pdisplay_order,'*','%')||''''; end if;
	if ppicture_file is not null then s:=s||' and picture_file like '''||replace(ppicture_file,'*','%')||''''; end if;
	if pdetail_file is not null then s:=s||' and detail_file like '''||replace(pdetail_file,'*','%')||''''; end if;
	if pmenu_level is not null then s:=s||' and menu_level like '''||replace(pmenu_level,'*','%')||''''; end if;
	if pparent_id is not null then s:=s||' and parent_id like '''||replace(pparent_id,'*','%')||''''; end if;
	if ppublish is not null then s:=s||' and publish like '''||replace(ppublish,'*','%')||''''; end if;
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
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
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('admin.menu|EDIT',pid||'|'||pname||'|'||pdisplay_order||'|'||ppicture_file||'|'||pdetail_file||'|'||pmenu_level||'|'||pparent_id||'|'||ppublish);
	s:='update admin.menu set  id=:id,name=:name,display_order=:display_order,picture_file=:picture_file,detail_file=:detail_file,menu_level=:menu_level,parent_id=:parent_id,publish=:publish where id=:id';
	execute immediate s using pid,pname,pdisplay_order,ppicture_file,pdetail_file,pmenu_level,pparent_id,ppublish,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_menu(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('admin.menu|DEL',pId);
	s:='delete from admin.menu where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;