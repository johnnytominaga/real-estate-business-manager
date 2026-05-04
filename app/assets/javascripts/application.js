// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui
//= require jquery-ui/widgets/datepicker
//= require jquery-ui/widgets/slider
//= require jquery-ui/widgets/autocomplete
//= require jquery.easing
//= require lightbox/lightbox
//= require jquery.waypoints
//= require jquery.touchSwipe
//= require bootstrap
//= require superfish
//= require hoverIntent
//= require wow
//= require isotope
//= require countUp
//= require rails-ujs
//= require toastr
//= require autocomplete-rails
//= require owl.carousel
//= require cable
//= require activestorage
//= require clipboard
//= require main
//= require rails_admin/custom/ui

//= require_tree .

jQuery(document).ready(function( $ ) {
  $(function () {
    toastr.options = {
      "closeButton": true,
      "newestOnTop": false,
      "progressBar": true,
      "positionClass": "toast-bottom-left",
      "preventDuplicates": true,
      "showDuration": "300",
      "hideDuration": "1000",
      "timeOut": "5000",
      "extendedTimeOut": "1000",
      "showEasing": "swing",
      "hideEasing": "linear",
      "showMethod": "fadeIn",
      "hideMethod": "fadeOut"
      };
  });


});
