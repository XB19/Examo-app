package com.examo.backend.audio;

public class VoiceUnavailableException extends RuntimeException {

    public VoiceUnavailableException(String message) {
        super(message);
    }

    public VoiceUnavailableException(String message, Throwable cause) {
        super(message, cause);
    }
}
