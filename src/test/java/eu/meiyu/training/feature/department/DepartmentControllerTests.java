package eu.meiyu.training.feature.department;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;

import eu.meiyu.training.WithoutOAuth2Application;
import eu.meiyu.training.feature.department.entity.Department;
import eu.meiyu.training.feature.department.repository.DepartmentRepository;

import java.lang.reflect.RecordComponent;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import tools.jackson.databind.ObjectMapper;

@SpringBootTest(
    classes= WithoutOAuth2Application.class, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT
)
@AutoConfigureMockMvc(addFilters = false)
public class DepartmentControllerTests {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private DepartmentRepository departmentRepository;

    private MultiValueMap<String, String> recordToParams(Record record) {
        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        if (record == null) return params;
        for (RecordComponent component : record.getClass().getRecordComponents()) {
            try {
                Object value = component.getAccessor().invoke(record);
                if (value != null) {
                    params.add(component.getName(), value.toString());
                }
            } catch (Exception e) {
                throw new RuntimeException("Error reading records", e);
            }
        }
        return params;
    }

    @Test
    void saveDepartment_should_return_created_department() throws Exception{
        Department testDepartment = new Department("ETC-02", "ETC", "Department Address");
        given(departmentRepository.save(any(Department.class))).willReturn(testDepartment);

        mockMvc.perform(post("/departments").contentType(MediaType.APPLICATION_JSON)
                        .content(asJsonString(testDepartment)).accept(MediaType.APPLICATION_JSON))
                        .andExpect(status().isOk());
    }

    @Test
    void searchDepartments_should_return_list_of_departments() throws Exception {
        List<Department> testDepartments = List.of(
            new Department("ETC-03", "ETC", "Department Address"),
            new Department("ETC-02", "ETC", "Department Address Similar")
        );
        DepartmentRepository.DepartmentFilter filter = new DepartmentRepository.DepartmentFilter(null, null, "Similar");

        given(departmentRepository.searchDepartments(filter)).willReturn(testDepartments);

        mockMvc.perform(
                get("/departments")
                .params(recordToParams(filter))
            )
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.length()").value(2))
            .andExpect(jsonPath("$[1].departmentCode").value("ETC-02"));

        verify(departmentRepository).searchDepartments(filter);
        verify(departmentRepository, never()).findAll();
    }

    @Test
    void getDepartment_should_return_department() throws Exception{
        Department testDepartment = new Department("ETC-02", "ETC", "Department Address");
        testDepartment.setDepartmentId(0L);
        given(departmentRepository.findById(0L)).willReturn(Optional.of(testDepartment));
        mockMvc.perform(get("/departments/{departmentId}", 0L))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("departmentId").value(0L))
                .andExpect(jsonPath("departmentCode").value("ETC-02"))
                .andExpect(jsonPath("departmentName").value("ETC"));
    }

    protected static String asJsonString(final Object obj) {
        try {
            final ObjectMapper mapper = new ObjectMapper();
            return mapper.writeValueAsString(obj);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }



}
