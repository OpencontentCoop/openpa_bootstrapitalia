(function ($, window, document, undefined) {
    "use strict";
    var pluginName = "initOwlCarousel";

    function InitOwlCarousel(container, options, showPreview, widePreview, controlButtons) {
        var owl = $(container);
        owl.owlCarousel(options);
        // if (showPreview) {
        //     owl.on('changed.owl.carousel', function (e) {
        //         $(e.target).find('[data-index]').removeClass('active').find('a').removeClass('focus');
        //         $(e.target).find('[data-index="' + e.item.index + '"]').addClass('active').find('a').addClass('focus');
        //     });
        //
        //     var previewContainer = $('<div class="owl-preview-container" />');
        //     var preview = $('<ul class="owl-preview" />');
        //     owl.find('.carousel-caption h3').each(function (index) {
        //         var item = $('<li data-index="' + index + '" />');
        //         var link = $($(this).html());
        //         link.bind('click', function (event) {
        //             owl.trigger('to.owl.carousel', [index, 250, true]);
        //             event.preventDefault();
        //         });
        //         if (index === 0) {
        //             item.addClass('active');
        //             link.addClass('focus');
        //         }
        //         preview.append(item.append(link));
        //     });
        //
        //     if (widePreview) {
        //         var wideContainer = $('<div class="text-center" />');
        //         preview.appendTo(wideContainer);
        //         wideContainer.appendTo(previewContainer);
        //     } else {
        //         preview.appendTo(previewContainer);
        //     }
        //     previewContainer.appendTo(owl);
        // }

        if ( controlButtons )
        {
          var contolContainer = $('<div class="control-buttons"></div>');
          var pauseButton = $('<a href="#" title="Ferma"><i class="fa fa-pause"></i></a>');
          var playButton = $(' <a href="#" title="Avvia" class="d-none"><i class="fa fa-play"></i></a>');

          contolContainer.append(pauseButton);
          contolContainer.append(playButton);
          owl.append(contolContainer);

          pauseButton.bind('click', function (event) {
            event.preventDefault();
            owl.trigger('stop.owl.autoplay');
            playButton.removeClass('d-none');
            pauseButton.addClass('d-none');
          });

          playButton.bind('click', function (event) {
            event.preventDefault();
            owl.trigger('play.owl.autoplay',[1000]);
            pauseButton.removeClass('d-none');
            playButton.addClass('d-none');
          });


        }

    }

    $.fn[pluginName] = function (options, showPreview, widePreview, controlButtons) {
        return this.each(function () {
            if (!$.data(this, pluginName)) {
                $.data(this, pluginName, new InitOwlCarousel(this, options, showPreview, widePreview, controlButtons));
            }
        });
    };

})(jQuery, window, document);
