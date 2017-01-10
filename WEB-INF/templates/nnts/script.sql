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
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nnts|NEW',pmst||'|'||pten_nnt||'|'||ploai_nnt||'|'||pso||'|'||pchuong||'|'||pma_cqt_ql||'|'||pmota_diachi||'|'||pma_tinh||'|'||pma_huyen||'|'||pma_xa||'|'||pmobile||'|'||pemail||'|'||pma_nv);
	s:='insert into tax.nnts(mst,ten_nnt,loai_nnt,so,chuong,ma_cqt_ql,mota_diachi,ma_tinh,ma_huyen,ma_xa,mobile,email,ma_nv)
	 values (:mst,:ten_nnt,:loai_nnt,:so,:chuong,:ma_cqt_ql,:mota_diachi,:ma_tinh,:ma_huyen,:ma_xa,:mobile,:email,:ma_nv)';
	execute immediate s using pmst,pten_nnt,ploai_nnt,pso,pchuong,pma_cqt_ql,pmota_diachi,pma_tinh,pma_huyen,pma_xa,pmobile,pemail,pma_nv;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
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
	pRecordPerPage varchar2,
	pPageIndex varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return sys_refcursor
is
	s varchar2(1000);
	ref_ sys_refcursor;
begin
	logger.access('tax.nnts|SEARCH',pmst||'|'||pten_nnt||'|'||ploai_nnt||'|'||pso||'|'||pchuong||'|'||pma_cqt_ql||'|'||pmota_diachi||'|'||pma_tinh||'|'||pma_huyen||'|'||pma_xa||'|'||pmobile||'|'||pemail||'|'||pma_nv);
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
	s:=s||' order by id';
	open ref_ for util.xuly_phantrang(s,pPageIndex,pRecordPerPage);
	return ref_;
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); open ref_ for 'select :1 err from dual' using err; return ref_;
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
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nnts|EDIT',pmst||'|'||pten_nnt||'|'||ploai_nnt||'|'||pso||'|'||pchuong||'|'||pma_cqt_ql||'|'||pmota_diachi||'|'||pma_tinh||'|'||pma_huyen||'|'||pma_xa||'|'||pmobile||'|'||pemail||'|'||pma_nv);
	s:='update tax.nnts set  mst=:mst,ten_nnt=:ten_nnt,loai_nnt=:loai_nnt,so=:so,chuong=:chuong,ma_cqt_ql=:ma_cqt_ql,mota_diachi=:mota_diachi,ma_tinh=:ma_tinh,ma_huyen=:ma_huyen,ma_xa=:ma_xa,mobile=:mobile,email=:email,ma_nv=:ma_nv where id=:id';
	execute immediate s using pmst,pten_nnt,ploai_nnt,pso,pchuong,pma_cqt_ql,pmota_diachi,pma_tinh,pma_huyen,pma_xa,pmobile,pemail,pma_nv,pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;
function del_nnts(
	pId	varchar2,
	pUserId varchar2,
	pUserIp	varchar2)
return varchar2
is
	s varchar2(1000);
begin
	logger.access('tax.nnts|DEL',pId);
	s:='delete from tax.nnts where id=:id';
	execute immediate s using pid;
	commit;return '1';
	exception when others then
		declare	err varchar2(500); begin	err:='Loi thuc hien, ma loi:'||to_char(sqlerrm); return err;
	end;
end;