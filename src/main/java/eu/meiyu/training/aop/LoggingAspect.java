package eu.meiyu.training.aop;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.stereotype.Component;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Aspect
@Component
public class LoggingAspect {

    private static final Logger log = LoggerFactory.getLogger(LoggingAspect.class);

    @Before("eu.meiyu.training.aop.PointCuts.publicServiceMethods()")
    public void log(JoinPoint joinPoint) {
        log.debug("{}", joinPoint.getSignature().toShortString());
    }

}
