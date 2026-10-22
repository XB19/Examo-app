package com.examo.backend.audio;

import org.springframework.boot.context.properties.ConfigurationProperties;

/** Clé et voix ElevenLabs ; la clé vient de secrets.properties (jamais commitée). */
@ConfigurationProperties("elevenlabs")
public record ElevenLabsProperties(String apiKey, String voiceId, String modelId) {

    public ElevenLabsProperties {
        if (voiceId == null || voiceId.isBlank()) {
            voiceId = "jGGIwkfv43kUFffPXEEO"; // Louis – French Documentary Narrator.
        }
        if (modelId == null || modelId.isBlank()) {
            modelId = "eleven_multilingual_v2";
        }
    }

    public boolean configured() {
        return apiKey != null && !apiKey.isBlank();
    }
}
