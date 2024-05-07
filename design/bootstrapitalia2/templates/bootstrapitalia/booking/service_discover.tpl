{if $offices|count()|eq(0)}
    {include uri='design:bootstrapitalia/booking/breadcrumb.tpl'}
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-12 col-lg-10">
                <div class="cmp-heading pb-3 pb-lg-4">
                    <div class="alert alert-danger">
                        <p class="lead m-0">{'Service temporarily unavailable'|i18n('bootstrapitalia/booking')}</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

{else}
    {include uri='design:bootstrapitalia/booking/breadcrumb.tpl'}
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-12 col-lg-10">
                <div class="cmp-hero">
                    <section class="it-hero-wrapper bg-white align-items-start">
                        <div class="it-hero-text-wrapper pt-0 ps-0 pb-3 pb-lg-4">
                            <h1 class="text-black" data-element="page-name">
                                Qual è la tua necessità?
                            </h1>
                            <p class="subtitle-small text-black">
                                Prenota un appuntamento per il servizio più idoneo alle tue esigenze
                            </p>
                        </div>
                    </section>
                </div>

                <div class="input-group">
                    <input type="text" class="form-control" id="discover-search">
                    <div class="input-group-append">
                        <button class="btn btn-info rounded-0" type="button" id="FindContents">{'Search'|i18n('openpa/search')}</button>
                    </div>
                </div>

                <div class="row my-5">
                    <div class="col col-4">
                        <ul class="nav nav-tabs nav-tabs-vertical" role="tablist" style="height: 100%" aria-orientation="vertical">
                            {foreach $services_categories as $index => $services_category}
                                <li class="nav-item">
                                    <a class="nav-link ps-0 d-block mw-100 text-nowrap text-uppercase{if $index|eq(0)} active{/if}" data-bs-toggle="tab" href="#cat-{$services_category.identifier}">
                                        {$services_category.category|wash()}
                                    </a>
                                </li>
                            {/foreach}
                        </ul>
                    </div>
                    <div class="col col-8">
                        <div class="tab-content">
                            {foreach $services_categories as $index => $services_category}
                                <div class="position-relative clearfix attribute-edit tab-pane{if $index|eq(0)} active{/if} px-2 mt-2" id="cat-{$services_category.identifier|wash()}">
                                    <div class="it-list-wrapper">
                                        <ul class="it-list">
                                            {foreach $services_category.services as $service}
                                                <li>
                                                    <a href="{concat('/prenota_appuntamento?service_id=', $service.id)|ezurl(no)}" class="list-item">
                                                        <div class="it-right-zone">
                                                                <span class="text mb-0">
                                                                    <span>{$service.name|wash()}</span>
                                                                    <em>{$service|attribute('abstract').content|wash()}</em>
                                                                </span>
                                                            {display_icon('it-chevron-right', 'svg', 'icon')}
                                                        </div>
                                                    </a>
                                                </li>
                                            {/foreach}
                                        </ul>
                                    </div>
                                </div>
                            {/foreach}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src={"javascript/jquery.quicksearch.js"|ezdesign}></script>
    {literal}
    <script>
        $(document).ready(function (){
          $('input#discover-search').quicksearch('ul.it-list li', {
            'delay': 100,
            'onAfter': function () {
              $('.it-list li.qs-show').each(function () {
                let tabId = $(this).parents('.tab-pane').attr('id')
                console.log($(this).text(), tabId);
              })
            },
            show: function () {
              $(this).addClass('qs-show').removeClass('qs-hide').show();
            },
            hide: function () {
              $(this).addClass('qs-hide').removeClass('qs-show').hide();
            },
          });
        })
    </script>
    {/literal}
{/if}