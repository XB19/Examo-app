package com.examo.backend.audio;

import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;

/** Synthèse vocale ElevenLabs. Sans clé configurée, {@link #available()} renvoie false. */
@Component
public class ElevenLabsService {

    private static final Logger log = LoggerFactory.getLogger(ElevenLabsService.class);
    private static final MediaType AUDIO_MPEG = MediaType.valueOf("audio/mpeg");

    private final ElevenLabsProperties props;
    private final RestClient client;

    public ElevenLabsService(ElevenLabsProperties props) {
        this.props = props;
        this.client = RestClient.builder().baseUrl("https://api.elevenlabs.io").build();
        if (!props.configured()) {
            log.warn("Aucune clé ElevenLabs (elevenlabs.api-key) : lecture des dictées désactivée.");
        }
    }

    public boolean available() {
        return props.configured();
    }

    /** Synthétise [text] avec la voix configurée et renvoie l'audio MP3. */
    public byte[] synthesize(String text) {
        if (!props.configured()) {
            throw new VoiceUnavailableException("La lecture à voix haute n'est pas encore activée.");
        }
        try {
            byte[] audio = client.post()
                    .uri("/v1/text-to-speech/{voiceId}", props.voiceId())
                    .header("xi-api-key", props.apiKey())
                    .contentType(MediaType.APPLICATION_JSON)
                    .accept(AUDIO_MPEG)
                    .body(Map.of("text", text, "model_id", props.modelId()))
                    .retrieve()
                    .body(byte[].class);
            if (audio == null || audio.length == 0) {
                throw new VoiceUnavailableException("La lecture à voix haute n'a renvoyé aucun son.");
            }
            return audio;
        } catch (RestClientResponseException e) {
            log.warn("Erreur API ElevenLabs ({}) : {}", e.getStatusCode(), e.getResponseBodyAsString());
            throw new VoiceUnavailableException("La lecture à voix haute est momentanément indisponible.", e);
        } catch (ResourceAccessException e) {
            log.warn("ElevenLabs injoignable : {}", e.getMessage());
            throw new VoiceUnavailableException("La lecture à voix haute est injoignable.", e);
        }
    }
}
