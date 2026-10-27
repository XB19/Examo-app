package com.examo.backend.grading;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

import org.hibernate.annotations.ColumnTransformer;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "submission")
public class Submission {

    @Id
    private UUID id;

    @Column(name = "exam_id", nullable = false)
    private long examId;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "graded_by", nullable = false)
    private GradingResult.GradedBy gradedBy;

    @Column(nullable = false)
    private BigDecimal score;

    @Column(nullable = false)
    private BigDecimal total;

    @Column(nullable = false, columnDefinition = "jsonb")
    @ColumnTransformer(write = "?::jsonb")
    private String answers;

    @Column(nullable = false, columnDefinition = "jsonb")
    @ColumnTransformer(write = "?::jsonb")
    private String result;

    protected Submission() {
    }

    public Submission(UUID id, long examId, GradingResult.GradedBy gradedBy, BigDecimal score, BigDecimal total,
            String answers, String result) {
        this.id = id;
        this.examId = examId;
        this.createdAt = OffsetDateTime.now();
        this.gradedBy = gradedBy;
        this.score = score;
        this.total = total;
        this.answers = answers;
        this.result = result;
    }

    public UUID getId() { return id; }
    public long getExamId() { return examId; }
    public String getAnswers() { return answers; }
    public String getResult() { return result; }
}
