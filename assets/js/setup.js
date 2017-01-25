// Setup default values for the input fields at page load.
$(function () {
  // Set the current time every 5 seconds.
  var dateUpdate = function () {
    var date = new Date();
    var day = date.toLocaleTimeString('en-US', {weekday: "long"});
    var time = date.toLocaleTimeString('en-US', {hour: '2-digit', minute: '2-digit'});

    // Set the placeholder values for the input fields.
    day = day.substring(0, day.indexOf(' '));
    $('#day').attr('placeholder', day);
    $('#actualDay').attr('value', day);
    $('#time').attr('placeholder', time);
    $('#actualTime').attr('value', time);
  };
  setInterval(dateUpdate, 5000);
  dateUpdate();

  // This is a crazy hack, but the upside is that I get the semantics of a single-page
  // application, without any of the state maintenance.
  var updateRecommendation = function () {
    $.post('/', $('#when').serialize(), function (data) {
      // Create a temporary element from the returned page.
      parsed = $(data);

      // Drop it in and hope no one notices.
      var form = parsed.siblings('.resizing-input');
      var output = parsed.siblings('#recommendation');
      $('.resizing-input').replaceWith(form);
      $('#recommendation').replaceWith(output);

      // Force the page to update.
      dateUpdate();
      $(window).trigger('resize');
    });
  };
  updateRecommendation();

  // Setup an event listener to automatically update state whenever a change is
  // detected.
  $(document).on('change', '#when', updateRecommendation);
});
