package eu.meiyu.training.aop;

import eu.meiyu.training.aop.annotation.MetricType;
import eu.meiyu.training.aop.annotation.TrackMetric;
import eu.meiyu.training.aop.annotation.TrackMetricService;
import eu.meiyu.training.aop.annotation.TrackMetrics;
import io.micrometer.core.instrument.*;
import io.micrometer.core.instrument.Timer;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.annotation.AnnotatedElementUtils;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;
import java.time.Duration;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicReference;

@Aspect
@Component
public class TrackMetricAspect {

    private final MeterRegistry registry;
    private final Map<String, AtomicReference<Double>> gaugeValues = new ConcurrentHashMap<>();

    @Value("${app.monitoring.distribution.boundaries}")
    private double[] distributionBoundaries;

    @Value("#{'${app.monitoring.timer.boundaries}'.split(',')}")
    private List<String> timerBoundaries;

    public TrackMetricAspect(MeterRegistry registry) {
        this.registry = registry;
    }

    @Around("@within(trackedService) && (@annotation(eu.meiyu.training.aop.annotation.TrackMetric) || @annotation(eu.meiyu.training.aop.annotation.TrackMetrics))")
    public Object trackMetrics(ProceedingJoinPoint joinPoint, TrackMetricService trackedService) throws Throwable {
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        Set<TrackMetric> metrics = AnnotatedElementUtils.getMergedRepeatableAnnotations(
            method, TrackMetric.class, TrackMetrics.class
        );

        String name = trackedService.value();

        // Start any timers before method execution
        Timer.Sample timerSample = null;
        LongTaskTimer.Sample longTaskSample = null;
        TrackMetric timerTrackMetric = null;

        for (TrackMetric metric : metrics) {
            String tagKey = !Objects.equals(metric.tag(), "") ? metric.tag() : trackedService.value();
            String metricName = name + '.' + metric.value();
            if (metric.type() == MetricType.TIMER) {
                timerSample = Timer.start(registry);
                timerTrackMetric = metric;
            } else if (metric.type() == MetricType.LONG_TASK_TIMER) {
                longTaskSample = LongTaskTimer.builder(metricName)
                    .description(metric.desc())
                    .tag(tagKey, metric.value())
                    .register(registry)
                    .start();
            }
        }

        try {
            // Execute the actual service method
            Object result = joinPoint.proceed();

            // Record post-execution metrics
            for (TrackMetric metric : metrics) {
                String metricName = name + '.' + metric.value();
                String tagKey = !Objects.equals(metric.tag(), "") ? metric.tag() : trackedService.value();
                recordPostExecution(metric, metricName, tagKey, metric.value(), result, joinPoint.getArgs());
            }
            return result;

        } finally {
            // Always stop active timers even if an exception is thrown
            if (timerSample != null && timerTrackMetric != null) {
                String tagKey = !Objects.equals(timerTrackMetric.tag(), "") ? timerTrackMetric.tag() : trackedService.value();
                String metricName = name + '.' + timerTrackMetric.value();

                var tb = Timer.builder(metricName)
                    .description(timerTrackMetric.desc())
                    .tag(tagKey, timerTrackMetric.value());
                if (timerBoundaries != null &&  !timerBoundaries.isEmpty()) {
                    Duration[] durations = timerBoundaries.stream().map(
                        durationValue -> Duration.ofMillis(Long.parseLong(durationValue))
                    ).toArray(Duration[]::new);
                    tb.serviceLevelObjectives(durations);
                }
                timerSample.stop(tb.register(registry));
            }
            if (longTaskSample != null) {
                longTaskSample.stop();
            }
        }
    }

    private void recordPostExecution(TrackMetric metric, String name, String tagKey, String tagValue, Object result, Object[] args) {
        switch (metric.type()) {
            case COUNTER -> Counter.builder(name)
                .description(metric.desc())
                .tag(tagKey, tagValue)
                .register(registry)
                .increment();

            case DISTRIBUTION_SUMMARY -> {
                Double amount = switch(result) {
                    case Number n -> n.doubleValue();
                    case Collection<?> c -> (double) c.size();
                    case null, default -> null;
                };
                if (!Objects.isNull(amount)) {
                    var dsBuilder = DistributionSummary.builder(name)
                        .description(metric.desc())
                        .tag(tagKey, tagValue);
                    if (distributionBoundaries != null) {
                        dsBuilder.serviceLevelObjectives(distributionBoundaries);
                    }
                    dsBuilder.register(registry).record(amount);
                }
            }
            case TIMER, LONG_TASK_TIMER -> {
                // Handled in before/finally blocks
            }
        }
    }

}
