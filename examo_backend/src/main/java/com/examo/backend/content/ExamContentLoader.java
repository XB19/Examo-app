package com.examo.backend.content;

import java.io.IOException;
import java.io.InputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.HexFormat;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.examo.backend.exam.Exam;
import com.examo.backend.exam.ExamRepository;

import tools.jackson.databind.DeserializationFeature;
import tools.jackson.databind.json.JsonMapper;

/**
 * Synchronise au démarrage les épreuves retranscrites (resources/exams/**.json) avec la base.
 * Le démarrage échoue si un fichier est invalide : on ne publie jamais une épreuve cassée.
 */
@Component
@Order(0)
public class ExamContentLoader implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(ExamContentLoader.class);
    private static final String LOCATION = "classpath*:exams/**/*.json";

    private final ExamRepository repository;
    private final JsonMapper strictMapper;
    private final JsonMapper mapper;

    public ExamContentLoader(ExamRepository repository, JsonMapper mapper) {
        this.repository = repository;
        this.mapper = mapper;
        this.strictMapper = mapper.rebuild().enable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES).build();
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) throws IOException {
        Resource[] resources = new PathMatchingResourcePatternResolver().getResources(LOCATION);
        List<String> problems = new ArrayList<>();
        int updated = 0;
        for (Resource resource : resources) {
            String name = resource.getFilename();
            byte[] raw;
            try (InputStream in = resource.getInputStream()) {
                raw = in.readAllBytes();
            }
            ExamContent content;
            try {
                content = strictMapper.readValue(raw, ExamContent.class);
            } catch (RuntimeException e) {
                problems.add(name + " : JSON illisible (" + e.getMessage() + ")");
                continue;
            }
            List<String> errors = ExamContentValidator.validate(content);
            if (!errors.isEmpty()) {
                errors.forEach(err -> problems.add(name + " : " + err));
                continue;
            }
            Exam exam = repository.findByLevelAndSessionYearAndSessionMonthAndSubjectCode(
                    content.level(), (short) content.year(), content.month(), content.subject()).orElse(null);
            if (exam == null) {
                problems.add(name + " : aucune épreuve " + content.level() + " " + content.year() + " "
                        + content.month() + " " + content.subject() + " dans le catalogue");
                continue;
            }
            String hash = sha256(raw);
            if (!hash.equals(exam.getContentHash())) {
                exam.updateContent(mapper.writeValueAsString(content), hash, content.durationMinutes(),
                        content.totalPoints(), content.questions().size());
                updated++;
            }
        }
        if (!problems.isEmpty()) {
            throw new IllegalStateException("Épreuves invalides :\n - " + String.join("\n - ", problems));
        }
        log.info("{} épreuve(s) interactive(s) chargée(s), {} mise(s) à jour.", resources.length, updated);
    }

    public ExamContent parse(Exam exam) {
        return mapper.readValue(exam.getContent(), ExamContent.class);
    }

    private static String sha256(byte[] data) {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(data));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }
}
