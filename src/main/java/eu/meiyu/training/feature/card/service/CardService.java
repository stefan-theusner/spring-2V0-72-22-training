package eu.meiyu.training.feature.card.service;

import eu.meiyu.training.feature.card.dto.CardDto;
import eu.meiyu.training.feature.card.dto.CardNameDto;
import eu.meiyu.training.feature.card.dto.CategoryCountDto;
import eu.meiyu.training.feature.card.dto.KindCountDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;

public interface CardService {

    // e.g. Annotations, Starters, Properties,
    List<KindCountDto> getAllKinds();

    // e.g. Container & Config, AOP, JPA & Spring Data,....
    // Card count only includes cards of the given kinds; empty list = all kinds
    List<CategoryCountDto> getAllCategories(List<Long> kindIds);

    // Empty list = no filtering on that dimension
    Page<CardDto> getCards(List<Long> kindIds, List<Long> categoryIds, Pageable pageable);

    Optional<CardDto> getCardById(Long id);

    // Id and name of every card; small enough to load once at startup.
    List<CardNameDto> getAllCardNames();

}
