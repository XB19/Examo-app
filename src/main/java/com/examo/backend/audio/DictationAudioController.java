package com.examo.backend.audio;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

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
import com.examo.backend.content.ExamContentLoader;
import com.examo.backend.content.StudentExamView;
import com.examo.backend.exam.Exam;
import com.examo.backend.exam.ExamRepository;

@RestController
public class DictationAudioController {

    // Contenu fixe (un sujet officiel ne change jamais) : le téléphone peut garder le fichier longtemps.
    private static final CacheControl IMMUTABLE = CacheControl.maxAge(30, TimeUnit.DAYS).cachePublic();

    private final ExamRepository exams;
    private final ExamContentLoader contentLoader;
    private final ElevenLabsService voice;
    private final DictationAudioStorage storage;

    public DictationAudioController(ExamRepository exams, ExamContentLoader contentLoader, ElevenLabsService voice,
            DictationAudioStorage storage) {
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
        byte[] cached = storage.load(id, index);
        if (cached != null) {
            return audioResponse(cached);
        }

        Exam exam = exams.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Épreuve introuvable"));
        ExamContent content = contentLoader.parse(exam);
        Passage dictation = content.passages().stream()
                .filter(p -> p.kind() == PassageKind.DICTATION)
                .findFirst()
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Cette épreuve n'a pas de dictée"));
        List<String> sentences = StudentExamView.spokenSentences(dictation);
        if (index < 0 || index >= sentences.size()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Phrase inexistante");
        }

        byte[] audio = voice.synthesize(sentences.get(index));
        storage.save(id, index, audio);
        return audioResponse(audio);
    }

    private ResponseEntity<byte[]> audioResponse(byte[] audio) {
        return ResponseEntity.ok().cacheControl(IMMUTABLE).contentType(MediaType.valueOf("audio/mpeg")).body(audio);
    }

    @ExceptionHandler(VoiceUnavailableException.class)
    ResponseEntity<Map<String, String>> unavailable(VoiceUnavailableException e) {
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(Map.of("message", e.getMessage()));
    }
}
