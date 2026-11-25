package eu.meiyu.training.security;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import java.util.UUID;

/** PKCE helpers (RFC 7636, method S256). */
final class Pkce {

    private Pkce() {
    }

    static String newCodeVerifier() {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(
            (UUID.randomUUID() + "-" + UUID.randomUUID()).getBytes(StandardCharsets.US_ASCII));
    }

    static String codeChallenge(String verifier) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(verifier.getBytes(StandardCharsets.US_ASCII));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(digest);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }
}
