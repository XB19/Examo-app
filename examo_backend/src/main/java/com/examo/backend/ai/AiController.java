package com.examo.backend.ai;

import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.examo.backend.ai.ExplanationService.ExplainRequest;
import com.examo.backend.ai.ExplanationService.ExplainResponse;

@RestController
public class AiController {

    private final ClaudeService claude;
    private final ExplanationService explanations;

    public AiController(ClaudeService claude, ExplanationService explanations) {
        this.claude = claude;
        this.explanations = explanations;
    }

    @GetMapping("/api/ai/status")
    public Map<String, Boolean> status() {
        return Map.of("available", claude.available());
    }

    @PostMapping("/api/explanations")
    public ExplainResponse explain(@RequestBody ExplainRequest request) {
        return explanations.explain(request);
    }

    @ExceptionHandler(AiUnavailableException.class)
    ResponseEntity<Map<String, String>> unavailable(AiUnavailableException e) {
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(Map.of("message", e.getMessage()));
    }

    @ExceptionHandler(IllegalArgumentException.class)
    ResponseEntity<Map<String, String>> badRequest(IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
    }
}
