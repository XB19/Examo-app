package com.examo.backend.ai;

import org.springframework.boot.context.properties.ConfigurationProperties;

/** Clé et modèle Claude ; la clé vient de secrets.properties (jamais commitée). */
@ConfigurationProperties("anthropic")
public record AiProperties(String apiKey, String model) {

    public AiProperties {
        if (model == null || model.isBlank()) {
            model = "claude-opus-5-5";
        }
    }

    public boolean configured() {
        return apiKey != null && !apiKey.isBlank();
    }
}
