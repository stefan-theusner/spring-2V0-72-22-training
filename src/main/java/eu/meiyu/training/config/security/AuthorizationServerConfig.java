package eu.meiyu.training.config.security;

import com.nimbusds.jose.jwk.JWKSet;
import com.nimbusds.jose.jwk.RSAKey;
import com.nimbusds.jose.jwk.source.ImmutableJWKSet;
import com.nimbusds.jose.jwk.source.JWKSource;
import com.nimbusds.jose.proc.SecurityContext;
import eu.meiyu.training.security.AppClaims;
import eu.meiyu.training.security.principal.CognitoOidcPrincipal;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.http.MediaType;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.oauth2.core.AuthorizationGrantType;
import org.springframework.security.oauth2.core.oidc.OidcScopes;
import org.springframework.security.oauth2.core.oidc.StandardClaimNames;
import org.springframework.security.oauth2.core.oidc.endpoint.OidcParameterNames;
import org.springframework.security.oauth2.server.authorization.OAuth2TokenType;
import org.springframework.security.oauth2.server.authorization.token.JwtEncodingContext;
import org.springframework.security.oauth2.server.authorization.token.OAuth2TokenCustomizer;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.LoginUrlAuthenticationEntryPoint;
import org.springframework.security.web.util.matcher.MediaTypeRequestMatcher;

import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.util.Set;

@Configuration
public class AuthorizationServerConfig {

    @Bean
    public JWKSource<SecurityContext> jwkSource(
        @Value("${app.security.signing-key.public}") RSAPublicKey publicKey,
        @Value("${app.security.signing-key.private}") RSAPrivateKey privateKey,
        @Value("${app.security.signing-key.id}") String keyId) {
        RSAKey rsaKey = new RSAKey.Builder(publicKey)
            .privateKey(privateKey)
            .keyID(keyId)
            .build();
        return new ImmutableJWKSet<>(new JWKSet(rsaKey));
    }

    @Bean
    // used in authorization server
    public OAuth2TokenCustomizer<JwtEncodingContext> federatedIdentityTokenCustomizer() {
        return context -> {

            boolean isAccessToken = OAuth2TokenType.ACCESS_TOKEN.equals(context.getTokenType());
            boolean isIdToken = OidcParameterNames.ID_TOKEN.equals(context.getTokenType().getValue());
            if (!isAccessToken && !isIdToken) {
                return;
            }

            if (context.getPrincipal() instanceof OAuth2AuthenticationToken login
                && login.getPrincipal() instanceof CognitoOidcPrincipal cognitoUser) {
                Set<String> scopes = context.getAuthorizedScopes();
                context.getClaims().claims(claims -> {
                    claims.put(AppClaims.SUBJECT_TYPE, AppClaims.SUBJECT_TYPE_USER);
                    if (scopes.contains(OidcScopes.PROFILE)) {
                        claims.put(StandardClaimNames.PREFERRED_USERNAME, cognitoUser.username());
                    }
                    if (scopes.contains(OidcScopes.EMAIL)) {
                        claims.put(StandardClaimNames.EMAIL, cognitoUser.email());
                        claims.put(StandardClaimNames.EMAIL_VERIFIED, cognitoUser.getEmailVerified());
                    }
                    claims.put(AppClaims.GROUPS, cognitoUser.groups());
                });
            } else if (AuthorizationGrantType.CLIENT_CREDENTIALS.equals(context.getAuthorizationGrantType())) {
                context.getClaims().claim(AppClaims.SUBJECT_TYPE, AppClaims.SUBJECT_TYPE_CLIENT);
            }
        };
    }

    @Bean
    @Order(1)
    // login for rest e.g. clients
    public SecurityFilterChain authorizationServerSecurityFilterChain(HttpSecurity http) throws Exception {
        http.oauth2AuthorizationServer(authorizationServer -> {
                http.securityMatcher(authorizationServer.getEndpointsMatcher());
                authorizationServer.oidc(Customizer.withDefaults());
            })
            .authorizeHttpRequests(authorize -> authorize.anyRequest().authenticated())
            .exceptionHandling(
                exceptions -> exceptions.defaultAuthenticationEntryPointFor(
                    new LoginUrlAuthenticationEntryPoint("/oauth2/authorization/sso"),
                    new MediaTypeRequestMatcher(MediaType.TEXT_HTML))
            )
            .oauth2ResourceServer(
                resourceServer -> resourceServer.jwt(Customizer.withDefaults())
            );
        return http.build();
    }
}
