package eu.meiyu.training.security;

import eu.meiyu.training.security.principal.AppPrincipal;
import org.jspecify.annotations.NullMarked;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.AbstractOAuth2TokenAuthenticationToken;

import java.util.Collection;
import java.util.Map;
import java.util.Optional;

public class AppJwtAuthenticationToken extends AbstractOAuth2TokenAuthenticationToken<Jwt> {

    public AppJwtAuthenticationToken(Jwt jwt, AppPrincipal principal, Collection<? extends GrantedAuthority> authorities) {
        super(jwt, principal, jwt, authorities);
        setAuthenticated(true);
    }

    @Override
    @NullMarked
    public Map<String, Object> getTokenAttributes() {
        return getToken().getClaims();
    }

    @Override
    @NullMarked
    public String getName() {
        return Optional.ofNullable(getToken().getSubject()).orElse("unknown");
    }
}
