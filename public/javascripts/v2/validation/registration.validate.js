$(document).ready(function() {
    $(".register").validate({
        rules: {
            "registration[username]": {required: true, minlength: 3, maxlength: 25, regex : /^\w*$/, remote:"/registrations/check_user" }
        },
        messages: {
            "registration[username]": {
                required: 'You must specify a username',
                remote: 'Username already taken',
                regex: 'Username cannot contain spaces or special characters'
            }},
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    });

    $('#registration_username').simplyCountable({
        counter: '#registration_username_counter',
        countType: 'characters',
        maxCount: 25,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });

    $('#registration_email').simplyCountable({
        counter: '#registration_email_counter',
        countType: 'characters',
        maxCount: 100,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });
});
  
$.validator.addMethod(
    "regex",
    function(value, element, regexp) {
        var check = false;
        return this.optional(element) || regexp.test(value);
    },
    "Please check your input."
);