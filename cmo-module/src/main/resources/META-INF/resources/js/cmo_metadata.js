(function ($) {

  $(document).ready(function () {

    var isArabic = /^([\u0600-\u06ff]|[\u0750-\u077f]|[\ufb50-\ufbc1]|[\ufbd3-\ufd3f]|[\ufd50-\ufd8f]|[\ufd92-\ufdc7]|[\ufe70-\ufefc]|[\ufdf0-\ufdfd]|[ ]|[\]]|[\[])*$/g;
    $('.cmo_titleStmt').each(function(i, obj) {
      if(isArabic.test($(obj).html())) {
            $(obj).addClass('cmo_isArabic');
            $(obj).attr('dir', 'rtl');
          }
    });


      $("#modal-pi-add").click(function () {
          let button = jQuery(this);
          let mcrId = button.attr("data-mycoreID");
          let baseURL = button.attr("data-baseURL");
          let service = button.attr("data-register-pi");
          let resource = baseURL + "rsc/pi/registration/service/" + service + "/" + mcrId;
          let type = button.attr("data-type");

          $.ajax({
              type: 'POST',
              url: resource,
              data: {}
          }).done(function (result) {
              window.location.search = "XSL.Status.Message=component.pi.register." + type + ".success&XSL.Status.Style=success";
          }).fail(function (result) {
              if ("responseJSON" in result && "code" in result.responseJSON) {
                  window.location.search = "XSL.Status.Message=component.pi.register.error." + result.responseJSON.code + "&XSL.Status.Style=danger";
              } else {
                  window.location.search = "XSL.Status.Message=component.pi.register." + type + ".error&XSL.Status.Style=danger";
              }
          });
      });

      $("[data-register-pi]").click(function () {
          let registerButton = $(this);
          replaceI18n($("#modal-pi"), $(this).attr("data-register-pi")).then(function () {
              setPiModalDataAndShow(registerButton);
          });
      });

      $(".searchfield_box form").submit(function() {
          $("input").each(function(i,elem){ if($(elem).prop("value").length==0){ $(elem).prop("disabled", "disabled"); } });
      });

  }); // end document ready

    function setPiModalDataAndShow(button) {
        let modalButton = $("#modal-pi-add");
        button.attr("data-mycoreID") ? modalButton.attr("data-mycoreID", button.attr("data-mycoreID")) : modalButton.removeAttr("data-mycoreID");
        button.attr("data-baseURL") ? modalButton.attr("data-baseURL", button.attr("data-baseURL")) : modalButton.removeAttr("data-baseURL");
        button.attr("data-register-pi") ? modalButton.attr("data-register-pi", button.attr("data-register-pi")) : modalButton.removeAttr("data-register-pi");
        button.attr("data-type") ? modalButton.attr("data-type", button.attr("data-type")) : modalButton.removeAttr("data-type");
        $("#modal-pi").modal("show");
    }

    function replaceI18n(element, suffix) {
        var requests = [];
        $(element).find("[data-i18n]").each(function () {
            requests.push(getI18n($(this).attr("data-i18n") + suffix, $(this)));
        });
        return $.when.apply($, requests);
    }

    function getI18n(i18nKey, currentElm) {
        return $.ajax({
            url: webApplicationBaseURL + "rsc/locale/translate/" + $("html").attr("lang") + "/" + i18nKey,
            type: "GET"
        }).done(function (text) {
            $(currentElm).html(text);

        }).fail(function () {
            console.log("Can not get i18nKey: " + i18nKey);
            $(currentElm).html(i18nKey);
        });
    }

})(jQuery);
