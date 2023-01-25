{if or(
    and(is_set($module_result.content_info.persistent_variable.show_valuation),$module_result.content_info.persistent_variable.show_valuation),
    openpacontext().is_search_page
)}
    {include uri='design:footer/valuation.tpl'}
{/if}
{include uri='design:footer/main_contacts.tpl'}

{def $use_auto_menu = cond(and($pagedata.homepage|attribute('use_auto_footer_menu'), $pagedata.homepage|attribute('use_auto_footer_menu').data_int|eq(1)), true(), false())}
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
                        <img class="ue-logo" src="{'images/assets/logo-eu-inverted.svg'|ezdesign( 'no' )}" alt="logo Unione Europea" />
                    {/if}
                    {include uri='design:logo.tpl'}
                </div>
            </div>

            {if $show_footer_menu}
                {def $top_menu_tree = array()}
                {def $top_menu_node_ids = openpaini( 'TopMenu', 'NodiCustomMenu', array())}
                {if count($top_menu_node_ids)|gt(0)}
                    {foreach $top_menu_node_ids as $id}
                        {set $top_menu_tree = $top_menu_tree|append(tree_menu( hash( 'root_node_id', $id, 'scope', 'side_menu')))}
                    {/foreach}
                {/if}
                {undef $top_menu_node_ids}

                {if and(count($top_menu_tree), $use_auto_menu)}
                <div class="row">
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
                </div>
                {elseif count($top_menu_tree)}
                <div class="row">
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
                                {include recursion=0
                                         name=top_menu
                                         uri='design:footer/menu_item.tpl'
                                         menu_item=$top_menu_tree[2]
                                         show_main_link=false()
                                         show_more=true()
                                         max=8
                                         offset=8}
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

                    <div class="col-md-9 mt-md-4 footer-items-wrapper">
                        <h3 class="footer-heading-title">Contatti</h3>
                        <div class="row">
                            <div class="col-md-4">
                                <ul class="contact-list p-0 footer-info">
                                {if is_set($pagedata.contacts.indirizzo)}
                                    <li style="display: flex;align-items: center;">
                                        {display_icon('it-pa', 'svg', 'icon icon-sm icon-white')}
                                        <small class="ms-2" style="word-wrap: anywhere;">{$pagedata.contacts.indirizzo|wash()}</small>
                                    </li>
                                {/if}
                                {if is_set($pagedata.contacts.telefono)}
                                <li>
                                    {def $tel = strReplace($pagedata.contacts.telefono,array(" ",""))}
                                    <a style="display: flex;align-items: center;" class="text-decoration-none" href="tel:{$tel}">
                                        {display_icon('it-telephone', 'svg', 'icon icon-sm icon-white')}
                                        <small class="ms-2" style="word-wrap: anywhere;">{$pagedata.contacts.telefono}</small>
                                    </a>
                                </li>
                                {/if}
                                {if is_set($pagedata.contacts.fax)}
                                    <li>
                                        {def $fax = strReplace($pagedata.contacts.fax,array(" ",""))}
                                        <a style="display: flex;align-items: center;" class="text-decoration-none" href="tel:{$fax}">
                                            {display_icon('it-file', 'svg', 'icon icon-sm icon-white')}
                                            <small class="ms-2" style="word-wrap: anywhere;">{$pagedata.contacts.fax}</small>
                                        </a>
                                    </li>
                                {/if}
                                {if is_set($pagedata.contacts.email)}
                                    <li>
                                        <a style="display: flex;align-items: center;" class="text-decoration-none" href="mailto:{$pagedata.contacts.email}">
                                            {display_icon('it-mail', 'svg', 'icon icon-sm icon-white')}
                                            <small class="ms-2" style="word-wrap: anywhere;">{$pagedata.contacts.email}</small>
                                        </a>
                                    </li>
                                {/if}
                                {if is_set($pagedata.contacts.pec)}
                                    <li>
                                        <a style="display: flex;align-items: center;" class="text-decoration-none" href="mailto:{$pagedata.contacts.pec}">
                                            {display_icon('it-mail', 'svg', 'icon icon-sm icon-warning')}
                                            <small class="ms-2" style="word-wrap: anywhere;">{$pagedata.contacts.pec}</small>
                                        </a>
                                    </li>
                                {/if}
                                {if is_set($pagedata.contacts.web)}
                                    {def $webs = $pagedata.contacts.web|explode_contact()}
                                    {foreach $webs as $name => $link}
                                        <li>
                                            <a style="display: flex;align-items: center;" class="text-decoration-none" href="{$link|wash()}">
                                                {display_icon('it-link', 'svg', 'icon icon-sm icon-white')}
                                                <small class="ms-2" style="word-wrap: anywhere;">{$name|wash()}</small>
                                            </a>
                                        </li>
                                    {/foreach}
                                    {undef $webs}
                                {/if}
                                {if is_set($pagedata.contacts.partita_iva)}
                                    <li>
                                        <a style="display: flex;align-items: center;" class="text-decoration-none" href="#">
                                            {display_icon('it-card', 'svg', 'icon icon-sm icon-white')}
                                            <small class="ms-2" style="word-wrap: anywhere;">P.IVA {$pagedata.contacts.partita_iva}</small>
                                        </a>
                                    </li>
                                {/if}
                                {if is_set($pagedata.contacts.codice_fiscale)}
                                    <li>
                                        <a style="display: flex;align-items: center;" class="text-decoration-none" href="#">
                                            {display_icon('it-card', 'svg', 'icon icon-sm icon-white')}
                                            <small class="ms-2" style="word-wrap: anywhere;">C.F. {$pagedata.contacts.codice_fiscale}</small>
                                        </a>
                                    </li>
                                {/if}
                                {if is_set($pagedata.contacts.codice_sdi)}
                                    <li>
                                        <a style="display: flex;align-items: center;" class="text-decoration-none" href="#">
                                            {display_icon('it-card', 'svg', 'icon icon-sm icon-white')}
                                            <small class="ms-2" style="word-wrap: anywhere;">SDI {$pagedata.contacts.codice_sdi}</small>
                                        </a>
                                    </li>
                                {/if}
                                </ul>
                            </div>
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
                                                {'Book an appointment'|i18n('bootstrapitalia')}
                                            </a>
                                        </li>
                                        <li>
                                            <a data-element="report-inefficiency" href="{if is_set($pagedata.contacts['link_segnalazione_disservizio'])}{$pagedata.contacts['link_segnalazione_disservizio']|wash()}{else}{'segnala_disservizio'|ezurl(no)}{/if}">
                                                {'Report a disservice'|i18n('bootstrapitalia')}
                                            </a>
                                        </li>
                                        <li>
                                            <a data-element="contacts" href="{if is_set($pagedata.contacts['link_assistenza'])}{$pagedata.contacts['link_assistenza']|wash()}{else}{'richiedi_assistenza'|ezurl(no)}{/if}">
                                                {'Request assistance'|i18n('bootstrapitalia')}
                                            </a>
                                        </li>
                                </ul>
                            </div>
                            <div class="col-md-4">
                                {def $footer_links = fetch( 'openpa', 'footer_links' )}
                                <ul class="footer-list">
                                    {foreach $footer_links as $item}
                                        <li>{node_view_gui content_node=$item view=text_linked}</li>
                                    {/foreach}
                                </ul>
                            </div>
                        </div>
                    </div>
                    {include uri='design:footer/social.tpl'}
                </div>
                {/if}
            {/if}

            <div class="row">
                <div class="col-12 footer-items-wrapper">
                    <div class="footer-bottom">
                        {def $needCookieConsent = cond(or(
                                and( openpaini('Seo', 'GoogleAnalyticsAccountID'), openpaini('Seo', 'GoogleCookieless')|eq('disabled') ),
                                and( openpaini('Seo', 'webAnalyticsItaliaID'), openpaini('Seo', 'WebAnalyticsItaliaCookieless')|eq('disabled') ),
                                openpaini('Seo', 'CookieConsentMultimedia')|eq('enabled')
                            ), true(), false())}
                        {if and(openpaini('CookiesSettings', 'Consent', 'advanced')|eq('advanced'), $needCookieConsent)}
                            <a href="#" class="ccb__edit">{'Cookie settings'|i18n('bootstrapitalia/cookieconsent')}</a>
                        {/if}

                        {undef $needCookieConsent}
                        <a href="#">Media policy</a> {*@todo*}
                        <a href={"/content/view/sitemap/2/"|ezurl}>{"Sitemap"|i18n("design/standard/layout")}</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</footer>
{include uri='design:footer/copyright.tpl'}
{undef $use_auto_menu}