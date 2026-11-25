package eu.meiyu.training;

import eu.meiyu.training.config.ActuatorConfig;
import eu.meiyu.training.config.security.AuthorizationServerConfig;
import eu.meiyu.training.config.security.RestSecurityConfig;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

@Configuration
@Import({RestSecurityConfig.class, ActuatorConfig.class, AuthorizationServerConfig.class})
public class TrainingConfig {

}
