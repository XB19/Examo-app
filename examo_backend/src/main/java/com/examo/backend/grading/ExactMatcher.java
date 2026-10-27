package com.examo.backend.grading;

import java.text.Normalizer;
import java.util.List;
import java.util.Locale;

import com.examo.backend.content.ExamContent.Question;
import com.examo.backend.grading.SubmissionRequest.StudentAnswer;

/**
 * Reconnaît sans IA les trous et tableaux remplis exactement comme le corrigé
 * (à la casse, aux accents, à l'article et à la ponctuation finale près).
 */
final class ExactMatcher {

    private ExactMatcher() {
    }

    static boolean matches(Question q, StudentAnswer a) {
        if (a == null) {
            return false;
        }
        return switch (q.type()) {
            case FILL_BLANKS -> a.blanks() != null && sameList(q.blanksAnswer(), a.blanks());
            case TABLE -> tableMatches(q, a.table());
            default -> false;
        };
    }

    private static boolean sameList(List<String> expected, List<String> given) {
        if (expected.size() != given.size()) {
            return false;
        }
        for (int i = 0; i < expected.size(); i++) {
            if (!same(expected.get(i), given.get(i))) {
                return false;
            }
        }
        return true;
    }

    private static boolean tableMatches(Question q, List<List<String>> filled) {
        if (filled == null) {
            return false;
        }
        List<List<String>> rows = q.table().rows();
        for (int r = 0; r < rows.size(); r++) {
            for (int c = 0; c < rows.get(r).size(); c++) {
                if (rows.get(r).get(c) != null) {
                    continue;
                }
                String given = r < filled.size() && filled.get(r) != null && c < filled.get(r).size() ? filled.get(r).get(c) : null;
                if (!same(q.tableAnswer().get(r).get(c), given)) {
                    return false;
                }
            }
        }
        return true;
    }

    static boolean same(String expected, String given) {
        return given != null && normalize(expected).equals(normalize(given));
    }

    static String normalize(String s) {
        String n = Normalizer.normalize(s.toLowerCase(Locale.FRENCH), Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace('’', '\'')
                .replaceAll("\\s+", " ")
                .strip()
                .replaceAll("[.;,!]+$", "")
                .strip();
        return n.replaceFirst("^(l'|le |la |les |du |de la |des )", "");
    }
}
