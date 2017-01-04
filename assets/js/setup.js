// Setup default values for the input fields at page load.
$(function () {
  // Get the current day of the week and hour.
  var date = new Date();
  var day = date.toLocaleTimeString([], {weekday: "long"});
  var time = date.toLocaleTimeString([], {hour: '2-digit', minute: '2-digit'});

  // Set the placeholder values for the input fields.
  $('#day').attr('placeholder', day.substring(0, day.indexOf(' ')));
  $('#time').attr('placeholder', time);

  // Setup an event listener to automatically submit the form whenever a change is
  // detected.
  $('#when').on('change', function () {
    $(this).closest('form').submit();
  });
});
