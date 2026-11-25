package eu.meiyu.training.aop.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface TrackMetricService {
    String value(); // value will be metric name and if mot present also tag of all TrackMetrics
}


