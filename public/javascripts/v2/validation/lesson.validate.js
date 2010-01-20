$(document).ready(function() {
    $(".new_lesson").validate({
        rules: {
            "lesson[title]": { required: true, remote:"/lessons/check_lesson_by_title" }},
        messages: {
            "lesson[title]": {
                required: 'Please provide a title for your lesson',
                remote: 'A lesson with this title already exists'
            }},
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            $('.upload_warning').show();
            form.submit();
        }
    });
    $(".edit_lesson").validate({
        rules: {
            "lesson[title]": { required: true }},
        messages: {
            "lesson[title]": {
                required: 'Please provide a title for your lesson'
            }},
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    });

    $('#lesson_title').simplyCountable({
        counter: '#lesson_title_counter',
        countType: 'characters',
        maxCount: 50,
        countDirection: 'down'
    });

    $('#lesson_synopsis').simplyCountable({
        counter: '#lesson_synopsis_counter',
        countType: 'characters',
        maxCount: 500,
        strictMax: true,
        countDirection: 'down'
    });
});
