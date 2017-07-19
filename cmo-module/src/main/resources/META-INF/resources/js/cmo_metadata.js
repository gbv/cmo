(function ($) {

  $(document).ready(function () {

    var isArabic = /^([\u0600-\u06ff]|[\u0750-\u077f]|[\ufb50-\ufbc1]|[\ufbd3-\ufd3f]|[\ufd50-\ufd8f]|[\ufd92-\ufdc7]|[\ufe70-\ufefc]|[\ufdf0-\ufdfd]|[ ]|[\]]|[\[])*$/g;
    $('.cmo_titleStmt').each(function(i, obj) {
      if(isArabic.test($(obj).html())) {
            $(obj).addClass('cmo_isArabic');
          }
    });


  }); // end document ready

})(jQuery);