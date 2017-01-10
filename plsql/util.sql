--------------------------------------------------------
--  File created - Tuesday-January-10-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body UTIL
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "TAX"."UTIL" 
IS
FUNCTION CONVERT_UTD (pstext VARCHAR2) RETURN VARCHAR2
is
 unicode   varchar2(30000);
       ncr_decimal   VARCHAR2 (30000);
       tcvn3     VARCHAR2 (30000);
       khongdau   VARCHAR2 (30000);
       text       VARCHAR2 (30000):=pstext;
       s         VARCHAR2 (30000) := '';
       chr_      VARCHAR2 (10000);
       idx       NUMBER;
       i         NUMBER;
        unicode_arr util.StringArray;
        decimal_arr util.StringArray;
        str util.StringArray:=util.str_to_array(pstext);
        result varchar2(30000);
        temp varchar2(200);
        n NUMBER:=0;
BEGIN
  ncr_decimal:='&#417;,&#416;,&#7901;,&#7900;,&#7903;,&#7902;,&#7907;,&#7906;,&#7899;,&#7898;,&#7905;,&#7904;,&#7843;,&#7842;,&#224;,&#192;,&#7841;,&#7840;,&#225;,&#193;,&#227;,&#195;,&#226;,&#194;,&#7849;,&#7848;,&#7853;,&#7852;,&#7847;,&#7846;,&#7845;,&#7844;,&#7851;,&#7850;,&#7861;,&#7860;,&#259;,&#258;,&#7859;,&#7858;,&#7857;,&#7856;,&#7863;,&#7862;,&#7855;,&#7854;,&#273;,&#272;,&#233;,&#201;,&#232;,&#200;,&#7865;,&#7864;,&#7867;,&#7866;,&#7869;,&#7868;,&#234;,&#202;,&#7875;,&#7874;,&#7873;,&#7872;,&#7879;,&#7878;,&#7871;,&#7870;,&#7877;,&#7876;,&#7885;,&#7896;,&#7887;,&#7886;,&#242;,&#210;,&#243;,&#211;,&#245;,&#213;,&#244;,&#212;,&#7893;,&#7892;,&#7897;,&#7896;,&#7891;,&#7890;,&#7889;,&#7888;,&#7895;,&#7894;,&#7881;,&#7880;,&#7883;,&#7882;,&#236;,&#204;,&#297;,&#296;,&#237;,&#205;,&#7911;,&#7910;,&#7909;,&#7908;,&#249;,&#217;,&#250;,&#218;,&#361;,&#360;,&#432;,&#431;,&#7917;,&#7916;,&#7915;,&#7914;,&#7919;,&#7918;,&#7921;,&#7920;,&#7913;,&#7912;,&#7925;,&#7924;,&#7923;,&#7922;,&#7927;,&#7926;,&#253;,&#221;,&#7929;,&#7928;';
       unicode:='o,O,?,?,?,?,?,?,?,?,?,?,?,?,à,À,?,?,á,Á,ã,Ã,â,Â,?,?,?,?,?,?,?,?,?,?,?,?,a,A,?,?,?,?,?,?,?,?,d,Ð,é,É,è,È,?,?,?,?,?,?,ê,Ê,?,?,?,?,?,?,?,?,?,?,?,?,?,?,ò,Ò,ó,Ó,õ,Õ,ô,Ô,?,?,?,?,?,?,?,?,?,?,?,?,?,?,ì,Ì,i,I,í,Í,?,?,?,?,ù,Ù,ú,Ú,u,U,u,U,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,ý,Ý,?,?';
       unicode_arr:=util.str_to_array(unicode,',');
       decimal_arr:=util.str_to_array(ncr_decimal,',');
       if(pstext IS null) THEN
        RETURN pstext;
       ELSE
       FOR i IN 1 .. LENGTH(pstext) LOOP


           temp:=substr(pstext,i,1);

            FOR j in unicode_arr.first..unicode_arr.last LOOP
                if(unicode_arr(j)=temp) THEN
                chr_:=chr_||decimal_arr(j);
                  temp:='';
                end if;
           END LOOP;
           if(temp is not null) then
                  chr_:=chr_||temp;

           end if;

        dbms_output.put_line(temp);
      END loop;

       RETURN chr_;
           END IF;
    EXCEPTION
       WHEN OTHERS
       THEN
          RETURN SQLCODE||SQLERRM;
