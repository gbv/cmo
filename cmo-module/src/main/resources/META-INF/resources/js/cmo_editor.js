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

      let $datetimepicker = $('.datetimepicker');
      if($datetimepicker.length>0){
          $datetimepicker.datetimepicker({
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
      }

      $("[data-toggleDate=true]").each(function (i,e) {
          let element = jQuery(e);

          let toggleApproxInput = element.find(".cmo_toggleApprox");
          let toggleRangeInput = element.find(".cmo_toggleRange");

          let cmoIsoDateBox = element.find(".cmoIsodate");
          let approxBox = element.find(".cmoApproxBox");
          let rangeBox = element.find(".cmoRangeBox");



          let showAsInline = function (element) {
              if (element.css("display") !== "none") {
                  element.css("display", "inline");
              }
          };

          if(toggleRangeInput.prop("checked")){
              cmoIsoDateBox.toggle();
              rangeBox.toggle();
              showAsInline(rangeBox);
          }

          if(toggleApproxInput.prop("checked")){
              cmoIsoDateBox.toggle();
              approxBox.toggle();
              showAsInline(approxBox);
          }

          toggleApproxInput.click(function () {
              approxBox.toggle();
              showAsInline(approxBox);

              if (toggleRangeInput.prop("checked")) {
                  toggleRangeInput.prop("checked", false);
                  rangeBox.css("display", "none");
              }
              else {
                  cmoIsoDateBox.toggle();
              }
          });

          toggleRangeInput.click(function (e) {
              rangeBox.toggle();
              showAsInline(rangeBox);

              if (toggleApproxInput.prop("checked")) {
                  toggleApproxInput.prop("checked", false);
                  approxBox.toggle();
                  approxBox.css("display", "none");
              }
              else {
                  cmoIsoDateBox.toggle();
              }
          });

      });
  }); // end document ready

})(jQuery);
