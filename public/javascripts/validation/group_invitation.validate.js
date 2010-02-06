$(document).ready(function() {
    $("#inline").validate({
        rules: {
            "group_invitation[to_user]": {remote:"/group_invitations/check_user" },
            "group_invitation[to_user_email]": {email: true, remote:"/group_invitations/check_user" }
        },
        messages: {
            "group_invitation[to_user]": {
                remote: 'No such user'
            },    
            "group_invitation[to_user_email]": {
                email: 'Please enter a valid email address',
                remote: 'No such user'
            }},
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    });
});