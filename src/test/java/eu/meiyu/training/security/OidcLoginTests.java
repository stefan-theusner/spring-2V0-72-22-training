package eu.meiyu.training.security;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockHttpSession;

import java.util.List;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.startsWith;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/** OIDC login via Cognito: Spring as OAuth2 client (registration {@code sso}), session based. */
class OidcLoginTests extends AbstractAuthenticationTests {

    @Test
    void unauthenticated_browser_request_is_redirected_to_the_cognito_login() throws Exception {
        mockMvc.perform(get(USER_INFO).accept(MediaType.TEXT_HTML))
            .andExpect(status().is3xxRedirection())
            .andExpect(redirectedUrl("/oauth2/authorization/sso"));
    }

    @Test
    void login_start_redirects_to_the_cognito_authorize_endpoint() throws Exception {
        mockMvc.perform(get("/oauth2/authorization/sso"))
            .andExpect(status().is3xxRedirection())
            .andExpect(header().string(HttpHeaders.LOCATION, startsWith(COGNITO.baseUrl() + "/oauth2/authorize?")))
            .andExpect(header().string(HttpHeaders.LOCATION, containsString("response_type=code")))
            .andExpect(header().string(HttpHeaders.LOCATION, containsString("client_id=" + ssoClientId())));
    }

    @Test
    void user_in_group_user_can_access_the_secured_endpoint() throws Exception {
        MockHttpSession session = loginViaCognito("jane.doe", List.of("user"));

        mockMvc.perform(get(USER_INFO).session(session).accept(MediaType.APPLICATION_JSON))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.username").value("jane.doe"))
            .andExpect(jsonPath("$.email").value("jane.doe@example.com"))
            .andExpect(jsonPath("$.groups[0]").value("user"))
            .andExpect(jsonPath("$.client").value(false));
    }

    @Test
    void user_without_group_user_is_forbidden() throws Exception {
        MockHttpSession session = loginViaCognito("admin.user", List.of("admin", "superadmin"));

        mockMvc.perform(get(USER_INFO).session(session).accept(MediaType.APPLICATION_JSON))
            .andExpect(status().isForbidden());
    }

    @Test
    void callback_with_unknown_state_fails_the_login() throws Exception {
        mockMvc.perform(get("/login/oauth2/code/sso").param("code", "fake-code").param("state", "unknown"))
            .andExpect(status().is3xxRedirection())
            .andExpect(redirectedUrl("/login?error"));
    }

    @Test
    void id_token_with_wrong_nonce_fails_the_login() throws Exception {
        LoginStart start = startLogin();
        COGNITO.prepareLogin(new CognitoLogin(ssoClientId(), "jane.doe", List.of("user"), "wrong-nonce"));

        mockMvc.perform(get("/login/oauth2/code/sso")
                .param("code", "fake-code").param("state", start.state()).session(start.session()))
            .andExpect(status().is3xxRedirection())
            .andExpect(redirectedUrl("/login?error"));
    }
}
