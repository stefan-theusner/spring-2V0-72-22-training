package eu.meiyu.training.security;

import java.util.List;

/** The login {@link FakeCognito} answers the next token and userinfo requests with. */
record CognitoLogin(String clientId, String username, List<String> groups, String nonce) {

    String subject() {
        return "sub-" + username;
    }

    String email() {
        return username + "@example.com";
    }
}
