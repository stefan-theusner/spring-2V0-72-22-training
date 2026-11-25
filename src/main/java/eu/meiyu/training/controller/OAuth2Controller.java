package eu.meiyu.training.controller;

import eu.meiyu.training.dto.PrincipalDto;
import eu.meiyu.training.security.principal.AppPrincipal;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.authentication.InsufficientAuthenticationException;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/secured-endpoint")
public class OAuth2Controller {

    @GetMapping("/user-info")
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<PrincipalDto> getLoggedInUser(
        @AuthenticationPrincipal AppPrincipal principal
        ) {
        if (principal == null) {
            throw new InsufficientAuthenticationException("Principal incorrect - try to login again");
        }
        return ResponseEntity.ok(PrincipalDto.of(principal));
    }

}
