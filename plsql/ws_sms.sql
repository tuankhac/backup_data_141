--------------------------------------------------------
--  File created - Tuesday-January-10-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body WS_SMS
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "TAX"."WS_SMS" 
IS
FUNCTION SEND_SMS(i_taxcode varchar2, i_message varchar2)
Return varchar2
Is
    l_sql VARCHAR2(10000);
    l_out VARCHAR2(10000);
    l_msisdn VARCHAR2(20);
BEGIN
    Begin
        select mobile into l_msisdn from tax.nnts_2016 where mst = i_taxcode and rownum =1;
        Exception when others then
            l_msisdn :='0';
    End;

    If l_msisdn <> '0' then
        l_sql:='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">
                    <soapenv:Header/>
                    <soapenv:Body>
                    <tem:SendBrandSms>
                    <tem:username>'||luser||'</tem:username>
                    <tem:password>'||lpassword||'</tem:password>
                    <tem:phonenumber>'||l_msisdn||'</tem:phonenumber>
                    <tem:message>'||i_message||'</tem:message>
                    <tem:brandname>'||lbandname||'</tem:brandname>
                    <tem:loaitin>'||ltype||'</tem:loaitin>
                    </tem:SendBrandSms>
                    </soapenv:Body>
                </soapenv:Envelope>';

        l_sql := tax.invoke_sms(l_sql,'221.132.39.104','8083','','','SendBrandSms','bsmsws.asmx','');
        l_sql := REPLACE(l_sql,'<?xml version="1.0" encoding="utf-8"?>');
        select value(t).extract('/*/*/*/*/text()').getstringval() into l_out from table(XMLSEQUENCE(xmltype.createxml(l_sql))) t;
        execute immediate 'insert into tax.sms_log(msisdn, taxcode, message, response) values (:1,:2,:3,:4)' using l_msisdn,i_taxcode,i_message,l_out;
        commit;
    End if;

    Return '1';

    EXCEPTION WHEN others THEN
    Return TO_CHAR(SQLCODE)||': '||SQLERRM;
END;


FUNCTION CAMEL_SMS(i_type varchar2, i_mst varchar2, i_agent varchar2, i_msisdn varchar2, i_message varchar2)
Return varchar2
Is
    s_ VARCHAR2(3000);
    c_ sys_refcursor;
    cAgent_ sys_refcursor;
    text        varchar2(32767);
    agent       sys.aq$_agent   := sys.aq$_agent(' ', null, 0);
    msg_camel     sys.aq$_jms_text_message;
    enqueue_options    dbms_aq.enqueue_options_t;
    message_properties dbms_aq.message_properties_t;
    msgid  raw(16);
    mess_camel  varchar2(32767);
BEGIN
    mess_camel :=i_type||';'||i_mst||';'||i_agent||';'||i_msisdn||';'||i_message;
    msg_camel := SYS.AQ$_JMS_TEXT_MESSAGE.construct;
    msg_camel.set_text(mess_camel);

    DBMS_AQ.enqueue(queue_name       => 'tax.SMS_QUEUE',
                 enqueue_options     => enqueue_options,
                 message_properties  => message_properties,
                 payload             => msg_camel,
                 msgid               => msgid);
    Commit;
    RETURN '1';
    EXCEPTION when OTHERS then
    DECLARE
    err_ VARCHAR2(1000);
    BEGIN
        err_:=TO_CHAR(SQLCODE)||': '||SQLERRM;
        logger.access('tax.CAMEL_SMS|ERR',TO_CHAR(SQLCODE)||': '||SQLERRM);
        RETURN err_;
    END;
END;

Function NOTIFICATION_SMS(i_type varchar2)
Return varchar2
Is
    l_message varchar2(500);
    l_nam varchar2(20) := to_char(sysdate,'yyyy');
    l_mb number:=0;
    l_gtgt number:=0;
    l_tncn number:=0;
    l_ckn varchar2(100):= crud.ckn_hientai();
    l_sms varchar2(1000);
