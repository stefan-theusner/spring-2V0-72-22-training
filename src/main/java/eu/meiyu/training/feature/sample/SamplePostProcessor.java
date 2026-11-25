package eu.meiyu.training.feature.sample;

import eu.meiyu.training.config.AppConfigProperties;
import org.jspecify.annotations.NonNull;
import org.jspecify.annotations.Nullable;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanFactoryPostProcessor;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.stereotype.Component;

@Component
public class SamplePostProcessor implements BeanFactoryPostProcessor, BeanPostProcessor {

    private static final Logger log = LoggerFactory.getLogger(SamplePostProcessor.class);

    @Override
    // avoid calling beanFactory.getBean(..)
    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {
        if (beanFactory.containsBeanDefinition("sampleBean")) {
            var beanDefinition = beanFactory.getBeanDefinition("sampleBean");
            log.info("postProcessBeanFactory about to modify {}", beanDefinition.getBeanClassName());
            var config = new AppConfigProperties("Modified by postProcessBeanFactory", "0.0.1");
            var arguments = beanDefinition.getConstructorArgumentValues();
            arguments.clear();
            arguments.addIndexedArgumentValue(0, config);
        }
    }

    @Override
    public @Nullable Object postProcessBeforeInitialization(@NonNull Object bean, @NonNull String beanName) throws BeansException {
        if (bean instanceof SampleBean) {
            log.info("postProcessBeforeInitialization {}", beanName);
        }
        return bean;
    }

    @Override
    public @Nullable Object postProcessAfterInitialization(@NonNull Object bean, @NonNull String beanName) throws BeansException {
        if (bean instanceof SampleBean) {
            log.info("postProcessAfterInitialization {}", beanName);
        }
        return bean;
    }


}
