$(document).ready(function() {  
    $('#ofirst_name').simplyCountable({
        counter: '#ofirst_name_counter',
        countType: 'characters',
        maxCount: 40,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });

    $('#olast_name').simplyCountable({
        counter: '#olast_name_counter',
        countType: 'characters',
        maxCount: 40,
        countDirection: 'down',
        safeClass: 'safe',
        overClass: 'over'
    });
});