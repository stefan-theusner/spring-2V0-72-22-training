package eu.meiyu.training.feature.card;

import eu.meiyu.training.feature.card.dto.CardDto;
import eu.meiyu.training.feature.card.dto.CardNameDto;
import eu.meiyu.training.feature.card.dto.CardPageDto;
import eu.meiyu.training.feature.card.dto.CategoryCountDto;
import eu.meiyu.training.feature.card.dto.KindCountDto;
import eu.meiyu.training.feature.card.service.CardService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/cards")
public class CardController {

    private final CardService cardService;

    @Autowired
    protected CardController(CardService cardService) {
        this.cardService = cardService;
    }

    @GetMapping
    public ResponseEntity<CardPageDto> retrieveCards(
        @RequestParam(name = "kind_ids", required = false, defaultValue = "") List<Long> kindIds,
        @RequestParam(name = "category_ids", required = false, defaultValue = "") List<Long> categoryIds,
        @PageableDefault(size = 24, sort = "name", direction = Sort.Direction.ASC) Pageable pageable
    ) {
        return ResponseEntity.ok(CardPageDto.from(cardService.getCards(kindIds, categoryIds, pageable)));
    }

    @GetMapping("/categories")
    public ResponseEntity<List<CategoryCountDto>> retrieveCategories(
        @RequestParam(name = "kind_ids", required = false, defaultValue = "") List<Long> kindIds
    ) {
        return ResponseEntity.ok(cardService.getAllCategories(kindIds));
    }

    @GetMapping("/kinds")
    public ResponseEntity<List<KindCountDto>> retrieveKinds() {
        return ResponseEntity.ok(cardService.getAllKinds());
    }

    // Small id/name index so the UI can resolve links without downloading every card.
    @GetMapping("/names")
    public ResponseEntity<List<CardNameDto>> retrieveCardNames() {
        return ResponseEntity.ok(cardService.getAllCardNames());
    }

    // Used only when the user follows a link to a card that has not been paged in yet.
    @GetMapping("/{id}")
    public ResponseEntity<CardDto> retrieveCard(@PathVariable Long id) {
        return cardService.getCardById(id)
            .map(ResponseEntity::ok)
            .orElseGet(() -> ResponseEntity.notFound().build());
    }

}
