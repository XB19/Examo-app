package com.examo.backend.exam;

import java.io.IOException;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import com.examo.backend.content.ExamContentLoader;
import com.examo.backend.content.StudentExamView;

@RestController
@RequestMapping("/api/exams")
public class ExamController {

    // Un sujet officiel ne change jamais : le téléphone peut garder les fichiers longtemps (utile hors connexion).
    private static final CacheControl IMMUTABLE = CacheControl.maxAge(30, TimeUnit.DAYS).cachePublic();

    private final ExamRepository repository;
    private final ExamStorage storage;
    private final ExamContentLoader contentLoader;

    public ExamController(ExamRepository repository, ExamStorage storage, ExamContentLoader contentLoader) {
        this.repository = repository;
        this.storage = storage;
        this.contentLoader = contentLoader;
    }

    @GetMapping
    public List<ExamDto> list(@RequestParam(defaultValue = "CEPD") String level,
                              @RequestParam(required = false) Short year,
                              @RequestParam(required = false) String subject) {
        String subjectCode = subject == null || subject.isBlank() ? null : subject.toUpperCase(Locale.ROOT);
        return repository.search(level.toUpperCase(Locale.ROOT), year, subjectCode).stream()
                .map(ExamDto::from)
                .toList();
    }

    @GetMapping("/{id}")
    public ExamDto get(@PathVariable long id) {
        return ExamDto.from(find(id));
    }

    @GetMapping("/{id}/content")
    public StudentExamView content(@PathVariable long id) {
        Exam exam = find(id);
        if (!exam.isInteractive()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Cette épreuve n'est pas encore disponible en mode questions");
        }
        return StudentExamView.of(exam, contentLoader.parse(exam));
    }

    @GetMapping("/{id}/pdf")
    public ResponseEntity<Resource> pdf(@PathVariable long id) {
        Exam exam = findAvailable(id);
        return ResponseEntity.ok()
                .cacheControl(IMMUTABLE)
                .contentType(MediaType.APPLICATION_PDF)
                .body(new FileSystemResource(storage.pdf(exam)));
    }

    @GetMapping("/{id}/pages/{page}")
    public ResponseEntity<Resource> page(@PathVariable long id, @PathVariable int page) throws IOException {
        Exam exam = findAvailable(id);
        if (page < 1 || page > exam.getPageCount()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Page inexistante");
        }
        return ResponseEntity.ok()
                .cacheControl(IMMUTABLE)
                .contentType(MediaType.IMAGE_PNG)
                .body(new FileSystemResource(storage.pageImage(exam, page)));
    }

    private Exam find(long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Épreuve introuvable"));
    }

    private Exam findAvailable(long id) {
        Exam exam = find(id);
        if (!exam.isAvailable()) {
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "Sujet en cours d'import, réessaie dans un instant");
        }
        return exam;
    }
}
