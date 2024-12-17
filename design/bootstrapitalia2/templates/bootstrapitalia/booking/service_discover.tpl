{if $services_categories|count()|eq(0)}
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
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-12 col-lg-10">
                <div class="cmp-hero">
                    <section class="it-hero-wrapper bg-white align-items-start">
                        <div class="it-hero-text-wrapper pt-0 ps-0 pb-3 pb-lg-4">
                            <h1 class="text-black" data-element="page-name">
                                {'Appointment booking'|i18n('bootstrapitalia/booking')}
                            </h1>
                            <p class="subtitle-small text-black">
                                {'Book an appointment for the service best suited to your needs'|i18n('bootstrapitalia/booking')}
                            </p>
                        </div>
                    </section>
                </div>

                <div class="form-group floating-labels">
                    <div class="form-label-group pr-2 pe-2 pe-2">
                        <input type="text"
                               class="form-control pl-0 ps-0"
                               id="discover-search"
                               name="SearchText"
                               value=""
                               placeholder="{'Search text'|i18n('bootstrapitalia/documents')}"/>
                        <label class="pl-0 ps-0" for="discover-text">{'Search'|i18n('openpa/search')}</label>
                        <button id="ResetButton" class="autocomplete-icon btn btn-link" style="right: 45px;display:none" aria-label="{'Cancel'|i18n('design/base')}">
                            {display_icon('it-close', 'svg', 'icon')}
                        </button>
                        <button class="autocomplete-icon btn btn-link" aria-label="{'Search'|i18n('openpa/search')}">
                            {display_icon('it-search', 'svg', 'icon')}
                        </button>
                    </div>
                    <em style="display:none" id="NoResult">{'The service you are looking for is not available for appointment booking'|i18n('bootstrapitalia/booking')}</em>
                </div>

                <div class="row my-5">
                    <div class="col col-4">
                        <ul class="nav nav-tabs nav-tabs-vertical overflow-hidden" role="tablist" style="height: 100%" aria-orientation="vertical">
                            {foreach $services_categories as $index => $services_category}
                                <li class="nav-item service-discover-category" data-category="cat-{$services_category.identifier}">
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
                                                                    <em class="w-75">
                                                                        {$service|attribute('abstract').content|wash()}
                                                                        {if $service|has_attribute('produces_output')}
                                                                            <span class="d-none">
                                                                            {foreach $service|attribute('produces_output').content.relation_list as $item}{*
                                                                            *}<i class="fa fa-tag"></i> {fetch(content,object,hash('object_id', $item.contentobject_id)).name|wash()}{delimiter} {/delimiter}{*
                                                                            *}{/foreach}
                                                                            </span>
                                                                        {/if}
                                                                    </em>
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
          let searchInput = $('input#discover-search');
          let resetButton = $('#ResetButton');
          let noResult = $('#NoResult')
          searchInput.quicksearch('ul.it-list li', {
            'delay': 0,
            'onNoResultFound': function (){
              noResult.show();
            },
            'onAfter': function () {
              let activeTag = false
              $('.service-discover-category').each(function (i) {
                let tabId = $(this).data('category')
                let hasContent = $('.qs-show', $('#'+tabId)).length > 0
                if (hasContent){
                  $(this).show()
                  if (!activeTag) {
                    activeTag = tabId
                  }
                }else{
                  $(this).hide().find('.active').removeClass('active')
                }
              })
              if (activeTag !== false){
                bootstrap.Tab.getOrCreateInstance($('[data-category="'+activeTag+'"] a')[0]).show();
              }
            },
            show: function () {
              $(this).addClass('qs-show').removeClass('qs-hide').show();
            },
            hide: function () {
              $(this).addClass('qs-hide').removeClass('qs-show').hide();
            },
            'prepareQuery': function (val) {
              noResult.hide();
              if (val.length > 0){
                resetButton.show();
              } else {
                resetButton.hide();
              }
              return val.toLowerCase().split(' ');
            }
          });
          resetButton.on('click', function (e){
            $(this).hide();
            searchInput.val('').reset();
            e.preventDefault();
          });
        })
    </script>
    {/literal}
{/if}