package utils;

import javax.servlet.http.*;
import constants.Constants;

public class SessionManager {
    public static Integer getUserId(HttpSession session) {
        Object userId = session.getAttribute(Constants.SESSION_USER_ID);
        return userId != null ? (Integer) userId : null;
    }

    public static boolean isAdmin(HttpSession session) {
        return Constants.ROLE_ADMIN.equals(session.getAttribute(Constants.SESSION_USER_ROLE));
    }
}