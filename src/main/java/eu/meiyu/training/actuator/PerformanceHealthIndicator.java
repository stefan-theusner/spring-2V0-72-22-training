package eu.meiyu.training.actuator;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.health.contributor.Health;
import org.springframework.boot.health.contributor.HealthIndicator;
import org.springframework.boot.health.contributor.Status;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component("servicePerformance")
public class PerformanceHealthIndicator implements HealthIndicator {

    static final Status BAD_PERFORMANCE = new Status("BAD_PERFORMANCE", "Avg response time to high!");
    private final PerformanceTracker tracker;

    @Autowired
    PerformanceHealthIndicator(PerformanceTracker tracker) {
        this.tracker = tracker;
    }

    @Override
    public Health health() {
        double average = tracker.averageMillis();
        Health.Builder builder = average > 500 ? Health.status(BAD_PERFORMANCE) : Health.up();
        return builder.withDetails(Map.of(
            "avgMillis", Math.round(average),
                "executions", tracker.execPerService()
        )).build();
    }
}
