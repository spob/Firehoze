$(document).ready(function() {
    $("#discount").validate({
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    });
});