package eu.meiyu.training.feature.card.dto;

import org.springframework.data.domain.Page;

import java.util.List;

/**
 * Stable API representation of a page of cards. The Spring Data {@link Page} is kept
 * inside the service layer so Jackson internals do not leak into the HTTP contract.
 */
public record CardPageDto(
    List<CardDto> content,
    int page,
    int size,
    long totalElements,
    int totalPages,
    boolean last
) {

    public static CardPageDto from(Page<CardDto> page) {
        return new CardPageDto(
            page.getContent(),
            page.getNumber(),
            page.getSize(),
            page.getTotalElements(),
            page.getTotalPages(),
            page.isLast()
        );
    }
}
