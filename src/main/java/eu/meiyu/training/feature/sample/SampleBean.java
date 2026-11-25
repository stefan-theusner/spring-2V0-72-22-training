package eu.meiyu.training.feature.sample;

import eu.meiyu.training.config.AppConfigProperties;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.DisposableBean;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Lazy;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;

@Component
public class SampleBean implements InitializingBean {

    private static final Logger log = LoggerFactory.getLogger(SampleBean.class);

    private final AppConfigProperties appConfig;
    private final ApplicationContext context;

    // nested class as spring bean
    @Lazy
    @Component
    @Scope("prototype")
    static protected final class InlineSampleBean implements InitializingBean, DisposableBean {
        @Override
        public void afterPropertiesSet() throws Exception {
            log.info("afterPropertiesSet inlineSampleBean");
        }

        @Override
        public void destroy() throws Exception {
            // has no effect with @Scope("prototype")
            log.info("destroy inlineSampleBean");
        }
    }

    @Autowired
    SampleBean(AppConfigProperties appConfig, ApplicationContext context) {
        log.info("Constructor sampleBean");
        this.context = context;
        this.appConfig = appConfig;
    }

    @PostConstruct()
    private void postConstruct() {
        log.info("Post construct sampleBean");
    }

    public AppConfigProperties getAppConfig() {
        return appConfig;
    }

    @Override
    public void afterPropertiesSet() throws Exception {
        log.info("afterPropertiesSet sampleBean");

        // Without @Lazy would be the 'afterPropertiesSet inlineSampleBean' would show up
        // before 'afterPropertiesSet sampleBean'
        var inlineSample1 = context.getBean(SampleBean.InlineSampleBean.class);

        // With @Scope("prototype") 'afterPropertiesSet inlineSampleBean' will be
        // logged again -> new instance has been created
        var inlineSample2 = context.getBean(SampleBean.InlineSampleBean.class);
    }
}
