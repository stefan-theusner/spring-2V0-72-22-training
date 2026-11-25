package eu.meiyu.training.feature.about;

import eu.meiyu.training.WithoutOAuth2Application;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.info.BuildProperties;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(classes = WithoutOAuth2Application.class, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc(addFilters = false)
class AboutControllerTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private BuildProperties buildProperties;

    @Test
    void about_should_return_version_and_build_time() throws Exception {
        mockMvc.perform(get("/about").accept(MediaType.APPLICATION_JSON))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON))
            .andExpect(jsonPath("$.version").value(buildProperties.getVersion()))
            .andExpect(jsonPath("$.buildTime").value(buildProperties.getTime().toString()));
    }
}
