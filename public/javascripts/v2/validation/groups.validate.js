$(document).ready(function() {
    $(".new_group, .edit_group").validate({
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait dude...");
            form.submit();
        }
    })

// $('#lesson_title').simplyCountable({
//     counter: '#lesson_title_counter',
//     countType: 'characters',
//     maxCount: 50,
//     countDirection: 'down'
// });
//
// $('#lesson_synopsis').simplyCountable({
//     counter: '#lesson_synopsis_counter',
//     countType: 'characters',
//     maxCount: 500,
//     countDirection: 'down'
// });
});
