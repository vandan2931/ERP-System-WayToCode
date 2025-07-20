package filters;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import constants.Constants;

public class AuthFilter implements Filter {
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
        throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        HttpSession session = request.getSession(false);

        boolean loggedIn = session != null && session.getAttribute(Constants.SESSION_USER_ID) != null;
        String loginURI = request.getContextPath() + "/" + Constants.JSP_LOGIN;

        if (loggedIn) {
            chain.doFilter(req, res);
        } else {
            response.sendRedirect(loginURI);
        }
    }

    public void init(FilterConfig config) {}
    public void destroy() {}
}