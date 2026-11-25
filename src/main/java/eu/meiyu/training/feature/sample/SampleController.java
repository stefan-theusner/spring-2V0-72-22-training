package eu.meiyu.training.feature.sample;

import eu.meiyu.training.config.AppConfigProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/samples")
public class SampleController {

    private static final Logger log = LoggerFactory.getLogger(SampleController.class);
    AppConfigProperties appConfig;

    @Autowired
    SampleController(SampleBean sampleBean) {
        this.appConfig = sampleBean.getAppConfig();
    }

    @Value("#{@'app.config-eu.meiyu.training.config.AppConfigProperties'.someValue}")
    private String someValue;
    private String anotherValue;

    @Value("${app.config.someValue}")
    public void someConfig(String value) {
        anotherValue = value;
        log.info("someConfig called {}", anotherValue);
    }

    @GetMapping
    public ResponseEntity<Map<String, String>>getConfigValues() {
        return ResponseEntity.ok(Map.of(
            "fromValueInjectOfPropClass", someValue,
            "fromMethodInject", anotherValue,
            "fromAutowiredInject", appConfig.someValue
        ));
    }
}
