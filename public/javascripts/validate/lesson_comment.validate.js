$(document).ready(function() {
    $("#lesson_comment").validate({
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait...");
            form.submit();
        }
    })
});
