<div class="it-brand-wrapper">
{def $only_logo = cond(and( $pagedata.homepage|has_attribute('only_logo'), $pagedata.homepage|attribute('only_logo').data_int|eq(1) ), true(), false())}
{def $colorize_logo = cond(and(is_set($pagedata.header.logo.mime_type), $pagedata.header.logo.mime_type|eq('image/png'), and( $pagedata.homepage|has_attribute('colorize_logo'), $pagedata.homepage|attribute('colorize_logo').data_int|eq(1) )), true(), false())}
<a href="{'/'|ezurl(no)}"
   title="{ezini('SiteSettings','SiteName')}"
   {if and($only_logo, openpaini('GeneralSettings','tag_line', false()))} class="d-block text-center"{/if}>
    {if $pagedata.header.logo.url}
        <img class="icon {if $colorize_logo}colorize{/if}"
             alt="{ezini('SiteSettings','SiteName')}"
             src={$pagedata.header.logo.url|ezroot()}
             {if $only_logo}style="width: auto !important;"{/if}/>
    {/if}
    <div class="it-brand-text">
        {if $only_logo|not()}<div class="it-brand-title">{ezini('SiteSettings','SiteName')}</div>{/if}
        {if openpaini('GeneralSettings','tag_line', false())}
            <div class="it-brand-tagline d-none d-md-block">{openpaini('GeneralSettings','tag_line')|wash()}</div>
        {/if}
    </div>
</a>
{undef $only_logo $colorize_logo }
</div>
