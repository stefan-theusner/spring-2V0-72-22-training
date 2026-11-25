package eu.meiyu.training.security;

import eu.meiyu.training.TrainingApplication;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.HttpHeaders;
import org.springframework.mock.web.MockHttpSession;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.not;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Shared setup for the authentication tests, with the real security configuration (profile {@code security}):
 * <ul>
 *     <li>{@link OidcLoginTests}: OIDC login (Spring as OAuth2 client of Cognito)</li>
 *     <li>{@link AuthorizationCodePkceTests}: embedded authorization server, authorization code + PKCE</li>
 *     <li>{@link ClientCredentialsTests}: embedded authorization server, client credentials</li>
 *     <li>{@link BearerTokenTests}: resource server, Bearer JWTs</li>
 * </ul>
 * Cognito (Floci) is replaced by {@link FakeCognito} and the signing keys by {@link TestKeys}, so neither Floci nor
 * {@code keys/} are needed. All subclasses share this configuration and therefore one cached application context.
 */
@SpringBootTest(classes = TrainingApplication.class, properties = "otel.sdk.disabled=true")
@ActiveProfiles("security")
@AutoConfigureMockMvc
abstract class AbstractAuthenticationTests {

    static final String USER_INFO = "/secured-endpoint/user-info";
    static final String ISSUER = "http://localhost:8080";
    static final FakeCognito COGNITO = FakeCognito.INSTANCE;

    @DynamicPropertySource
    static void securityProperties(DynamicPropertyRegistry registry) {
        // Signing keys for the embedded authorization server (instead of file:keys/...)
        registry.add("app.security.signing-key.private",
            () -> TestKeys.pem("PRIVATE KEY", TestKeys.APP_SIGNING_KEYS.getPrivate().getEncoded()));
        registry.add("app.security.signing-key.public",
            () -> TestKeys.pem("PUBLIC KEY", TestKeys.APP_SIGNING_KEYS.getPublic().getEncoded()));

        // Cognito provider -> fake OIDC provider (the test application.properties points to http://localhost)
        String provider = "spring.security.oauth2.client.provider.cognito.";
        registry.add(provider + "issuer-uri", COGNITO::issuer);
        registry.add(provider + "authorization-uri", () -> COGNITO.baseUrl() + "/oauth2/authorize");
        registry.add(provider + "token-uri", () -> COGNITO.baseUrl() + "/oauth2/token");
        registry.add(provider + "user-info-uri", () -> COGNITO.baseUrl() + "/oauth2/userInfo");
        registry.add(provider + "jwk-set-uri", () -> COGNITO.issuer() + "/.well-known/jwks.json");
    }

    @Autowired
    protected MockMvc mockMvc;

    @Autowired
    protected JwtDecoder jwtDecoder;

    @Autowired
    private ClientRegistrationRepository clientRegistrations;

    /** Session and parameters of a started (not yet completed) Cognito login. */
    record LoginStart(MockHttpSession session, String state, String nonce) {
    }

    /** Starts the OIDC login: redirect to the Cognito authorize endpoint. */
    protected LoginStart startLogin() throws Exception {
        MvcResult result = mockMvc.perform(get("/oauth2/authorization/sso"))
            .andExpect(status().is3xxRedirection())
            .andReturn();
        String location = result.getResponse().getRedirectedUrl();
        return new LoginStart(
            (MockHttpSession) result.getRequest().getSession(false),
            queryParam(location, "state"),
            queryParam(location, "nonce"));
    }

    /** Runs the full OIDC authorization code login against the fake Cognito and returns the logged-in session. */
    protected MockHttpSession loginViaCognito(String username, List<String> groups) throws Exception {
        LoginStart start = startLogin();
        COGNITO.prepareLogin(new CognitoLogin(ssoClientId(), username, groups, start.nonce()));

        MvcResult result = mockMvc.perform(get("/login/oauth2/code/sso")
                .param("code", "fake-code").param("state", start.state()).session(start.session()))
            .andExpect(status().is3xxRedirection())
            .andExpect(header().string(HttpHeaders.LOCATION, not(containsString("error"))))
            .andReturn();
        return (MockHttpSession) result.getRequest().getSession(false);
    }

    protected String ssoClientId() {
        return clientRegistrations.findByRegistrationId("sso").getClientId();
    }

    protected static String queryParam(String url, String name) {
        String value = UriComponentsBuilder.fromUriString(url).build().getQueryParams().getFirst(name);
        assertThat(value).as("query parameter %s in %s", name, url).isNotNull();
        return URLDecoder.decode(value, StandardCharsets.UTF_8);
    }
}
