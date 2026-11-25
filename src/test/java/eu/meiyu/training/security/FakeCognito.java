package eu.meiyu.training.security;

import com.nimbusds.jose.jwk.JWKSet;
import com.nimbusds.jose.jwk.RSAKey;
import com.nimbusds.jose.jwk.source.ImmutableJWKSet;
import com.nimbusds.jose.util.JSONObjectUtils;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;
import org.springframework.security.oauth2.jose.jws.SignatureAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.security.KeyPair;
import java.security.interfaces.RSAPublicKey;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Minimal in-process OIDC provider standing in for Cognito on Floci: discovery, JWKS, token and userinfo endpoints.
 * The token endpoint answers with an ID token for the login set with {@link #prepareLogin(CognitoLogin)}.
 * <p>
 * One instance per JVM ({@link #INSTANCE}), shared by all test classes so they reuse one cached Spring context.
 */
final class FakeCognito {

    static final FakeCognito INSTANCE = start();

    private static final String USER_POOL_ID = "us-east-1_test";

    private final String baseUrl;
    private final String issuer;
    private final RSAKey key;
    private volatile CognitoLogin nextLogin;

    private FakeCognito(HttpServer server) {
        this.baseUrl = "http://localhost:" + server.getAddress().getPort();
        this.issuer = baseUrl + "/" + USER_POOL_ID;
        KeyPair keyPair = TestKeys.generateRsaKeyPair();
        this.key = new RSAKey.Builder((RSAPublicKey) keyPair.getPublic())
            .privateKey(keyPair.getPrivate())
            .keyID("fake-cognito")
            .build();

        server.createContext("/" + USER_POOL_ID + "/.well-known/openid-configuration",
            exchange -> respond(exchange, discovery()));
        server.createContext("/" + USER_POOL_ID + "/.well-known/jwks.json",
            exchange -> respond(exchange, new JWKSet(key).toString()));
        server.createContext("/oauth2/token", exchange -> respond(exchange, tokenResponse()));
        server.createContext("/oauth2/userInfo", exchange -> respond(exchange, userInfo()));
    }

    private static FakeCognito start() {
        try {
            HttpServer server = HttpServer.create(new InetSocketAddress("localhost", 0), 0);
            FakeCognito cognito = new FakeCognito(server);
            server.start();
            Runtime.getRuntime().addShutdownHook(new Thread(() -> server.stop(0)));
            return cognito;
        } catch (IOException e) {
            throw new IllegalStateException("Cannot start fake Cognito", e);
        }
    }

    String baseUrl() {
        return baseUrl;
    }

    String issuer() {
        return issuer;
    }

    void prepareLogin(CognitoLogin login) {
        this.nextLogin = login;
    }

    /** Signs a JWT with the fake Cognito key (not trusted by the app's resource server). */
    String sign(JwtClaimsSet claims) {
        return new NimbusJwtEncoder(new ImmutableJWKSet<>(new JWKSet(key)))
            .encode(JwtEncoderParameters.from(JwsHeader.with(SignatureAlgorithm.RS256).keyId(key.getKeyID()).build(), claims))
            .getTokenValue();
    }

    private String discovery() {
        Map<String, Object> metadata = new LinkedHashMap<>();
        metadata.put("issuer", issuer);
        metadata.put("authorization_endpoint", baseUrl + "/oauth2/authorize");
        metadata.put("token_endpoint", baseUrl + "/oauth2/token");
        metadata.put("userinfo_endpoint", baseUrl + "/oauth2/userInfo");
        metadata.put("jwks_uri", issuer + "/.well-known/jwks.json");
        metadata.put("response_types_supported", List.of("code"));
        metadata.put("subject_types_supported", List.of("public"));
        metadata.put("id_token_signing_alg_values_supported", List.of("RS256"));
        metadata.put("scopes_supported", List.of("openid", "profile", "email"));
        metadata.put("token_endpoint_auth_methods_supported", List.of("client_secret_basic", "client_secret_post"));
        return JSONObjectUtils.toJSONString(metadata);
    }

    private String tokenResponse() {
        CognitoLogin login = nextLogin;
        Instant now = Instant.now();
        String idToken = sign(JwtClaimsSet.builder()
            .issuer(issuer)
            .subject(login.subject())
            .audience(List.of(login.clientId()))
            .issuedAt(now)
            .expiresAt(now.plusSeconds(300))
            .claim("auth_time", now.getEpochSecond())
            .claim("nonce", login.nonce())
            .claim("cognito:username", login.username())
            .claim("cognito:groups", login.groups())
            .claim("email", login.email())
            .claim("email_verified", true)
            .build());

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("access_token", "fake-cognito-access-token");
        response.put("token_type", "Bearer");
        response.put("expires_in", 300);
        response.put("id_token", idToken);
        response.put("scope", "openid profile email");
        return JSONObjectUtils.toJSONString(response);
    }

    private String userInfo() {
        CognitoLogin login = nextLogin;
        Map<String, Object> claims = new LinkedHashMap<>();
        claims.put("sub", login.subject());
        claims.put("username", login.username());
        claims.put("email", login.email());
        claims.put("email_verified", "true");
        return JSONObjectUtils.toJSONString(claims);
    }

    private static void respond(HttpExchange exchange, String json) throws IOException {
        byte[] body = json.getBytes(StandardCharsets.UTF_8);
        exchange.getResponseHeaders().add("Content-Type", "application/json");
        exchange.sendResponseHeaders(200, body.length);
        try (OutputStream out = exchange.getResponseBody()) {
            out.write(body);
        }
    }
}
