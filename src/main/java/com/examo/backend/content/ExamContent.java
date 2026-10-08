package com.examo.backend.content;

import java.math.BigDecimal;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonInclude;

/**
 * Épreuve retranscrite mot pour mot depuis le sujet officiel, avec son corrigé.
 * Source : un fichier JSON par épreuve dans resources/exams/.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record ExamContent(
        String level,
        int year,
        String month,
        String subject,
        String title,
        Integer durationMinutes,
        String reviewNotes,
        List<Passage> passages,
        List<Question> questions) {

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record Passage(String id, PassageKind kind, String title, String text) {
    }

    public enum PassageKind {
        /** Texte support lu par l'élève. */
        TEXT,
        /** Énoncé commun à plusieurs questions (problème). */
        STATEMENT,
        /** Texte de dictée : jamais montré avant que l'élève ait rendu sa dictée. */
        DICTATION
    }

    public enum QuestionType {
        SHORT_TEXT, LONG_TEXT, CHOICE, FILL_BLANKS, TABLE, PHOTO, DICTATION
    }

    /** Une cellule null dans {@code rows} est une case à compléter par l'élève. */
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record Table(List<String> header, List<List<String>> rows) {
    }

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record Question(
            String id,
            String section,
            String stem,
            String label,
            String prompt,
            BigDecimal points,
            QuestionType type,
            String passage,
            List<String> options,
            Integer correctOption,
            Table table,
            List<List<String>> tableAnswer,
            List<String> blanksAnswer,
            String answer,
            String grading) {

        /** Marqueur d'un trou dans l'énoncé d'une question FILL_BLANKS. */
        public static final String BLANK = "___";

        public int blankCount() {
            if (prompt == null) {
                return 0;
            }
            int count = 0;
            for (int i = prompt.indexOf(BLANK); i >= 0; i = prompt.indexOf(BLANK, i + BLANK.length())) {
                count++;
            }
            return count;
        }
    }

    public BigDecimal totalPoints() {
        return questions.stream().map(Question::points).reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public Question question(String id) {
        return questions.stream().filter(q -> q.id().equals(id)).findFirst().orElse(null);
    }

    public Passage passage(String id) {
        return id == null ? null : passages.stream().filter(p -> p.id().equals(id)).findFirst().orElse(null);
    }
}
