$(document).ready(function()
{
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
    countDirection: 'down'
  });
});
