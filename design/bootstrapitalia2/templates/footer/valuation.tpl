{def $load_deferred = false()}
{if is_set($satisfy_entrypoint)|not()}
    {def $satisfy_entrypoint = satisfy_main_entrypoint()}
    {set $load_deferred = true()}
{/if}
{if $satisfy_entrypoint}
    <div class="bg-primary">
        <div class="container">
            <div class="row d-flex justify-content-center">
                <div class="col-12 col-lg-6 p-lg-0 px-4 satisfy-placeholder" data-load_deferred="{$load_deferred|int()}" data-satisfy="{$satisfy_entrypoint}">
                    <div class="cmp-rating mt-lg-80 mb-lg-80 p-0 bg-white" data-element="feedback"></div>
                </div>
            </div>
        </div>
    </div>
    {literal}
    <script>
      $(document).ready(function () {
        var scriptSource = "{/literal}{openpaini('StanzaDelCittadinoBridge', 'BuiltInWidgetSource_satisfy', 'https://satisfy.opencontent.it/widget_ns.js')}{literal}";
        let isInViewport = function(el) {
          var elementTop = el.offset().top;
          var elementBottom = elementTop + el.outerHeight();
          var viewportTop = $(window).scrollTop();
          var viewportBottom = viewportTop + $(window).height();
          return elementBottom > viewportTop && elementTop < viewportBottom;
        };
        let satisfyIsLoaded = false;
        let loadWidget = function(){
          if (!satisfyIsLoaded) {
            let needLoadWidget = false;
            $('[data-satisfy]').each(function () {
              let deferredLoad = $(this).data('load_deferred') === 1;
              if (isInViewport($(this)) || !deferredLoad) {
                //console.log('Start satisfy at entrypoint ' + $(this).data('satisfy'));
                $(this).html('<app-widget data-entrypoints="' + $(this).data('satisfy') + '"></app-widget>');
                needLoadWidget = true;
              }
            });
            if (needLoadWidget) {
              $.getScript(scriptSource, function () {
                //console.log('Satisfy widget is loaded');
              });
              satisfyIsLoaded = true;
            }
          }
        }
        $(window).on('resize scroll', function () {
          loadWidget();
        });
        loadWidget();
      });
    </script>
    {/literal}
{/if}
{undef $load_deferred}