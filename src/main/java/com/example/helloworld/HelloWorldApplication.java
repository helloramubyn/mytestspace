// "package" groups related Java files together, like a folder namespace.
// This must match the folder structure: com/example/helloworld.
package com.example.helloworld;

// "import" brings in code that someone else already wrote, so we can use it.
// SpringApplication is the class that actually starts our application.
import org.springframework.boot.SpringApplication;
// @SpringBootApplication (used below) comes from this import — it's a shortcut
// annotation that turns on Spring Boot's auto-configuration magic.
import org.springframework.boot.autoconfigure.SpringBootApplication;

// An "annotation" (the @Something) is a label that tells the framework how to
// treat this class. @SpringBootApplication marks this as the entry point and
// tells Spring Boot to auto-configure a web server, scan for other components
// (like our HelloController), etc.
@SpringBootApplication
public class HelloWorldApplication {

    // Every standalone Java program needs a "main" method — this is the first
    // code that runs when you execute `java -jar app.jar`.
    public static void main(String[] args) {
        // This one line boots up the entire application: starts the embedded
        // web server (on port 8080 by default), wires up our controllers, etc.
        SpringApplication.run(HelloWorldApplication.class, args);
    }
}
