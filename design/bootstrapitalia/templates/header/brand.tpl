{def $only_logo = cond(and( $pagedata.homepage|has_attribute('only_logo'), $pagedata.homepage|attribute('only_logo').data_int|eq(1) ), true(), false())}
{def $original_colors = cond(or($pagedata.header.logo.mime_type|ne('image/png'), and( $pagedata.homepage|has_attribute('original_colors'), $pagedata.homepage|attribute('original_colors').data_int|eq(1) )), true(), false())}
<div class="it-brand-wrapper">
    <a href={"/"|ezurl} title="{ezini('SiteSettings','SiteName')}">
        {if $pagedata.header.logo.url}
            <img class="icon {if $original_colors|not()}colorize{/if}"
                 src={$pagedata.header.logo.url|ezroot()} alt="{ezini('SiteSettings','SiteName')}"
                 {if $only_logo}style="width: auto !important;"{/if}/>
        {/if}
        {if $only_logo|not()}
        <div class="it-brand-text">
            <h2 class="no_toc">{ezini('SiteSettings','SiteName')}</h2>
            {if openpaini('GeneralSettings','tag_line', false())}
            <h3 class="no_toc d-none d-md-block">
                {openpaini('GeneralSettings','tag_line')|wash()}
            </h3>
            {/if}
        </div>
        {/if}
    </a>
</div>
{undef $only_logo}