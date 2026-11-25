package eu.meiyu.training.security.principal;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.FactorGrantedAuthority;
import org.springframework.security.oauth2.core.oidc.OidcIdToken;
import org.springframework.security.oauth2.core.oidc.user.DefaultOidcUser;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;

import java.io.Serial;
import java.time.Instant;
import java.util.*;

public class CognitoOidcPrincipal extends DefaultOidcUser implements AppPrincipal {

    @Serial
    private static final long serialVersionUID = 1L;
    private final String username;
    private final List<String> groups;

    private static final String USER_CLAIM = "cognito:username";
    private static final String GROUP_CLAIM = "cognito:groups";

    private CognitoOidcPrincipal(Collection<? extends GrantedAuthority> authorities, OidcUser user, String username, List<String> groups) {
        super(authorities, user.getIdToken(), user.getUserInfo());
        this.username = username;
        this.groups = groups;
    }

    public static CognitoOidcPrincipal from(OidcUser user) {
        OidcIdToken idToken = user.getIdToken();
        List<String> groups = Optional.ofNullable(idToken.getClaimAsStringList(GROUP_CLAIM)).orElse(List.of());
        Instant loginTime = Optional.ofNullable(idToken.getAuthenticatedAt()).orElse(Instant.now());

        Set<GrantedAuthority> authorities = new LinkedHashSet<>(user.getAuthorities());
        authorities.addAll(AppAuthorities.fromGroups(groups));
        authorities.add(FactorGrantedAuthority.withAuthority(FactorGrantedAuthority.AUTHORIZATION_CODE_AUTHORITY).issuedAt(loginTime).build());
        return new CognitoOidcPrincipal(authorities, user, user.getClaimAsString(USER_CLAIM), groups);
    }

    @Override
    public String username() {
        return username;
    }

    @Override
    public String email() {
        return getEmail();
    }

    @Override
    public List<String> groups() {
        return groups;
    }

    @Override
    public boolean isClient() {
        return false;
    }
}
