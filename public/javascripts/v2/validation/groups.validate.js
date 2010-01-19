$(document).ready(function() {
    $(".new_group").validate({
        rules: {
            "group[name]": { required: true, remote:"/groups/check_group_by_name" }},
        messages: {
            "group[name]": {
                required: 'Please provide a name for your group',
                remote: 'A group with this name already exists'
            }},
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    });
    $(".edit_group").validate({
        rules: {
            "group[name]": { required: true }},
        messages: {
            "group[name]": {
                required: 'Please provide a name for your group'
            }},
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    });

    $('#group_name').simplyCountable({
        counter: '#group_name_counter',
        countType: 'characters',
        maxCount: 50,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });
});