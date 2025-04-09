{if or(
    and(is_set($module_result.content_info.persistent_variable.show_valuation),$module_result.content_info.persistent_variable.show_valuation),
    openpacontext().is_search_page
)}
    {include uri='design:footer/valuation.tpl'}
{/if}
{if or(openpaini('GeneralSettings','ShowMainContacts', 'enabled')|eq('enabled'), $pagedata.homepage|has_attribute('footer_main_contacts_label'))}
{include uri='design:footer/main_contacts.tpl'}
{/if}

{def $use_auto_menu = cond(openpaini('GeneralSettings','FooterAutoMenu', 'disabled')|eq('enabled'), true(), false())}
{if $pagedata.homepage|attribute('use_auto_footer_menu')}
    {set $use_auto_menu = cond($pagedata.homepage|attribute('use_auto_footer_menu').data_int|eq(1), true(), false())}
{/if}
{def $show_footer_menu = true()}
{if $pagedata.homepage|has_attribute('hide_footer_menu')}
    {set $show_footer_menu = cond($pagedata.homepage|attribute('hide_footer_menu').data_int|eq(1), false(), true())}
{/if}
<footer class="it-footer" id="footer">
    <div class="it-footer-main">
        <div class="container">

            <div class="row">
                <div class="col-12 footer-items-wrapper logo-wrapper">
                    {if openpaini('GeneralSettings','ShowUeLogo', 'enabled')|eq('enabled')}
                        <img class="ue-logo" src="{concat('images/assets/logo-eu/',ezini('RegionalSettings', 'Locale'),'.svg')|ezdesign( 'no' )}"
                             title="{'Financed by the European Union'|i18n( 'bootstrapitalia' )}"
                             alt="{'Financed by the European Union'|i18n( 'bootstrapitalia' )}" width="178" height="56" />
                    {/if}
                    {if $pagedata.homepage|has_attribute('footer_logo')}
                        <div class="it-brand-wrapper">
                            <a href="{'/'|ezurl(no)}"
                               title="{ezini('SiteSettings','SiteName')}">
                                <img class="icon" style="width: auto !important;"
                                     alt="{ezini('SiteSettings','SiteName')}"
                                     src="{render_image($pagedata.homepage|attribute('footer_logo').content['header_logo'].full_path|ezroot(no,full)).src}" />
                            </a>
                        </div>
                    {else}
                        {include uri='design:logo.tpl' in_footer=true()}
                    {/if}
                    {if and( openpaini('GeneralSettings', 'ShowFooterBanner', 'disabled')|eq('enabled'), $pagedata.homepage|has_attribute('footer_banner') )}
                        {def $footer_banner = object_handler(fetch(content, object, hash( object_id, $pagedata.homepage|attribute('footer_banner').content.relation_list[0].contentobject_id)))}
                        <a href="{$footer_banner.content_link.full_link}" class="ms-md-auto"
                           title="{$footer_banner.name.contentobject_attribute.content|wash()}">
                            <img class="icon" style="width: auto !important;height: 50px"
                                 alt="{$footer_banner.name.contentobject_attribute.content|wash()}"
                                 src="{render_image($footer_banner.image.contentobject_attribute.content['header_logo'].full_path|ezroot(no,full)).src}" />
                        </a>
                        {undef $footer_banner}
                    {/if}
                </div>
            </div>

            {if $show_footer_menu}
                {def $top_menu_tree = array()}
                {def $top_menu_node_ids = openpaini( 'TopMenu', 'NodiCustomMenu', array())}
                {if count($top_menu_node_ids)|gt(0)}
                    {foreach $top_menu_node_ids as $id}
                        {set $top_menu_tree = $top_menu_tree|append(tree_menu( hash( 'root_node_id', $id, 'scope', 'side_menu', 'hide_empty_tag', true(), 'hide_empty_tag_callback', array('OpenPABootstrapItaliaOperators', 'tagTreeHasContents'))))}
                    {/foreach}
                {/if}
                {undef $top_menu_node_ids}

                <div class="row">
                    {if and(count($top_menu_tree), $use_auto_menu)}
                        {foreach $top_menu_tree as $tree_menu}
                            <div class="col-md-3 footer-items-wrapper">
                                {include recursion=0
                                        name=top_menu
                                        uri='design:footer/menu_item.tpl'
                                        menu_item=$tree_menu
                                        show_main_link=true()
                                        show_more=true()
                                        max=5
                                        offset=0}
                            </div>
                        {/foreach}
                    {elseif count($top_menu_tree)}
                        <div class="col-md-3 footer-items-wrapper">
                            <h3 class="footer-heading-title">
                                {$top_menu_tree[0].item.name|wash()}
                            </h3>
                            {include recursion=0
                                     name=top_menu
                                     uri='design:footer/menu_item.tpl'
                                     menu_item=$top_menu_tree[0]
                                     show_main_link=false()
                                     show_more=true()
                                     max=8
                                     offset=0}
                        </div>
                        <div class="col-md-6 footer-items-wrapper">
                            <h3 class="footer-heading-title">
                                {$top_menu_tree[2].item.name|wash()}
                            </h3>
                            <div class="row">
                                <div class="col-md-6">
                                    {include recursion=0
                                             name=top_menu
                                             uri='design:footer/menu_item.tpl'
                                             menu_item=$top_menu_tree[2]
                                             show_main_link=false()
                                             show_more=false()
                                             max=8
                                             offset=0}
                                </div>
                                <div class="col-md-6">
                                    {if count($top_menu_tree[2].children)|gt(8)}
                                    {include recursion=0
                                             name=top_menu
                                             uri='design:footer/menu_item.tpl'
                                             menu_item=$top_menu_tree[2]
                                             show_main_link=false()
                                             show_more=true()
                                             max=8
                                             offset=8}
                                    {/if}
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3 footer-items-wrapper">
                            <h3 class="footer-heading-title">
                                {$top_menu_tree[1].item.name|wash()}
                            </h3>
                            {include recursion=0
                                     name=top_menu
                                     uri='design:footer/menu_item.tpl'
                                     menu_item=$top_menu_tree[1]
                                     show_main_link=false()
                                     show_more=true()
                                     max=3
                                     offset=0}
                            <h3 class="footer-heading-title">
                                {$top_menu_tree[3].item.name|wash()}
                            </h3>
                            {include recursion=0
                                     name=top_menu
                                     uri='design:footer/menu_item.tpl'
                                     menu_item=$top_menu_tree[3]
                                     show_main_link=false()
                                     show_more=true()
                                     max=2
                                     offset=0}
                        </div>
                    {/if}
                    <div class="col-md-9 mt-md-4 footer-items-wrapper">
                        <h3 class="footer-heading-title">{'Contacts'|i18n('openpa/footer')}</h3>
                        <div class="row">
                            <div class="col-md-4">
                                <ul class="contact-list p-0 footer-info">
                                {if is_set($pagedata.contacts.indirizzo)}
                                    <li style="display: flex;align-items: center;">
                                        {display_icon('it-pa', 'svg', 'icon icon-sm icon-white', 'Address')}
                                        <small class="ms-2" style="word-wrap: anywhere;user-select: all;">{$pagedata.contacts.indirizzo|wash()}</small>
                                    </li>
                                {/if}
                                {if is_set($pagedata.contacts.telefono)}
                                <li>
                                    {def $tel = strReplace($pagedata.contacts.telefono,array(" ",""))}
                                    <a style="display: flex;align-items: center;" class="text-decoration-none" href="tel:{$tel}">
                                        {display_icon('it-telephone', 'svg', 'icon icon-sm icon-white', 'Phone')}
                                        <small class="ms-2" style="word-wrap: anywhere;user-select: all;">{$pagedata.contacts.telefono}</small>
                                    </a>
                                </li>
                                {/if}
                                {if is_set($pagedata.contacts.fax)}
                                    <li>
                                        {def $fax = strReplace($pagedata.contacts.fax,array(" ",""))}
                                        <a style="display: flex;align-items: center;" class="text-decoration-none" href="tel:{$fax}">
                                            {display_icon('it-file', 'svg', 'icon icon-sm icon-white', 'Fax')}
                                            <small class="ms-2" style="word-wrap: anywhere;user-select: all;">{$pagedata.contacts.fax}</small>
                                        </a>
                                    </li>
                                {/if}
                                {if is_set($pagedata.contacts.email)}
                                    <li>
                                        <a style="display: flex;align-items: center;" class="text-decoration-none" href="mailto:{$pagedata.contacts.email}">
                                            {display_icon('it-mail', 'svg', 'icon icon-sm icon-white', 'Email')}
                                            <small class="ms-2" style="word-wrap: anywhere;user-select: all;">{$pagedata.contacts.email}</small>
                                        </a>
                                    </li>
                                {/if}
                                {if is_set($pagedata.contacts.pec)}
                                    <li>
                                        <a style="display: flex;align-items: center;" class="text-decoration-none" href="mailto:{$pagedata.contacts.pec}">
                                            {display_icon('it-mail', 'svg', 'icon icon-sm icon-warning', 'PEC')}
                                            <small class="ms-2" style="word-wrap: anywhere;user-select: all;">{$pagedata.contacts.pec}</small>
                                        </a>
                                    </li>
                                {/if}
                                {if is_set($pagedata.contacts.web)}
                                    {def $webs = $pagedata.contacts.web|explode_contact()}
                                    {foreach $webs as $name => $link}
                                        <li>
                                            <a style="display: flex;align-items: center;" class="text-decoration-none" href="{$link|wash()}">
                                                {display_icon('it-link', 'svg', 'icon icon-sm icon-white', 'Website')}
                                                <small class="ms-2" style="word-wrap: anywhere;user-select: all;">{$name|wash()}</small>
                                            </a>
                                        </li>
                                    {/foreach}
                                    {undef $webs}
                                {/if}
                                {if is_set($pagedata.contacts.partita_iva)}
                                    <li style="display: flex;align-items: center;">
                                        {display_icon('it-card', 'svg', 'icon icon-sm icon-white', 'P.IVA')}
                                        <small class="ms-2" style="word-wrap: anywhere;user-select: all;">P.IVA {$pagedata.contacts.partita_iva}</small>
                                    </li>
                                {/if}
                                {if is_set($pagedata.contacts.codice_fiscale)}
                                    <li style="display: flex;align-items: center;">
                                        {display_icon('it-card', 'svg', 'icon icon-sm icon-white', 'Codice fiscale')}
                                        <small class="ms-2" style="word-wrap: anywhere;user-select: all;">C.F. {$pagedata.contacts.codice_fiscale}</small>
                                    </li>
                                {/if}
                                {if is_set($pagedata.contacts.codice_sdi)}
                                    <li>
                                        {display_icon('it-card', 'svg', 'icon icon-sm icon-white', 'SDI')}
                                        <small class="ms-2" style="word-wrap: anywhere;user-select: all;">SDI {$pagedata.contacts.codice_sdi}</small>
                                    </li>
                                {/if}
                                </ul>
                            </div>
                            {if openpaini('GeneralSettings','ShowMainContacts', 'enabled')|eq('enabled')}
                                <div class="col-md-4">
                                <ul class="footer-list"> {*@todo*}
                                    {def $faq_system = fetch(content, object, hash(remote_id, 'faq_system'))}
                                    {if $faq_system}
                                        <li>
                                            <a data-element="faq" href="{object_handler($faq_system).content_link.full_link}">{'Read the FAQ'|i18n('bootstrapitalia')}</a>
                                        </li>
                                    {/if}
                                    {undef $faq_system}
                                        <li>
                                            <a data-element="appointment-booking" href="{if is_set($pagedata.contacts['link_prenotazione_appuntamento'])}{$pagedata.contacts['link_prenotazione_appuntamento']|wash()}{else}{'prenota_appuntamento'|ezurl(no)}{/if}">
                                                {'Book an appointment'|i18n('bootstrapitalia/footer')}
                                            </a>
                                        </li>
                                        <li>
                                            <a data-element="report-inefficiency" href="{if is_set($pagedata.contacts['link_segnalazione_disservizio'])}{$pagedata.contacts['link_segnalazione_disservizio']|wash()}{else}{'segnala_disservizio'|ezurl(no)}{/if}">
                                                {'Report a inefficiency'|i18n('bootstrapitalia/footer')}
                                            </a>
                                        </li>
                                        <li>
                                            <a data-element="contacts" href="{if is_set($pagedata.contacts['link_assistenza'])}{$pagedata.contacts['link_assistenza']|wash()}{else}{'richiedi_assistenza'|ezurl(no)}{/if}">
                                                {'Request assistance'|i18n('bootstrapitalia/footer')}
                                            </a>
                                        </li>
                                    </ul>
                                </div>
                            {/if}
                            {def $footer_links = fetch( 'openpa', 'footer_links' )}
                            {if openpaini('GeneralSettings','ShowMainContacts', 'enabled')|eq('enabled')}
                                <div class="col-md-4">
                                    <ul class="footer-list">
                                        {foreach $footer_links as $item}
                                            <li>{node_view_gui content_node=$item view=text_linked}</li>
                                        {/foreach}
                                        {if openpaini('GeneralSettings', 'PerformanceLink', false())}
                                            <li>
                                                <a href="{openpaini('GeneralSettings', 'PerformanceLink', '#')}" title="{'Performance improvement plan'|i18n( 'bootstrapitalia' )}">{'Performance improvement plan'|i18n( 'bootstrapitalia' )}</a>
                                            </li>
                                        {/if}
                                    </ul>
                                </div>
                            {else}
                                {def $max = count($footer_links)|div(2)|int()
                                     $_offset = count($footer_links)|sub($max)}
                                <div class="col-md-4">
                                    <ul class="footer-list">
                                        {foreach $footer_links as $item max $max}
                                            <li>{node_view_gui content_node=$item view=text_linked}</li>
                                        {/foreach}
                                    </ul>
                                </div>
                                <div class="col-md-4">
                                    <ul class="footer-list">
                                        {if $_offset|gt(0)}
                                        {foreach $footer_links as $item offset $_offset}
                                            <li>{node_view_gui content_node=$item view=text_linked}</li>
                                        {/foreach}
                                        {/if}
                                        {if openpaini('GeneralSettings', 'PerformanceLink', false())}
                                            <li>
                                                <a href="{openpaini('GeneralSettings', 'PerformanceLink', '#')}" title="{'Performance improvement plan'|i18n( 'bootstrapitalia' )}">{'Performance improvement plan'|i18n( 'bootstrapitalia' )}</a>
                                            </li>
                                        {/if}
                                    </ul>
                                </div>
                                {undef $max $_offset}
                            {/if}
                            {undef $footer_links}
                        </div>
                    </div>
                    {include uri='design:footer/social.tpl'}
                </div>
            {/if}

            <div class="row">
                <div class="col-12 footer-items-wrapper">
                    <div class="footer-bottom">
                        {if openpaini('Seo', 'CookieConsentMultimedia')|eq('enabled')}
                            <a role="button" href="#" data-cc="show-preferencesModal">
                              {'Cookie settings'|i18n('bootstrapitalia/cookieconsent')}
                            </a>
                        {/if}
                        {*<a href="#">Media policy</a> @todo*}
                        {if openpaini('GeneralSettings', 'ShowFooterSiteMap', 'enabled')|eq('enabled')}
                        <a href={"/content/view/sitemap/2/"|ezurl}>{"Sitemap"|i18n("design/standard/layout")}</a>
                        {/if}
{*                        <a href={"/openapi/doc/"|ezurl}>API</a>*}
                    </div>
                </div>
            </div>
        </div>
    </div>
</footer>
{include uri='design:footer/copyright.tpl'}
{undef $use_auto_menu}