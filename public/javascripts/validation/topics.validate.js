$(document).ready(function() {
    $("#new_topic, #edit_topic").validate({
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    })

    $('#topic_title').simplyCountable({
        counter: '#topic_title_counter',
        countType: 'characters',
        maxCount: 200,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });
});