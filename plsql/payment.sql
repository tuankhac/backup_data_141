--------------------------------------------------------
--  File created - Tuesday-January-10-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body PAYMENT
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "TAX"."PAYMENT" 
IS


FUNCTION ImportAndPublishInv(i_taxcode VARCHAR2,
                            i_month VARCHAR2,
                            i_agent VARCHAR2,
                            i_bill varchar2,
                            i_nguoigachno varchar2)
RETURN clob
IS
    l_sql clob;
    l_fkey VARCHAR2(100);
    l_return clob;
    ckn varchar2(100):= crud.ckn_hientai();
	l_exists number;
BEGIN
    l_sql:='select  ''<Inv><key>''||replace(trim(x.mst),''-'','''')||''''||replace(b.phieu_id,''-'','''')||''</key><Invoice><CusCode>''||replace(trim(x.mst),''-'','''')||''</CusCode><CusName>''||util.convert_utd(x.TEN_NNT)||''</CusName><CusAddress>''||util.convert_utd(x.mota_diachi)||''</CusAddress><CusTaxCode>''||replace(trim(x.mst),''-'','''')||''</CusTaxCode><Products>''||(select tax.rows_to_str_clob(''select ''''<Product><ProdName>''''||util.convert_utd(nvl(D.tentieumuc,A.ma_tmuc))||''''</ProdName><ProdUnit>''''||a.ma_tmuc||''''</ProdUnit><Amount>''''||round(tra.tientra)||''''</Amount><Extra1>0</Extra1><Extra2>''''||round(a.no_cuoi_ky)||''''</Extra2><Remark>''''||k.ky||''''</Remark></Product>''''
						from
                        ( SELECT mst,kythue,kythue tenky,ma_tinh,sum(no_cuoi_ky) no_cuoi_ky,ma_chuong,ma_cq_thu, ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh, loai_tien,ti_gia,loai_thue,chuky
                        FROM ct_no_'||ckn||' where ma_tinh = ''''''||x.ma_tinh||'''''' and mst= '''''||i_taxcode||'''''
                        group by mst,kythue,ma_tinh,ma_chuong,ma_cq_thu, ma_tmuc,so_taikhoan_co,so_qdinh,ngay_qdinh,loai_tien,ti_gia,loai_thue,chuky order by chuky ) a,
                           ct_tra_'||ckn||' tra, tieu_mucs d, ck_thue k
                           where a.mst = tra.mst and a.ma_tmuc =tra.ma_tmuc
                           and a.kythue=tra.kythue and a.chuky = tra.chuky and a.chuky = k.chuky(+)
                           and tra.phieu_id='||i_bill||' and a.ma_tmuc=d.id(+)
                            and a.MST = ''''''||x.mst||'''''''','''') from dual)||''</Products><Amount>''||round(b.tientra)||''</Amount><Total/><VATRate/><VATAmount/><AmountInWords>''||util.convert_utd(util.doisosangchu(round(b.tientra)))||''</AmountInWords><Extra/><PaymentStatus>1</PaymentStatus></Invoice></Inv>''
                   from tax.nnts_'||ckn||' x,( select sum(tientra) tientra,mst,phieu_id from tax.ct_tra_'||ckn||'
                                                   where phieu_id ='||i_bill||'
                                                   group by mst,phieu_id) b
                   where x.mst = b.mst and x.ma_tinh ='''||i_agent||'''
                   and x.mst = '''||i_taxcode||'''';
    EXECUTE IMMEDIATE l_sql into l_return;

    l_sql:='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/"><soapenv:Header/><soapenv:Body><tem:ImportAndPublishInv><tem:Account>unttadmin</tem:Account><tem:ACpass>Untt@1234</tem:ACpass><tem:xmlInvData><![CDATA[<Invoices>'||l_return||'</Invoices>]]></tem:xmlInvData><tem:username>unttservice</tem:username><tem:password>Untt@1234</tem:password><tem:pattern>01GTKT0/002</tem:pattern><tem:serial>PT/16E</tem:serial><tem:convert>1</tem:convert></tem:ImportAndPublishInv></soapenv:Body></soapenv:Envelope>';
	l_sql:= translate(l_sql,chr(10)||chr(11)||chr(13),' ');
	--kiem tra bill
	select count(1) into l_exists from log_bill_ws where code = i_taxcode and bill = i_bill and method = 'ImportAndPublishInv' ;

	if l_exists =0 then
    	execute immediate' insert into log_bill_ws(code,agent,bill,cashier,content,method,month) values(:1,:2,:3,:4,:5,:6,:7)'
        using i_taxcode,i_agent,i_bill,i_nguoigachno,l_sql,'ImportAndPublishInv',i_month;
	end if;

	commit;
    return l_sql;
