package com.examo.backend.exam;

import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import com.examo.backend.config.ExamoProperties;

import jakarta.annotation.PreDestroy;

/**
 * Télécharge en arrière-plan les sujets officiels qui ne sont pas encore stockés localement,
 * pour que le serveur démarre tout de suite et que l'import reprenne là où il s'est arrêté.
 */
@Component
public class ExamImporter implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(ExamImporter.class);

    private final ExamRepository repository;
    private final ExamStorage storage;
    private final ExamoProperties props;
    private final ExecutorService executor = Executors.newSingleThreadExecutor(r -> {
        Thread t = new Thread(r, "exam-importer");
        t.setDaemon(true);
        return t;
    });

    public ExamImporter(ExamRepository repository, ExamStorage storage, ExamoProperties props) {
        this.repository = repository;
        this.storage = storage;
        this.props = props;
    }

    @Override
    public void run(ApplicationArguments args) {
        if (props.importOnStartup()) {
            executor.submit(this::importMissing);
        }
    }

    void importMissing() {
        List<Exam> missing = repository.findByFilePathIsNull();
        if (missing.isEmpty()) {
            return;
        }
        log.info("Import de {} sujet(s) depuis ecole.gouv.tg…", missing.size());
        int ok = 0;
        for (Exam exam : missing) {
            try {
                String path = storage.download(exam);
                exam.markImported(path, storage.countPages(path));
                repository.save(exam);
                ok++;
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return;
            } catch (Exception e) {
                log.warn("Échec de l'import {} {} {} : {}", exam.getLevel(), exam.getSessionYear(),
                        exam.getSubjectName(), e.getMessage());
            }
        }
        log.info("Import terminé : {}/{} sujet(s) importé(s).", ok, missing.size());
    }

    @PreDestroy
    void shutdown() {
        executor.shutdownNow();
    }
}
