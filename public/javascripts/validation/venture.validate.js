$(document).ready(function() {
    $('#user_description').simplyCountable({
        counter: '#user_description_counter',
        countType: 'characters',
        maxCount: 1000,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });

    $('#user_website_URL').simplyCountable({
        counter: '#user_website_URL_counter',
        countType: 'characters',
        maxCount: 255,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });

    $('#user_venture_name').simplyCountable({
        counter: '#user_venture_name_counter',
        countType: 'characters',
        maxCount: 255,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });
});