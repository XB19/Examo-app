package com.examo.backend.exam;

import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.time.Duration;
import java.util.Locale;

import javax.imageio.ImageIO;

import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.rendering.ImageType;
import org.apache.pdfbox.rendering.PDFRenderer;
import org.springframework.stereotype.Component;

import com.examo.backend.config.ExamoProperties;

@Component
public class ExamStorage {

    // Assez net pour lire un sujet scanné sur téléphone, sans images trop lourdes à télécharger.
    private static final float RENDER_DPI = 150f;

    private final Path root;
    private final HttpClient http = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(20))
            .followRedirects(HttpClient.Redirect.NORMAL)
            .build();

    public ExamStorage(ExamoProperties props) {
        this.root = props.storageDir().toAbsolutePath().normalize();
    }

    /** Télécharge le PDF officiel et renvoie son chemin relatif à la racine de stockage. */
    public String download(Exam exam) throws IOException, InterruptedException {
        String relative = relativePdfPath(exam);
        Path target = root.resolve(relative);
        Files.createDirectories(target.getParent());

        HttpRequest request = HttpRequest.newBuilder(URI.create(exam.getSourceUrl() + "?forcedownload=1"))
                .timeout(Duration.ofMinutes(2))
                .header("User-Agent", "Examo/1.0")
                .build();
        HttpResponse<InputStream> response = http.send(request, HttpResponse.BodyHandlers.ofInputStream());
        if (response.statusCode() != 200) {
            response.body().close();
            throw new IOException("HTTP " + response.statusCode() + " pour " + exam.getSourceUrl());
        }
        Path tmp = Files.createTempFile(target.getParent(), "dl-", ".part");
        try (InputStream in = response.body()) {
            Files.copy(in, tmp, StandardCopyOption.REPLACE_EXISTING);
            Files.move(tmp, target, StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.ATOMIC_MOVE);
        } finally {
            Files.deleteIfExists(tmp);
        }
        return relative;
    }

    public int countPages(String relativePdf) throws IOException {
        try (PDDocument doc = Loader.loadPDF(resolve(relativePdf).toFile())) {
            return doc.getNumberOfPages();
        }
    }

    public Path pdf(Exam exam) {
        return resolve(exam.getFilePath());
    }

    /** Renvoie l'image PNG d'une page (1-indexée), générée une seule fois puis mise en cache. */
    public Path pageImage(Exam exam, int page) throws IOException {
        Path pdf = pdf(exam);
        Path png = pdf.resolveSibling(stripExtension(pdf.getFileName().toString()) + "_p" + page + ".png");
        if (Files.exists(png)) {
            return png;
        }
        synchronized (this) {
            if (Files.exists(png)) {
                return png;
            }
            try (PDDocument doc = Loader.loadPDF(pdf.toFile())) {
                BufferedImage image = new PDFRenderer(doc).renderImageWithDPI(page - 1, RENDER_DPI, ImageType.GRAY);
                Path tmp = Files.createTempFile(png.getParent(), "render-", ".part");
                ImageIO.write(image, "png", tmp.toFile());
                Files.move(tmp, png, StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.ATOMIC_MOVE);
            }
        }
        return png;
    }

    private Path resolve(String relative) {
        Path p = root.resolve(relative).normalize();
        if (!p.startsWith(root)) {
            throw new IllegalArgumentException("Chemin hors du stockage : " + relative);
        }
        return p;
    }

    private static String relativePdfPath(Exam exam) {
        String name = exam.getSubjectCode().toLowerCase(Locale.ROOT);
        if (!"JUIN".equals(exam.getSessionMonth())) {
            name += "_" + exam.getSessionMonth().toLowerCase(Locale.ROOT);
        }
        return exam.getLevel().toLowerCase(Locale.ROOT) + "/" + exam.getSessionYear() + "/" + name + ".pdf";
    }

    private static String stripExtension(String fileName) {
        int dot = fileName.lastIndexOf('.');
        return dot < 0 ? fileName : fileName.substring(0, dot);
    }
}
