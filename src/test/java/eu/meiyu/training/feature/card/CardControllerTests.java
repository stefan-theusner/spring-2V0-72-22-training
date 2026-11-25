package eu.meiyu.training.feature.card;

import eu.meiyu.training.WithoutOAuth2Application;
import eu.meiyu.training.feature.card.dto.CardNameDto;
import eu.meiyu.training.feature.card.dto.CategoryCountDto;
import eu.meiyu.training.feature.card.dto.KindCountDto;
import eu.meiyu.training.feature.card.entity.Card;
import eu.meiyu.training.feature.card.entity.CardFact;
import eu.meiyu.training.feature.card.entity.Category;
import eu.meiyu.training.feature.card.entity.Kind;
import eu.meiyu.training.feature.card.repository.CardRepository;
import eu.meiyu.training.feature.card.repository.CategoryRepository;
import eu.meiyu.training.feature.card.repository.KindRepository;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.ArgumentMatchers;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(classes = WithoutOAuth2Application.class, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc(addFilters = false)
class CardControllerTests {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private CardRepository cardRepository;

    @MockitoBean
    private CategoryRepository categoryRepository;

    @MockitoBean
    private KindRepository kindRepository;

    @Test
    void retrieveKinds_should_return_list_of_kinds() throws Exception {
        List<KindCountDto> kinds = List.of(
            new KindCountDto(1L, "Annotation", "ann", 2L),
            new KindCountDto(2L, "Starter", "sta", 1L)
        );
        given(kindRepository.findAllWithCardCount()).willReturn(kinds);

        mockMvc.perform(get("/cards/kinds").accept(MediaType.APPLICATION_JSON))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON))
            .andExpect(jsonPath("$.length()").value(2))
            .andExpect(jsonPath("$[0].id").value(1))
            .andExpect(jsonPath("$[0].name").value("Annotation"))
            .andExpect(jsonPath("$[0].hint").value("ann"))
            .andExpect(jsonPath("$[0].cardCount").value(2));

        verify(kindRepository).findAllWithCardCount();
    }

    @Test
    void retrieveCategories_should_return_list_of_categories() throws Exception {
        List<Long> kindIds = List.of(1L, 2L);
        List<CategoryCountDto> categories = List.of(
            new CategoryCountDto(10L, "AOP", "AOP", 2L),
            new CategoryCountDto(20L, "JPA", "JPA & Spring Data", 1L)
        );
        given(categoryRepository.findAllWithCardCountForKinds(kindIds)).willReturn(categories);

        mockMvc.perform(get("/cards/categories")
                .param("kind_ids", "1", "2")
                .accept(MediaType.APPLICATION_JSON))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON))
            .andExpect(jsonPath("$.length()").value(2))
            .andExpect(jsonPath("$[0].id").value(10))
            .andExpect(jsonPath("$[0].code").value("AOP"))
            .andExpect(jsonPath("$[0].name").value("AOP"))
            .andExpect(jsonPath("$[0].cardCount").value(2));

        verify(categoryRepository).findAllWithCardCountForKinds(kindIds);
    }

    @Test
    void retrieveCards_should_return_a_page_of_cards_with_metadata() throws Exception {
        Card card = newCard();

        given(cardRepository.findAll(ArgumentMatchers.<Specification<Card>>any(), ArgumentMatchers.any(Pageable.class)))
            .willReturn(new PageImpl<>(List.of(card), Pageable.ofSize(24), 1));

        mockMvc.perform(get("/cards")
                .param("kind_ids", "1")
                .param("category_ids", "10")
                .accept(MediaType.APPLICATION_JSON))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON))
            .andExpect(jsonPath("$.page").value(0))
            .andExpect(jsonPath("$.size").value(24))
            .andExpect(jsonPath("$.totalElements").value(1))
            .andExpect(jsonPath("$.totalPages").value(1))
            .andExpect(jsonPath("$.last").value(true))
            .andExpect(jsonPath("$.content.length()").value(1))
            .andExpect(jsonPath("$.content[0].id").value(100))
            .andExpect(jsonPath("$.content[0].name").value("Card A"))
            .andExpect(jsonPath("$.content[0].kind.name").value("Annotation"))
            .andExpect(jsonPath("$.content[0].category.code").value("AOP"))
            .andExpect(jsonPath("$.content[0].description").value("Desc A"))
            .andExpect(jsonPath("$.content[0].facts[0].text").value("Fact text"))
            .andExpect(jsonPath("$.content[0].facts[0].important").value(true))
            .andExpect(jsonPath("$.content[0].relatedCards[0].name").value("Card B"))
            .andExpect(jsonPath("$.content[0].sourceUrl").value("http://a"));

        ArgumentCaptor<Pageable> pageable = ArgumentCaptor.forClass(Pageable.class);
        verify(cardRepository).findAll(ArgumentMatchers.<Specification<Card>>any(), pageable.capture());
        assertThat(pageable.getValue().getPageNumber()).isZero();
        assertThat(pageable.getValue().getPageSize()).isEqualTo(24);
        assertThat(pageable.getValue().getSort()).isEqualTo(Sort.by(Sort.Direction.ASC, "name"));
    }

    @Test
    void retrieveCards_should_pass_requested_page_and_size_to_the_repository() throws Exception {
        given(cardRepository.findAll(ArgumentMatchers.<Specification<Card>>any(), ArgumentMatchers.any(Pageable.class)))
            .willReturn(new PageImpl<>(List.of(), PageRequest.of(2, 5), 42));

        mockMvc.perform(get("/cards")
                .param("page", "2")
                .param("size", "5")
                .accept(MediaType.APPLICATION_JSON))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.page").value(2))
            .andExpect(jsonPath("$.size").value(5))
            .andExpect(jsonPath("$.totalElements").value(42))
            .andExpect(jsonPath("$.totalPages").value(9))
            .andExpect(jsonPath("$.last").value(false))
            .andExpect(jsonPath("$.content.length()").value(0));

        ArgumentCaptor<Pageable> pageable = ArgumentCaptor.forClass(Pageable.class);
        verify(cardRepository).findAll(ArgumentMatchers.<Specification<Card>>any(), pageable.capture());
        assertThat(pageable.getValue().getPageNumber()).isEqualTo(2);
        assertThat(pageable.getValue().getPageSize()).isEqualTo(5);
    }

    @Test
    void retrieveCard_should_return_a_single_card_or_404() throws Exception {
        given(cardRepository.findById(100L)).willReturn(Optional.of(newCard()));
        given(cardRepository.findById(999L)).willReturn(Optional.empty());

        mockMvc.perform(get("/cards/100").accept(MediaType.APPLICATION_JSON))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.id").value(100))
            .andExpect(jsonPath("$.name").value("Card A"));

        mockMvc.perform(get("/cards/999").accept(MediaType.APPLICATION_JSON))
            .andExpect(status().isNotFound());
    }

    @Test
    void retrieveCardNames_should_return_the_lightweight_index() throws Exception {
        given(cardRepository.findAllCardNames()).willReturn(List.of(new CardNameDto(100L, "Card A")));

        mockMvc.perform(get("/cards/names").accept(MediaType.APPLICATION_JSON))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.length()").value(1))
            .andExpect(jsonPath("$[0].id").value(100))
            .andExpect(jsonPath("$[0].name").value("Card A"));

        verify(cardRepository).findAllCardNames();
    }

    private static Card newCard() {
        Kind kind = newKind(1L, "Annotation", "ann");
        Category category = newCategory(10L, "AOP", "AOP");
        Card related = newCardShell(101L, "Card B");
        Card card = new Card("Card A", kind, category, "Desc A");
        ReflectionTestUtils.setField(card, "id", 100L);
        card.setExampleCode("code A");
        card.setSourceUrl("http://a");
        card.setFacts(List.of(new CardFact("Fact text", true)));
        card.setInfoTables(List.of());
        card.setRelatedCards(List.of(related));
        return card;
    }

    private static Kind newKind(Long id, String name, String hint) {
        try {
            var ctor = Kind.class.getDeclaredConstructor();
            ctor.setAccessible(true);
            Kind kind = ctor.newInstance();
            ReflectionTestUtils.setField(kind, "id", id);
            ReflectionTestUtils.setField(kind, "name", name);
            ReflectionTestUtils.setField(kind, "hint", hint);
            return kind;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private static Category newCategory(Long id, String code, String name) {
        try {
            var ctor = Category.class.getDeclaredConstructor();
            ctor.setAccessible(true);
            Category category = ctor.newInstance();
            ReflectionTestUtils.setField(category, "id", id);
            ReflectionTestUtils.setField(category, "code", code);
            ReflectionTestUtils.setField(category, "name", name);
            return category;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private static Card newCardShell(Long id, String name) {
        try {
            var ctor = Card.class.getDeclaredConstructor();
            ctor.setAccessible(true);
            Card card = ctor.newInstance();
            ReflectionTestUtils.setField(card, "id", id);
            ReflectionTestUtils.setField(card, "name", name);
            return card;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
