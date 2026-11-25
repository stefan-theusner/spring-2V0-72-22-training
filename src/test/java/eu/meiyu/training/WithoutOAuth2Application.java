package eu.meiyu.training;

import eu.meiyu.training.config.AppConfigProperties;
import eu.meiyu.training.controller.OAuth2Controller;
import org.springframework.boot.SpringBootConfiguration;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.security.oauth2.client.autoconfigure.OAuth2ClientAutoConfiguration;
import org.springframework.boot.security.oauth2.client.autoconfigure.servlet.OAuth2ClientWebSecurityAutoConfiguration;
import org.springframework.boot.security.oauth2.server.authorization.autoconfigure.servlet.OAuth2AuthorizationServerAutoConfiguration;
import org.springframework.boot.security.oauth2.server.authorization.autoconfigure.servlet.OAuth2AuthorizationServerJwtAutoConfiguration;
import org.springframework.boot.security.oauth2.server.resource.autoconfigure.OAuth2ResourceServerAutoConfiguration;
import org.springframework.boot.security.oauth2.server.resource.autoconfigure.web.OAuth2ResourceServerWebSecurityAutoConfiguration;
import org.springframework.boot.test.context.TestComponent;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.FilterType;

@TestComponent
@SpringBootConfiguration
@EnableConfigurationProperties({AppConfigProperties.class})
@EnableAutoConfiguration(exclude = {
    OAuth2ClientAutoConfiguration.class,
    OAuth2ClientWebSecurityAutoConfiguration.class,
    OAuth2ResourceServerAutoConfiguration.class,
    OAuth2ResourceServerWebSecurityAutoConfiguration.class,
    OAuth2AuthorizationServerAutoConfiguration.class,
    OAuth2AuthorizationServerJwtAutoConfiguration.class
})
@ComponentScan(
    basePackageClasses = TrainingApplication.class,
    excludeFilters = {
        @ComponentScan.Filter(type = FilterType.ASSIGNABLE_TYPE,
            classes = {TrainingApplication.class, TrainingConfig.class, OAuth2Controller.class}),
        @ComponentScan.Filter(type = FilterType.REGEX,
            pattern = "eu\\.meiyu\\.training\\.config\\.security\\..*"),
        @ComponentScan.Filter(type = FilterType.REGEX,
            pattern = "eu\\.meiyu\\.training\\.security\\..*")
    })
public class WithoutOAuth2Application {
}
