package kz.aman;

import kz.aman.config.AppProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication
@EnableConfigurationProperties(AppProperties.class)
public class AmanApplication {

    public static void main(String[] args) {
        SpringApplication.run(AmanApplication.class, args);
    }
}
