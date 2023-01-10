<div class="bg-grey-card shadow-contacts">
    <div class="container">
        <div class="row d-flex justify-content-center p-contacts">
            <div class="col-12 col-lg-6">
                <div class="cmp-contacts">
                    <div class="card w-100">
                        <div class="card-body">
                            <h2 class="title-medium-2-semi-bold">{'Contact the municipality'|i18n('bootstrapitalia')}</h2>
                            <ul class="contact-list p-0">
                                {def $faq_system = fetch(content, object, hash(remote_id, 'faq_system'))}
                                {if $faq_system}
                                <li>
                                    <a class="list-item" href="{object_handler($faq_system).content_link.full_link}" data-element="faq">
                                        {display_icon('it-help-circle', 'svg', 'icon icon-primary')}<span>{'Read the FAQ'|i18n('bootstrapitalia')}</span>
                                    </a>
                                </li>
                                {/if}
                                {undef $faq_system}
                                {if or(is_set($pagedata.contacts['link_assistenza']), is_set($pagedata.contacts['email']))}
                                <li>
                                    <a class="list-item" href="{if is_set($pagedata.contacts['link_assistenza'])}{$pagedata.contacts['link_assistenza']|wash()}{else}mailto:{$pagedata.contacts['email']|wash()}{/if}" data-element="contacts">
                                        {display_icon('it-mail', 'svg', 'icon icon-primary')}<span>{'Request assistance'|i18n('bootstrapitalia')}</span>
                                    </a>
                                </li>
                                {/if}
                                {if or(is_set($pagedata.contacts['numero_verde']), is_set($pagedata.contacts['telefono']))}
                                <li>
                                    <a class="list-item" href="{if is_set($pagedata.contacts['numero_verde'])}tel:{$pagedata.contacts['numero_verde']|wash()}{else}tel:{$pagedata.contacts['telefono']|wash()}{/if}">
                                        {display_icon('it-hearing', 'svg', 'icon icon-primary')}<span>{'Call the municipality'|i18n('bootstrapitalia')}</span>
                                    </a>
                                </li>
                                {/if}
                                {if or(is_set($pagedata.contacts['link_prenotazione_appuntamento']), is_set($pagedata.contacts['email']))}
                                <li>
                                    <a class="list-item" href="{if is_set($pagedata.contacts['link_prenotazione_appuntamento'])}{$pagedata.contacts['link_prenotazione_appuntamento']|wash()}{else}mailto:{$pagedata.contacts['email']|wash()}{/if}" data-element="appointment-booking">
                                        {display_icon('it-calendar', 'svg', 'icon icon-primary')}<span>{'Book an appointment'|i18n('bootstrapitalia')}</span>
                                    </a>
                                </li>
                                {/if}
                            </ul>

                            {if or(is_set($pagedata.contacts['link_segnalazione_disservizio']), is_set($pagedata.contacts['email']))}
                            <h2 class="title-medium-2-semi-bold mt-4">{'Trouble in the city'|i18n('bootstrapitalia')}</h2>
                            <ul class="contact-list p-0">
                                <li>
                                    <a class="list-item" data-element="report-inefficiency" href="{if is_set($pagedata.contacts['link_segnalazione_disservizio'])}{$pagedata.contacts['link_segnalazione_disservizio']|wash()}{else}mailto:{$pagedata.contacts['email']|wash()}{/if}">
                                        {display_icon('it-map-marker-circle', 'svg', 'icon icon-primary')}<span>{'Report a disservice'|i18n('bootstrapitalia')}</span>
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