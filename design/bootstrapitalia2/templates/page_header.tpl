<header class="it-header-wrapper it-header-sticky" data-bs-toggle="sticky" data-bs-position-type="fixed" data-bs-sticky-class-name="is-sticky" data-bs-target="#header-nav-wrapper" style="z-index: 6">
    
    {include uri='design:page_toolbar.tpl'}
    
    <div class="it-header-slim-wrapper theme-light bs-is-sticky border-bottom"
      data-bs-toggle="sticky"
      style="top: 0px;">
      <div class="container">
        <div class="row">
          <div class="col-12">
            <div class="it-header-slim-wrapper-content justify-content-center">
              <span class="fw-semibold text-secondary">In caso di situazioni di pericolo immediato chiama il 112 oppure fai qualcosa di saggio tipo scappare</span>
              <a href="#"
                class="fw-semibold link-primary text-nowrap d-inline-flex ms-2">
                {'Read more'|i18n('bootstrapitalia')}
              </a>
            </div> 
          </div>
        </div>
      </div>
    </div>

    {include uri='design:header/service.tpl'}

    <div class="it-nav-wrapper">
        <div class="it-header-center-wrapper{if current_theme_has_variation('light_center')} theme-light{/if}">
            <div class="container">
                <div class="row">
                    <div class="col-12">
                        <div class="it-header-center-content-wrapper">
                            {include uri='design:logo.tpl'}
                            <div class="it-right-zone">
                                {include uri='design:header/social.tpl' css="d-none d-lg-flex"}
                                {if openpaini('GeneralSettings', 'ShowHeaderSearch', 'enabled')|eq('enabled')}
                                    {include uri='design:header/search.tpl'}
                                {/if}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        {include uri='design:header/navbar.tpl'}
    </div>
</header>