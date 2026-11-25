package eu.meiyu.training.feature.card.repository;

import eu.meiyu.training.feature.card.dto.CategoryCountDto;
import eu.meiyu.training.feature.card.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

public interface CategoryRepository extends JpaRepository<Category, Long>, JpaSpecificationExecutor<Category> {

    // Left join so categories without cards are returned with a count of 0
    @Query("""
        select new eu.meiyu.training.feature.card.dto.CategoryCountDto(cat.id, cat.code, cat.name, count(c))
        from Category cat left join Card c on c.category = cat
        group by cat.id, cat.code, cat.name
        order by cat.id
        """)
    List<CategoryCountDto> findAllWithCardCount();

    // Only cards of the given kinds are counted. The filter sits in the join so categories
    // without matching cards still come back with 0. kindIds must not be empty (IN () is invalid SQL).
    @Query("""
        select new eu.meiyu.training.feature.card.dto.CategoryCountDto(cat.id, cat.code, cat.name, count(c))
        from Category cat left join Card c on c.category = cat and c.kind.id in :kindIds
        group by cat.id, cat.code, cat.name
        order by cat.id
        """)
    List<CategoryCountDto> findAllWithCardCountForKinds(@Param("kindIds") Collection<Long> kindIds);
}
