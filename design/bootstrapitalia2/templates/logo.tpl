{def $additional_logo = cond(and( $pagedata.homepage|has_attribute('additional_logo'), $pagedata.homepage|attribute('additional_logo').has_content ), $pagedata.homepage|attribute('additional_logo'), false())}
{def $only_logo = cond(and( $pagedata.homepage|has_attribute('only_logo'), $pagedata.homepage|attribute('only_logo').data_int|eq(1) ), true(), false())}
{def $colorize_logo = cond(and(is_set($pagedata.header.logo.mime_type), $pagedata.header.logo.mime_type|eq('image/png'), and( $pagedata.homepage|has_attribute('colorize_logo'), $pagedata.homepage|attribute('colorize_logo').data_int|eq(1) )), true(), false())}
{def $double_logo = cond(and(current_theme_has_variation('light_center'), current_theme_has_variation('light_navbar')|not(), $pagedata.homepage|has_attribute('footer_logo'), $pagedata.homepage|attribute('footer_logo').data_type_string|eq('ezimage')), true(), false())}

<div class="it-brand-wrapper{if $additional_logo} d-flex{/if}">
  <a href="{'/'|ezurl(no)}"
     title="{ezini('SiteSettings','SiteName')}"
     {if and($only_logo, openpaini('GeneralSettings','tag_line', false()))} class="d-block text-center"{/if}>
      {if $double_logo}
        <img class="icon{if $colorize_logo} colorize{/if} oc-fix-double-logo-rev"
             alt="{ezini('SiteSettings','SiteName')}"
             src="{render_image($pagedata.homepage|attribute('footer_logo').content['header_logo'].full_path|ezroot(no,full)).src}"
             style="width: auto !important;" />
      {/if}
      {if $pagedata.header.logo.url}
        <img class="icon{if $colorize_logo} colorize{/if} {if $double_logo}oc-fix-double-logo-base{/if}"
             alt="{ezini('SiteSettings','SiteName')}"
            src="{render_image($pagedata.header.logo.url|ezroot(no,full)).src}"
            style="width: auto !important;" />
      {/if}
      <div class="it-brand-text">
          {if $only_logo|not()}
              {if and(is_set($in_footer),$in_footer)}
                  <h2>{ezini('SiteSettings','SiteName')}</h2>
              {else}
                  <div class="it-brand-title">{ezini('SiteSettings','SiteName')}</div>
              {/if}
          {/if}
          {if openpaini('GeneralSettings','tag_line', false())}
              <div class="it-brand-tagline d-none d-md-block">{openpaini('GeneralSettings','tag_line')|wash()}</div>
          {/if}
      </div>
  </a>
  {if $additional_logo}
    <div class="additional-logo d-none d-lg-block">
      <img style="width: auto;height: 82px;vertical-align: middle;"
           alt="{$additional_logo.content.data_map.image.content.alternative_text}"
           src="{render_image($additional_logo.content.data_map.image.content.reference.url|ezroot(no,full)).src}"  />
    </div>
    <style>.cloned-element .additional-logo{ldelim}display:none !important;{rdelim}</style>
  {/if}
</div>
{undef $only_logo $colorize_logo $double_logo}