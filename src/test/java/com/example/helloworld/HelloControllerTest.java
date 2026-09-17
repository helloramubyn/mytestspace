// Same package as the class under test — by convention, tests live in
// src/test/java mirroring the same package/folder structure as src/main/java.
package com.example.helloworld;

// @Test marks a method as an automated test that JUnit (the testing
// framework) should run.
import org.junit.jupiter.api.Test;
// @Autowired asks Spring to automatically supply (inject) an object we need,
// instead of us having to construct it manually.
import org.springframework.beans.factory.annotation.Autowired;
// Sets up MockMvc, a tool that lets us simulate HTTP requests to our
// controllers WITHOUT starting a real web server — fast and isolated.
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
// Boots up the full Spring application context for this test, similar to
// how the app starts for real, so our controllers/config are all wired up.
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

// "static import" lets us call these helper methods directly by name
// (e.g. get(...)) instead of writing their full class path every time.
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

// Tells the test runner to start the whole Spring Boot app for this test class.
@SpringBootTest
// Tells Spring to set up MockMvc for us so we can simulate HTTP calls.
@AutoConfigureMockMvc
class HelloControllerTest {

    // Spring automatically hands us a ready-to-use MockMvc instance here —
    // we don't create it ourselves.
    @Autowired
    private MockMvc mockMvc;

    // This method is an actual test case. Its name describes what it checks.
    @Test
    void helloEndpointReturnsGreeting() throws Exception {
        // Simulate a GET request to "/" (same as opening the app in a browser)...
        mockMvc.perform(get("/"))
                // ...and check the HTTP response code was 200 (success)...
                .andExpect(status().isOk())
                // ...and check the response body is exactly the greeting we expect.
                .andExpect(content().string("Hello, World! This is my Java app running on AKS."));
    }
}
