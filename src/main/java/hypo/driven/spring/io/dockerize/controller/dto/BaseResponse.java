package hypo.driven.spring.io.dockerize.controller.dto;

import lombok.Data;

@Data
public class BaseResponse<T> {
    private String status;
    private String statusMessage;
    private T data;

    public static <T> BaseResponse success() {
        BaseResponse<T> response = new BaseResponse<>();
        response.setStatus("SUCCESS");
        response.setStatusMessage("Request successfully finished.");
        return response;
    }
}
