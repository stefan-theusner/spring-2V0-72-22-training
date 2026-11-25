package eu.meiyu.training.feature.department.entity;

import jakarta.persistence.*;

import java.util.Objects;

@Entity
public class Department {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long departmentId;

    @Column(nullable = false, unique = true)
    private String departmentCode;

    @Column(nullable = false)
    private String departmentName;

    @Column(nullable = false)
    private String departmentAddress;

    public Department() {}

    public Department(String departmentCode, String departmentName, String departmentAddress) {
        this.departmentCode = departmentCode;
        this.departmentName = departmentName;
        this.departmentAddress = departmentAddress;
    }

    public Long getDepartmentId() {
        return departmentId;
    }

    public void setDepartmentId(Long departmentId) {
        this.departmentId = departmentId;
    }

    public String getDepartmentCode() {
        return departmentCode;
    }

    public void setDepartmentCode(String departmentCode) {
        this.departmentCode = departmentCode;
    }

    public String getDepartmentName() {
        return departmentName;
    }

    public void setDepartmentName(String departmentName) {
        this.departmentName = departmentName;
    }

    public String getDepartmentAddress() {
        return departmentAddress;
    }

    public void setDepartmentAddress(String departmentAddress) {
        this.departmentAddress = departmentAddress;
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof Department that)) return false;
        return Objects.equals(departmentId, that.departmentId) && Objects.equals(departmentCode, that.departmentCode);
    }

    @Override
    public int hashCode() {
        return Objects.hash(departmentId, departmentCode);
    }
}
