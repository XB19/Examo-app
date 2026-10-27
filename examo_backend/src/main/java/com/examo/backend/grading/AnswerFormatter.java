package com.examo.backend.grading;

import java.util.ArrayList;
import java.util.List;

import com.examo.backend.content.ExamContent.Question;
import com.examo.backend.grading.SubmissionRequest.StudentAnswer;

/** Met une réponse d'élève sous forme de texte lisible (pour l'affichage et pour l'IA). */
final class AnswerFormatter {

    private AnswerFormatter() {
    }

    static boolean isEmpty(Question q, StudentAnswer a) {
        if (a == null) {
            return true;
        }
        return switch (q.type()) {
            case CHOICE -> a.choice() == null;
            case PHOTO, DICTATION -> !a.hasPhoto();
            case FILL_BLANKS -> a.blanks() == null || a.blanks().stream().allMatch(AnswerFormatter::blank);
            case TABLE -> a.table() == null || a.table().stream().flatMap(List::stream).allMatch(AnswerFormatter::blank);
            case LONG_TEXT -> blank(a.text()) && !a.hasPhoto();
            default -> blank(a.text());
        };
    }

    static String display(Question q, StudentAnswer a) {
        if (isEmpty(q, a)) {
            return null;
        }
        return switch (q.type()) {
            case CHOICE -> q.options().get(a.choice());
            case PHOTO, DICTATION -> "Réponse en photo";
            case FILL_BLANKS -> String.join(" / ", a.blanks().stream().map(s -> blank(s) ? "…" : s.strip()).toList());
            case TABLE -> tableToText(q, a.table());
            case LONG_TEXT -> blank(a.text()) ? "Réponse en photo" : a.text().strip();
            default -> a.text().strip();
        };
    }

    /** Version complète d'un tableau : cases imprimées + cases remplies par l'élève. */
    static String tableToText(Question q, List<List<String>> filled) {
        List<String> lines = new ArrayList<>();
        if (q.table().header() != null) {
            lines.add(String.join(" | ", q.table().header()));
        }
        List<List<String>> rows = q.table().rows();
        for (int r = 0; r < rows.size(); r++) {
            List<String> cells = new ArrayList<>();
            for (int c = 0; c < rows.get(r).size(); c++) {
                String printed = rows.get(r).get(c);
                String value = printed != null ? printed : cell(filled, r, c);
                cells.add(value == null || value.isBlank() ? "…" : value.strip());
            }
            lines.add(String.join(" | ", cells));
        }
        return String.join("\n", lines);
    }

    private static String cell(List<List<String>> table, int r, int c) {
        if (table == null || r >= table.size() || table.get(r) == null || c >= table.get(r).size()) {
            return null;
        }
        return table.get(r).get(c);
    }

    private static boolean blank(String s) {
        return s == null || s.isBlank();
    }
}
