package hypo.driven.spring.io.springfluentd.task;


import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class HelloScheduledTask {

    @Scheduled(fixedRate = 10000) // 200ms
    public void task0() {
        log.info("hello scheduled task");
    }
}
