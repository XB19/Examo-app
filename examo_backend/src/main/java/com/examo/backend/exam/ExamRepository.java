package com.examo.backend.exam;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ExamRepository extends JpaRepository<Exam, Long> {

    @Query("""
            SELECT e FROM Exam e
            WHERE e.level = :level
              AND (:year IS NULL OR e.sessionYear = :year)
              AND (:subject IS NULL OR e.subjectCode = :subject)
            ORDER BY e.sessionYear DESC, e.subjectName ASC, e.sessionMonth DESC
            """)
    List<Exam> search(@Param("level") String level, @Param("year") Short year, @Param("subject") String subject);

    List<Exam> findByFilePathIsNull();

    Optional<Exam> findByLevelAndSessionYearAndSessionMonthAndSubjectCode(String level, short sessionYear,
            String sessionMonth, String subjectCode);
}
