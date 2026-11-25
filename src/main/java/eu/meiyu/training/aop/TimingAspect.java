package eu.meiyu.training.aop;

import eu.meiyu.training.actuator.PerformanceTracker;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Aspect
@Component
public class TimingAspect {

    private static final Logger log = LoggerFactory.getLogger(TimingAspect.class);
    private final PerformanceTracker tracker;

    @Autowired
    TimingAspect(PerformanceTracker tracker) {
        this.tracker = tracker;
    }

    @Around("eu.meiyu.training.aop.PointCuts.publicServiceMethods()")
    public Object around(ProceedingJoinPoint joinPoint) throws Throwable {
        long startTime = System.currentTimeMillis();
        try {
            return joinPoint.proceed();
        } finally {
            long endTime = System.currentTimeMillis() - startTime;
            tracker.record(endTime, joinPoint.getSignature().toShortString());
            log.debug("{} took {} ms", joinPoint.getSignature().toShortString(), endTime);
        }
    }

}