END;


FUNCTION create_bill(i_taxcode VARCHAR2,
                    i_month VARCHAR2,
                    i_agentcode VARCHAR2,
                    i_bill varchar2,
                    i_nguoigachno varchar2)
RETURN CLOB
IS
    l_return clob;
BEGIN
    l_return := ImportAndPublishInv(i_taxcode=> i_taxcode, i_month=> i_month, i_agent=> i_agentcode, i_bill=>i_bill, i_nguoigachno=> i_nguoigachno);

    Return l_return;
    EXCEPTION WHEN OTHERS THEN
    logger.access('create_bill',TO_CHAR (SQLCODE) || ':' || TO_CHAR (SQLERRM));
    RETURN '-1001';
END;

FUNCTION update_bill(i_taxcode VARCHAR2,
                    i_month VARCHAR2,
                    i_agentcode VARCHAR2,
                    i_bill varchar2,
                    i_cashier_code varchar2)
RETURN VARCHAR2
IS
    l_return VARCHAR2(10000);
BEGIN
    l_return := ConfirmPaymentFkey(i_taxcode=> i_taxcode, i_month=> i_month, i_agent=> i_agentcode, i_bill=> i_bill, i_cashier_code=>i_cashier_code);
    Return l_return;
    EXCEPTION WHEN OTHERS THEN
    logger.access('update_bill',TO_CHAR (SQLCODE) || ':' || TO_CHAR (SQLERRM));
    RETURN '10';
END;

FUNCTION del_bill(i_taxcode VARCHAR2,
                    i_month VARCHAR2,
                    i_agentcode VARCHAR2,
                    i_bill varchar2,
                    i_cashier_code varchar2)
RETURN VARCHAR2
IS
    l_return varchar2(1000);
BEGIN
    If i_agentcode='79TTT' then
        l_return := cancelInvNoPay(i_taxcode=> i_taxcode, i_month=> i_month, i_agent=> i_agentcode, i_bill=> i_bill, i_cashier_code=>i_cashier_code);
    Else
        l_return := UnConfirmPaymentFkey(i_taxcode=> i_taxcode, i_month=> i_month, i_agent=> i_agentcode, i_bill=> i_bill, i_cashier_code=>i_cashier_code);
    End if;

    Return l_return;
    EXCEPTION WHEN OTHERS THEN
    logger.access('del_bill',TO_CHAR (SQLCODE) || ':' || TO_CHAR (SQLERRM));
    RETURN '10';
END;

FUNCTION ConfirmPaymentFkey(i_taxcode VARCHAR2,
                            i_month VARCHAR2,
                            i_agent VARCHAR2,
                            i_bill varchar2,
                            i_cashier_code varchar2)
RETURN VARCHAR2
IS
    l_sql VARCHAR2(10000);
    l_fkey VARCHAR2(100);
    l_user VARCHAR2(100);
    l_pass VARCHAR2(100);
	l_exists number;
BEGIN
    if i_agent='01TTT' then
        l_user := luser;
        l_pass := lpassword;
    else
        l_user := luser_hcm;
        l_pass := lpassword_hcm;
    end if;

    l_fkey := replace(i_taxcode||i_month,'-','');
    l_sql:='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">
               <soapenv:Header/>
               <soapenv:Body>
                  <tem:confirmPaymentFkey>
                     <tem:lstFkey>'||l_fkey||'</tem:lstFkey>
                     <tem:userName>'||l_user||'</tem:userName>
                     <tem:userPass>'||l_pass||'</tem:userPass>
                  </tem:confirmPaymentFkey>
               </soapenv:Body>
            </soapenv:Envelope>';
	l_sql:= translate(l_sql,chr(10)||chr(11)||chr(13),' ');
	--kiem tra bill
	select count(1) into l_exists from log_bill_ws where code = i_taxcode and bill = i_bill and method = 'ConfirmPaymentFkey' ;

	if l_exists =0 then
    	execute immediate' insert into log_bill_ws(code,agent,bill,cashier,content,method,month) values(:1,:2,:3,:4,:5,:6,:7)'
        	using i_taxcode,i_agent,i_bill,i_cashier_code,l_sql,'ConfirmPaymentFkey',i_month;
	end if;
	commit;
    return l_sql;
