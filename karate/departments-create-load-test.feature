Feature: Configurable Department Load Test

  @load
  Scenario Outline: Worker thread #<worker> running for #(duration)
    * def durationMs = parseDuration(duration)
    * def endTime = Date.now() + durationMs
    * def count = 0

    * def runUntilTimeout =
      """
      function() {
        while (Date.now() < endTime) {
          karate.call(target_feature + '.feature');
          count++;
        java.lang.Thread.sleep(parseInt(wait_time_ms));
        }
        return count;
      }
      """
    * def totalCreated = runUntilTimeout()
    * karate.log('Worker', <worker>, 'created', totalCreated, 'departments in', duration)

    Examples:
      | karate.range(1, parseInt(num_workers)+1).map(function(i) { return { worker: i }; }) |