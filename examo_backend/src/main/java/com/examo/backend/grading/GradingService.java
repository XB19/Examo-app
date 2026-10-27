package com.examo.backend.grading;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.examo.backend.ai.AiUnavailableException;
import com.examo.backend.ai.ClaudeService;
import com.examo.backend.content.ExamContent;
import com.examo.backend.content.ExamContent.QuestionType;
import com.examo.backend.content.ExamContent.Question;
import com.examo.backend.exam.Exam;
import com.examo.backend.grading.GradingResult.GradedBy;
import com.examo.backend.grading.GradingResult.QuestionResult;
import com.examo.backend.grading.GradingResult.Status;
import com.examo.backend.grading.SubmissionRequest.StudentAnswer;

import tools.jackson.databind.json.JsonMapper;

@Service
public class GradingService {

    private static final Logger log = LoggerFactory.getLogger(GradingService.class);

    static final String SELF_NOTICE = "Compare chacune de tes réponses avec le corrigé et indique si tu avais juste.";

    private final ClaudeService claude;
    private final AiGrader aiGrader;
    private final PhotoStorage photoStorage;
    private final SubmissionRepository submissions;
    private final JsonMapper mapper;

    public GradingService(ClaudeService claude, AiGrader aiGrader, PhotoStorage photoStorage,
            SubmissionRepository submissions, JsonMapper mapper) {
        this.claude = claude;
        this.aiGrader = aiGrader;
        this.photoStorage = photoStorage;
        this.submissions = submissions;
        this.mapper = mapper;
    }

    @Transactional
    public GradingResult grade(Exam exam, ExamContent content, SubmissionRequest request, Map<String, byte[]> photos)
            throws IOException {
        UUID id = UUID.randomUUID();
        Map<String, StudentAnswer> answers = request.answers() == null ? Map.of() : request.answers();

        Map<String, byte[]> usablePhotos = new HashMap<>();
        for (Map.Entry<String, byte[]> photo : photos.entrySet()) {
            Question q = content.question(photo.getKey());
            if (q != null) {
                photoStorage.save(id, q.id(), photo.getValue());
                usablePhotos.put(q.id(), photo.getValue());
            }
        }

        List<Question> forAi = new ArrayList<>();
        Map<String, QuestionResult> results = new HashMap<>();
        for (Question q : content.questions()) {
            StudentAnswer a = answers.get(q.id());
            boolean photoAnswer = q.type() == QuestionType.PHOTO || q.type() == QuestionType.DICTATION;
            if (photoAnswer && !usablePhotos.containsKey(q.id())) {
                a = null;
            }
            if (AnswerFormatter.isEmpty(q, a)) {
                results.put(q.id(), result(q, a, BigDecimal.ZERO, Status.UNANSWERED, null, content, usablePhotos));
            } else if (q.type() == QuestionType.CHOICE) {
                boolean ok = q.correctOption().equals(a.choice());
                results.put(q.id(), result(q, a, ok ? q.points() : BigDecimal.ZERO, ok ? Status.CORRECT : Status.WRONG,
                        null, content, usablePhotos));
            } else if (ExactMatcher.matches(q, a)) {
                results.put(q.id(), result(q, a, q.points(), Status.CORRECT, null, content, usablePhotos));
            } else {
                forAi.add(q);
            }
        }

        GradedBy gradedBy = GradedBy.AI;
        String notice = null;
        if (!forAi.isEmpty()) {
            Map<String, AiGrader.Grade> grades = null;
            if (claude.available()) {
                try {
                    grades = aiGrader.grade(content, forAi, answers, usablePhotos).stream()
                            .collect(Collectors.toMap(AiGrader.Grade::id, Function.identity(), (x, y) -> x));
                    if (!grades.keySet().containsAll(forAi.stream().map(Question::id).toList())) {
                        log.warn("Correction IA incomplète pour l'épreuve {}", exam.getId());
                        grades = null;
                        notice = "La correction automatique est incomplète. " + SELF_NOTICE;
                    }
                } catch (AiUnavailableException e) {
                    notice = e.getMessage() + " " + SELF_NOTICE;
                }
            } else {
                notice = "La correction automatique n'est pas encore activée. " + SELF_NOTICE;
            }

            if (grades == null) {
                gradedBy = GradedBy.SELF;
            }
            for (Question q : forAi) {
                StudentAnswer a = answers.get(q.id());
                if (grades == null) {
                    results.put(q.id(), result(q, a, null, Status.TO_CHECK, null, content, usablePhotos));
                } else {
                    AiGrader.Grade g = grades.get(q.id());
                    BigDecimal awarded = clamp(g.awarded(), q.points());
                    results.put(q.id(), result(q, a, awarded, statusOf(awarded, q.points()), g.feedback(), content, usablePhotos));
                }
            }
        }

        List<QuestionResult> ordered = content.questions().stream().map(q -> results.get(q.id())).toList();
        BigDecimal score = ordered.stream().map(QuestionResult::awarded).filter(v -> v != null)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        GradingResult result = new GradingResult(id, exam.getId(), gradedBy, score, content.totalPoints(),
                request.durationSeconds(), notice, ordered);

        submissions.save(new Submission(id, exam.getId(), gradedBy, score, content.totalPoints(),
                mapper.writeValueAsString(request), mapper.writeValueAsString(result)));
        return result;
    }

    private static QuestionResult result(Question q, StudentAnswer a, BigDecimal awarded, Status status, String feedback,
            ExamContent content, Map<String, byte[]> photos) {
        String expected = q.type() == QuestionType.DICTATION ? content.passage(q.passage()).text() : q.answer();
        return new QuestionResult(q.id(), q.points(), awarded, status, feedback, expected,
                AnswerFormatter.display(q, a), photos.containsKey(q.id()));
    }

    static BigDecimal clamp(double awarded, BigDecimal max) {
        double quarters = Math.round(Math.max(0, awarded) * 4) / 4.0;
        BigDecimal value = BigDecimal.valueOf(quarters).setScale(2, RoundingMode.HALF_UP);
        return value.compareTo(max) > 0 ? max : value;
    }

    static Status statusOf(BigDecimal awarded, BigDecimal max) {
        if (awarded.compareTo(max) >= 0) {
            return Status.CORRECT;
        }
        return awarded.signum() == 0 ? Status.WRONG : Status.PARTIAL;
    }
}
