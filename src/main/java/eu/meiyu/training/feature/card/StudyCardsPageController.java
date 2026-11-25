package eu.meiyu.training.feature.card;

import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class StudyCardsPageController {

    private static final Resource STUDY_CARDS_PAGE =
        new ClassPathResource("static/Spring 2V0-72.22 Study Cards.html");

    @GetMapping({"/training", "/training/"})
    public ResponseEntity<Resource> studyCardsPage() {
        return ResponseEntity.ok()
            .contentType(MediaType.TEXT_HTML)
            .body(STUDY_CARDS_PAGE);
    }
}