END;


FUNCTION UnConfirmPaymentFkey(i_taxcode VARCHAR2,
                                  i_month VARCHAR2,
                                  i_agent VARCHAR2,
                                  i_bill varchar2,
                                  i_cashier_code varchar2)
RETURN VARCHAR2
IS
    l_sql VARCHAR2(10000);
    l_fkey VARCHAR2(100);
    l_user VARCHAR2(100);
    l_pass VARCHAR2(100);
BEGIN
    if i_agent='01TTT' then
        l_user := luser;
        l_pass := lpassword;
        l_fkey := i_taxcode||i_month;
    else
        l_user := luser_hcm;
        l_pass := lpassword_hcm;
        l_fkey := i_taxcode||i_month||i_bill;
    end if;


    l_sql:='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">
               <soapenv:Header/>
               <soapenv:Body>
                  <tem:UnConfirmPaymentFkey>
                     <tem:lstFkey>'||l_fkey||'</tem:lstFkey>
                     <tem:userName>'||l_user||'</tem:userName>
                     <tem:userPass>'||l_pass||'</tem:userPass>
                  </tem:UnConfirmPaymentFkey>
               </soapenv:Body>
            </soapenv:Envelope>';
	l_sql:= translate(l_sql,chr(10)||chr(11)||chr(13),' ');
    execute immediate' insert into log_bill_ws(code,agent,bill,cashier,content,method) values(:1,:2,:3,:4,:5,:6)'
        using i_taxcode,i_agent,i_bill,i_cashier_code,l_sql,'UnConfirmPaymentFkey'; commit;

    Return l_sql;
END;


function write_log_elec_bill(i_result VARCHAR2,
                              i_taxcode VARCHAR2,
                              i_month VARCHAR2,
                              i_agent VARCHAR2,
                              i_bill varchar2,
                              i_cashier_code varchar2,
							  i_method varchar2
							  )
RETURN VARCHAR2
IS
    l_sql VARCHAR2(30000);
    out_ VARCHAR2(30000);
	l_count number;
	l_retry number;
