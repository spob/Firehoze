$(function() {
  $("#latest_firehoze_tweets").tweet({
    username: "firehoze",
    count: 5,
    loading_text: "loading tweets..."
  });
});
