package eu.meiyu.training.feature.card.service;

import eu.meiyu.training.aop.annotation.MetricType;
import eu.meiyu.training.aop.annotation.TrackMetric;
import eu.meiyu.training.aop.annotation.TrackMetricService;
import eu.meiyu.training.aop.annotation.TrackMetrics;
import eu.meiyu.training.feature.card.dto.CardDto;
import eu.meiyu.training.feature.card.dto.CardNameDto;
import eu.meiyu.training.feature.card.dto.CategoryCountDto;
import eu.meiyu.training.feature.card.dto.KindCountDto;
import eu.meiyu.training.feature.card.entity.Card;
import eu.meiyu.training.feature.card.repository.CardRepository;
import eu.meiyu.training.feature.card.repository.CategoryRepository;
import eu.meiyu.training.feature.card.repository.KindRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
@TrackMetricService("card")
public class CardServiceImpl implements CardService {

    private final CardRepository cardRepository;
    private final CategoryRepository categoryRepository;
    private final KindRepository kindRepository;

    @Autowired
    protected CardServiceImpl(CardRepository cardRepository, CategoryRepository categoryRepository, KindRepository kindRepository) {
        this.cardRepository = cardRepository;
        this.categoryRepository = categoryRepository;
        this.kindRepository = kindRepository;
    }

    @Override
    @TrackMetric(value = "timer", tag = "kinds", type = MetricType.TIMER, desc = "Timer Metric")
    public List<KindCountDto> getAllKinds() {
        return kindRepository.findAllWithCardCount();
    }

    @Override
    @TrackMetric(value = "timer", tag = "categories", type = MetricType.TIMER, desc = "Timer Metric")
    public List<CategoryCountDto> getAllCategories(List<Long> kindIds) {
        if (kindIds == null || kindIds.isEmpty()) {
            return categoryRepository.findAllWithCardCount();
        }
        return categoryRepository.findAllWithCardCountForKinds(kindIds);
    }

    @Override
    @TrackMetrics({
        @TrackMetric(value = "timer", tag = "all", type = MetricType.TIMER, desc = "Timer Metric"),
        @TrackMetric(value = "cards-by-kind-cat", tag = "cards", type = MetricType.DISTRIBUTION_SUMMARY, desc = "Distribution Summary Metric")
    })
    public Page<CardDto> getCards(List<Long> kindIds, List<Long> categoryIds, Pageable pageable) {
        return cardRepository.findAll(cardSpec(kindIds, categoryIds), pageable).map(CardDto::from);
    }

    @Override
    @TrackMetric(value = "timer", tag = "by-id", type = MetricType.TIMER, desc = "Timer Metric")
    public Optional<CardDto> getCardById(Long id) {
        return cardRepository.findById(id).map(CardDto::from);
    }

    @Override
    public List<CardNameDto> getAllCardNames() {
        return cardRepository.findAllCardNames();
    }

    private Specification<Card> cardSpec(List<Long> kindIds, List<Long> categoryIds) {
        // Empty list = no filtering on that dimension
        Specification<Card> spec = Specification.unrestricted();
        if (kindIds != null && !kindIds.isEmpty()) {
            spec = spec.and((root, query, cb) -> root.get("kind").get("id").in(kindIds));
        }
        if (categoryIds != null && !categoryIds.isEmpty()) {
            spec = spec.and((root, query, cb) -> root.get("category").get("id").in(categoryIds));
        }
        return spec;
    }
}