BEGIN

    l_sql := REPLACE(i_result,'<?xml version="1.0" encoding="utf-8"?>');
    select value(t).extract('/*/*/*/*/text()').getstringval() into out_ from table(XMLSEQUENCE(xmltype.createxml(l_sql))) t;
    out_:= REPLACE(out_,'&lt;','<');
    out_:= REPLACE(out_,'&gt;','>');

    Execute immediate 'update tax.log_bill_ws set response =:1 where bill =:2 and method =:3 and rownum=1'
        Using out_,i_bill,i_method ;

	If ((substr(out_,1,INSTR(out_,':')-1)='OK') and (i_method ='ImportAndPublishInv')) then
		Begin
			l_sql:='insert into tax.hddts(id,status,pattern,fkey,numb_bill,serial,release_date,log_date, taxcode, month, bill)
     			values (:id,:status,:pattern,:fkey,:numb_bill,:serial,:release_date,:log_date,:taxcode,:month,:bill)';
    		Execute immediate l_sql using to_char(tax.util.GETSEQ('HDDTS_SEQ')),substr(out_,1,INSTR(out_,':')-1),
				substr(out_,INSTR(out_,':')+1,INSTR(out_,';')-INSTR(out_,':')-1),
				substr(out_,INSTR(out_,'-')+1,INSTR(out_,'_')-INSTR(out_,'-')-1),
				substr(out_,INSTR(out_,'_')+1),
				substr(out_,INSTR(out_,';')+1,INSTR(out_,'-')-INSTR(out_,';')-1),
        		trunc(sysdate),sysdate,i_taxcode,i_month,i_bill;
			Exception when others then
				null;
		End;
	End if;

	Execute immediate 'Select count(1) from tax.log_bill_ws where bill =:1 and method =:2 and response like ''OK:%'''
       into l_count  Using i_bill,'ImportAndPublishInv' ;

	If ((l_count =0) and (i_method ='ImportAndPublishInv')) then
		--check so lan retry
		select times into l_retry from tax.log_bill_ws where bill=i_bill and method=i_method;
		--resend
		If (l_retry < 6) then
			crud.enqueue_publish_inv(i_agent=> i_agent, i_taxcode=> i_taxcode, i_month=> i_month, i_bill=> i_bill, i_cashier_code=> i_cashier_code);
			--update log
			Execute immediate 'update tax.log_bill_ws set times = times +1
							where bill =:1 and method =:2 and rownum=1'
        		Using i_bill,i_method ;
		End if;
	End if;
	Commit;
    RETURN '1';
    EXCEPTION when others then
		Begin
        	logger.access('write_log_elec_bill',i_taxcode||'|'||i_month||'|'||i_agent||'|'||i_bill||'|'||i_cashier_code||'|'||substr(i_result,1,2000));
			If i_method ='ImportAndPublishInv' then
				select times into l_retry from tax.log_bill_ws where bill=i_bill and method=i_method;
				--resend
				If (l_retry < 6) then
					crud.enqueue_publish_inv(i_agent=> i_agent, i_taxcode=> i_taxcode, i_month=> i_month, i_bill=> i_bill, i_cashier_code=> i_cashier_code);
					--update log
					Execute immediate 'update tax.log_bill_ws set times = times +1
							where bill =:1 and method =:2 and rownum=1'
        			Using i_bill,i_method ;
				End if;
			End if;
		End;
    Return to_char(sqlerrm);

END;

FUNCTION listInvByCusFkey(i_taxcode VARCHAR2,
                            i_month VARCHAR2,
                            i_agent VARCHAR2,
                            i_startdate VARCHAR2,
                            i_enddate VARCHAR2)
RETURN VARCHAR2
IS
    l_sql VARCHAR2(10000);
    l_fkey VARCHAR2(100);
    l_result VARCHAR2(10000);
    l_out VARCHAR2(10000);
BEGIN
    l_fkey := i_taxcode||i_month||i_agent;
    l_sql:='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">
                 <soapenv:Header/>
                 <soapenv:Body>
                 <tem:listInvByCusFkey>
                 <tem:key>0307254325129967</tem:key>
                 <tem:fromDate/>
                 <tem:toDate/>
				 <tem:username>unttservice</tem:username>
                 <tem:password>Untt@1234</tem:password>
                 </tem:listInvByCusFkey>
                 </soapenv:Body>
                 </soapenv:Envelope>';
	l_sql:= translate(l_sql,chr(10)||chr(11)||chr(13),' ');
    l_sql := tax.invoke_internal(l_sql, '192.168.114.78', '80','','', 'listInvByCusFkey', 'https://unttadmin.vnpt-invoice.com.vn/PortalService.asmx','','');

	l_sql := REPLACE(l_sql,'<?xml version="1.0" encoding="utf-8"?>');
    select value(t).extract('/*/*/*/*/text()').getstringval() into l_out from table(XMLSEQUENCE(xmltype.createxml(l_sql))) t;
    l_out:= REPLACE(l_out,'&lt;','<');
    l_out:= REPLACE(l_out,'&gt;','>');

    Return l_out;
    EXCEPTION WHEN others THEN

    return TO_CHAR(SQLCODE)||': '||SQLERRM;
END;

FUNCTION cancelInv(i_taxcode VARCHAR2,
                            i_month VARCHAR2,
                            i_bill  VARCHAR2,
                            i_agent VARCHAR2)
RETURN VARCHAR2
IS
    l_sql VARCHAR2(10000);
    l_fkey VARCHAR2(100);
    l_result VARCHAR2(10000);
    l_out VARCHAR2(10000);
