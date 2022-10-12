<header class="it-header-wrapper it-header-sticky" data-bs-toggle="sticky" data-bs-position-type="fixed" data-bs-sticky-class-name="is-sticky" data-bs-target="#header-nav-wrapper">
    {include uri='design:page_toolbar.tpl'}
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
                                {include uri='design:header/search.tpl'}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        {include uri='design:header/navbar.tpl'}
    </div>
</header>