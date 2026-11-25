package eu.meiyu.training.security;

import com.nimbusds.jose.jwk.source.JWKSource;
import com.nimbusds.jose.proc.SecurityContext;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.oauth2.jose.jws.SignatureAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;

import java.security.interfaces.RSAPublicKey;
import java.time.Instant;
import java.util.List;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/** Resource server: Bearer JWTs issued (signed) by the embedded authorization server. */
class BearerTokenTests extends AbstractAuthenticationTests {

    @Autowired
    private JWKSource<SecurityContext> jwkSource;

    @Test
    void token_with_group_user_is_accepted() throws Exception {
        String token = appToken(List.of("user"), Instant.now().plusSeconds(300));

        mockMvc.perform(get(USER_INFO).header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.username").value("jane.doe"))
            .andExpect(jsonPath("$.groups[0]").value("user"));
    }

    @Test
    void token_without_group_user_is_forbidden() throws Exception {
        String token = appToken(List.of("admin", "superadmin"), Instant.now().plusSeconds(300));

        mockMvc.perform(get(USER_INFO).header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
            .andExpect(status().isForbidden());
    }

    @Test
    void expired_token_is_rejected() throws Exception {
        String token = appToken(List.of("user"), Instant.now().minusSeconds(600));

        mockMvc.perform(get(USER_INFO).header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
            .andExpect(status().isUnauthorized());
    }

    @Test
    void token_signed_by_another_issuer_is_rejected() throws Exception {
        // A valid Cognito-signed token is not accepted: the API only trusts the embedded authorization server
        String token = COGNITO.sign(JwtClaimsSet.builder()
            .issuer(COGNITO.issuer())
            .subject("jane.doe")
            .claim(AppClaims.GROUPS, List.of("user"))
            .issuedAt(Instant.now())
            .expiresAt(Instant.now().plusSeconds(300))
            .build());

        mockMvc.perform(get(USER_INFO).header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
            .andExpect(status().isUnauthorized());
    }

    @Test
    void malformed_token_is_rejected() throws Exception {
        mockMvc.perform(get(USER_INFO).header(HttpHeaders.AUTHORIZATION, "Bearer not-a-jwt"))
            .andExpect(status().isUnauthorized());
    }

    @Test
    void missing_token_on_api_request_is_rejected() throws Exception {
        mockMvc.perform(get(USER_INFO).accept(MediaType.APPLICATION_JSON))
            .andExpect(status().isUnauthorized());
    }

    @Test
    void jwks_endpoint_publishes_the_configured_signing_key() throws Exception {
        RSAPublicKey publicKey = (RSAPublicKey) TestKeys.APP_SIGNING_KEYS.getPublic();

        mockMvc.perform(get("/oauth2/jwks"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.keys[0].kid").value("training-signing-key-1"))
            .andExpect(jsonPath("$.keys[0].n").value(TestKeys.base64UrlUnsigned(publicKey.getModulus().toByteArray())));
    }

    /** A user token signed with the app's signing key, like one issued by the embedded authorization server. */
    private String appToken(List<String> groups, Instant expiresAt) {
        JwtClaimsSet claims = JwtClaimsSet.builder()
            .issuer(ISSUER)
            .subject("jane.doe")
            .issuedAt(expiresAt.minusSeconds(300))
            .expiresAt(expiresAt)
            .claim("preferred_username", "jane.doe")
            .claim("email", "jane.doe@example.com")
            .claim(AppClaims.SUBJECT_TYPE, AppClaims.SUBJECT_TYPE_USER)
            .claim(AppClaims.GROUPS, groups)
            .build();
        return new NimbusJwtEncoder(jwkSource)
            .encode(JwtEncoderParameters.from(JwsHeader.with(SignatureAlgorithm.RS256).build(), claims))
            .getTokenValue();
    }
}
