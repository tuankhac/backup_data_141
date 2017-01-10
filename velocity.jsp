<%@ taglib uri="/WEB-INF/neotag.tld" prefix="n" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:setProperty name="n" property="language" value="${not empty param.language ? param.language : 'vi_VN'}"/>
<n:check value="${param.crud_type}" minLength="3" maxLength="200" type="string" exp="[0-9a-zA-Z_/.]+">Tham số không chính xác, vui lòng kiểm tra lại!</n:check>
<% out.clear(); %><n:velocity>
    #parse ("${param.crud_type}")
</n:velocity>
