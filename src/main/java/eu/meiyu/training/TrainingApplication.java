package eu.meiyu.training;

import eu.meiyu.training.config.AppConfigProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.context.annotation.Import;

@SpringBootApplication
@EnableConfigurationProperties({AppConfigProperties.class})
@Import(TrainingConfig.class)
@EntityScan(value = {
    "eu.meiyu.training.feature.card.entity",
    "eu.meiyu.training.feature.department.entity"
})
public class TrainingApplication {

	public static void main(String[] args) {
		SpringApplication.run(TrainingApplication.class, args);
	}

}
