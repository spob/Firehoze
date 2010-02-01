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
