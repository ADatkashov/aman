package kz.aman.config;

import kz.aman.service.SmsSender;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SmsConfig {

    private static final Logger log = LoggerFactory.getLogger(SmsConfig.class);

    /**
     * Fallback used until an SMS gateway {@link SmsSender} bean is provided.
     * It never logs the message because it contains the one-time code.
     */
    @Bean
    @ConditionalOnMissingBean(SmsSender.class)
    SmsSender noGatewaySmsSender() {
        return (phone, message) -> log.warn("No SMS gateway configured: one-time code was not delivered");
    }
}
