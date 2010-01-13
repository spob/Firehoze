$(document).ready(function() {
    $("#order").validate({
        errorElement: "span",
        success: "valid",
        submitHandler: function(form) {
            $(form).find(":submit").attr("disabled", true).attr("value", "Please wait ...");
            form.submit();
        }
    });

    $('#order_first_name').simplyCountable({
        counter: '#order_first_name_counter',
        countType: 'characters',
        maxCount: 50,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });

    $('#order_last_name').simplyCountable({
        counter: '#order_last_name_counter',
        countType: 'characters',
        maxCount: 50,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });

    $('#order_billing_name').simplyCountable({
        counter: '#order_billing_name_counter',
        countType: 'characters',
        maxCount: 100,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });

    $('#order_address1').simplyCountable({
        counter: '#order_address1_counter',
        countType: 'characters',
        maxCount: 150,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });

    $('#order_address2').simplyCountable({
        counter: '#order_address2_counter',
        countType: 'characters',
        maxCount: 150,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });

    $('#order_city').simplyCountable({
        counter: '#order_city_counter',
        countType: 'characters',
        maxCount: 50,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });

    $('#order_state').simplyCountable({
        counter: '#order_state_counter',
        countType: 'characters',
        maxCount: 50,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });

    $('#order_zip').simplyCountable({
        counter: '#order_zip_counter',
        countType: 'characters',
        maxCount: 25,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });
});
