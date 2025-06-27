{def $additional_logo = cond(and( $pagedata.homepage|has_attribute('additional_logo'), $pagedata.homepage|attribute('additional_logo').has_content ), $pagedata.homepage|attribute('additional_logo'), false())}
<header class="it-header-wrapper it-header-sticky" data-bs-toggle="sticky" data-bs-position-type="fixed" data-bs-sticky-class-name="is-sticky" data-bs-target="#header-nav-wrapper" style="z-index: 6">
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
                                {if $additional_logo}
                                    <div class="additional-logo d-none d-lg-block">
                                        <img style="width: auto;height: 82px;vertical-align: middle;margin-right:30px"
                                             alt="{$additional_logo.content.data_map.image.content.alternative_text}"
                                             src="{render_image($additional_logo.content.data_map.image.content.reference.url|ezroot(no,full)).src}"  />
                                    </div>
                                {/if}
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
{undef $additional_logo}