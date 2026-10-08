package com.examo.backend.content;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.junit.jupiter.api.Test;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;

import tools.jackson.databind.DeserializationFeature;
import tools.jackson.databind.json.JsonMapper;

/** Chaque épreuve retranscrite doit être valide, unique et avoir un barème plausible. */
class ExamContentFilesTest {

    private static final JsonMapper MAPPER = JsonMapper.builder()
            .enable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)
            .build();

    @Test
    void everyExamFileIsValid() throws IOException {
        Resource[] files = new PathMatchingResourcePatternResolver().getResources("classpath*:exams/**/*.json");
        assertThat(files).isNotEmpty();

        List<String> problems = new ArrayList<>();
        Set<String> keys = new HashSet<>();
        for (Resource file : files) {
            ExamContent content;
            try (InputStream in = file.getInputStream()) {
                content = MAPPER.readValue(in, ExamContent.class);
            }
            ExamContentValidator.validate(content).forEach(e -> problems.add(file.getFilename() + " : " + e));

            String key = content.level() + "/" + content.year() + "/" + content.month() + "/" + content.subject();
            if (!keys.add(key)) {
                problems.add(file.getFilename() + " : épreuve en double " + key);
            }
            String folder = file.getURL().getPath();
            if (!folder.contains("/" + content.year() + "/")) {
                problems.add(file.getFilename() + " : rangé dans le mauvais dossier d'année");
            }
            BigDecimal total = content.totalPoints();
            if (total.compareTo(BigDecimal.ZERO) <= 0 || total.compareTo(BigDecimal.valueOf(40)) > 0) {
                problems.add(file.getFilename() + " : total de points improbable (" + total + ")");
            }
        }
        assertThat(problems).isEmpty();
    }

    @Test
    void dictationTitleIsReadWithoutItsLabel() {
        assertThat(StudentExamView.spokenTitle("<u>Dictée</u> : Tout le monde travaille.")).isEqualTo("Tout le monde travaille.");
        assertThat(StudentExamView.sentences("Sur la terre, qui ne travaille pas ? Les abeilles fabriquent le miel ; les oiseaux tissent leurs nids."))
                .containsExactly("Sur la terre, qui ne travaille pas ?", "Les abeilles fabriquent le miel ;", "les oiseaux tissent leurs nids.");
    }
}
