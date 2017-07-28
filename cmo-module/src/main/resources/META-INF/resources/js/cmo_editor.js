(function ($) {

  $(document).ready(function () {

    if ($("#cmo_toggleDate").prop("checked")) {
      $("#cmo_isodate").toggle();
      $("#cmo_toggleDate_approx").toggle();
      if ($("#cmo_toggleDate_approx").css("display") != "none") {
        $("#cmo_toggleDate_approx").css("display", "inline");
      }
    }

    if ($("#cmo_toggleRange").prop("checked")) {
        $("#cmo_isodate").toggle();
        $("#cmo_toggleDate_range").toggle();
        if ($("#cmo_toggleDate_range").css("display") != "none") {
          $("#cmo_toggleDate_range").css("display", "inline");
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
    $("#cmo_toggleDate_approx").toggle();
    if ($("#cmo_toggleDate_approx").css("display") != "none") {
      $("#cmo_toggleDate_approx").css("display", "inline");
    }
    if ($("#cmo_toggleRange").prop("checked")) {
      $("#cmo_toggleRange").prop("checked", false);
      $("#cmo_toggleDate_range").toggle();
      $("#cmo_toggleDate_range").css("display", "none");
    }
    else {
      $("#cmo_isodate").toggle();
    }
  });

  $("#cmo_toggleRange").click(function(e){
    $("#cmo_toggleDate_range").toggle();
    if ($("#cmo_toggleDate_range").css("display") != "none") {
      $("#cmo_toggleDate_range").css("display", "inline");
    }
    if ($("#cmo_toggleDate").prop("checked")) {
      $("#cmo_toggleDate").prop("checked", false);
      $("#cmo_toggleDate_approx").toggle();
      $("#cmo_toggleDate_approx").css("display", "none");
    }
    else {
      $("#cmo_isodate").toggle();
    }
  });

})(jQuery);