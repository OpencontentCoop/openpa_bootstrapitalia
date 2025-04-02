{def $main_contacts = array()}
{def $secondary_contacts = array()}

{def $main_contacts_label = 'Contact the municipality'|i18n('bootstrapitalia')}
{if $pagedata.homepage|has_attribute('footer_main_contacts_label')}
    {set $main_contacts_label = $pagedata.homepage|attribute('footer_main_contacts_label').content|wash()}
{/if}

{def $secondary_contacts_label = 'Trouble in the city'|i18n('bootstrapitalia')}
{if $pagedata.homepage|has_attribute('footer_secondary_contacts_label')}
    {set $secondary_contacts_label = $pagedata.homepage|attribute('footer_secondary_contacts_label').content|wash()}
{/if}

{if $pagedata.homepage|has_attribute('footer_main_contacts')}
    {set $main_contacts = matrix_to_hash($pagedata.homepage|attribute('footer_main_contacts'))}
    {if $pagedata.homepage|has_attribute('footer_secondary_contacts')}
        {set $secondary_contacts = matrix_to_hash($pagedata.homepage|attribute('footer_secondary_contacts'))}
    {/if}
{else}
    {def $context = openpapagedata()}
    {def $current_app = cond(is_set($context.persistent_variable.built_in_app), $context.persistent_variable.built_in_app, false())}
    {def $faq_system = fetch(content, object, hash(remote_id, 'faq_system'))}

    {if and($faq_system, $current_app|ne('faq'))}
        {set $main_contacts = $main_contacts|append(hash(
            'href', object_handler($faq_system).content_link.full_link,
            'element', 'faq',
            'icon', 'it-help-circle',
            'label', 'Read the FAQ'|i18n('bootstrapitalia')
        ))}
    {/if}

    {if $current_app|ne('support')}
        {set $main_contacts = $main_contacts|append(hash(
            'href', cond(is_set($pagedata.contacts['link_assistenza']), $pagedata.contacts['link_assistenza']|wash(), 'richiedi_assistenza'|ezurl(no)),
            'element', 'contacts',
            'icon', 'it-mail',
            'label', 'Request assistance'|i18n('bootstrapitalia')
        ))}
    {/if}
    {if or(is_set($pagedata.contacts['numero_verde']), is_set($pagedata.contacts['telefono']))}
        {set $main_contacts = $main_contacts|append(hash(
            'href', concat('tel:', cond(is_set($pagedata.contacts['numero_verde']), $pagedata.contacts['numero_verde']|wash(), $pagedata.contacts['telefono']|wash())),
            'element', '',
            'icon', 'it-hearing',
            'label', concat('Call the municipality'|i18n('bootstrapitalia'), ' ', cond(is_set($pagedata.contacts['numero_verde']), $pagedata.contacts['numero_verde']|wash(), $pagedata.contacts['telefono']|wash()))
        ))}
    {/if}
    {if $current_app|ne('booking')}
        {set $main_contacts = $main_contacts|append(hash(
            'href', cond(is_set($pagedata.contacts['link_prenotazione_appuntamento']), $pagedata.contacts['link_prenotazione_appuntamento']|wash(), 'prenota_appuntamento'|ezurl(no)),
            'element', 'appointment-booking',
            'icon', 'it-calendar',
            'label', 'Book an appointment'|i18n('bootstrapitalia')
        ))}
    {/if}
    {if $current_app|ne('inefficiency')}
        {set $secondary_contacts = $secondary_contacts|append(hash(
            'href', cond(is_set($pagedata.contacts['link_segnalazione_disservizio']), $pagedata.contacts['link_segnalazione_disservizio']|wash(), 'segnala_disservizio'|ezurl(no)),
            'element', 'report-inefficiency',
            'icon', 'it-map-marker-circle',
            'label', 'Report a inefficiency'|i18n('bootstrapitalia')
        ))}
    {/if}
    {undef $context}
    {undef $current_app}
    {undef $faq_system}
{/if}

{if or(count($main_contacts), count($secondary_contacts))}
<div class="bg-grey-card shadow-contacts">
    <div class="container">
        <div class="row d-flex justify-content-center p-contacts">
            <div class="col-12 col-lg-6">
                <div class="cmp-contacts">
                    <div class="card w-100">
                        <div class="card-body">
                            {if count($main_contacts)}
                            <h2 class="title-medium-2-semi-bold">{$main_contacts_label|wash()}</h2>
                            <ul class="contact-list p-0">
                                {foreach $main_contacts as $contact}
                                    <li>
                                        <a class="list-item" href="{$contact.href}" data-element="{$contact.element|wash()}">
                                            {display_icon($contact.icon, 'svg', 'icon icon-primary icon-sm', $contact.label|wash())}<span>{$contact.label|wash()}</span>
                                        </a>
                                    </li>
                                {/foreach}
                            </ul>
                            {/if}
                            {if count($secondary_contacts)}
                                <h2 class="title-medium-2-semi-bold mt-4">{$secondary_contacts_label|wash()}</h2>
                                <ul class="contact-list p-0">
                                    {foreach $secondary_contacts as $contact}
                                        <li>
                                            <a class="list-item" href="{$contact.href}" data-element="{$contact.element|wash()}">
                                                {display_icon($contact.icon, 'svg', 'icon icon-primary icon-sm', $contact.label|wash())}<span>{$contact.label|wash()}</span>
                                            </a>
                                        </li>
                                    {/foreach}
                                </ul>
                            {/if}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
{/if}
{undef $main_contacts $main_contacts_label $secondary_contacts $secondary_contacts_label}