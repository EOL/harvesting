console.log("#main.js");

if(!EOL) {
  var EOL = {};

  EOL.ready = function() {
    $('.ui.dropdown').dropdown();
    $('.ui.nag').nag('show');
  };
};

$(document).on("ready page:load page:change", EOL.ready);
