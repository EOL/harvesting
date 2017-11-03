console.log("#main.js");

if(!EOL) {
  var EOL = {};

  EOL.ready = function() {
    $('.ui.dropdown').dropdown();
    $('.ui.nag').nag('show');
    $('.message .close')
      .on('click', function() {
        $(this)
          .closest('.message')
          .transition('fade');
      });
  };
};

$(document).on("ready page:load page:change", EOL.ready);
