// Be sure to read the Rails docs before modifying this file.
//
//= require jquery
//= require jquery_ujs
//= require main

$('.message .close')
  .on('click', function() {
    $(this)
      .closest('.message')
      .transition('fade');
  });