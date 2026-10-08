package com.examo.backend.grading;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.UUID;
import java.util.regex.Pattern;

import org.springframework.stereotype.Component;

import com.examo.backend.config.ExamoProperties;

/** Photos des copies (dessins, schémas, dictées) : storage/submissions/<id>/<question>.jpg */
@Component
public class PhotoStorage {

    private static final Pattern SAFE_ID = Pattern.compile("[A-Za-z0-9_-]{1,40}");

    private final Path root;

    public PhotoStorage(ExamoProperties props) {
        this.root = props.storageDir().toAbsolutePath().normalize().resolve("submissions");
    }

    public void save(UUID submissionId, String questionId, byte[] image) throws IOException {
        Path file = path(submissionId, questionId);
        Files.createDirectories(file.getParent());
        Files.write(file, image);
    }

    public byte[] load(UUID submissionId, String questionId) throws IOException {
        Path file = path(submissionId, questionId);
        return Files.exists(file) ? Files.readAllBytes(file) : null;
    }

    private Path path(UUID submissionId, String questionId) {
        if (!SAFE_ID.matcher(questionId).matches()) {
            throw new IllegalArgumentException("Identifiant de question invalide");
        }
        return root.resolve(submissionId.toString()).resolve(questionId + ".jpg");
    }

    public static String mediaType(byte[] image) {
        if (image.length > 3 && (image[0] & 0xFF) == 0x89 && image[1] == 'P' && image[2] == 'N' && image[3] == 'G') {
            return "image/png";
        }
        if (image.length > 2 && (image[0] & 0xFF) == 0xFF && (image[1] & 0xFF) == 0xD8) {
            return "image/jpeg";
        }
        if (image.length > 11 && image[8] == 'W' && image[9] == 'E' && image[10] == 'B' && image[11] == 'P') {
            return "image/webp";
        }
        return null;
    }
}
