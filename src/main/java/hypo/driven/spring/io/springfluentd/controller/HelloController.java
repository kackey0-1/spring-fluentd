package hypo.driven.spring.io.springfluentd.controller;

import hypo.driven.spring.io.springfluentd.controller.dto.BaseResponse;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequestMapping("/hello")
public class HelloController {

    @GetMapping("/{name}")
    public ResponseEntity helloWorld(@PathVariable("name") String name) {
        log.info("sample log");
        BaseResponse response = BaseResponse.success();
        Message message = new Message(String.format("Hello %s", name));
        response.setData(message);
        return new ResponseEntity(response, HttpStatus.OK);
    }

    @Data
    @AllArgsConstructor
    public static class Message {
        private String message;
    }
}
