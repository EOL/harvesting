console.log("#main.js");

if(!EOL) {
  var EOL = {};

  EOL.ready = function() {
    $('.ui.dropdown').dropdown();
  };
};

$(document).on("ready page:load page:change", EOL.ready);
