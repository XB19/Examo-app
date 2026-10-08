package com.examo.backend.grading;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record GradingResult(
        UUID submissionId,
        long examId,
        GradedBy gradedBy,
        BigDecimal score,
        BigDecimal total,
        Integer durationSeconds,
        String notice,
        List<QuestionResult> questions) {

    public enum GradedBy {
        /** Corrigé par l'IA (et automatiquement pour les QCM). */
        AI,
        /** IA indisponible : l'élève compare avec le corrigé et se note lui-même. */
        SELF
    }

    public enum Status {
        CORRECT, PARTIAL, WRONG, UNANSWERED,
        /** Mode SELF : à vérifier par l'élève en comparant avec le corrigé. */
        TO_CHECK
    }

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record QuestionResult(
            String id,
            BigDecimal points,
            BigDecimal awarded,
            Status status,
            String feedback,
            String expected,
            String studentAnswer,
            boolean hasPhoto) {
    }
}
