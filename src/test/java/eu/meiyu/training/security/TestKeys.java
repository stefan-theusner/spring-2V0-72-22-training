package eu.meiyu.training.security;

import java.nio.charset.StandardCharsets;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

/** RSA keys for the tests, so the real signing keys in {@code keys/} are not needed. */
final class TestKeys {

    /** Signing keys of the embedded authorization server, generated once per test run. */
    static final KeyPair APP_SIGNING_KEYS = generateRsaKeyPair();

    private TestKeys() {
    }

    static KeyPair generateRsaKeyPair() {
        try {
            KeyPairGenerator generator = KeyPairGenerator.getInstance("RSA");
            generator.initialize(2048);
            return generator.generateKeyPair();
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }

    /** PEM encoding as expected by {@code app.security.signing-key.*} ({@code PRIVATE KEY} / {@code PUBLIC KEY}). */
    static String pem(String type, byte[] der) {
        return "-----BEGIN " + type + "-----\n"
            + Base64.getMimeEncoder(64, "\n".getBytes(StandardCharsets.US_ASCII)).encodeToString(der)
            + "\n-----END " + type + "-----\n";
    }

    /** Base64url of an unsigned big-endian number, as used for the {@code n} / {@code e} members of a JWK. */
    static String base64UrlUnsigned(byte[] twosComplement) {
        byte[] bytes = twosComplement.length > 1 && twosComplement[0] == 0
            ? java.util.Arrays.copyOfRange(twosComplement, 1, twosComplement.length)
            : twosComplement;
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}
