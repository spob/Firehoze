$(function() {

    $("#profile").validate({
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    });
    $("#author").validate({
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    });
    
    $("#password_form").validate({
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    });

    $("#avatar_form").validate({
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    });

    $("#password_form").validate({
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    });

    $("#privacy").validate({
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    });

});


$(function() {

  $('#user_login').simplyCountable({
    counter: '#login_counter',
    countType: 'characters',
    maxCount: 25,
    countDirection: 'down',
    safeClass: 'safe',
    overClass: 'over'
  });

  $('#user_email').simplyCountable({
    counter: '#email_counter',
    countType: 'characters',
    maxCount: 100,
    countDirection: 'down',
    safeClass: 'safe',
    overClass: 'over'
  });

  $('#user_first_name').simplyCountable({
    counter: '#first_name_counter',
    countType: 'characters',
    maxCount: 40,
    countDirection: 'down',
    safeClass: 'safe',
    overClass: 'over'
  });

  $('#user_last_name').simplyCountable({
    counter: '#last_name_counter',
    countType: 'characters',
    maxCount: 40,
    countDirection: 'down',
    safeClass: 'safe',
    overClass: 'over'
  });

});
