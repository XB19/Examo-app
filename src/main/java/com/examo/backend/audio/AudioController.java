package com.examo.backend.audio;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.regex.Pattern;

import org.springframework.http.CacheControl;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import com.examo.backend.content.ExamContent;
import com.examo.backend.content.ExamContent.Passage;
import com.examo.backend.content.ExamContent.PassageKind;
import com.examo.backend.content.ExamContent.Question;
import com.examo.backend.content.ExamContentLoader;
import com.examo.backend.content.StudentExamView;
import com.examo.backend.exam.Exam;
import com.examo.backend.exam.ExamRepository;

/** Lecture à voix haute : le texte d'une dictée, ou l'énoncé de n'importe quelle question. */
@RestController
public class AudioController {

    private static final Pattern SAFE_ID = Pattern.compile("[A-Za-z0-9_-]{1,40}");

    // Contenu fixe (un sujet officiel ne change jamais) : le téléphone peut garder le fichier longtemps.
    private static final CacheControl IMMUTABLE = CacheControl.maxAge(30, TimeUnit.DAYS).cachePublic();

    private final ExamRepository exams;
    private final ExamContentLoader contentLoader;
    private final ElevenLabsService voice;
    private final AudioStorage storage;

    public AudioController(ExamRepository exams, ExamContentLoader contentLoader, ElevenLabsService voice,
            AudioStorage storage) {
        this.exams = exams;
        this.contentLoader = contentLoader;
        this.voice = voice;
        this.storage = storage;
    }

    @GetMapping("/api/voice/status")
    public Map<String, Boolean> status() {
        return Map.of("available", voice.available());
    }

    @GetMapping("/api/exams/{id}/dictation-audio/{index}")
    public ResponseEntity<byte[]> dictationAudio(@PathVariable long id, @PathVariable int index) throws IOException {
        String key = "dictation-" + index;
        byte[] cached = storage.load(id, key);
        if (cached != null) {
            return audioResponse(cached);
        }

        ExamContent content = content(id);
        Passage dictation = content.passages().stream()
                .filter(p -> p.kind() == PassageKind.DICTATION)
                .findFirst()
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Cette épreuve n'a pas de dictée"));
        List<String> sentences = StudentExamView.spokenSentences(dictation);
        if (index < 0 || index >= sentences.size()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Phrase inexistante");
        }

        byte[] audio = voice.synthesize(sentences.get(index));
        storage.save(id, key, audio);
        return audioResponse(audio);
    }

    @GetMapping("/api/exams/{id}/questions/{questionId}/audio")
    public ResponseEntity<byte[]> questionAudio(@PathVariable long id, @PathVariable String questionId) throws IOException {
        if (!SAFE_ID.matcher(questionId).matches()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Identifiant de question invalide");
        }
        String key = "question-" + questionId;
        byte[] cached = storage.load(id, key);
        if (cached != null) {
            return audioResponse(cached);
        }

        Question question = content(id).questions().stream()
                .filter(q -> q.id().equals(questionId))
                .findFirst()
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Question introuvable"));

        byte[] audio = voice.synthesize(question.spokenText());
        storage.save(id, key, audio);
        return audioResponse(audio);
    }

    private ExamContent content(long examId) {
        Exam exam = exams.findById(examId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Épreuve introuvable"));
        return contentLoader.parse(exam);
    }

    private ResponseEntity<byte[]> audioResponse(byte[] audio) {
        return ResponseEntity.ok().cacheControl(IMMUTABLE).contentType(MediaType.valueOf("audio/mpeg")).body(audio);
    }

    @ExceptionHandler(VoiceUnavailableException.class)
    ResponseEntity<Map<String, String>> unavailable(VoiceUnavailableException e) {
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(Map.of("message", e.getMessage()));
    }
}
