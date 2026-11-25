package eu.meiyu.training.feature.department.repository;

import eu.meiyu.training.feature.department.entity.Department;
import org.springframework.data.domain.Example;
import org.springframework.data.domain.ExampleMatcher;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Optional;

@Repository
public interface DepartmentRepository extends JpaRepository<Department, Long>, JpaSpecificationExecutor<Department> {

    record DepartmentFilter(String name, String code, String address) {
        public DepartmentFilter {
            name = StringUtils.hasText(name) ? name : null;
            code = StringUtils.hasText(code) ? code : null;
            address = StringUtils.hasText(address) ? address : null;
        }
        public boolean isEmpty() {
            return ObjectUtils.isEmpty(name) && ObjectUtils.isEmpty(code) && ObjectUtils.isEmpty(address);
        }
    }

    Optional<Department> findByDepartmentCode(String departmentCode);

    private static String blankToNull(String s) {
        return StringUtils.hasText(s) ? s : null;
    }

    // JQL, same result as ExampleMatcher
    // 3rd. option would be creating a specification
//    @Query("SELECT d FROM Department d WHERE " +
//        "(:#{#filter.name} IS NULL OR :#{#filter.name} = '' OR lower(d.departmentName) = lower(:#{#filter.name})) AND " +
//        "(:#{#filter.code} IS NULL OR :#{#filter.code} = '' OR lower(d.departmentCode) = lower(:#{#filter.code})) AND " +
//        "(:#{#filter.address} IS NULL OR :#{#filter.address} = '' OR " +
//        "LOWER(d.departmentAddress) LIKE LOWER(CONCAT('%', :#{#filter.address}, '%')))")
    default List<Department> searchDepartments(@Param("filter") DepartmentFilter filter) {
        var probe = new Department(filter.code, filter.name, filter.address);
        var matcher = ExampleMatcher.matching()
            .withIgnoreNullValues()
            .withIgnoreCase()
            .withMatcher("departmentAddress", ExampleMatcher.GenericPropertyMatcher::contains);
        return findAll(Example.of(probe, matcher));
    }

}
