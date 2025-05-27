{if openpaini('GeneralSettings','ShowMainContacts', 'enabled')|eq('enabled')}
    <div class="row">
    <div class="col-md-9 mt-md-4 footer-items-wrapper">
        <h3 class="footer-heading-title">{'Contacts'|i18n('openpa/footer')}</h3>
        <div class="row">
            <div class="col-md-4">
                {include uri='design:footer/contact_list.tpl'}
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
                {def $footer_links = fetch( 'openpa', 'footer_links' )}
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
                {undef $footer_links}
        </div>
    </div>
    {include uri='design:footer/social.tpl'}
</div>
{else}
    <div class="row">
        <div class="col-md-3 mt-md-4 footer-items-wrapper">
            <h3 class="footer-heading-title">{'Contacts'|i18n('openpa/footer')}</h3>
            {include uri='design:footer/contact_list.tpl'}
        </div>
        <div class="col-md-3 mt-md-4 footer-items-wrapper">
        {if $pagedata.homepage|has_attribute('link_nel_footer')}
            <h3 class="footer-heading-title">{$pagedata.homepage|attribute('link_nel_footer').contentclass_attribute_name|wash()}</h3>
            <ul class="footer-list">
                {foreach $pagedata.homepage|attribute('link_nel_footer').content.relation_list as $relation}
                    <li>{node_view_gui content_node=fetch(content, node, hash(node_id, $relation.node_id)) view=text_linked}</li>
                {/foreach}
            </ul>
        {/if}
        </div>
        <div class="col-md-3 mt-md-4 footer-items-wrapper">
            {if $pagedata.homepage|has_attribute('link_nel_footer_2')}
                <h3 class="footer-heading-title">{$pagedata.homepage|attribute('link_nel_footer_2').contentclass_attribute_name|wash()}</h3>
                <ul class="footer-list">
                    {foreach $pagedata.homepage|attribute('link_nel_footer_2').content.relation_list as $relation}
                        <li>{node_view_gui content_node=fetch(content, node, hash(node_id, $relation.node_id)) view=text_linked}</li>
                    {/foreach}
                </ul>
            {/if}
        </div>
        {include uri='design:footer/social.tpl'}
    </div>
{/if}