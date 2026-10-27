ALTER TABLE exam
    ADD COLUMN duration_minutes INTEGER,
    ADD COLUMN total_points     NUMERIC(6, 2),
    ADD COLUMN question_count   INTEGER,
    ADD COLUMN content          JSONB,
    ADD COLUMN content_hash     VARCHAR(64);

CREATE TABLE submission (
    id         UUID PRIMARY KEY,
    exam_id    BIGINT       NOT NULL REFERENCES exam (id),
    created_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
    graded_by  VARCHAR(10)  NOT NULL,
    score      NUMERIC(6, 2) NOT NULL,
    total      NUMERIC(6, 2) NOT NULL,
    answers    JSONB        NOT NULL,
    result     JSONB        NOT NULL
);

CREATE INDEX idx_submission_exam ON submission (exam_id);