Begin
    For j in (select * from tax.nnts_2016) loop
        Begin
            If i_type=1 then
                l_message := 'VNPT TP thong bao: so thue phai nop nam '||l_nam||' cua HKD '||j.mst||' la: MB: '||l_mb||'d, GTGT: '||l_gtgt||'d, TNCN '||l_tncn||'d. Goi (08) 800126 de y/c thu tan noi';
            Else
                l_message := 'VNPT TP thong bao: so thue phai nop quy '||l_ckn||' cua HKD '||j.mst||' la: MB: '||l_mb||'d, GTGT: '||l_gtgt||'d, TNCN '||l_tncn||'d. Goi (08) 800126 de y/c thu tan noi';
            End if;
            l_sms := CAMEL_SMS(i_type=>i_type, i_mst=>j.mst, i_agent=>j.ma_tinh, i_msisdn=>j.mobile, i_message=>l_message);
            Commit;
        End;
    End loop;
    Return '1';
    EXCEPTION when OTHERS then
    DECLARE
    err_ VARCHAR2(1000);
    BEGIN
        err_:=TO_CHAR(SQLCODE)||': '||SQLERRM;
        logger.access('tax.NOTIFICATION_SMS|ERR',TO_CHAR(SQLCODE)||': '||SQLERRM);
        RETURN err_;
    END;
End;


Function UPDATE_EMAIL(i_mst varchar2, i_status varchar2)
Return varchar2
Is
Begin
    Insert into tax.log_email(mst,status) values (i_mst,i_status);
    Commit;
    Return '1';
    Exception when others then
        Return '0';
End;

Function UPDATE_SMS(i_mst varchar2, i_msisdn varchar2, i_message varchar2, i_response varchar2)
Return varchar2
Is
Begin
    Insert into tax.sms_log(msisdn,taxcode,message,response) values (i_msisdn,i_mst,i_message,i_response);
    Commit;
    Return '1';
    Exception when others then
        logger.access('tax.UPDATE_SMS|ERR',TO_CHAR(SQLCODE)||': '||SQLERRM);
        Return '0';
End;

Function CAMEL_EMAIL
RETURN VARCHAR2
Is
    s_ VARCHAR2(3000);
    c_ sys_refcursor;
    cAgent_ sys_refcursor;
    text        varchar2(32767);
    agent       sys.aq$_agent   := sys.aq$_agent(' ', null, 0);
    message     sys.aq$_jms_text_message;
    enqueue_options    dbms_aq.enqueue_options_t;
    message_properties dbms_aq.message_properties_t;
    msgid  raw(16);
    l_ckn varchar2(100):= crud.ckn_hientai();
    l_tongno number :=0;
    l_mb number :=0;
    l_gtgt number :=0;
    l_tncn number :=0;
BEGIN

    For j in (select * from tax.nnts_2016) loop
        Begin
            Execute immediate 'Select sum(no_cuoi_ky) from tax.ct_no_'||l_ckn||' where mst =:1' into l_tongno using j.mst;

            message := sys.aq$_jms_text_message.construct;
            message.set_string_property('kieunhac','nam 2016');
            message.set_string_property('mst', j.mst);
            message.set_string_property('ten_nnt', j.ten_nnt);
            message.set_string_property('ngay_tk', '01/01/2016');

            message.set_string_property('nam','2016');
            message.set_string_property('tien_no', l_tongno);
            message.set_string_property('thue_mon_bai', l_mb);
            message.set_string_property('thue_ca_nhan', l_tncn);
            message.set_string_property('thue_gtgt', l_gtgt);

            message.set_string_property('to', j.email);
            message.set_text('');

            dbms_aq.enqueue(queue_name => 'tax.email_queue',
                             enqueue_options => enqueue_options,
                             message_properties => message_properties,
                             payload => message,
                             msgid => msgid);
        End;
    End loop;
    Commit;
    RETURN '1';
    EXCEPTION when OTHERS then
    DECLARE
    err_ VARCHAR2(1000);
    BEGIN
        err_:=TO_CHAR(SQLCODE)||': '||SQLERRM;
        logger.access('tax.SEND_EMAIL|ERR',TO_CHAR(SQLCODE)||': '||SQLERRM);
        RETURN err_;
    END;
END;

