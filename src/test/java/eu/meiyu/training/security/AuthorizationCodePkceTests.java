package eu.meiyu.training.security;

import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockHttpSession;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.startsWith;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Embedded authorization server: authorization code + PKCE for the public client {@code frontend}.
 * The user authenticates (federated) through the Cognito login.
 */
class AuthorizationCodePkceTests extends AbstractAuthenticationTests {

    private static final String REDIRECT_URI = "http://localhost:8080/oauth2/callback";

    @Test
    void unauthenticated_authorize_request_is_redirected_to_the_cognito_login() throws Exception {
        mockMvc.perform(authorizeRequest(Pkce.codeChallenge(Pkce.newCodeVerifier())).accept(MediaType.TEXT_HTML))
            .andExpect(status().is3xxRedirection())
            .andExpect(redirectedUrl("/oauth2/authorization/sso"));
    }

    @Test
    void federated_user_gets_tokens_with_cognito_groups_and_can_call_the_api() throws Exception {
        MockHttpSession session = loginViaCognito("jane.doe", List.of("user"));
        String verifier = Pkce.newCodeVerifier();
        String code = authorize(session, verifier);

        MvcResult tokenResult = mockMvc.perform(tokenRequest(code, verifier))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.access_token").isString())
            .andExpect(jsonPath("$.id_token").isString())
            // refresh_token is configured for "frontend", but never issued to public clients
            .andExpect(jsonPath("$.refresh_token").doesNotExist())
            .andReturn();

        String accessToken = JsonPath.read(tokenResult.getResponse().getContentAsString(), "$.access_token");
        Jwt jwt = jwtDecoder.decode(accessToken);
        assertThat(jwt.getIssuer()).hasToString(ISSUER);
        assertThat(jwt.getClaimAsString(AppClaims.SUBJECT_TYPE)).isEqualTo(AppClaims.SUBJECT_TYPE_USER);
        assertThat(jwt.getClaimAsStringList(AppClaims.GROUPS)).containsExactly("user");
        assertThat(jwt.getClaimAsString("preferred_username")).isEqualTo("jane.doe");
        assertThat(jwt.getClaimAsString("email")).isEqualTo("jane.doe@example.com");

        mockMvc.perform(get(USER_INFO).header(HttpHeaders.AUTHORIZATION, "Bearer " + accessToken))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.username").value("jane.doe"))
            .andExpect(jsonPath("$.groups[0]").value("user"))
            .andExpect(jsonPath("$.client").value(false));
    }

    @Test
    void authorize_request_without_pkce_is_rejected() throws Exception {
        MockHttpSession session = loginViaCognito("jane.doe", List.of("user"));

        mockMvc.perform(get("/oauth2/authorize").session(session)
                .queryParam("response_type", "code")
                .queryParam("client_id", "frontend")
                .queryParam("redirect_uri", REDIRECT_URI)
                .queryParam("scope", "openid profile email")
                .queryParam("state", "state-1"))
            .andExpect(status().is3xxRedirection())
            .andExpect(header().string(HttpHeaders.LOCATION, startsWith(REDIRECT_URI + "?error=invalid_request")));
    }

    @Test
    void token_request_with_wrong_code_verifier_is_rejected() throws Exception {
        MockHttpSession session = loginViaCognito("jane.doe", List.of("user"));
        String code = authorize(session, Pkce.newCodeVerifier());

        mockMvc.perform(tokenRequest(code, Pkce.newCodeVerifier()))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.error").value("invalid_grant"));
    }

    /** Runs the authorize step for a logged-in session and returns the authorization code. */
    private String authorize(MockHttpSession session, String verifier) throws Exception {
        MvcResult result = mockMvc.perform(authorizeRequest(Pkce.codeChallenge(verifier)).session(session))
            .andExpect(status().is3xxRedirection())
            .andExpect(header().string(HttpHeaders.LOCATION, startsWith(REDIRECT_URI + "?code=")))
            .andReturn();
        return queryParam(result.getResponse().getRedirectedUrl(), "code");
    }

    private static MockHttpServletRequestBuilder authorizeRequest(String codeChallenge) {
        return get("/oauth2/authorize")
            .queryParam("response_type", "code")
            .queryParam("client_id", "frontend")
            .queryParam("redirect_uri", REDIRECT_URI)
            .queryParam("scope", "openid profile email")
            .queryParam("state", "state-1")
            .queryParam("code_challenge", codeChallenge)
            .queryParam("code_challenge_method", "S256");
    }

    private static MockHttpServletRequestBuilder tokenRequest(String code, String codeVerifier) {
        return post("/oauth2/token")
            .param("grant_type", "authorization_code")
            .param("code", code)
            .param("redirect_uri", REDIRECT_URI)
            .param("client_id", "frontend")
            .param("code_verifier", codeVerifier);
    }
}
