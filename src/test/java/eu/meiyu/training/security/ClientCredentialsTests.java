package eu.meiyu.training.security;

import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpHeaders;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.test.web.servlet.MvcResult;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.httpBasic;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/** Embedded authorization server: client credentials for the confidential client {@code test}. */
class ClientCredentialsTests extends AbstractAuthenticationTests {

    @Test
    void client_secret_basic_issues_a_client_token() throws Exception {
        Jwt jwt = jwtDecoder.decode(clientCredentialsToken());

        assertThat(jwt.getIssuer()).hasToString(ISSUER);
        assertThat(jwt.getSubject()).isEqualTo("test");
        assertThat(jwt.getClaimAsString(AppClaims.SUBJECT_TYPE)).isEqualTo(AppClaims.SUBJECT_TYPE_CLIENT);
        assertThat(jwt.getClaimAsStringList("scope")).containsExactly("api.read");
        assertThat(jwt.hasClaim(AppClaims.GROUPS)).isFalse();
    }

    @Test
    void client_token_is_authenticated_but_has_no_user_role() throws Exception {
        mockMvc.perform(get(USER_INFO).header(HttpHeaders.AUTHORIZATION, "Bearer " + clientCredentialsToken()))
            .andExpect(status().isForbidden());
    }

    @Test
    void wrong_client_secret_is_rejected() throws Exception {
        mockMvc.perform(post("/oauth2/token").with(httpBasic("test", "wrong"))
                .param("grant_type", "client_credentials")
                .param("scope", "api.read"))
            .andExpect(status().isUnauthorized())
            .andExpect(jsonPath("$.error").value("invalid_client"));
    }

    @Test
    void client_secret_post_is_not_allowed_for_the_test_client() throws Exception {
        mockMvc.perform(post("/oauth2/token")
                .param("grant_type", "client_credentials")
                .param("scope", "api.read")
                .param("client_id", "test")
                .param("client_secret", "test"))
            .andExpect(status().isUnauthorized())
            .andExpect(jsonPath("$.error").value("invalid_client"));
    }

    @Test
    void scope_not_registered_for_the_client_is_rejected() throws Exception {
        mockMvc.perform(post("/oauth2/token").with(httpBasic("test", "test"))
                .param("grant_type", "client_credentials")
                .param("scope", "api.write"))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.error").value("invalid_scope"));
    }

    private String clientCredentialsToken() throws Exception {
        MvcResult result = mockMvc.perform(post("/oauth2/token").with(httpBasic("test", "test"))
                .param("grant_type", "client_credentials")
                .param("scope", "api.read"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.token_type").value("Bearer"))
            .andExpect(jsonPath("$.refresh_token").doesNotExist())
            .andReturn();
        return JsonPath.read(result.getResponse().getContentAsString(), "$.access_token");
    }
}
