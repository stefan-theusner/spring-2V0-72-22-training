package eu.meiyu.training.feature.about.dto;

import java.time.Instant;

/**
 * Public build information for the app. The values come from the generated
 * {@code META-INF/build-info.properties} file.
 */
public record AboutDto(
    String version,
    Instant buildTime
) {
}
