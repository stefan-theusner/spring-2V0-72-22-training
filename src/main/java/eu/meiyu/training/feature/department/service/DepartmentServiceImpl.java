package eu.meiyu.training.feature.department.service;

import eu.meiyu.training.aop.annotation.MetricType;
import eu.meiyu.training.aop.annotation.TrackMetricService;
import eu.meiyu.training.aop.annotation.TrackMetric;
import eu.meiyu.training.aop.annotation.TrackMetrics;
import eu.meiyu.training.feature.department.entity.Department;
import eu.meiyu.training.feature.department.entity.excpetion.DepartmentNotFoundException;
import eu.meiyu.training.feature.department.repository.DepartmentRepository;
import eu.meiyu.training.feature.department.repository.DepartmentSpecifications;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.instrumentation.annotations.SpanAttribute;
import io.opentelemetry.instrumentation.annotations.WithSpan;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Objects;

@Service("departmentService")
@Transactional
@TrackMetricService("department")
public class DepartmentServiceImpl implements DepartmentService {

    private final DepartmentRepository departmentRepository;

    @Autowired
    public DepartmentServiceImpl(DepartmentRepository departmentRepository) {
        this.departmentRepository = departmentRepository;
    }

    @Override
    public List<Department> likeByNameOrAddress(String name, String address) {
        return departmentRepository.findAll(DepartmentSpecifications.likeDepartmentNameOrAddress(name, address));
    }

    @TrackMetric(value="search-results", tag="d", type=MetricType.DISTRIBUTION_SUMMARY, desc="Test Distribution Summary Metric")
    public List<Department> searchDepartments(DepartmentRepository.DepartmentFilter filter) {
        if (filter.isEmpty()) {
            return findAllDepartments();
        }
        return departmentRepository.searchDepartments(filter);
    }

    @Override
    @TrackMetrics({
        @TrackMetric(value="timer", tag = "t", type=MetricType.TIMER, desc="Test Timer Metric"),
        @TrackMetric(value="counter", tag = "c", type=MetricType.COUNTER, desc="Test Counter Metric"),
        @TrackMetric(value="long-task", tag="l", type=MetricType.LONG_TASK_TIMER, desc="Test Long Task Timer Metric"),
    })
    @WithSpan
    public Department saveDepartment(Department department) {
        var saved = departmentRepository.save(department);
        if (!Objects.isNull(saved.getDepartmentId())) {
            Span span = Span.current();
            span.setAttribute("departmentId", saved.getDepartmentId());
        }
        return saved;
    }

    @Override
    public List<Department> findAllDepartments() {
        return departmentRepository.findAll();
    }

    @Override
    @WithSpan
    public void deleteDepartmentById(@SpanAttribute("departmentId") Long departmentId) {
        Department dep = getDepartmentById(departmentId);
        departmentRepository.delete(dep);
    }

    public Department getDepartmentByCode(String code) {
        return departmentRepository.findByDepartmentCode(code).orElseThrow(() -> new DepartmentNotFoundException(code));
    }

    @Override
    @WithSpan
    public Department getDepartmentById(@SpanAttribute("departmentId") Long departmentId) {
        return departmentRepository.findById(departmentId).orElseThrow(() -> new DepartmentNotFoundException(departmentId));
    }

    @Override
    @WithSpan
    public Department updateDepartment(Department department, @SpanAttribute("departmentId") Long id) {
        Department dbDep = getDepartmentById(id);
        if (Objects.nonNull(department.getDepartmentName())) {
            dbDep.setDepartmentName(department.getDepartmentName());
        }
        if (Objects.nonNull(department.getDepartmentCode())) {
            dbDep.setDepartmentCode(department.getDepartmentCode());
        }
        if (Objects.nonNull(department.getDepartmentAddress())) {
            dbDep.setDepartmentAddress(department.getDepartmentAddress());
        }
        return departmentRepository.save(dbDep);
    }

}
