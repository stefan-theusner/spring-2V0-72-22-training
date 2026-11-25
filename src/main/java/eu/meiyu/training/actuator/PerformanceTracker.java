package eu.meiyu.training.actuator;

import org.springframework.stereotype.Component;

import java.util.HashMap;

@Component
public class PerformanceTracker {
    private static final double ALPHA = 0.1;      // weight of the newest call
    private double avgMillis = 0;
    private final HashMap<String, ExecutionPerService> execPerService = new HashMap<String, ExecutionPerService>();

    public synchronized void record(long millis, String serviceName) {
        avgMillis = avgMillis == 0 ? millis : ALPHA * millis + (1 - ALPHA) * avgMillis;
        if (!execPerService.containsKey(serviceName)) {
            execPerService.put(serviceName, new ExecutionPerService(0, 0));
        }
        ExecutionPerService executionPerService = execPerService.get(serviceName);
        double svcAvgMillis = executionPerService.avgMillis() == 0 ? millis : ALPHA * millis + (1 - ALPHA) * executionPerService.avgMillis();
        long countExecutions = executionPerService.count() + 1;
        execPerService.put(serviceName, new ExecutionPerService(Math.round(svcAvgMillis), countExecutions));
    }

    public synchronized double averageMillis() { return avgMillis; }
    public synchronized HashMap<String, ExecutionPerService> execPerService() { return execPerService; }
}
