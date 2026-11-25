package eu.meiyu.training.feature.department.entity.excpetion;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.NOT_FOUND)
public class DepartmentNotFoundException extends RuntimeException {
    public DepartmentNotFoundException(Long id) {
        super("Department with id " + id + " not found");
    }

    public DepartmentNotFoundException(String code) {
        super("Department with code " + code + " not found");
    }

}
