package com.examo.backend.exam;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

import org.hibernate.annotations.ColumnTransformer;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "exam")
public class Exam {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String level;

    @Column(name = "session_year", nullable = false)
    private short sessionYear;

    @Column(name = "session_month", nullable = false)
    private String sessionMonth;

    @Column(name = "subject_code", nullable = false)
    private String subjectCode;

    @Column(name = "subject_name", nullable = false)
    private String subjectName;

    @Column(name = "source_url", nullable = false)
    private String sourceUrl;

    @Column(name = "file_path")
    private String filePath;

    @Column(name = "page_count")
    private Integer pageCount;

    @Column(name = "imported_at")
    private OffsetDateTime importedAt;

    @Column(name = "duration_minutes")
    private Integer durationMinutes;

    @Column(name = "total_points")
    private BigDecimal totalPoints;

    @Column(name = "question_count")
    private Integer questionCount;

    @Column(name = "content", columnDefinition = "jsonb")
    @ColumnTransformer(write = "?::jsonb")
    private String content;

    @Column(name = "content_hash")
    private String contentHash;

    protected Exam() {
    }

    public Long getId() { return id; }
    public String getLevel() { return level; }
    public short getSessionYear() { return sessionYear; }
    public String getSessionMonth() { return sessionMonth; }
    public String getSubjectCode() { return subjectCode; }
    public String getSubjectName() { return subjectName; }
    public String getSourceUrl() { return sourceUrl; }
    public String getFilePath() { return filePath; }
    public Integer getPageCount() { return pageCount; }
    public OffsetDateTime getImportedAt() { return importedAt; }
    public Integer getDurationMinutes() { return durationMinutes; }
    public BigDecimal getTotalPoints() { return totalPoints; }
    public Integer getQuestionCount() { return questionCount; }
    public String getContent() { return content; }
    public String getContentHash() { return contentHash; }

    public boolean isInteractive() {
        return content != null;
    }

    public void updateContent(String json, String hash, Integer durationMinutes, BigDecimal totalPoints, int questionCount) {
        this.content = json;
        this.contentHash = hash;
        this.durationMinutes = durationMinutes;
        this.totalPoints = totalPoints;
        this.questionCount = questionCount;
    }

    public boolean isAvailable() {
        return filePath != null && pageCount != null;
    }

    public void markImported(String filePath, int pageCount) {
        this.filePath = filePath;
        this.pageCount = pageCount;
        this.importedAt = OffsetDateTime.now();
    }
}
