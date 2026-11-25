package eu.meiyu.training.security.principal;

import eu.meiyu.training.security.AppClaims;
import org.springframework.security.oauth2.jwt.Jwt;

import java.io.Serial;
import java.io.Serializable;
import java.util.List;
import java.util.Optional;

public class JwtAppPrincipal implements AppPrincipal, Serializable {

    @Serial
    private static final long serialVersionUID = 1L;
    private final String username;
    private final String email;
    private final List<String> groups;
    private final boolean client;

    private JwtAppPrincipal(String username, String email, List<String> groups, boolean client) {
        this.username = username;
        this.email = email;
        this.groups = groups;
        this.client = client;
    }

    public static JwtAppPrincipal from(Jwt jwt) {
        String username = jwt.getClaimAsString("preferred_username");
        List<String> groups = Optional.ofNullable(jwt.getClaimAsStringList("groups")).orElse(List.of());
        boolean client = AppClaims.SUBJECT_TYPE_CLIENT.equals(jwt.getClaimAsString(AppClaims.SUBJECT_TYPE));
        return new JwtAppPrincipal(username, jwt.getClaimAsString("email"), groups, client);
    }

    @Override
    public String username() {
        return username;
    }

    @Override
    public String email() {
        return email;
    }

    @Override
    public List<String> groups() {
        return groups;
    }

    @Override
    public boolean isClient() {
        return client;
    }
}
