$(document).ready(function()
{
  $('#review_headline').simplyCountable({
    counter: '#headline_counter',
    countType: 'characters',
    maxCount: 100,
    countDirection: 'down'
  });
});