END CONVERT_UTD;
function GetTotalRecord
   (
        psSQL           in varchar2,
        piPAGEID        in varchar2,    --dieu khien viec phan trang
        piREC_PER_PAGE  in varchar2     --dieu khien viec phan trang
   )
return sys_refcursor
is
    spt_    varchar2(32000);
    psPageid number:=0;
    pspagerec number:=0;
    pscount number:=0;
    psmod number:=0;
    ref_ sys_refcursor;
begin
    execute immediate 'select count(1) from ('||psSql||')' into pscount;
    open ref_ for 'select '||pscount||' record from dual where rownum<2';
    return ref_;
end;

function xuly_phantrang
(
    psSQL           in varchar2,
    piPAGEID        in number,    --dieu khien viec phan trang
    piREC_PER_PAGE  in number     --dieu khien viec phan trang
)
return varchar2
is
    spt_    varchar2(32000);
begin
    if (piREC_PER_PAGE>0) then
        if (piPAGEID<2) then
            spt_:='select * from ('||psSQL||') where rownum<'||(piREC_PER_PAGE+1);
        else
            spt_:= 'select * from ('||psSQL||') where rownum<'||(piPAGEID*piREC_PER_PAGE+1)
                ||' minus '
                ||' select * from ('||psSQL||') where rownum<'||((piPAGEID-1)*piREC_PER_PAGE+1)
                ;
        end if;
    end if;
    --
    return spt_;
end;
FUNCTION getMd5(input_string VARCHAR2) return varchar2
IS
    raw_input RAW(128) := UTL_RAW.CAST_TO_RAW(input_string);
    decrypted_raw RAW(2048);
    error_in_input_buffer_length EXCEPTION;
BEGIN
    sys.dbms_obfuscation_toolkit.MD5(input => raw_input, checksum => decrypted_raw);
    return lower(rawtohex(decrypted_raw));
END;
FUNCTION GETSEQ( psSeqName varchar2)
RETURN number IS
    s varchar2(4000);
    res number(20);
BEGIN
    s:='SELECT '||psSeqName||'.NEXTVAL from dual';
    if instr(psSeqName,'@')>0 then
        s:='select '||replace(psSeqName,'@','.NEXTVAL@')||' from dual';
    end if;
    execute immediate s into res;
    return res;
EXCEPTION
      WHEN others THEN
          s:='CREATE SEQUENCE '||psSeqName||'
                INCREMENT BY 1
                START WITH 1
                MINVALUE 1
                MAXVALUE 999999999999999999999999999
                NOCYCLE
                NOORDER
                CACHE 20';
          execute immediate s;
          s:='SELECT '||psSeqName||'.NEXTVAL from dual';
          execute immediate s into res;
          return res;
END;
FUNCTION str_to_array (string_ VARCHAR2)
   RETURN stringarray
IS
   ref_   sys_refcursor;
   out_   stringarray;
   n      NUMBER;
   i      NUMBER;
   s      varchar2(30000);
BEGIN
   if string_ is null then return out_; end if;
   s:=' '||replace(trim(string_),',,',', ,')||' ';
   n:=1;
   loop
       exit when instr(s,',')=0;
       if substr(s,1,instr(s,',')-1)!=' ' then
           out_(n):=trim(substr(s,1,instr(s,',')-1));
       end if;
       n:=n+1;
       s:=substr(s,instr(s,',')+1);
   end loop;
   if trim(s) is not null then
       out_(n):=trim(s);
   end if;
   RETURN out_;
exception
    when others then
        return out_;
END;
FUNCTION str_to_array (string_ VARCHAR2, separator varchar2)
   RETURN stringarray
