<div class="row">
    <div class="col-12 footer-items-wrapper logo-wrapper" style="flex-wrap: wrap;">
        {if openpaini('GeneralSettings','ShowUeLogo', 'enabled')|eq('enabled')}
            <img class="ue-logo" src="{concat('images/assets/logo-eu/',ezini('RegionalSettings', 'Locale'),'.svg')|ezdesign( 'no' )}"
                 title="{'Financed by the European Union'|i18n( 'bootstrapitalia' )}"
                 alt="{'Financed by the European Union'|i18n( 'bootstrapitalia' )}" width="178" height="56"
                 loading="lazy" />
        {/if}
        {if and($pagedata.homepage|has_attribute('footer_logo'), $pagedata.homepage|attribute('footer_logo').data_type_string|eq('ezimage'))}
            <div class="it-brand-wrapper">
                <a href="{'/'|ezurl(no)}"
                  title="{ezini('SiteSettings','SiteName')}">
                    <img class="icon" style="width: auto !important;"
                        alt="{ezini('SiteSettings','SiteName')}"
                        src="{render_image($pagedata.homepage|attribute('footer_logo').content['header_logo'].full_path|ezroot(no,full)).src}"
                        loading="lazy" />
                </a>
            </div>
        {elseif and($pagedata.homepage|has_attribute('footer_logo'), $pagedata.homepage|attribute('footer_logo').data_type_string|eq('ezobjectrelationlist'))}
            {foreach $pagedata.homepage|attribute('footer_logo').content.relation_list as $related}
                {def $related_object = fetch(content, object, hash(object_id, $related['contentobject_id']))}
                {if and($related_object, $related_object|has_attribute('image'))}
                  <img
                      style="max-width: 100%; max-height: 56px; object-fit: contain; object-position: 0 0; vertical-align: middle;"
                      alt="{ezini('SiteSettings','SiteName')}"
                      src="{render_image($related_object|attribute('image').content['header_logo'].full_path|ezroot(no,full)).src}"
                      loading="lazy" />
                {/if}
                {undef $related_object}
            {/foreach} 
            {include uri='design:logo.tpl' in_footer=true()}
        {else}
            {include uri='design:logo.tpl' in_footer=true()}
        {/if}
        {if and( openpaini('GeneralSettings', 'ShowFooterBanner', 'disabled')|eq('enabled'), $pagedata.homepage|has_attribute('footer_banner') )}
            {def $footer_banner = object_handler(fetch(content, object, hash( object_id, $pagedata.homepage|attribute('footer_banner').content.relation_list[0].contentobject_id)))}
            <a href="{$footer_banner.content_link.full_link}" class="ms-md-auto"
               title="{$footer_banner.name.contentobject_attribute.content|wash()}">
                <img class="icon" style="width: auto !important;height: 50px"
                     alt="{$footer_banner.name.contentobject_attribute.content|wash()}"
                     src="{render_image($footer_banner.image.contentobject_attribute.content['header_logo'].full_path|ezroot(no,full)).src}"
                     loading="lazy" />
            </a>
            {undef $footer_banner}
        {/if}
    </div>
</div>