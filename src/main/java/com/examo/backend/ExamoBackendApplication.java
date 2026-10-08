package com.examo.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan
public class ExamoBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(ExamoBackendApplication.class, args);
	}

}
