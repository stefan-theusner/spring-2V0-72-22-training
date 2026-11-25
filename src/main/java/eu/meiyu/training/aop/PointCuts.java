package eu.meiyu.training.aop;

import org.aspectj.lang.annotation.Pointcut;

public class PointCuts {

    @Pointcut("execution(public * eu.meiyu.training.service..*(..))")
    public void publicServiceMethods() {}

}
