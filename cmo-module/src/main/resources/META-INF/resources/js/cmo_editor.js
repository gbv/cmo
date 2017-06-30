(function ($) {

  $(document).ready(function () {

    if ($("#cmo_toggleDate").prop("checked")) {
      $("#cmo_isodate").toggle();
      $("#cmo_toggleDate_approx").toggle();
      if ($("#cmo_toggleDate_approx").css("display") != "none") {
        $("#cmo_toggleDate_approx").css("display", "inline");
      }
    }

    $('[data-toggle="popover"]').popover();

    $('.datetimepicker').datetimepicker({
      format: 'YYYY-MM-DD',
      icons: {
        time: 'fa fa-time',
        date: 'fa fa-calendar',
        up: 'fa fa-chevron-up',
        down: 'fa fa-chevron-down',
        previous: 'fa fa-chevron-left',
        next: 'fa fa-chevron-right',
        today: 'fa fa-screenshot',
        clear: 'fa fa-trash',
        close: 'fa fa-remove'
      }
    });
  }); // end document ready


  $("#cmo_toggleDate").click(function(e){
    // e.preventDefault();
    $("#cmo_isodate").toggle();
    $("#cmo_toggleDate_approx").toggle();
    if ($("#cmo_toggleDate_approx").css("display") != "none") {
      $("#cmo_toggleDate_approx").css("display", "inline");
    }
  });

})(jQuery);