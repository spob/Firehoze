$(document).ready(function() {  
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