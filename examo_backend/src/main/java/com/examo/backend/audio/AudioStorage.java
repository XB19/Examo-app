package com.examo.backend.audio;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

import org.springframework.stereotype.Component;

import com.examo.backend.config.ExamoProperties;

/**
 * Audio généré par ElevenLabs pour un texte fixe d'une épreuve (phrase de
 * dictée ou énoncé de question) : storage/audio/<examId>/<key>.mp3
 * Le contenu d'une épreuve ne change jamais : généré une seule fois par clé,
 * puis servi depuis le cache pour tous les élèves.
 */
@Component
public class AudioStorage {

    private final Path root;

    public AudioStorage(ExamoProperties props) {
        this.root = props.storageDir().toAbsolutePath().normalize().resolve("audio");
    }

    public byte[] load(long examId, String key) throws IOException {
        Path file = path(examId, key);
        return Files.exists(file) ? Files.readAllBytes(file) : null;
    }

    public void save(long examId, String key, byte[] audio) throws IOException {
        Path file = path(examId, key);
        Files.createDirectories(file.getParent());
        Files.write(file, audio);
    }

    private Path path(long examId, String key) {
        return root.resolve(String.valueOf(examId)).resolve(key + ".mp3");
    }
}
