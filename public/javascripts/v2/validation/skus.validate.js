$(document).ready(function() {
    $("#sku").validate({
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    });

    $('#sku_sku').simplyCountable({
        counter: '#sku_counter',
        countType: 'characters',
        maxCount: 30,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });

    $('#sku_description').simplyCountable({
        counter: '#sku_description_counter',
        countType: 'characters',
        maxCount: 150,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });
});