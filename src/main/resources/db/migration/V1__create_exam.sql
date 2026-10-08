CREATE TABLE exam (
    id            BIGSERIAL PRIMARY KEY,
    level         VARCHAR(10)  NOT NULL,
    session_year  SMALLINT     NOT NULL,
    session_month VARCHAR(10)  NOT NULL DEFAULT 'JUIN',
    subject_code  VARCHAR(40)  NOT NULL,
    subject_name  VARCHAR(80)  NOT NULL,
    source_url    TEXT         NOT NULL,
    file_path     TEXT,
    page_count    INTEGER,
    imported_at   TIMESTAMPTZ,
    CONSTRAINT uq_exam UNIQUE (level, session_year, session_month, subject_code)
);

CREATE INDEX idx_exam_level_year ON exam (level, session_year);
