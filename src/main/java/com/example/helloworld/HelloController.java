// Same package as the main application class — keeps related files together.
package com.example.helloworld;

// @GetMapping lets us say "when someone visits this URL with an HTTP GET
// request, run this method."
import org.springframework.web.bind.annotation.GetMapping;
// @RestController marks this whole class as something that handles web
// requests and sends back plain data (like text or JSON) instead of a page.
import org.springframework.web.bind.annotation.RestController;

// This annotation tells Spring: "this class contains web endpoints — scan it
// and register any URLs it defines."
@RestController
public class HelloController {

    // @GetMapping("/") means: when a browser (or curl, or a load balancer
    // health check) requests the root URL "/", run this method.
    @GetMapping("/")
    public String hello() {
        // Whatever this method returns is sent back as the HTTP response body.
        // Because the class is a @RestController, Spring sends this back as
        // plain text (no HTML page needed).
        return "Hello, World! This is my Java app running on AKS.";
    }
}
