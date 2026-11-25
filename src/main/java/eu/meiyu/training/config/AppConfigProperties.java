package eu.meiyu.training.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app.config")
public class AppConfigProperties {
    public final String someValue;
    public final String version;
    public AppConfigProperties(String someValue, String version) {
        this.someValue = someValue;
        this.version = version;
    }
}
