<div class="it-brand-wrapper">
{def $only_logo = cond(and( $pagedata.homepage|has_attribute('only_logo'), $pagedata.homepage|attribute('only_logo').data_int|eq(1) ), true(), false())}
{def $colorize_logo = cond(and($pagedata.header.logo.mime_type|eq('image/png'), and( $pagedata.homepage|has_attribute('colorize_logo'), $pagedata.homepage|attribute('colorize_logo').data_int|eq(1) )), true(), false())}
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
        {if $only_logo|not()}<h2 class="no_toc">{ezini('SiteSettings','SiteName')}</h2>{/if}
        {if openpaini('GeneralSettings','tag_line', false())}
        <h3 class="no_toc d-none d-lg-block">
            {openpaini('GeneralSettings','tag_line')|wash()}
        </h3>
        {/if}
    </div>
</a>
{undef $only_logo}
</div>