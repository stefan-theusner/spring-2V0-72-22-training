package eu.meiyu.training.feature.card.dto;

import eu.meiyu.training.feature.card.entity.Card;
import eu.meiyu.training.feature.card.entity.CardInfoTable;

import java.util.List;

public record CardDto(
    Long id,
    String name,
    KindDto kind,
    CategoryDto category,
    String description,
    List<FactDto> facts,
    String exampleCode,
    List<CardInfoTable> infoTables,
    List<RelatedCardDto> relatedCards,
    String sourceUrl
) {

    public record KindDto(Long id, String name) {}

    public record CategoryDto(Long id, String code, String name) {}

    public record FactDto(String text, boolean important) {}

    public record RelatedCardDto(Long id, String name) {}

    // Must be called inside a transaction: it touches the lazy associations of the card
    public static CardDto from(Card card) {
        return new CardDto(
            card.getId(),
            card.getName(),
            new KindDto(card.getKind().getId(), card.getKind().getName()),
            new CategoryDto(card.getCategory().getId(), card.getCategory().getCode(), card.getCategory().getName()),
            card.getDescription(),
            card.getFacts().stream().map(f -> new FactDto(f.getText(), f.isImportant())).toList(),
            card.getExampleCode(),
            card.getInfoTables() == null ? List.of() : List.copyOf(card.getInfoTables()),
            card.getRelatedCards().stream().map(r -> new RelatedCardDto(r.getId(), r.getName())).toList(),
            card.getSourceUrl()
        );
    }
}
