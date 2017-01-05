// Rebalance the central time div whenever the text changes.
$(function () {
  var $inputs = $('.resizing-input input[type=text]');

  // Resize based on text if text.length > 0
  // Otherwise resize based on the placeholder
  function resizeForText(text) {
    var $this = $(this);
    if (!text.trim()) {
      text = $this.attr('placeholder').trim();
    }
    var $span = $this.next();
    $span.text(text);
    var $inputSize = $span.width() + 10;
    $this.css("width", $inputSize);
  }

  var selector = '.resizing-input input[type=text]';
  $(document).on('keypress', selector, function (e) {
    if (e.which && e.charCode) {
      var c = String.fromCharCode(e.keyCode | e.charCode);
      var $this = $(this);
      resizeForText.call($this, $this.val() + c);
    }
  });

  // Backspace event only fires for keyup
  $(document).on('keyup', selector, function (e) {
    if (e.keyCode === 8 || e.keyCode === 46) {
      resizeForText.call($(this), $(this).val());
    }
  });

  // Also call resizing function when the window is resized.
  $(window).resize(function () {
    $(selector).each(function () {
      var $this = $(this);
      resizeForText.call($this, $this.val());
    });
  });

  $(selector).each(function () {
    var $this = $(this);
    resizeForText.call($this, $this.val())
  });
});
