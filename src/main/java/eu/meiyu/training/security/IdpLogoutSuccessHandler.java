package eu.meiyu.training.security;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.jspecify.annotations.Nullable;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.logout.LogoutSuccessHandler;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;
import tools.jackson.databind.json.JsonMapper;

import java.io.IOException;
import java.util.Map;

@Component
public class IdpLogoutSuccessHandler implements LogoutSuccessHandler {

    private final String logoutEndpoint;
    private final String clientId;
    private final String postLogoutRedirectUri;
    private final JsonMapper json;

    public IdpLogoutSuccessHandler(
        @Value("${app.security.idp-logout.endpoint}") String logoutEndpoint,
        @Value("${spring.security.oauth2.client.registration.sso.client-id}") String clientId,
        @Value("${app.security.idp-logout.post-logout-redirect-uri}") String postLogoutRedirectUri,
        JsonMapper json) {
        this.logoutEndpoint = logoutEndpoint;
        this.clientId = clientId;
        this.postLogoutRedirectUri = postLogoutRedirectUri;
        this.json = json;
    }

    @Override
    public void onLogoutSuccess(HttpServletRequest request, HttpServletResponse response, @Nullable Authentication authentication) throws IOException, ServletException {
        String logoutUrl = UriComponentsBuilder.fromUriString(logoutEndpoint)
            .queryParam("client_id", clientId)
            .queryParam("logout_uri", postLogoutRedirectUri)
            .build()
            .encode()
            .toUriString();

        // Browser navigation (form POST / confirmation page): redirect straight to the IdP logout.
        String accept = request.getHeader("Accept");
        if (accept != null && accept.contains(MediaType.TEXT_HTML_VALUE)) {
            response.sendRedirect(logoutUrl);
            return;
        }

        // XHR / fetch from an SPA: return the URL so the client can navigate itself.
        response.setStatus(HttpServletResponse.SC_OK);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        json.writeValue(response.getOutputStream(), Map.of("logoutUrl", logoutUrl));
    }
}