BEGIN
    l_fkey := replace(i_taxcode||i_month||i_bill,'-','');
    l_sql:='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">
               <soapenv:Header/>
               <soapenv:Body>
                  <tem:cancelInv>
                     <tem:Account>vnptthuhoadmin</tem:Account>
                     <tem:ACpass>Thuho@2015</tem:ACpass>
                     <tem:fkey>'||l_fkey||'</tem:fkey>
                     <tem:username>vnptthuhoservice</tem:username>
                     <tem:password>Thuho@2015</tem:password>
                  </tem:cancelInv>
               </soapenv:Body>
            </soapenv:Envelope>';
	l_sql:= translate(l_sql,chr(10)||chr(11)||chr(13),' ');
    l_sql := tax.invoke_internal(l_sql, '192.168.114.78', '80','','', 'cancelInv', 'https://vnptthuhoadmin.vnpt-invoice.com.vn/BusinessService.asmx','','');
    l_out:= REPLACE(l_sql,'&lt;','<');
    l_out:= REPLACE(l_out,'&gt;','>');
    Return l_out;
    EXCEPTION WHEN others THEN

    return TO_CHAR(SQLCODE)||': '||SQLERRM;
END;


FUNCTION cancelInvNoPay(i_taxcode VARCHAR2,
                            i_month VARCHAR2,
                            i_agent VARCHAR2,
                            i_bill varchar2,
                            i_cashier_code varchar2)
RETURN VARCHAR2
IS
    l_sql VARCHAR2(10000);
    l_fkey VARCHAR2(100);
    l_user VARCHAR2(100);
    l_pass VARCHAR2(100);
BEGIN
    if i_agent='01TTT' then
        l_user := luser;
        l_pass := lpassword;
    else
        l_user := luser_hcm;
        l_pass := lpassword_hcm;
    end if;

    l_fkey := replace(i_taxcode||i_month||i_bill,'-','');
    l_sql:='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">
               <soapenv:Header/>
               <soapenv:Body>
                  <tem:cancelInvNoPay>
                     <tem:Account>unttadmin</tem:Account>
                     <tem:ACpass>'||l_pass||'</tem:ACpass>
                     <tem:fkey>'||l_fkey||'</tem:fkey>
                     <tem:userName>'||l_user||'</tem:userName>
                     <tem:userPass>'||l_pass||'</tem:userPass>
                  </tem:cancelInvNoPay>
               </soapenv:Body>
            </soapenv:Envelope>';
	l_sql:= translate(l_sql,chr(10)||chr(11)||chr(13),' ');
    execute immediate' insert into log_bill_ws(code,agent,bill,cashier,content,method) values(:1,:2,:3,:4,:5,:6)'
        using i_taxcode,i_agent,i_bill,i_cashier_code,l_sql,'cancelInvNoPay'; commit;
    Return l_sql;
END;

FUNCTION UpdateCus(i_agent VARCHAR2)
RETURN clob
IS
    l_sql clob;
    l_return clob;
	l_out varchar2(32000);
    ckn varchar2(100):= crud.ckn_hientai();
BEGIN

	l_sql:='select ''<Customers>''||tax.rows_to_str_clob(''select ''''<Customer><Name><![CDATA[''''||x.TEN_NNT||'''']]></Name><Code>''''||replace(x.mst,''''-'''','''''''')||''''</Code>
            <TaxCode></TaxCode><Address><![CDATA[''''||x.mota_diachi||'''']]></Address><BankAccountName></BankAccountName><BankName></BankName>
            <BankNumber></BankNumber><Email><![CDATA[''''||x.EMAIL||'''']]></Email><Fax></Fax><Phone></Phone><ContactPerson></ContactPerson><RepresentPerson></RepresentPerson><CusType>0</CusType></Customer>''''
            from tax.nnts_'||ckn||' x where not exists (select 1 from tax.cus_bill y where x.mst = y.mst and x.ma_cqt_ql = y.ma_cqt_ql and y.trang_thai=1) and x.ma_tinh ='''''||i_agent||''''''','''')||''</Customers>'' from dual';
    EXECUTE IMMEDIATE l_sql into l_return;
	l_sql := tax.invoke_internal(l_sql, '192.168.114.78', '80','','', 'UpdateCus', 'https://unttadmin.vnpt-invoice.com.vn/BusinessService.asmx','','');

    Return '0';
    EXCEPTION WHEN others THEN

    return TO_CHAR(SQLCODE)||': '||SQLERRM;

END;

END;

/
