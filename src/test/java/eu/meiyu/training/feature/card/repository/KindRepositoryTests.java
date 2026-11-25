package eu.meiyu.training.feature.card.repository;

import eu.meiyu.training.WithoutOAuth2Application;
import eu.meiyu.training.feature.card.dto.KindCountDto;
import io.micrometer.core.instrument.MeterRegistry;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.boot.jdbc.test.autoconfigure.AutoConfigureTestDatabase;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.jdbc.Sql;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest(showSql = false)
@ContextConfiguration(classes = WithoutOAuth2Application.class)
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Sql("/card-test-data.sql")
class KindRepositoryTests {

    @Autowired
    private KindRepository kindRepository;

    @MockitoBean
    private MeterRegistry meterRegistry;

    @Test
    void findAllWithCardCount_returnsKindsWithCardCounts() {
        List<KindCountDto> kinds = kindRepository.findAllWithCardCount();

        assertThat(kinds).hasSize(2);
        assertThat(kinds).extracting(KindCountDto::name).containsExactly("Annotation", "Starter");
        assertThat(kinds).extracting(KindCountDto::cardCount).containsExactly(2L, 1L);
    }
}
