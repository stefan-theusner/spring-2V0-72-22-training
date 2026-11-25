package eu.meiyu.training.dto;

import eu.meiyu.training.security.principal.AppPrincipal;

import java.util.List;

public record PrincipalDto(String username, String email, List<String> groups, boolean client) {

    public static PrincipalDto of(AppPrincipal principal) {
        return new PrincipalDto(principal.username(), principal.email(), principal.groups(), principal.isClient());
    }

}
