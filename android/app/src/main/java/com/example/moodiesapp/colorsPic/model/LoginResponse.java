package com.example.moodiesapp.colorsPic.model;

public class LoginResponse {

    /**
     * status : success
     * msg : Image uplopaded.
     * data : {"Image":"http://ignitiveit.com/moodies//storage/app/misc_image/w0lNO3TNfJqW18Hzvqex9gca7C5laPzbyA5gk8Tp.jpeg"}
     */

    private String status;
    private String msg;
    private DataBean data;

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public DataBean getData() {
        return data;
    }

    public void setData(DataBean data) {
        this.data = data;
    }

    public static class DataBean {
        /**
         * Image : http://ignitiveit.com/moodies//storage/app/misc_image/w0lNO3TNfJqW18Hzvqex9gca7C5laPzbyA5gk8Tp.jpeg
         */

        private String Image;

        public String getImage() {
            return Image;
        }

        public void setImage(String Image) {
            this.Image = Image;
        }
    }
}
