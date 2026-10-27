package com.examo.backend.grading;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import org.springframework.http.CacheControl;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.server.ResponseStatusException;

import com.examo.backend.content.ExamContentLoader;
import com.examo.backend.exam.Exam;
import com.examo.backend.exam.ExamRepository;

import tools.jackson.core.JacksonException;
import tools.jackson.databind.json.JsonMapper;

@RestController
public class SubmissionController {

    private static final String PHOTO_PREFIX = "photo_";
    private static final long MAX_PHOTO_BYTES = 5L * 1024 * 1024;

    private final ExamRepository exams;
    private final ExamContentLoader contentLoader;
    private final GradingService grading;
    private final SubmissionRepository submissions;
    private final PhotoStorage photoStorage;
    private final JsonMapper mapper;

    public SubmissionController(ExamRepository exams, ExamContentLoader contentLoader, GradingService grading,
            SubmissionRepository submissions, PhotoStorage photoStorage, JsonMapper mapper) {
        this.exams = exams;
        this.contentLoader = contentLoader;
        this.grading = grading;
        this.submissions = submissions;
        this.photoStorage = photoStorage;
        this.mapper = mapper;
    }

    @PostMapping(path = "/api/exams/{id}/submissions", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public GradingResult submit(@PathVariable long id, @RequestPart("answers") String answersJson,
            MultipartHttpServletRequest multipart) throws IOException {
        Exam exam = exams.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Épreuve introuvable"));
        if (!exam.isInteractive()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Cette épreuve n'est pas disponible en mode questions");
        }
        SubmissionRequest request;
        try {
            request = mapper.readValue(answersJson, SubmissionRequest.class);
        } catch (JacksonException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Réponses illisibles");
        }

        Map<String, byte[]> photos = new HashMap<>();
        for (Map.Entry<String, MultipartFile> part : multipart.getFileMap().entrySet()) {
            if (!part.getKey().startsWith(PHOTO_PREFIX)) {
                continue;
            }
            MultipartFile file = part.getValue();
            if (file.getSize() > MAX_PHOTO_BYTES) {
                throw new ResponseStatusException(HttpStatus.PAYLOAD_TOO_LARGE, "Photo trop lourde (5 Mo maximum)");
            }
            byte[] bytes = file.getBytes();
            if (PhotoStorage.mediaType(bytes) == null) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La photo doit être une image JPEG, PNG ou WebP");
            }
            photos.put(part.getKey().substring(PHOTO_PREFIX.length()), bytes);
        }
        return grading.grade(exam, contentLoader.parse(exam), request, photos);
    }

    @GetMapping("/api/submissions/{id}")
    public GradingResult get(@PathVariable UUID id) {
        Submission submission = submissions.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Copie introuvable"));
        return mapper.readValue(submission.getResult(), GradingResult.class);
    }

    @GetMapping("/api/submissions/{id}/photos/{questionId}")
    public ResponseEntity<byte[]> photo(@PathVariable UUID id, @PathVariable String questionId) throws IOException {
        byte[] image;
        try {
            image = photoStorage.load(id, questionId);
        } catch (IllegalArgumentException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, e.getMessage());
        }
        if (image == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Photo introuvable");
        }
        return ResponseEntity.ok()
                .cacheControl(CacheControl.maxAge(30, TimeUnit.DAYS).cachePrivate())
                .contentType(MediaType.parseMediaType(PhotoStorage.mediaType(image)))
                .body(image);
    }
}
