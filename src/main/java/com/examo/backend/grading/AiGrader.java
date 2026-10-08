package com.examo.backend.grading;

import java.util.ArrayList;
import java.util.Base64;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.stereotype.Component;

import com.anthropic.models.messages.Base64ImageSource;
import com.anthropic.models.messages.ContentBlockParam;
import com.anthropic.models.messages.ImageBlockParam;
import com.anthropic.models.messages.TextBlockParam;
import com.examo.backend.ai.ClaudeService;
import com.examo.backend.content.ExamContent;
import com.examo.backend.content.ExamContent.Passage;
import com.examo.backend.content.ExamContent.Question;
import com.examo.backend.grading.SubmissionRequest.StudentAnswer;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;

/** Fait corriger par Claude, en un seul appel, toutes les questions qui ne se corrigent pas automatiquement. */
@Component
class AiGrader {

    static final String SYSTEM = """
            Tu es correcteur du CEPD (Certificat d'Études du Premier Degré) au Togo. Tu notes la copie \
            d'un élève de CM2, question par question, en appliquant le corrigé et le barème fournis.

            Règles :
            - Pour chaque question, attribue une note entre 0 et le maximum indiqué, par pas de 0,25 point.
            - Applique le barème détaillé quand il existe ; sinon, accorde les points en proportion des éléments justes.
            - Accepte toute réponse juste formulée autrement que dans le corrigé : synonymes, autre méthode \
            de calcul, autre ordre, autre exemple valable.
            - Ne pénalise pas l'orthographe, sauf dans la dictée et dans les questions de langue qui l'évaluent.
            - Calculs : vérifie le résultat et la démarche, selon le barème.
            - Photos (dessin, schéma, carte, copie manuscrite) : examine l'image. Si elle est illisible ou sans \
            rapport avec la question, donne 0 et dis-le simplement.
            - Dictée : déchiffre la copie photographiée, compare-la mot à mot au texte de la dictée et applique \
            le barème fourni.
            - Le feedback s'adresse à l'élève : une ou deux phrases courtes, en français simple, en le tutoyant, \
            avec bienveillance. Dis ce qui est juste et ce qui manque, sans recopier tout le corrigé.

            Renvoie une entrée par question reçue, avec exactement le même id.""";

    record Grades(@JsonPropertyDescription("Une note par question reçue") List<Grade> grades) {
    }

    record Grade(
            @JsonPropertyDescription("Identifiant exact de la question, par exemple q3") String id,
            @JsonPropertyDescription("Points accordés, entre 0 et le maximum de la question, par pas de 0,25") double awarded,
            @JsonPropertyDescription("Une ou deux phrases pour l'élève, en le tutoyant") String feedback) {
    }

    private final ClaudeService claude;

    AiGrader(ClaudeService claude) {
        this.claude = claude;
    }

    List<Grade> grade(ExamContent exam, List<Question> questions, Map<String, StudentAnswer> answers,
            Map<String, byte[]> photos) {
        List<ContentBlockParam> content = new ArrayList<>();
        StringBuilder intro = new StringBuilder()
                .append("Épreuve : ").append(exam.level()).append(" ").append(exam.month()).append(" ")
                .append(exam.year()).append(" - ").append(exam.title()).append("\n");

        Set<String> passageIds = new LinkedHashSet<>();
        questions.forEach(q -> {
            if (q.passage() != null) {
                passageIds.add(q.passage());
            }
        });
        for (String id : passageIds) {
            Passage p = exam.passage(id);
            intro.append("\n=== ").append(label(p)).append(" ===\n").append(p.text()).append("\n");
        }
        content.add(text(intro.toString()));

        for (Question q : questions) {
            StudentAnswer answer = answers.get(q.id());
            StringBuilder block = new StringBuilder()
                    .append("\n=== Question ").append(q.id()).append(" (maximum ").append(q.points().toPlainString())
                    .append(" pt) ===\n");
            if (q.stem() != null) {
                block.append(q.stem()).append("\n");
            }
            if (q.label() != null) {
                block.append(q.label()).append(" ");
            }
            block.append(q.prompt()).append("\n");
            if (q.table() != null) {
                block.append("Tableau imprimé (… = case à compléter) :\n").append(AnswerFormatter.tableToText(q, null)).append("\n");
            }
            block.append("Corrigé : ").append(q.answer()).append("\n");
            if (q.grading() != null) {
                block.append("Barème : ").append(q.grading()).append("\n");
            }
            byte[] photo = photos.get(q.id());
            String typed = AnswerFormatter.display(q, answer);
            if (photo != null) {
                if (answer != null && answer.text() != null && !answer.text().isBlank()) {
                    block.append("Texte tapé par l'élève : ").append(answer.text().strip()).append("\n");
                }
                block.append("Réponse de l'élève : la photo ci-dessous.");
                content.add(text(block.toString()));
                content.add(image(photo));
            } else {
                block.append("Réponse de l'élève : ").append(typed == null ? "(aucune réponse)" : typed);
                content.add(text(block.toString()));
            }
        }
        return claude.structured(SYSTEM, content, Grades.class).grades();
    }

    private static String label(Passage p) {
        String kind = switch (p.kind()) {
            case DICTATION -> "Texte de la dictée (" + p.id() + ")";
            case STATEMENT -> "Énoncé (" + p.id() + ")";
            case TEXT -> "Texte support (" + p.id() + ")";
        };
        return p.title() == null ? kind : kind + " : " + p.title();
    }

    private static ContentBlockParam text(String s) {
        return ContentBlockParam.ofText(TextBlockParam.builder().text(s).build());
    }

    private static ContentBlockParam image(byte[] data) {
        String type = PhotoStorage.mediaType(data);
        Base64ImageSource.MediaType mediaType = switch (type == null ? "" : type) {
            case "image/png" -> Base64ImageSource.MediaType.IMAGE_PNG;
            case "image/webp" -> Base64ImageSource.MediaType.IMAGE_WEBP;
            default -> Base64ImageSource.MediaType.IMAGE_JPEG;
        };
        return ContentBlockParam.ofImage(ImageBlockParam.builder()
                .source(Base64ImageSource.builder().data(Base64.getEncoder().encodeToString(data)).mediaType(mediaType).build())
                .build());
    }
}
