" These snippets work only in html context of a eruby file
if &filetype != 'eruby'
    finish
endif

XPTemplate priority=lang-


XPT ruby " <% ...
<%
    `cursor^
%>


XPT r " <% ... %>
<% `cursor^ %>


XPT re " <%= ...
<%= `expr^ %>


XPT rc " <%# ...
<%# `cursor^ %>
