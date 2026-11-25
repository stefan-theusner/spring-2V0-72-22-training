package eu.meiyu.training.config.security;

import eu.meiyu.training.security.AppJwtAuthenticationToken;
import eu.meiyu.training.security.IdpLogoutSuccessHandler;
import eu.meiyu.training.security.principal.AppAuthorities;
import eu.meiyu.training.security.principal.CognitoOidcPrincipal;
import eu.meiyu.training.security.principal.JwtAppPrincipal;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.core.convert.converter.Converter;
import org.springframework.http.HttpHeaders;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.oauth2.client.oidc.userinfo.OidcUserRequest;
import org.springframework.security.oauth2.client.oidc.userinfo.OidcUserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserService;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableMethodSecurity(
    prePostEnabled = true,
    securedEnabled = true,
    jsr250Enabled = true
)
public class RestSecurityConfig {

    @Bean
    public OAuth2UserService<OidcUserRequest, OidcUser> appOidcUserService() {
        OidcUserService userService = new OidcUserService();
        return request -> CognitoOidcPrincipal.from(userService.loadUser(request));
    }

    @Bean
    public Converter<Jwt, AppJwtAuthenticationToken> appJwtAuthenticationConverter() {
        return jwt -> {
            JwtAppPrincipal principal = JwtAppPrincipal.from(jwt);
          return new AppJwtAuthenticationToken(jwt, principal, AppAuthorities.fromGroups(principal.groups()));
        };
    }

    @Bean
    @Order(2)
    public SecurityFilterChain securityFilterChain(
        HttpSecurity http,
        @Autowired IdpLogoutSuccessHandler idpLogoutSuccessHandler
    ) {
        http.authorizeHttpRequests(
                (authorize) -> authorize
                    .requestMatchers("/favicon.ico").permitAll()
                    .requestMatchers("/about").permitAll()
                    .requestMatchers("/error").permitAll()
                    .requestMatchers("/actuator/**").permitAll()
                    .requestMatchers("/departments/**").permitAll()
                    .requestMatchers("/cards/**").permitAll()
                    .requestMatchers("/training", "/training/").permitAll()
                    .requestMatchers("/samples/**").permitAll()
                    .requestMatchers("/secured-endpoint/**").authenticated()
                    .anyRequest().denyAll()
            )
            .logout(logout -> logout.logoutSuccessHandler(idpLogoutSuccessHandler))
            // oidc (e.g. browser)
            .oauth2Login(login -> login
                .userInfoEndpoint(userInfo -> userInfo.oidcUserService(appOidcUserService())))
            // oauth rest client
            .oauth2ResourceServer(oauth2 -> oauth2.jwt(
                jwt -> jwt.jwtAuthenticationConverter(appJwtAuthenticationConverter()))
            )
            .csrf(
                csrf -> csrf.spa().ignoringRequestMatchers(request -> request.getHeader(HttpHeaders.AUTHORIZATION) != null)
                    .ignoringRequestMatchers("/departments/**") // allow for testing / learning
            );
        return http.build();
    }

}
