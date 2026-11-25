package eu.meiyu.training.security.principal;

import java.util.List;

public interface AppPrincipal {
    String username();
    String email();
    List<String> groups();
    boolean isClient();
}
