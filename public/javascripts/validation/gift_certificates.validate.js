$(document).ready(function() {
    $("#gift_certificate").validate({
        rules: {
            "gift_certificate[code]": {required: true, remote:"/gift_certificates/check_gift_certificate_code" }
        },
        messages: {
            "gift_certificate[code]": {
                required: 'You must specify a gift certificate',
                remote: 'This is not a valid gift certificate code'
            }},
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    })
});