Function SEND_EMAIL (i_taxcode varchar2, i_subject varchar2, i_content varchar2)
RETURN VARCHAR2
Is
    s_ VARCHAR2(3000);
    c_ sys_refcursor;
    cAgent_ sys_refcursor;
    text        varchar2(32767);
    agent       sys.aq$_agent   := sys.aq$_agent(' ', null, 0);
    message     sys.aq$_jms_text_message;
    enqueue_options    dbms_aq.enqueue_options_t;
    message_properties dbms_aq.message_properties_t;
    msgid  raw(16);
    l_email varchar2(100);
BEGIN
    Begin
        select email into l_email from tax.nnts_2016 where mst = i_taxcode and rownum =1;
        Exception when others then
            l_email :='0';
    End;

    If l_email <>'0' then
        message := sys.aq$_jms_text_message.construct;
        message.set_string_property('subject', i_subject);
        message.set_string_property('body', i_content);
        message.set_string_property('to', l_email);
        message.set_text('');

        dbms_aq.enqueue(queue_name => 'tax.email_queue_manual',
                        enqueue_options => enqueue_options,
                        message_properties => message_properties,
                        payload => message,
                        msgid => msgid);

        commit;
    End if;
    RETURN '1';
    EXCEPTION when OTHERS then
    DECLARE
    err_ VARCHAR2(1000);
    BEGIN
        err_:=TO_CHAR(SQLCODE)||': '||SQLERRM;
        logger.access('tax.SEND_EMAIL|ERR',TO_CHAR(SQLCODE)||': '||SQLERRM);
        RETURN err_;
    END;
END;

FUNCTION SEND_SMS_AUTHENTICATION(i_mobile varchar2, i_message varchar2)
Return varchar2
Is
    l_sql VARCHAR2(10000);
    l_out VARCHAR2(10000);

BEGIN

    l_sql:='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">
                <soapenv:Header/>
                <soapenv:Body>
                <tem:SendBrandSms>
                <tem:username>'||luser||'</tem:username>
                <tem:password>'||lpassword||'</tem:password>
                <tem:phonenumber>'||i_mobile||'</tem:phonenumber>
                <tem:message>'||i_message||'</tem:message>
                <tem:brandname>'||lbandname||'</tem:brandname>
                <tem:loaitin>'||ltype||'</tem:loaitin>
                </tem:SendBrandSms>
                </soapenv:Body>
            </soapenv:Envelope>';

    l_sql := tax.invoke_sms(l_sql,'221.132.39.104','8083','','','SendBrandSms','bsmsws.asmx','');
    commit;

    Return '1';

    EXCEPTION WHEN others THEN
    Return TO_CHAR(SQLCODE)||': '||SQLERRM;
END;

FUNCTION CAMEL_PAYMENT(i_message varchar2)
Return varchar2
Is
    s_ VARCHAR2(3000);
    c_ sys_refcursor;
    cAgent_ sys_refcursor;
    text        varchar2(32767);
    agent       sys.aq$_agent   := sys.aq$_agent(' ', null, 0);
    msg_camel     sys.aq$_jms_text_message;
    enqueue_options    dbms_aq.enqueue_options_t;
    message_properties dbms_aq.message_properties_t;
    msgid  raw(16);
    mess_camel  varchar2(32767);
BEGIN
    mess_camel := i_message||chr(13);
    msg_camel := SYS.AQ$_JMS_TEXT_MESSAGE.construct;
    msg_camel.set_text(mess_camel);

    DBMS_AQ.enqueue(queue_name       => 'tax.PAYMENT_QUEUE',
                 enqueue_options     => enqueue_options,
                 message_properties  => message_properties,
                 payload             => msg_camel,
                 msgid               => msgid);
    Commit;
    RETURN '1';
    EXCEPTION when OTHERS then
    DECLARE
    err_ VARCHAR2(1000);
    BEGIN
        err_:=TO_CHAR(SQLCODE)||': '||SQLERRM;
        logger.access('tax.CAMEL_SMS|ERR',TO_CHAR(SQLCODE)||': '||SQLERRM);
        RETURN err_;
    END;
END;

END;

/
