package eu.meiyu.training.feature.department;

import eu.meiyu.training.feature.department.entity.Department;
import static eu.meiyu.training.feature.department.repository.DepartmentRepository.DepartmentFilter;
import eu.meiyu.training.feature.department.service.DepartmentService;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.time.Duration;
import java.util.List;

@RestController()
@RequestMapping("/departments")
public class DepartmentController {

    private final DepartmentService departmentService;

    @Autowired
    protected DepartmentController(DepartmentService departmentService) {
        this.departmentService = departmentService;
    }

    @GetMapping()
    public ResponseEntity<List<Department>>searchDepartment(@ModelAttribute DepartmentFilter filter) throws Exception {
        if (filter.isEmpty()) {
            return ResponseEntity.ok(departmentService.findAllDepartments());
        }
        return ResponseEntity.ok(departmentService.searchDepartments(filter));
    }

    @PostMapping()
    @ResponseStatus(HttpStatus.CREATED)
    public ResponseEntity<Object> saveDepartment(@RequestBody @Valid Department department) throws Exception {
        try {
            if (department.getDepartmentName().contains("wait")) {
                Thread.sleep(Duration.ofSeconds(5));
            }
            return ResponseEntity.ok(departmentService.saveDepartment(department));
        } catch (RuntimeException e) {
            ProblemDetail pd = ProblemDetail.forStatusAndDetail(HttpStatus.BAD_REQUEST, e.getMessage());
            pd.setTitle("Invalid request");
            return ResponseEntity.of(pd).build();
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<Department> getDepartment(@PathVariable Long id) {
        Department dep = departmentService.getDepartmentById(id);
        return ResponseEntity.ok(dep);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteDepartment(@PathVariable Long id) {
        departmentService.deleteDepartmentById(id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<Department> updateDepartment(@PathVariable Long id, @RequestBody @Valid Department department) {
        try {
            return ResponseEntity.ok(departmentService.updateDepartment(department, id));
        } catch (EntityNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * Return a response with the location of the new resource. It's URL is assumed
     * to be a child of the URL just received.
     */
    private ResponseEntity<Void> entityWithLocation(Object resourceId) {

        // Determines URL of child resource based on the full URL of the given
        // request, appending the path info with the given resource Identifier
        URI location = ServletUriComponentsBuilder.fromCurrentRequestUri().path("/{childId}").buildAndExpand(resourceId)
                .toUri();

        // Return an HttpEntity object - it will be used to build the
        // HttpServletResponse
        return ResponseEntity.created(location).build();
    }

}
