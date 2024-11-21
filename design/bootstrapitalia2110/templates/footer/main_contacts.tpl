<div class="bg-grey-card shadow-contacts">
    <div class="container">
        <div class="row d-flex justify-content-center p-contacts">
            <div class="col-12 col-lg-6">
                <div class="cmp-contacts">
                    <div class="card w-100">
                        <div class="card-body">
                            <h2 class="title-medium-2-semi-bold">{'Contact the municipality'|i18n('bootstrapitalia')}</h2>
                            <ul class="contact-list p-0">
                                {def $context = openpapagedata()}
                                {def $current_app = cond(is_set($context.persistent_variable.built_in_app), $context.persistent_variable.built_in_app, false())}
                                {def $faq_system = fetch(content, object, hash(remote_id, 'faq_system'))}
                                {if and($faq_system, $current_app|ne('faq'))}
                                    <li>
                                        <a class="list-item" href="{object_handler($faq_system).content_link.full_link}" data-element="faq">
                                            {display_icon('it-help-circle', 'svg', 'icon icon-primary icon-sm', 'Read the FAQ'|i18n('bootstrapitalia'))}<span>{'Read the FAQ'|i18n('bootstrapitalia')}</span>
                                        </a>
                                    </li>
                                {/if}
                                {undef $faq_system}
                                {if $current_app|ne('support')}
                                    <li>
                                        <a class="list-item" href="{if is_set($pagedata.contacts['link_assistenza'])}{$pagedata.contacts['link_assistenza']|wash()}{else}{'richiedi_assistenza'|ezurl(no)}{/if}" data-element="contacts">
                                            {display_icon('it-mail', 'svg', 'icon icon-primary icon-sm', 'Request assistance'|i18n('bootstrapitalia'))}<span>{'Request assistance'|i18n('bootstrapitalia')}</span>
                                        </a>
                                    </li>
                                {/if}
                                {if or(is_set($pagedata.contacts['numero_verde']), is_set($pagedata.contacts['telefono']))}
                                    <li>
                                        <a class="list-item" href="{if is_set($pagedata.contacts['numero_verde'])}tel:{$pagedata.contacts['numero_verde']|wash()}{else}tel:{$pagedata.contacts['telefono']|wash()}{/if}">
                                            {display_icon('it-hearing', 'svg', 'icon icon-primary icon-sm', 'Call the municipality'|i18n('bootstrapitalia'))}<span>{'Call the municipality'|i18n('bootstrapitalia')} {if is_set($pagedata.contacts['numero_verde'])}{$pagedata.contacts['numero_verde']|wash()}{else}{$pagedata.contacts['telefono']|wash()}{/if}</span>
                                        </a>
                                    </li>
                                {/if}
                                {if $current_app|ne('booking')}
                                    <li>
                                        <a class="list-item" href="{if is_set($pagedata.contacts['link_prenotazione_appuntamento'])}{$pagedata.contacts['link_prenotazione_appuntamento']|wash()}{else}{'prenota_appuntamento'|ezurl(no)}{/if}" data-element="appointment-booking">
                                            {display_icon('it-calendar', 'svg', 'icon icon-primary icon-sm', 'Book an appointment'|i18n('bootstrapitalia'))}<span>{'Book an appointment'|i18n('bootstrapitalia')}</span>
                                        </a>
                                    </li>
                                {/if}
                                {undef $context}
                            </ul>

                            {if $current_app|ne('inefficiency')}
                                <h2 class="title-medium-2-semi-bold mt-4">{'Trouble in the city'|i18n('bootstrapitalia')}</h2>
                                <ul class="contact-list p-0">
                                    <li>
                                        <a class="list-item" data-element="report-inefficiency" href="{if is_set($pagedata.contacts['link_segnalazione_disservizio'])}{$pagedata.contacts['link_segnalazione_disservizio']|wash()}{else}{'segnala_disservizio'|ezurl(no)}{/if}">
                                            {display_icon('it-map-marker-circle', 'svg', 'icon icon-primary icon-sm', 'Report a inefficiency'|i18n('bootstrapitalia'))}<span>{'Report a inefficiency'|i18n('bootstrapitalia')}</span>
                                        </a>
                                    </li>
                                </ul>
                            {/if}

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>