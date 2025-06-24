package com.vdt.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HelloController {
    @GetMapping("/hello")
    public String greet() {
//        return "hello"; // specify the view name
        return "debug_memshell_interceptor";
//        return "replace_me";
    }
}
