package com.examo.backend.exam;

import java.math.BigDecimal;

public record ExamDto(
        long id,
        String level,
        int sessionYear,
        String sessionMonth,
        String subjectCode,
        String subjectName,
        boolean available,
        Integer pageCount,
        boolean interactive,
        Integer questionCount,
        Integer durationMinutes,
        BigDecimal totalPoints) {

    static ExamDto from(Exam e) {
        return new ExamDto(e.getId(), e.getLevel(), e.getSessionYear(), e.getSessionMonth(),
                e.getSubjectCode(), e.getSubjectName(), e.isAvailable(), e.getPageCount(),
                e.isInteractive(), e.getQuestionCount(), e.getDurationMinutes(), e.getTotalPoints());
    }
}
