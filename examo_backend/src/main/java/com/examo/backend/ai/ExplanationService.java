package com.examo.backend.ai;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.examo.backend.ai.ClaudeService.ChatTurn;
import com.examo.backend.content.ExamContent;
import com.examo.backend.content.ExamContent.Passage;
import com.examo.backend.content.ExamContent.Question;
import com.examo.backend.content.ExamContentLoader;
import com.examo.backend.exam.Exam;
import com.examo.backend.exam.ExamRepository;
import com.examo.backend.grading.GradingResult;
import com.examo.backend.grading.GradingResult.QuestionResult;
import com.examo.backend.grading.Submission;
import com.examo.backend.grading.SubmissionRepository;

import tools.jackson.databind.json.JsonMapper;

/** Tuteur conversationnel : explique une question de l'épreuve à l'élève, à l'écrit ou pour la lecture vocale. */
@Service
public class ExplanationService {

    static final int MAX_TURNS = 20;
    static final int MAX_CHARS = 2000;

    private static final String TUTOR = """
            Tu es Examo, un tuteur bienveillant qui aide un élève de CM2 au Togo à préparer le CEPD.
            Tu expliques une question de l'épreuve que l'élève vient de passer.

            Comment tu réponds :
            - En français simple, avec des phrases courtes, en tutoyant l'élève.
            - Pas à pas : d'abord l'idée, ensuite la méthode, enfin la bonne réponse.
            - Avec des exemples de la vie de tous les jours au Togo quand cela aide (le marché, les francs CFA, l'école, le village).
            - En partant de ce que l'élève a répondu : dis ce qui était juste, puis corrige l'erreur sans le décourager.
            - En 120 mots au maximum, sauf si l'élève demande plus de détails.
            - En texte simple : pas de titres, pas de gras, pas de tableaux, pas d'émojis, car ta réponse peut être lue \
            à voix haute. Tu peux numéroter des étapes (1., 2., 3.).
            Si l'élève parle d'autre chose, ramène-le gentiment à la question.""";

    private final SubmissionRepository submissions;
    private final ExamRepository exams;
    private final ExamContentLoader contentLoader;
    private final ClaudeService claude;
    private final JsonMapper mapper;

    public ExplanationService(SubmissionRepository submissions, ExamRepository exams, ExamContentLoader contentLoader,
            ClaudeService claude, JsonMapper mapper) {
        this.submissions = submissions;
        this.exams = exams;
        this.contentLoader = contentLoader;
        this.claude = claude;
        this.mapper = mapper;
    }

    public record ExplainRequest(UUID submissionId, String questionId, List<Turn> messages) {
    }

    public record Turn(String role, String text) {
    }

    public record ExplainResponse(String reply) {
    }

    public ExplainResponse explain(ExplainRequest request) {
        Submission submission = submissions.findById(request.submissionId())
                .orElseThrow(() -> new IllegalArgumentException("Copie introuvable"));
        Exam exam = exams.findById(submission.getExamId())
                .orElseThrow(() -> new IllegalArgumentException("Épreuve introuvable"));
        ExamContent content = contentLoader.parse(exam);
        Question question = content.question(request.questionId());
        if (question == null) {
            throw new IllegalArgumentException("Question introuvable");
        }
        GradingResult result = mapper.readValue(submission.getResult(), GradingResult.class);
        QuestionResult qr = result.questions().stream()
                .filter(r -> r.id().equals(question.id())).findFirst().orElse(null);

        List<ChatTurn> turns = new ArrayList<>();
        List<Turn> history = request.messages() == null ? List.of() : request.messages();
        if (history.size() > MAX_TURNS) {
            throw new IllegalArgumentException("Conversation trop longue : recommence une nouvelle explication.");
        }
        if (history.isEmpty()) {
            turns.add(new ChatTurn(true, "Je n'ai pas compris cette question. Explique-moi, s'il te plaît."));
        }
        boolean expectStudent = true;
        for (Turn t : history) {
            boolean student = "student".equals(t.role());
            if (student != expectStudent || t.text() == null || t.text().isBlank() || t.text().length() > MAX_CHARS) {
                throw new IllegalArgumentException("Conversation invalide");
            }
            turns.add(new ChatTurn(student, t.text().strip()));
            expectStudent = !expectStudent;
        }
        if (!history.isEmpty() && expectStudent) {
            throw new IllegalArgumentException("Le dernier message doit venir de l'élève");
        }
        return new ExplainResponse(claude.chat(TUTOR + "\n\n" + context(content, question, qr), turns));
    }

    private static String context(ExamContent content, Question q, QuestionResult qr) {
        StringBuilder sb = new StringBuilder("Épreuve : ").append(content.level()).append(" ")
                .append(content.year()).append(" - ").append(content.title()).append("\n");
        Passage p = content.passage(q.passage());
        if (p != null) {
            sb.append(p.kind() == ExamContent.PassageKind.DICTATION ? "Texte de la dictée" : "Texte de l'épreuve");
            if (p.title() != null) {
                sb.append(" (").append(p.title()).append(")");
            }
            sb.append(" :\n").append(p.text()).append("\n");
        }
        sb.append("Question (").append(q.points().toPlainString()).append(" pt) : ");
        if (q.stem() != null) {
            sb.append(q.stem()).append(" ");
        }
        if (q.label() != null) {
            sb.append(q.label()).append(" ");
        }
        sb.append(q.prompt()).append("\n");
        if (q.options() != null) {
            sb.append("Choix proposés : ").append(String.join(" ; ", q.options())).append("\n");
        }
        sb.append("Corrigé : ").append(q.answer()).append("\n");
        if (qr != null) {
            sb.append("Réponse de l'élève : ").append(qr.studentAnswer() == null ? "(aucune réponse)" : qr.studentAnswer()).append("\n");
            if (qr.awarded() != null) {
                sb.append("Note obtenue : ").append(qr.awarded().toPlainString()).append(" / ").append(qr.points().toPlainString()).append("\n");
            }
            if (qr.feedback() != null) {
                sb.append("Commentaire du correcteur : ").append(qr.feedback()).append("\n");
            }
        }
        return sb.toString();
    }
}