IS
   ref_   sys_refcursor;
   out_   stringarray;
   n      NUMBER;
   i      NUMBER;
   s      varchar2(30000);
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
FUNCTION rows_to_str
(
   sql_   IN varchar2, prs_DELI_CHAR_in varchar2
)
RETURN  varchar2
IS
   sResult     varchar2(32000);
   sColVal     varchar2(32000);
   a_ sys_refcursor;
BEGIN
   sResult := null;
   open a_ for sql_;
   loop
       fetch a_ into sColVal;
       if a_%notfound then
           exit;
       end if;
       --
       if sResult is null then
           sResult := sColVal;
       else
           sResult := sResult || prs_DELI_CHAR_in || sColVal;
       end if;
   end loop;
   close a_;
   return nvl(sResult,'');
exception
   when OTHERS then
   declare
       strTmp_  varchar2(2000);
   begin
       strTmp_ := TO_CHAR(SQLCODE);
       return strtmp_;
   end;
END;

FUNCTION rows_to_str2
(
   sql_   IN varchar2, prs_DELI_CHAR_in varchar2
)
RETURN  clob
IS
   sResult     clob;
   sColVal     clob;
   a_ sys_refcursor;
BEGIN
   sResult := null;
   open a_ for sql_;
   loop
       fetch a_ into sColVal;
       if a_%notfound then
           exit;
       end if;
       --
       if sResult is null then
           sResult := sColVal;
       else
           sResult := sResult || prs_DELI_CHAR_in || sColVal;
       end if;
   end loop;
   close a_;
   return nvl(sResult,'');
exception
   when OTHERS then
   declare
       strTmp_  varchar2(2000);
   begin
       strTmp_ := TO_CHAR(SQLCODE);
       return strtmp_;
   end;
END;

FUNCTION doi9chusosangchu
  (T  IN  VARCHAR2)
  RETURN  VARCHAR2
  IS
    s                  VARCHAR2(10);
    n                  NUMBER(3);
    d                  VARCHAR2(2000);
BEGIN

    s := RTRIM(LTRIM(t));
    n := LENGTH(s);

    d := '';
    If n > 9 Then
        RETURN d;
    End If;

    If n <= 3 Then
        --'0->999
        d := doi3chusothanhchu(s);
    Else
        If n <= 6 Then
            --'1000->999.999
            d := doi3chusothanhchu(SUBSTR(s,1,n - 3)) || ' nghìn';
            If SUBSTR(s, n - 2, 3) !='000' then
                d := d || doi3chusothanhchu(SUBSTR(s, n - 2, 3));
            End if;
        Else
            --'1.000.000->999.999.999
            d := doi3chusothanhchu(SUBSTR(s, 1, n - 6)) || ' tri?u';
            If SUBSTR(s, n - 5, 3) !='000' then
               d := d || doi3chusothanhchu(SUBSTR(s, n - 5, 3)) || ' nghìn';
            End if;

            If SUBSTR(s, n - 2, 3) !='000' then
                d := d || doi3chusothanhchu(SUBSTR(s, n - 2, 3));
            End if;
        End If;
    End If;
    RETURN d;
END;

FUNCTION doi3chusothanhchu
  (S  IN  VARCHAR2)
  RETURN  VARCHAR2
  IS
   t                  VARCHAR2(10);
   l                  NUMBER(3);
   tmp                VARCHAR2(5);
   return_value       VARCHAR2(2000);

