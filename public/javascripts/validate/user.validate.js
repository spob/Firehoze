$(document).ready(function() {
    $("#new_user").validate({
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait...");
            form.submit();
        }
    })
});
