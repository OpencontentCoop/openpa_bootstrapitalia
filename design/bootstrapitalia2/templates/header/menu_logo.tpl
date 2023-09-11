{def $only_logo = cond(and( $pagedata.homepage|has_attribute('only_logo'), $pagedata.homepage|attribute('only_logo').data_int|eq(1) ), true(), false())}
{def $colorize_logo = cond(and($pagedata.header.logo.mime_type|eq('image/png'), and( $pagedata.homepage|has_attribute('colorize_logo'), $pagedata.homepage|attribute('colorize_logo').data_int|eq(1) )), true(), false())}
<a href="#" aria-label="home Nome del Comune" class="logo-hamburger">
    {if $pagedata.header.logo.url}
        <img class="icon {if $colorize_logo}colorize{/if}"
             title="{ezini('SiteSettings','SiteName')}"
             alt="{ezini('SiteSettings','SiteName')}"
             src="{image_url($pagedata.header.logo.url|ezroot(no,full), false(), false())}"
             style="width: auto !important;"/>
    {/if}
    <div class="it-brand-text">
        <div class="it-brand-title">{ezini('SiteSettings','SiteName')}</div>
    </div>
</a>
{undef $only_logo $colorize_logo }