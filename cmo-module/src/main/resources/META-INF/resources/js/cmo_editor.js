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

        $("body").on("click", ".expand-item", function () {
            if($(this).attr("data-target")){
                $(this).closest(".form-group").next($(this).attr("data-target")).toggleClass("hidden");
            }
            else {
                $(this).closest(".cmo-fieldset-modsName").toggleClass("hiddenDetail").next().toggleClass("hidden");
            }
            if($(this).hasClass("fa-chevron-down")) {
                $(this).removeClass("fa-chevron-down");
                $(this).addClass("fa-chevron-up");
            }
            else {
                $(this).removeClass("fa-chevron-up");
                $(this).addClass("fa-chevron-down");
            }
        });

        $("[data-toggleDate=true]").each(function (i, e) {
            let element = jQuery(e);

            let toggleApproxInput = element.find(".cmo_toggleApprox");
            let toggleRangeInput = element.find(".cmo_toggleRange");

            let cmoIsoDateBox = element.find(".cmoIsodate");
            let approxBox = element.find(".cmoApproxBox");
            let rangeBox = element.find(".cmoRangeBox");


            let showAsInline = function (element) {
                if (element.css("display") !== "none") {
                    element.css("display", "");
                }
            };

            if (toggleRangeInput.prop("checked")) {
                cmoIsoDateBox.toggle();
                rangeBox.toggle();
                showAsInline(rangeBox);
            }

            if (toggleApproxInput.prop("checked")) {
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

        $("body").on("focusout", ".personExtended-container input[name*='mods:nameIdentifier']:first", function() {
            if($(this).val() == "") {
                $(this).parents(".personExtended_box").find(".search-person .input-group > a").remove();
            }
        });

    }); // end document ready

})(jQuery);
