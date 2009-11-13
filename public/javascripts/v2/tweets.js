$(function() {
  $("#latest_firehoze_tweets").tweet({
    username: "firehoze",
    avatar_size: 48,
    count: 5,
    loading_text: "loading tweets..."
  });
});
