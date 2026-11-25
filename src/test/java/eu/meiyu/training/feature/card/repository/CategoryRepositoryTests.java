package eu.meiyu.training.feature.card.repository;

import eu.meiyu.training.WithoutOAuth2Application;
import eu.meiyu.training.feature.card.dto.CategoryCountDto;
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
class CategoryRepositoryTests {

    @Autowired
    private CategoryRepository categoryRepository;

    @MockitoBean
    private MeterRegistry meterRegistry;

    @Test
    void findAllWithCardCount_returnsCategoriesWithCardCounts() {
        List<CategoryCountDto> categories = categoryRepository.findAllWithCardCount();

        assertThat(categories).hasSize(2);
        assertThat(categories).extracting(CategoryCountDto::code).containsExactly("AOP", "JPA");
        assertThat(categories).extracting(CategoryCountDto::cardCount).containsExactly(2L, 1L);
    }

    @Test
    void findAllWithCardCountForKinds_returnsCountsOnlyForMatchingKinds() {
        List<CategoryCountDto> categories = categoryRepository.findAllWithCardCountForKinds(List.of(1L));

        assertThat(categories).hasSize(2);
        assertThat(categories).extracting(CategoryCountDto::code).containsExactly("AOP", "JPA");
        assertThat(categories).extracting(CategoryCountDto::cardCount).containsExactly(1L, 1L);
    }
}
