package com.examo.backend.grading;

import static org.assertj.core.api.Assertions.assertThat;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;

import org.junit.jupiter.api.Test;

import com.examo.backend.content.ExamContent.Question;
import com.examo.backend.content.ExamContent.QuestionType;
import com.examo.backend.content.ExamContent.Table;
import com.examo.backend.grading.GradingResult.Status;
import com.examo.backend.grading.SubmissionRequest.StudentAnswer;

class GradingRulesTest {

    @Test
    void aiScoresAreRoundedToQuartersAndCappedByTheScale() {
        BigDecimal max = new BigDecimal("2");
        assertThat(GradingService.clamp(1.3, max)).isEqualByComparingTo("1.25");
        assertThat(GradingService.clamp(5, max)).isEqualByComparingTo("2");
        assertThat(GradingService.clamp(-1, max)).isEqualByComparingTo("0");
    }

    @Test
    void statusFollowsTheAwardedPoints() {
        BigDecimal max = new BigDecimal("2");
        assertThat(GradingService.statusOf(new BigDecimal("2"), max)).isEqualTo(Status.CORRECT);
        assertThat(GradingService.statusOf(new BigDecimal("0.5"), max)).isEqualTo(Status.PARTIAL);
        assertThat(GradingService.statusOf(BigDecimal.ZERO, max)).isEqualTo(Status.WRONG);
    }

    @Test
    void tableAnswerShowsPrintedAndFilledCells() {
        Question q = question(QuestionType.TABLE, new Table(List.of("Empire", "Capitale"),
                List.of(Arrays.asList(null, "Niani"), Arrays.asList("Songhai", null))));
        StudentAnswer a = new StudentAnswer(null, null, null, List.of(Arrays.asList("Mali", null), Arrays.asList(null, "")), null);
        assertThat(AnswerFormatter.display(q, a)).isEqualTo("Empire | Capitale\nMali | Niani\nSonghai | …");
    }

    @Test
    void emptyAnswersAreDetectedPerType() {
        assertThat(AnswerFormatter.isEmpty(question(QuestionType.SHORT_TEXT, null), new StudentAnswer("  ", null, null, null, null))).isTrue();
        assertThat(AnswerFormatter.isEmpty(question(QuestionType.PHOTO, null), new StudentAnswer(null, null, null, null, false))).isTrue();
        assertThat(AnswerFormatter.isEmpty(question(QuestionType.LONG_TEXT, null), new StudentAnswer(null, null, null, null, true))).isFalse();
        assertThat(AnswerFormatter.isEmpty(question(QuestionType.FILL_BLANKS, null), new StudentAnswer(null, null, List.of("", "exécutif"), null, null))).isFalse();
    }

    @Test
    void exactBlanksAreRecognisedWithoutAi() {
        assertThat(ExactMatcher.same("l’inspiration", "Inspiration.")).isTrue();
        assertThat(ExactMatcher.same("législatif", "legislatif")).isTrue();
        assertThat(ExactMatcher.same("exécutif", "judiciaire")).isFalse();
        assertThat(ExactMatcher.same("Gao", null)).isFalse();
    }

    private static Question question(QuestionType type, Table table) {
        return new Question("q1", null, null, "1.", "prompt ___", BigDecimal.ONE, type, null, null, null, table, null, null, "corrigé", null);
    }
}