BEGIN

    t := RTRIM(LTRIM(s));
    l := LENGTH(t);
    return_value := '';
    If l > 3 Then
        RETURN return_value;
    End If;

    IF l = 1 THEN
            return_value := P(TO_NUMBER(t) + 1,0);
    END IF;

    IF l = 2 THEN
            tmp := SUBSTR(t,1,1);

            If SUBSTR(t, l, 1) = '0' Then
                If tmp = '1' Then
                --10
                    return_value := ' mu?i';
                Else
                --tu 20 den 90
                    return_value := p(TO_NUMBER(tmp) + 1,0) || ' muoi';
                End If;
            Else
                --hang don vi tu 1-> 9, hang chuc tu 1->9
                If tmp = '1' Then
                --dung lam va bon
                    return_value := ' mu?i' || p(TO_NUMBER(SUBSTR(t, l, 1)) + 1,1);
                Else
                --dung tu val nham
                    return_value := p(TO_NUMBER(tmp) + 1,0) || ' muoi';

                    return_value := return_value || p(TO_NUMBER(SUBSTR(t, l, 1)) + 1,2);
                End If;
            End If;
       END IF;

       IF l = 3 THEN
            tmp := SUBSTR(t,1,1);
            return_value := p(TO_NUMBER(tmp) + 1,0) || ' tram';

            tmp := SUBSTR(t, 2, 1);
            If SUBSTR(t, l, 1) = '0' Then
                If tmp = '1' Then
                --10
                    return_value := return_value || ' mu?i';
                Else
                --0,2,3,4,5,6,7,8,9
                    If tmp <> '0' Then
                    --tu 20 den 90
                        return_value := return_value || p(TO_NUMBER(tmp) + 1,0) || ' muoi';
                    End If;
                End If;
            Else
            --hang don vi tu 1-> 9, hang chuc tu 1->9
                If tmp = '0' Then
                   return_value := return_value || ' linh' || p(TO_NUMBER(SUBSTR(t, l, 1)) + 1,0);
                    RETURN return_value ;
                End If;
                If tmp = '1' Then
                --dung lam va bon
                    return_value := return_value || ' mu?i' || p(TO_NUMBER(SUBSTR(t, l, 1)) + 1,1);
                Else
                --dung tu val nham
                    return_value := return_value || p(TO_NUMBER(tmp) + 1,0) || ' muoi';

                    return_value := return_value || p(TO_NUMBER(SUBSTR(t, l, 1)) + 1,2);
                End If;
            End If;
        End IF;

    RETURN return_value ;
END;

  FUNCTION doisosangchu
  (S  IN  VARCHAR2)
  RETURN  VARCHAR2
  IS
    l   NUMBER(3);
    t   VARCHAR2(50);
    d   VARCHAR2(2000);
    t1  VARCHAR2(50);
    t2  VARCHAR2(50);
    i   NUMBER(3);
BEGIN

    t := RTRIM(LTRIM(s));
    i := INSTR(t, '.', 1);

    l := LENGTH(t);

    If i = 0 Then
        --so nguyen
        If l > 9 Then
            d := doi9chusosangchu(SUBSTR(t, 1, l - 9)) || ' t?';
            d := d || doi9chusosangchu(SUBSTR(t, l - 8, 9));
        Else
            d := d || doi9chusosangchu(t);
        End If;
    Else
        --so thap phan
        t1 := SUBSTR(t, 1, i - 1);
        --phan nguyen
        t2 := SUBSTR(t, i + 1, l - i );
        --phan thap phan

        l := LENGTH(t1);
        If l > 9 Then
            d := doi9chusosangchu(SUBSTR(t1, 1, l - 9 )) || ' t?';
            d := d || doi9chusosangchu(SUBSTR(t1,l-8, 9));
        Else
            d := d || doi9chusosangchu(t1);
        End If;

        d := d || ' ph?y' || doi9chusosangchu(t2);

    End If;

    d := RTRIM(LTRIM(d));
    d := UPPER(SUBSTR(d, 1,1)) || SUBSTR(d, 2, LENGTH(d) -1 );

    RETURN d|| ' d?ng';
