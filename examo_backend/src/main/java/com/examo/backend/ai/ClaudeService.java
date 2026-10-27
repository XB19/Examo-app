package com.examo.backend.ai;

import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import com.anthropic.client.AnthropicClient;
import com.anthropic.client.okhttp.AnthropicOkHttpClient;
import com.anthropic.core.JsonValue;
import com.anthropic.errors.AnthropicIoException;
import com.anthropic.errors.AnthropicServiceException;
import com.anthropic.errors.RateLimitException;
import com.anthropic.models.messages.ContentBlockParam;
import com.anthropic.models.messages.Message;
import com.anthropic.models.messages.MessageCreateParams;
import com.anthropic.models.messages.OutputConfig;
import com.anthropic.models.messages.StopReason;
import com.anthropic.models.messages.StructuredMessage;
import com.anthropic.models.messages.StructuredMessageCreateParams;

import jakarta.annotation.PreDestroy;

/** Point d'accès unique à Claude. Sans clé configurée, {@link #available()} renvoie false. */
@Component
public class ClaudeService {

    private static final Logger log = LoggerFactory.getLogger(ClaudeService.class);

    // Repli automatique côté serveur si le modèle principal décline une requête.
    private static final String FALLBACK_BETA = "server-side-fallback-2026-07-01";

    private final AnthropicClient client;
    private final String model;

    public ClaudeService(AiProperties props) {
        this.model = props.model();
        this.client = props.configured() ? AnthropicOkHttpClient.builder().apiKey(props.apiKey()).build() : null;
        if (client == null) {
            log.warn("Aucune clé Anthropic (anthropic.api-key) : correction IA et explications désactivées.");
        }
    }

    public boolean available() {
        return client != null;
    }

    /** Une requête dont la réponse est contrainte au schéma JSON de {@code type}. */
    public <T> T structured(String system, List<ContentBlockParam> userContent, Class<T> type) {
        requireClient();
        StructuredMessageCreateParams<T> params = MessageCreateParams.builder()
                .model(model)
                .maxTokens(16000L)
                .system(system)
                .addUserMessageOfBlockParams(userContent)
                .putAdditionalHeader("anthropic-beta", FALLBACK_BETA)
                .putAdditionalBodyProperty("fallbacks", JsonValue.from("default"))
                .outputConfig(type)
                .build();
        StructuredMessage<T> response = call(() -> client.messages().create(params));
        checkStop(response.stopReason());
        return response.content().stream()
                .flatMap(block -> block.text().stream())
                .map(text -> text.text())
                .findFirst()
                .orElseThrow(() -> new AiUnavailableException("Réponse IA vide"));
    }

    /** Conversation simple : messages alternés élève/IA, le dernier venant de l'élève. */
    public String chat(String system, List<ChatTurn> turns) {
        requireClient();
        MessageCreateParams.Builder builder = MessageCreateParams.builder()
                .model(model)
                .maxTokens(8000L)
                .system(system)
                .outputConfig(OutputConfig.builder().effort(OutputConfig.Effort.LOW).build())
                .putAdditionalHeader("anthropic-beta", FALLBACK_BETA)
                .putAdditionalBodyProperty("fallbacks", JsonValue.from("default"));
        for (ChatTurn turn : turns) {
            if (turn.fromStudent()) {
                builder.addUserMessage(turn.text());
            } else {
                builder.addAssistantMessage(turn.text());
            }
        }
        Message response = call(() -> client.messages().create(builder.build()));
        checkStop(response.stopReason());
        String text = response.content().stream()
                .flatMap(block -> block.text().stream())
                .map(t -> t.text())
                .reduce("", String::concat)
                .strip();
        if (text.isEmpty()) {
            throw new AiUnavailableException("Réponse IA vide");
        }
        return text;
    }

    public record ChatTurn(boolean fromStudent, String text) {
    }

    private <R> R call(java.util.function.Supplier<R> request) {
        try {
            return request.get();
        } catch (RateLimitException e) {
            throw new AiUnavailableException("Trop de demandes en ce moment, réessaie dans une minute.", e);
        } catch (AnthropicServiceException e) {
            log.warn("Erreur API Claude ({}) : {}", e.statusCode(), e.getMessage());
            throw new AiUnavailableException("Le service de correction est momentanément indisponible.", e);
        } catch (AnthropicIoException e) {
            log.warn("Claude injoignable : {}", e.getMessage());
            throw new AiUnavailableException("Le service de correction est injoignable.", e);
        }
    }

    private static void checkStop(Optional<StopReason> stop) {
        if (stop.isPresent() && StopReason.REFUSAL.equals(stop.get())) {
            throw new AiUnavailableException("L'IA n'a pas pu traiter cette demande.");
        }
    }

    private void requireClient() {
        if (client == null) {
            throw new AiUnavailableException("La correction par l'IA n'est pas encore activée.");
        }
    }

    @PreDestroy
    void close() {
        if (client != null) {
            client.close();
        }
    }
}
