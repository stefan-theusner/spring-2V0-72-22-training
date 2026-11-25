package eu.meiyu.training.security.principal;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.Collection;
import java.util.List;

public class AppAuthorities {

    private static final String ROLE_PREFIX = "ROLE_";

    private AppAuthorities() {}

    private static String normalizeGroupName(String groupName) {
        return groupName.toUpperCase();
    }

    public static List<GrantedAuthority> fromGroups(Collection<String> groups) {
        return groups.stream().<GrantedAuthority>map(groupName -> new SimpleGrantedAuthority(ROLE_PREFIX + normalizeGroupName(groupName))).toList();
    }

}
