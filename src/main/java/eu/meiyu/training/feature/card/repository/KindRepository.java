package eu.meiyu.training.feature.card.repository;

import eu.meiyu.training.feature.card.dto.KindCountDto;
import eu.meiyu.training.feature.card.entity.Kind;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface KindRepository extends JpaRepository<Kind, Long>, JpaSpecificationExecutor<Kind> {

    // Left join so kinds without cards are returned with a count of 0
    @Query("""
        select new eu.meiyu.training.feature.card.dto.KindCountDto(k.id, k.name, k.hint, count(c))
        from Kind k left join Card c on c.kind = k
        group by k.id, k.name, k.hint
        order by k.id
        """)
    List<KindCountDto> findAllWithCardCount();
}
