package eu.meiyu.training.feature.card.repository;

import eu.meiyu.training.WithoutOAuth2Application;
import eu.meiyu.training.feature.card.entity.Card;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.boot.jdbc.test.autoconfigure.AutoConfigureTestDatabase;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.jdbc.Sql;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest(showSql = false)
@ContextConfiguration(classes = WithoutOAuth2Application.class)
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Sql("/card-test-data.sql")
class CardRepositoryTests {

    @Autowired
    private CardRepository cardRepository;

    @MockitoBean
    private MeterRegistry meterRegistry;

    @Test
    void findAll_withKindAndCategorySpecification_returnsFilteredCards() {
        Specification<Card> spec = Specification.unrestricted();
        spec = spec.and((root, query, cb) -> root.get("kind").get("id").in(List.of(1L)));
        spec = spec.and((root, query, cb) -> root.get("category").get("id").in(List.of(10L)));

        List<Card> cards = cardRepository.findAll(spec);

        assertThat(cards).extracting(Card::getName).containsExactly("Card A");
    }

    @Test
    void findAll_withSpecificationAndPageable_returnsOnePage() {
        Specification<Card> spec = (root, query, cb) -> cb.isTrue(cb.literal(true));

        Page<Card> page = cardRepository.findAll(spec, PageRequest.of(0, 1));

        assertThat(page.getContent()).hasSize(1);
        assertThat(page.getTotalElements()).isPositive();
        assertThat(page.getNumber()).isZero();
        assertThat(page.getSize()).isEqualTo(1);
        assertThat(page.isLast()).isFalse();
    }

    @Test
    void findAllCardNames_returnsTheNameIndex() {
        assertThat(cardRepository.findAllCardNames())
            .extracting(name -> name.name())
            .contains("Card A");
    }
}
