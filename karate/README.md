# Karate REST Tests

## Load test

1. Adjust `duration`, `wait_time_ms`, `num_workers` and `target_feature` in [env.yaml](./env.yaml).
2. Run the load test in this folder:

   ```bash
   karate run -T 5 -t @load departments-create-load-test.feature
   ```

`-T` sets the number of parallel threads. `-t @load` selects the load-test tag. Karate writes reports to `target/`.
