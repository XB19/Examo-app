package com.examo.backend.content;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.examo.backend.content.ExamContent.Passage;
import com.examo.backend.content.ExamContent.PassageKind;
import com.examo.backend.content.ExamContent.Question;

/** Vérifie qu'une épreuve est complète et cohérente avant de la publier aux élèves. */
public final class ExamContentValidator {

    private ExamContentValidator() {
    }

    public static List<String> validate(ExamContent c) {
        List<String> errors = new ArrayList<>();
        if (isBlank(c.level()) || isBlank(c.month()) || isBlank(c.subject()) || c.year() < 2000) {
            errors.add("level/year/month/subject obligatoires");
        }
        if (c.passages() == null || c.questions() == null || c.questions().isEmpty()) {
            errors.add("passages et questions obligatoires (au moins une question)");
            return errors;
        }

        Set<String> passageIds = new HashSet<>();
        for (Passage p : c.passages()) {
            if (isBlank(p.id()) || !passageIds.add(p.id())) {
                errors.add("passage sans id ou id en double : " + p.id());
            }
            if (p.kind() == null || isBlank(p.text())) {
                errors.add("passage " + p.id() + " : kind et text obligatoires");
            }
        }

        Set<String> questionIds = new HashSet<>();
        for (Question q : c.questions()) {
            String where = "question " + q.id();
            if (isBlank(q.id()) || !questionIds.add(q.id())) {
                errors.add("question sans id ou id en double : " + q.id());
            }
            if (q.type() == null || isBlank(q.prompt())) {
                errors.add(where + " : type et prompt obligatoires");
                continue;
            }
            if (q.points() == null || q.points().compareTo(BigDecimal.ZERO) <= 0) {
                errors.add(where + " : points doit être > 0");
            }
            if (isBlank(q.answer())) {
                errors.add(where + " : corrigé (answer) manquant");
            }
            if (q.passage() != null && !passageIds.contains(q.passage())) {
                errors.add(where + " : passage inconnu " + q.passage());
            }
            switch (q.type()) {
                case CHOICE -> {
                    if (q.options() == null || q.options().size() < 2 || q.correctOption() == null
                            || q.correctOption() < 0 || q.correctOption() >= q.options().size()) {
                        errors.add(where + " : CHOICE exige au moins 2 options et un correctOption valide");
                    }
                }
                case FILL_BLANKS -> {
                    int blanks = q.blankCount();
                    if (blanks == 0 || q.blanksAnswer() == null || q.blanksAnswer().size() != blanks) {
                        errors.add(where + " : FILL_BLANKS exige des " + Question.BLANK
                                + " dans prompt et autant de blanksAnswer (" + blanks + ")");
                    }
                }
                case TABLE -> validateTable(q, where, errors);
                case DICTATION -> {
                    Passage p = c.passage(q.passage());
                    if (p == null || p.kind() != PassageKind.DICTATION) {
                        errors.add(where + " : DICTATION doit référencer un passage de type DICTATION");
                    }
                }
                default -> {
                }
            }
        }
        return errors;
    }

    private static void validateTable(Question q, String where, List<String> errors) {
        if (q.table() == null || q.table().rows() == null || q.table().rows().isEmpty() || q.tableAnswer() == null) {
            errors.add(where + " : TABLE exige table.rows et tableAnswer");
            return;
        }
        List<List<String>> rows = q.table().rows();
        if (rows.size() != q.tableAnswer().size()) {
            errors.add(where + " : tableAnswer doit avoir autant de lignes que table.rows");
            return;
        }
        boolean hasBlank = false;
        for (int r = 0; r < rows.size(); r++) {
            List<String> row = rows.get(r);
            List<String> answerRow = q.tableAnswer().get(r);
            if (answerRow.size() != row.size()) {
                errors.add(where + " : ligne " + r + " de tableAnswer de mauvaise longueur");
                continue;
            }
            for (int col = 0; col < row.size(); col++) {
                if (row.get(col) == null) {
                    hasBlank = true;
                    if (isBlank(answerRow.get(col))) {
                        errors.add(where + " : case [" + r + "," + col + "] sans réponse dans tableAnswer");
                    } else if (q.options() != null && !q.options().contains(answerRow.get(col))) {
                        errors.add(where + " : la réponse de la case [" + r + "," + col + "] ne fait pas partie des options");
                    }
                }
            }
        }
        if (!hasBlank) {
            errors.add(where + " : TABLE sans aucune case à compléter (null)");
        }
    }

    private static boolean isBlank(String s) {
        return s == null || s.isBlank();
    }
}
