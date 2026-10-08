package com.examo.backend.config;

import java.nio.file.Path;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties("examo")
public record ExamoProperties(Path storageDir, boolean importOnStartup) {
}
