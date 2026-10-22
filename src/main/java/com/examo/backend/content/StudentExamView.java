package com.examo.backend.content;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;

import com.examo.backend.content.ExamContent.Passage;
import com.examo.backend.content.ExamContent.PassageKind;
import com.examo.backend.content.ExamContent.Question;
import com.examo.backend.content.ExamContent.QuestionType;
import com.examo.backend.content.ExamContent.Table;
import com.examo.backend.exam.Exam;
import com.fasterxml.jackson.annotation.JsonInclude;

/**
 * Épreuve telle qu'envoyée à l'élève : sans corrigé ni barème.
 * Le texte d'une dictée n'est transmis que découpé en phrases, pour la lecture à voix haute.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record StudentExamView(
        long id,
        String level,
        int sessionYear,
        String sessionMonth,
        String subjectCode,
        String subjectName,
        String title,
        Integer durationMinutes,
        BigDecimal totalPoints,
        List<PassageView> passages,
        List<QuestionView> questions) {

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record PassageView(String id, PassageKind kind, String title, String text, List<String> sentences) {
    }

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record QuestionView(String id, String section, String stem, String label, String prompt,
            BigDecimal points, QuestionType type, String passage, List<String> options, Table table,
            Integer blankCount) {
    }

    public static StudentExamView of(Exam exam, ExamContent c) {
        return new StudentExamView(exam.getId(), exam.getLevel(), exam.getSessionYear(), exam.getSessionMonth(),
                exam.getSubjectCode(), exam.getSubjectName(), c.title(), c.durationMinutes(), c.totalPoints(),
                c.passages().stream().map(StudentExamView::passage).toList(),
                c.questions().stream().map(StudentExamView::question).toList());
    }

    private static PassageView passage(Passage p) {
        if (p.kind() == PassageKind.DICTATION) {
            return new PassageView(p.id(), p.kind(), null, null, spokenSentences(p));
        }
        return new PassageView(p.id(), p.kind(), p.title(), p.text(), null);
    }

    /**
     * Phrases d'une dictée dans l'ordre de lecture (titre inclus en premier) : même liste que celle
     * envoyée à l'élève, réutilisée par DictationAudioController pour que les index correspondent.
     */
    public static List<String> spokenSentences(Passage p) {
        List<String> spoken = new java.util.ArrayList<>();
        String title = spokenTitle(p.title());
        if (title != null) {
            spoken.add(title);
        }
        spoken.addAll(sentences(p.text()));
        return spoken;
    }

    /** « <u>Dictée</u> : Tout le monde travaille. » se lit « Tout le monde travaille. » */
    static String spokenTitle(String title) {
        if (title == null) {
            return null;
        }
        String plain = title.replaceAll("<[^>]+>", "").strip();
        int colon = plain.indexOf(':');
        String spoken = (colon >= 0 ? plain.substring(colon + 1) : plain).strip();
        return spoken.isEmpty() ? null : spoken;
    }

    private static QuestionView question(Question q) {
        return new QuestionView(q.id(), q.section(), q.stem(), q.label(), q.prompt(), q.points(), q.type(),
                q.passage(), q.options(), q.table(), q.type() == QuestionType.FILL_BLANKS ? q.blankCount() : null);
    }

    /** Découpe après . ? ! ; en gardant la ponctuation, pour une lecture phrase par phrase. */
    static List<String> sentences(String text) {
        return Arrays.stream(text.replace('\n', ' ').split("(?<=[.?!;])\\s+"))
                .map(String::strip)
                .filter(s -> !s.isEmpty())
                .toList();
    }
}