END;
  FUNCTION p
  (SO  IN  NUMBER,KIEU  IN  NUMBER)
  RETURN  VARCHAR2
  IS
 BEGIN
    IF so = 1 THEN
        RETURN ' không';
    END IF;
    IF so = 2 THEN
        IF kieu = 0 or kieu = 1 THEN
            RETURN ' m?t';
        end if;
        IF kieu = 2 THEN
            RETURN ' m?t';
        end if;
    END IF;
    IF so = 3 THEN
        RETURN ' hai';
    END IF;
    IF so = 4 THEN
        RETURN ' ba';
    END IF;

    IF so = 5 THEN
        IF kieu = 0 or kieu = 1 THEN
            RETURN ' b?n';
        end if;
        IF kieu = 2 THEN
            RETURN ' tu';
        end if;
    END IF;

    IF so = 6 THEN
        IF kieu = 0 THEN
            RETURN ' nam';
        end if;
        IF kieu = 1 THEN
            RETURN ' nam';
        end if;
        IF kieu = 2 THEN
            RETURN ' nam';
        end if;
    END IF;

    IF so = 7 THEN
        RETURN ' sáu';
    END IF;
    IF so = 8 THEN
        RETURN ' b?y';
    END IF;
    IF so = 9 THEN
        RETURN ' tám';
    END IF;
    IF so = 10 THEN
        RETURN ' chín';
    END IF;
RETURN '';
END;

FUNCTION FSTR_TO_DROWS
(
    prs_TOKENED_STRING_in       IN  long
    , prs_DELI_CHAR_in          IN  varchar2
)
return sys_refcursor
is
    sTOKENED_STRING     varchar2(32000);
    sTOKENED_STRING2    varchar2(32000);
    cRows               sys_refcursor;
begin

    sTOKENED_STRING := prs_TOKENED_STRING_in;
    sTOKENED_STRING  := trim(sTOKENED_STRING);

    if instr(sTOKENED_STRING,prs_DELI_CHAR_in) != 1 then
        sTOKENED_STRING := prs_DELI_CHAR_in || sTOKENED_STRING;
    end if;
    sTOKENED_STRING2    := sTOKENED_STRING || prs_DELI_CHAR_in;
    open cRows for
        select rownum, Token
        from
        (
            select
                distinct trim(SUBSTR(
                    sTOKENED_STRING2
                    , INSTR(sTOKENED_STRING2 , prs_DELI_CHAR_in, 1, Rownum ) +1
                    , INSTR(sTOKENED_STRING2 , prs_DELI_CHAR_in, 1, Rownum+1)
                        - INSTR(sTOKENED_STRING2 , prs_DELI_CHAR_in, 1, Rownum ) -1
                )) Token
            from
                (select sTOKENED_STRING Str from dual) A
                , user_objects B
            where (1=1)
                and Rownum< length(A.Str)-length(REPLACE(A.Str,prs_DELI_CHAR_in))+1
        )
    ;
    return cRows;
END;
FUNCTION FSTR_TO_ROWS
(
    prs_TOKENED_STRING_in       IN  long
    , prs_DELI_CHAR_in          IN  varchar2
)
return sys_refcursor
is
    sTOKENED_STRING     varchar2(30000);
    sTOKENED_STRING2    varchar2(30000);
    cRows               sys_refcursor;
begin

    sTOKENED_STRING := prs_TOKENED_STRING_in;
    sTOKENED_STRING  := trim(sTOKENED_STRING);

    if instr(sTOKENED_STRING,prs_DELI_CHAR_in) != 1 then
        sTOKENED_STRING := prs_DELI_CHAR_in || sTOKENED_STRING;
    end if;
    sTOKENED_STRING2    := sTOKENED_STRING || prs_DELI_CHAR_in;

    open cRows for
    select
        Rownum STT
        , trim(SUBSTR(
            sTOKENED_STRING2
            , INSTR(sTOKENED_STRING2 , prs_DELI_CHAR_in, 1, Rownum ) +1
            , INSTR(sTOKENED_STRING2 , prs_DELI_CHAR_in, 1, Rownum+1)
                - INSTR(sTOKENED_STRING2 , prs_DELI_CHAR_in, 1, Rownum ) -1
        )) Token
    from
        (select sTOKENED_STRING Str from dual) A
        , user_objects B
    where (1=1)
        and Rownum< length(A.Str)-length(REPLACE(A.Str,prs_DELI_CHAR_in))+1
        ;

    return cRows;
END;
END;

/
