{if or(
    and(is_set($module_result.content_info.persistent_variable.show_valuation),$module_result.content_info.persistent_variable.show_valuation),
    openpacontext().is_search_page
)}
    {include uri='design:footer/valuation.tpl'}
{/if}
{if or(openpaini('GeneralSettings','ShowMainContacts', 'enabled')|eq('enabled'), $pagedata.homepage|has_attribute('footer_main_contacts_label'))}
{include uri='design:footer/main_contacts.tpl'}
{/if}

{def $show_footer_menu = true()}
{if $pagedata.homepage|has_attribute('hide_footer_menu')}
    {set $show_footer_menu = cond($pagedata.homepage|attribute('hide_footer_menu').data_int|eq(1), false(), true())}
{/if}
<footer class="it-footer" id="footer">
    <div class="it-footer-main">
        <div class="container">

            {include uri='design:footer/brand_and_logo.tpl'}
            {if $show_footer_menu}
                {include uri='design:footer/primary_menu.tpl'}
                {include uri='design:footer/secondary_menu.tpl'}
            {/if}
            <div class="row">
                <div class="col-12 footer-items-wrapper">
                    <ul class="footer-bottom d-flex flex-column flex-md-row gap-2 gap-md-5">
                        {if openpaini('Seo', 'CookieConsentMultimedia')|eq('enabled')}
                            <li><a role="button" href="#" data-cc="show-preferencesModal">
                              {'Cookie settings'|i18n('bootstrapitalia/cookieconsent')}
                            </a></li>
                        {/if}
                        {*<li><a href="#">Media policy</a> @todo*</li>*}
                        {if openpaini('GeneralSettings', 'ShowFooterSiteMap', 'enabled')|eq('enabled')}
                        <li><a href={"/content/view/sitemap/2/"|ezurl}>{"Sitemap"|i18n("design/standard/layout")}</a></li>
                        {/if}
                        {if openpaini('Seo', 'webAnalyticsItaliaSiteID', false() )}
                          <li><a href="/statistiche">{'Website Stats'|i18n('bootstrapitalia')}</a></li>
                        {/if}
                        {if openpaini('GeneralSettings', 'AdditionalFooterObjectLinks', array())|count()}
                            {foreach openpaini('GeneralSettings', 'AdditionalFooterObjectLinks', array()) as $id}
                                {def $f = fetch(content, object, hash(object_id, $id))}
                                {if $f}
                                    <li><a href={object_handler($f).content_link.full_link}>{$f.name|wash()}</a></li>
                                {/if}
                                {undef $f}
                            {/foreach}
                        {/if}
{*                        <li><a href={"/openapi/doc/"|ezurl}>API</a></li>*}
                    </ul>
                </div>
            </div>
        </div>
    </div>
</footer>
{include uri='design:footer/copyright.tpl'}
