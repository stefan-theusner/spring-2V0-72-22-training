package eu.meiyu.training.config;

import org.springframework.context.annotation.Bean;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.factory.PasswordEncoderFactories;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

// disabled, kept only for learning reasons
// to enable need to be added to TrainingConfig imports
// @Configuration
public class RepositoryConfig {

    @Bean
    public InMemoryUserDetailsManager userDetailsService(PasswordEncoder passwordEncoder) {

        @FunctionalInterface
        interface UserBuilder {
            UserDetails buildUser(String username, String password, List<GrantedAuthority> authorities);
            default UserDetails buildUser(String username, String password, String... roleNames) {
                final String rolePrefix = "ROLE_";
                List<GrantedAuthority> authorities = Arrays
                    .stream(roleNames)
                    .map((roleName) -> {
                        String authority = roleName.startsWith(rolePrefix) ?  roleName : rolePrefix + roleName;
                        return new SimpleGrantedAuthority(authority);
                    })
                    .collect(Collectors.toList());
                return buildUser(username, password, authorities);
            }
        }

        UserBuilder userBuilder = (name, password, roleList) ->
            User.withUsername(name).password(passwordEncoder.encode(password)).authorities(roleList).build();


        List<GrantedAuthority> superAdminAuthorities = List.of(
            new SimpleGrantedAuthority("ROLE_USER"),
            new SimpleGrantedAuthority("ROLE_ADMIN"),
            new SimpleGrantedAuthority("ROLE_SUPERADMIN")
        );

        UserDetails user = userBuilder.buildUser("user", "user", "USER");
        UserDetails admin = userBuilder.buildUser("admin", "admin", "USER", "ADMIN");
        UserDetails superadmin = userBuilder.buildUser("superadmin", "superadmin",  superAdminAuthorities);

        return new InMemoryUserDetailsManager(user, admin, superadmin);
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return PasswordEncoderFactories.createDelegatingPasswordEncoder();
    }


}
