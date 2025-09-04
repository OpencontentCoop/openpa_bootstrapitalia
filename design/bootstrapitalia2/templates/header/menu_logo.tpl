{def $only_logo = cond(and( $pagedata.homepage|has_attribute('only_logo'), $pagedata.homepage|attribute('only_logo').data_int|eq(1) ), true(), false())}
{def $colorize_logo = cond(and($pagedata.header.logo.mime_type|eq('image/png'), and( $pagedata.homepage|has_attribute('colorize_logo'), $pagedata.homepage|attribute('colorize_logo').data_int|eq(1) )), true(), false())}
{def $logo_is_white = cond(and( $pagedata.homepage|has_attribute('logo_is_white'), $pagedata.homepage|attribute('logo_is_white').data_int|eq(1) ), true(), false())}

<a href="#" aria-label="home Nome del Comune" class="logo-hamburger">
    {if $pagedata.header.logo.url}
        <img class="icon {if $colorize_logo}colorize{/if} {if $logo_is_white}bg-primary p-1 rounded{/if}"
          alt="{ezini('SiteSettings','SiteName')}"
          src="{render_image($pagedata.header.logo.url|ezroot(no,full)).src}"
          style="width: auto !important; {if or($logo_is_white, $only_logo)}height:50px;{/if}"/>
    {/if}
    {if $only_logo|not()}
    <div class="it-brand-text">
        <div class="it-brand-title">{ezini('SiteSettings','SiteName')}</div>
    </div>
    {/if}
</a>
{undef $only_logo $colorize_logo $logo_is_white }