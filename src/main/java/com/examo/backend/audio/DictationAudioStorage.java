package com.examo.backend.audio;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

import org.springframework.stereotype.Component;

import com.examo.backend.config.ExamoProperties;

/**
 * Audio de dictée généré par ElevenLabs, une phrase à la fois : storage/audio/<examId>/<index>.mp3
 * Contenu fixe (le texte d'une épreuve ne change pas) : généré une seule fois, puis servi depuis le cache.
 */
@Component
public class DictationAudioStorage {

    private final Path root;

    public DictationAudioStorage(ExamoProperties props) {
        this.root = props.storageDir().toAbsolutePath().normalize().resolve("audio");
    }

    public byte[] load(long examId, int index) throws IOException {
        Path file = path(examId, index);
        return Files.exists(file) ? Files.readAllBytes(file) : null;
    }

    public void save(long examId, int index, byte[] audio) throws IOException {
        Path file = path(examId, index);
        Files.createDirectories(file.getParent());
        Files.write(file, audio);
    }

    private Path path(long examId, int index) {
        return root.resolve(String.valueOf(examId)).resolve(index + ".mp3");
    }
}
