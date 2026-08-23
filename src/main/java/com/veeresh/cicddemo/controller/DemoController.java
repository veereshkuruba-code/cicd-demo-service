package com.veeresh.cicddemo.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/demo")
public class DemoController {

    @Value("${spring.application.name}")
    private String applicationName;

    @Value("${app.version:1.0.0}")
    private String version;

    @Value("${app.build-number:local}")
    private String buildNumber;

    @GetMapping("/hello")
    public Map<String, String> hello() {
        return Map.of(
                "message", "Hello from CI/CD Demo Service"
        );
    }

    @GetMapping("/version")
    public Map<String, String> version() {
        return Map.of(
                "application", applicationName,
                "version", version,
                "buildNumber", buildNumber
        );
    }
}