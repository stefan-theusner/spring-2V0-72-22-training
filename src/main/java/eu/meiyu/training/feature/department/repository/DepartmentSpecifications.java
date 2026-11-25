package eu.meiyu.training.feature.department.repository;

import eu.meiyu.training.feature.department.entity.Department;
import org.springframework.data.jpa.domain.Specification;
public class DepartmentSpecifications {

    public static Specification<Department> likeDepartmentName(String name) {
        return (root, query, cb) -> cb.like(
            cb.lower(root.get("departmentName")),
            "%" + name.toLowerCase() + "%"
        );
    }

    public static Specification<Department> likeDepartmentAddress(String address) {
        return (root, query, cb) -> cb.like(
            cb.lower(root.get("departmentAddress")),
            "%" + address.toLowerCase() + "%"
        );
    }

    public static Specification<Department> likeDepartmentNameOrAddress(String name, String address) {
        return DepartmentSpecifications.likeDepartmentName(name).or(DepartmentSpecifications.likeDepartmentAddress(address));
    }
}
