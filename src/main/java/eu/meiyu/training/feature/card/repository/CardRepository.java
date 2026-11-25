package eu.meiyu.training.feature.card.repository;

import eu.meiyu.training.feature.card.dto.CardNameDto;
import eu.meiyu.training.feature.card.entity.Card;
import org.jspecify.annotations.NullMarked;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CardRepository extends JpaRepository<Card, Long>, JpaSpecificationExecutor<Card> {

    // The two to-one associations are always needed by CardDto; fetch them with the page
    // instead of issuing one extra query per card. Collections are batch fetched on the entity.
    @Override
    @EntityGraph(attributePaths = {"kind", "category"})
    @NullMarked
    Page<Card> findAll(Specification<Card> spec, Pageable pageable);

    @Query("""
        select new eu.meiyu.training.feature.card.dto.CardNameDto(c.id, c.name)
        from Card c
        order by c.name
        """)
    List<CardNameDto> findAllCardNames();
}
