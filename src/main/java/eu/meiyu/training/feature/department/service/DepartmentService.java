package eu.meiyu.training.feature.department.service;

import eu.meiyu.training.feature.department.entity.Department;
import static eu.meiyu.training.feature.department.repository.DepartmentRepository.DepartmentFilter;

import java.util.List;

public interface DepartmentService {
    List<Department> likeByNameOrAddress(String name, String address);
    List<Department> searchDepartments(DepartmentFilter filter);
    Department getDepartmentById(Long id);
    Department saveDepartment(Department department);
    List<Department> findAllDepartments();
    void deleteDepartmentById(Long departmentId);
    Department updateDepartment(Department department, Long id);

}
