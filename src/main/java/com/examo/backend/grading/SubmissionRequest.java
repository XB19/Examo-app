package com.examo.backend.grading;

import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.annotation.JsonInclude;

/** Réponses de l'élève, envoyées dans la partie « answers » de la requête multipart. */
public record SubmissionRequest(Integer durationSeconds, Map<String, StudentAnswer> answers) {

    /** Les photos sont envoyées à part, dans des fichiers nommés « photo_<idQuestion> ». */
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record StudentAnswer(String text, Integer choice, List<String> blanks, List<List<String>> table, Boolean photo) {

        public boolean hasPhoto() {
            return Boolean.TRUE.equals(photo);
        }
    }

    public StudentAnswer answer(String questionId) {
        return answers == null ? null : answers.get(questionId);
    }
}
