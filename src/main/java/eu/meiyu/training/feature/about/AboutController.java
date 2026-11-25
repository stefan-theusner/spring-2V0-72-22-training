package eu.meiyu.training.feature.about;

import eu.meiyu.training.feature.about.dto.AboutDto;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.info.BuildProperties;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;

/**
 * Returns build metadata for the version badge in the study cards page.
 */
@RestController
public class AboutController {

    private final ObjectProvider<BuildProperties> buildProperties;

    AboutController(ObjectProvider<BuildProperties> buildProperties) {
        this.buildProperties = buildProperties;
    }

    @GetMapping("/about")
    public AboutDto about() {
        BuildProperties info = buildProperties.getIfAvailable();
        if (info == null) {
            return new AboutDto("unknown", null);
        }
        String version = info.getVersion() == null ? "unknown" : info.getVersion();
        Instant buildTime = info.getTime();
        return new AboutDto(version, buildTime);
    }
}
