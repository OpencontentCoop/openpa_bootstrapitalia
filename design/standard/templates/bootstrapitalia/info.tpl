{ezpagedata_set( 'has_container', true() )}
{def $pagedata = openpapagedata()}

<div class="container mb-3">
    <h2 class="mb-4">Gestioni contatti e informazioni generali</h2>

    {if is_set($message)}
        <div class="message-error">
            <p>{$message}</p>
        </div>
    {/if}

    {if $homepage}
        <form method="post" action="{'bootstrapitalia/info'|ezurl(no)}" enctype="multipart/form-data" class="form">
        {foreach $sections as $section}
            <div class="border border-light rounded p-3 mb-3">
                <h5>{$section.label}</h5>
                {foreach $section.contacts as $contact_identifier}
                    {def $contact = $contacts[$contact_identifier]}
                    <div class="row mb-3">
                        <label for="{$contact.identifier}" class="col-sm-3 col-form-label text-md-end">{$contact.label}</label>
                        <div class="col-sm-9">
                            <input type="text" name="Contacts[{$contact.label}]" class="form-control" id="{$contact.identifier}" value="{$contact.value}">
                        </div>
                    </div>
                    {undef $contact}
                {/foreach}
            </div>
        {/foreach}

        <div class="border border-light rounded p-3 mb-3">
            <h5>Logo</h5>
            <div class="row mb-3">
                <label for="Logo" class="col-sm-3 col-form-label">
                    {if $logo_url}
                        <img alt="{ezini('SiteSettings','SiteName')}"
                             width="82"
                             height="82"
                             class="bg-primary"
                             src="{$logo_url}" />
                    {/if}
                </label>
                <div class="col-sm-9">
                    <input type="file" name="Logo" class="form-control" id="Logo" value="">
                </div>
            </div>
        </div>

        <div class="border border-light rounded p-3 mb-3">
            <h5>Favicon</h5>
            <p class="form-text">La favicon viene visualizzata alla sinistra dell'URL nella barra degli indirizzi di un browser, quando si naviga sul sito. <br />Allegare un file di tipo .ico di almeno 48x48 pixel</p>
            <div class="row mb-3">
                <label for="Favicon" class="col-sm-3 col-form-label">
                    {def $_favicon_attribute = cond(
                        and( $homepage|has_attribute('favicon'), $homepage|attribute('favicon').has_content ),
                            $homepage|attribute('favicon'),
                            false()
                    )}
                    {def $_favicon = openpaini('GeneralSettings','favicon', 'favicon.ico')}
                    {def $_favicon_src = openpaini('GeneralSettings','favicon_src', 'ezimage')}
                    {if $_favicon_attribute}
                        <img alt="{ezini('SiteSettings','SiteName')}"
                             width="16"
                             height="16"
                             class="bg-primary"
                             src="{concat("content/download/",$_favicon_attribute.contentobject_id,"/",$_favicon_attribute.id,"/file/favicon.ico")|ezurl(no)}?v={$_favicon_attribute.version}" />
                    {elseif $_favicon_src|eq('ezimage')}
                        <img alt="{ezini('SiteSettings','SiteName')}"
                             width="16"
                             height="16"
                             class="bg-primary"
                             src="{$_favicon|ezimage(no)}" />
                    {else}
                        <img alt="{ezini('SiteSettings','SiteName')}"
                             width="16"
                             height="16"
                             class="bg-primary"
                             src="{$_favicon}" />
                    {/if}
                </label>
                <div class="col-sm-9">
                    <input type="file" name="Favicon" class="form-control" id="Favicon" value="">
                </div>
            </div>
        </div>

        {if is_set($homepage.data_map.apple_touch_icon)}
        <div class="border border-light rounded p-3 mb-3">
            <h5>Apple Touch Icon</h5>
            <p class="form-text">Icona per la schermata iniziale sui dispositivi mobili Apple e per i risultati nei motori di ricerca.<br />Allegare un file di tipo .png di 180x180 pixel</p>
            <div class="row mb-3">
                <label for="AppleTouchIcon" class="col-sm-3 col-form-label">
                    <img alt="{ezini('SiteSettings','SiteName')}"
                             width="50"
                             height="50"
                             src="{if $homepage.data_map.apple_touch_icon.has_content}{concat("content/download/",$homepage.data_map.apple_touch_icon.contentobject_id,"/",$homepage.data_map.apple_touch_icon.id,"/file/apple-touch-icon.png")|ezurl(no)}?v={$homepage.data_map.apple_touch_icon.version}{else}/extension/openpa_bootstrapitalia/design/standard/images/svg/icon.png{/if}" />
                </label>
                <div class="col-sm-9">
                    <input type="file" name="AppleTouchIcon" class="form-control" id="AppleTouchIcon" value="">
                </div>
            </div>
        </div>
        {/if}

        {if is_set($homepage.data_map.footer_logo)}
            <div class="border border-light rounded p-3 mb-3">
                <h5>Logo footer</h5>
                <div class="row mb-3">
                    <label for="LogoFooter" class="col-sm-3 col-form-label">
                        {if $homepage.data_map.footer_logo.has_content}
                            <img alt="{ezini('SiteSettings','SiteName')}"
                                 width="82"
                                 class="bg-primary"
                                 src="{$pagedata.homepage|attribute('footer_logo').content['header_logo'].full_path|ezroot(no)}" />
                        {/if}
                    </label>
                    <div class="col-sm-9">
                        <input type="file" name="LogoFooter" class="form-control" id="LogoFooter" value="">
                    </div>
                </div>
            </div>
        {/if}

        <div class="border border-light rounded p-3 mb-3">
            <h5>Link header</h5>
            <div class="row mb-3 ezcca-edit-datatype-ezobjectrelationlist">
                {include name=info_relation uri='design:bootstrapitalia/info/edit_relation.tpl' attribute=$homepage.data_map.link_nell_header attribute_base=ContentObjectAttribute max_items=5}
            </div>
        </div>

        <div class="border border-light rounded p-3 mb-3">
            <h5>Link footer</h5>
            <div class="row mb-3 ezcca-edit-datatype-ezobjectrelationlist">
                {include name=info_relation uri='design:bootstrapitalia/info/edit_relation.tpl' attribute=$homepage.data_map.link_nel_footer attribute_base=ContentObjectAttribute max_items=15}
            </div>
        </div>

        {if and( openpaini('GeneralSettings', 'ShowFooterBanner', 'disabled')|eq('enabled'), is_set($homepage.data_map.footer_banner) )}
            <div class="border border-light rounded p-3 mb-3">
                <h5>Banner footer</h5>
                <p class="text-muted">Viene visualizzato nel footer sulla destra il primo banner selezionato in questa sezione</p>
                <div class="row mb-3 ezcca-edit-datatype-ezobjectrelationlist">
                    {include name=info_relation uri='design:bootstrapitalia/info/edit_relation.tpl' attribute=$homepage.data_map.footer_banner attribute_base=ContentObjectAttribute max_items=1}
                </div>
            </div>
        {/if}

        <div class="row">
            <div class="col-12 text-right mt-3">
                <input type="submit" class="btn btn-success" name="Store" value="Salva"/>
            </div>
        </div>

    </form>
    {/if}

    {if $has_access_to_hot_zone}

        <div class="border border-light bg-danger rounded p-3 my-5">
            <div class="mb-4">
            <h4 class="text-white">Impostazioni avanzate</h4>
                <form method="post" action="{'bootstrapitalia/info'|ezurl(no)}" class="form bg-white rounded p-3">
                    <fieldset>
                        <legend class="h5 px-0">Importa informazioni</legend>
                        <div class="form-group mb-0">
                            <label for="ImportFrom" class="p-0">Importa contatti e informazioni generali da un'altra istanza OpenCity</label>
                            <div class="input-group">
                                <input type="text" class="form-control" id="ImportFrom" name="ImportFrom"
                                       placeholder="https://www.comune.bugliano.pi.it" />
                                <div class="input-group-append">
                                    <button class="btn btn-primary" type="submit">Importa</button>
                                </div>
                            </div>
                            <small class="form-text">
                                Inserisci l'indirizzo di un'altra istanza OpenCity da cui importare le informazioni. Ad esempio: https://www.comune.bugliano.pi.it
                            </small>
                        </div>
                    </fieldset>
                </form>
            </div>

            {*if $bridge_connection}
            <div class="mb-4">
                <form method="post" action="{'bootstrapitalia/info'|ezurl(no)}" class="form bg-white rounded p-3">
                <div class="form-group mb-0">
                    <label for="UpdateBridgeTargetUser" class="p-0">Aggiorna contatti e informazioni generali nell'area personale collegata {$bridge_connection|wash()}</label>
                    <div class="input-group">
                        <input type="text" class="form-control border-right" id="UpdateBridgeTargetUser" name="UpdateBridgeTargetUser" placeholder="Inserisci il nome utente" />
                        <div class="input-group-append" style="flex: 1 1 auto;">
                            <input type="text" class="form-control" id="UpdateBridgeTargetPassword" name="UpdateBridgeTargetPassword" placeholder="e la password dell'istanza collegata" />
                        </div>
                        <div class="input-group-append">
                            <button class="btn btn-primary" type="submit">Aggiorna</button>
                        </div>
                    </div>
                </div>
                </form>
            </div>
            {/if*}

            {if count($partners)}
                <div class="mb-4">
                    <form method="post" action="{'bootstrapitalia/info'|ezurl(no)}" class="form bg-white rounded p-3">
                    <fieldset>
                        <legend class="h5 px-0">Partner/distributore</legend>
                        <div class="form-group mb-0">
                            <label for="SelectPartner" class="p-0">Imposta partner/distributore</label>
                            <div class="input-group">
                                <select class="form-control" id="SelectPartner" name="SelectPartner">
                                    <option></option>
                                    {foreach $partners as $partner}
                                       <option value="{$partner.identifier|wash()}"{if and($current_partner, $current_partner.identifier|eq($partner.identifier))} selected="selected"{/if}>{$partner.name|wash()} - {$partner.url|wash()}</option>
                                    {/foreach}
                                </select>
                                <div class="input-group-append">
                                    <button class="btn btn-primary" type="submit">Seleziona</button>
                                </div>
                            </div>
                            <small class="form-text">
                                Il nome e l'url compaiono nel footer della pagina
                            </small>
                        </div>
                    </fieldset>
                </form>
            </div>
            {/if}

            <div class="mb-4">
                <form method="post" action="{'bootstrapitalia/info'|ezurl(no)}" class="form bg-white rounded p-3">
                    <fieldset>
                        <legend class="h5 px-0">Performance interfaccia di redazione</legend>
                        <div class="form-group mb-0">
                            <label for="UpdateBridgeTargetUser" class="p-0">Monitoraggio performance redazione</label>
                            <small class="form-text">Inserisci il valore di `src` del <a class="" href="https://docs.sentry.io/platforms/javascript/install/loader/">Sentry JavaScript Loader</a></small>
                            <div class="input-group">
                                <input type="text" class="form-control border-right" id="EditorPerformanceMonitor" name="EditorPerformanceMonitor" placeholder="https://js.sentry-cdn.com/xyz...min.js" value="{$sentry_script_loader_url}"/>
                                <div class="input-group-append">
                                    <button class="btn btn-primary" type="submit">Aggiorna</button>
                                </div>
                            </div>
                        </div>
                    </fieldset>
                </form>
            </div>

            {if has_bridge_connection()}
            <div class="mb-4">
                <form method="post" action="{'bootstrapitalia/info'|ezurl(no)}" class="form bg-white rounded p-3">
                    <fieldset>
                        <legend class="h5 px-0">Area personale</legend>
                        <input type="hidden" name="StanzadelcittadinoBridge" value="1" />
                        <div class="form-group form-check m-0 ps-1 pt-1 bg-white">
                            <input id="RuntimeServiceStatusCheck"
                                   class="form-check-input"
                                   type="checkbox"
                                   name="RuntimeServiceStatusCheck" {$sdc_status_check|choose( '', 'checked="checked"' )}
                                   value="" />
                            <label class="form-check-label mb-0 text-black" for="RuntimeServiceStatusCheck">
                                Mostra/nasconde i canali di erogazione nelle schede di servizio in base allo stato del servizio corrispondente in area personale
                            </label>
                        </div>
                        <div class="text-right mt-1">
                            <button class="btn btn-primary" type="submit">Aggiorna</button>
                        </div>
                    </fieldset>
                </form>
            </div>
            {/if}

            <div class="mb-4">
                <form method="post" action="{'bootstrapitalia/info'|ezurl(no)}" class="form bg-white rounded p-3">
                    <fieldset>
                        <legend class="h5 px-0">OpenAgenda</legend>
                        <input type="hidden" name="OpenAgendaBridge" value="1">
                        <div class="form-group mb-3">
                            <label for="OpenAgendaUrl" class="p-0">URL OpenAgenda</label>
                            <input type="text" class="form-control border-right" id="OpenAgendaUrl" name="OpenAgendaUrl" placeholder="https://openagenda.opencontent.it" value="{$openagenda_url}"/>
                        </div>
                        <div class="form-group form-check m-0 ps-1 bg-white">
                            <input id="OpenAgendaMainCalendar"
                                   class="form-check-input"
                                   type="checkbox"
                                   name="OpenAgendaMainCalendar" {$openagenda_embed_main|choose( '', 'checked="checked"' )}
                                   value="" />
                            <label class="form-check-label mb-0 text-black" for="OpenAgendaMainCalendar">
                                Visualizza i prossimi eventi di OpenAgenda in /Vivere-il-comune/Eventi
                            </label>
                        </div>
                        <div class="form-group form-check m-0 ps-1 bg-white">
                            <input id="OpenAgendaTopicCalendar"
                                   class="form-check-input"
                                   type="checkbox"
                                   name="OpenAgendaTopicCalendar" {$openagenda_embed_topic|choose( '', 'checked="checked"' )}
                                   value="" />
                            <label class="form-check-label mb-0 text-black" for="OpenAgendaTopicCalendar">
                                Visualizza i prossimi eventi di OpenAgenda nelle pagine argomento
                            </label>
                        </div>
                        <div class="form-group form-check m-0 ps-1 bg-white">
                            <input id="OpenAgendaOrganization"
                                   class="form-check-input"
                                   type="checkbox"
                                   name="OpenAgendaOrganization" {$openagenda_embed_organization|choose( '', 'checked="checked"' )}
                                   value="" />
                            <label class="form-check-label mb-0 text-black" for="OpenAgendaOrganization">
                                Visualizza le associazioni in /Amministrazione/Enti-e-fondazioni
                            </label>
                        </div>
                        <div class="form-group form-check m-0 ps-1 bg-white">
                            <input id="OpenAgendaPushPlace"
                                   class="form-check-input"
                                   type="checkbox"
                                   name="OpenAgendaPushPlace" {$openagenda_push_place|choose( '', 'checked="checked"' )}
                                   value="" />
                            <label class="form-check-label mb-0 text-black" for="OpenAgendaPushPlace">
                                Abilita il bottone di invio dei luoghi in OpenAgenda
                            </label>
                        </div>
                        {*<div class="form-group form-check m-0 ps-1 bg-white">
                            <input id="OpenAgendaPlaceCalendar"
                                   class="form-check-input"
                                   type="checkbox"
                                   name="OpenAgendaPlaceCalendar" {$openagenda_embed_place|choose( '', 'checked="checked"' )}
                                   value="" />
                            <label class="form-check-label mb-0 text-black" for="OpenAgendaPlaceCalendar">
                                Visualizza i prossimi eventi di OpenAgenda nelle pagine luogo
                            </label>
                        </div>*}
                        <div class="text-right mt-1">
                            <button class="btn btn-primary" type="submit">Aggiorna</button>
                        </div>
                    </fieldset>
                </form>
            </div>

            <div class="mb-4" id="Booking">
                <form method="post" action="{'bootstrapitalia/info'|ezurl(no)}" class="form bg-white rounded p-3">
                    <fieldset>
                        <legend class="h5 px-0">Calendari e prenotazione appuntamenti</legend>
                        <input type="hidden" name="StanzaDelCittadinoBooking" value="1">
                        <div class="form-group form-check m-0 ps-1 bg-white">
                            <input id="StanzaDelCittadinoBookingEnable"
                                   class="form-check-input"
                                   type="checkbox"
                                   name="StanzaDelCittadinoBookingEnable" {$stanzadelcittadino_booking|choose( '', 'checked="checked"' )}
                                   value="" />
                            <label class="form-check-label mb-0 text-black" for="StanzaDelCittadinoBookingEnable">
                                Abilita la configurazione dei calendari e il relativo widget di prenotazione
                            </label>
                        </div>
                        <div class="form-group form-check m-0 ps-1 bg-white">
                            <input id="StanzaDelCittadinoBookingStoreAsApplication"
                                   class="form-check-input"
                                   type="checkbox"
                                   name="StanzaDelCittadinoBookingStoreAsApplication" {$stanzadelcittadino_booking_store_as_application|choose( '', 'checked="checked"' )}
                                   value="" />
                            <label class="form-check-label mb-0 text-black" for="StanzaDelCittadinoBookingStoreAsApplication">
                                Salva in area personale gli appuntamenti come pratiche (applications)
                            </label>
                        </div>
                        <div class="form-group form-check m-0 ps-1 bg-white">
                            <input id="StanzaDelCittadinoBookingServiceDiscover"
                                   class="form-check-input"
                                   type="checkbox"
                                   name="StanzaDelCittadinoBookingServiceDiscover" {$stanzadelcittadino_booking_service_discover|choose( '', 'checked="checked"' )}
                                   value="" />
                            <label class="form-check-label mb-0 text-black" for="StanzaDelCittadinoBookingServiceDiscover">
                                Visualizza il selettore dei servizi invece che il widget di appuntamento generico
                            </label>
                        </div>
                        <div class="text-right mt-1">
                            <button class="btn btn-primary" type="submit">Aggiorna</button>
                        </div>
                    </fieldset>
                </form>
            </div>

            <div class="mb-4" id="Builtin">
                <form method="post" action="{'bootstrapitalia/info'|ezurl(no)}" class="form bg-white rounded p-3">
                    <fieldset>
                        <legend class="h5 px-0">Integrazione con area personale (servizi builtin)</legend>
                        {foreach $built_in_options as $built_in_option}
                        {if $built_in_option.type|eq('boolean')}
                            <p class="font-weight-bold mt-2 mb-1 d-none">{$built_in_option.name|wash()}</p>
                            <div class="form-group form-check m-0 mb-4 ps-1 bg-white">
                                <input id="StanzaDelCittadinoBuiltin_{$built_in_option.identifier|wash()}"
                                       class="form-check-input"
                                       type="checkbox"
                                       name="StanzaDelCittadinoBuiltin[{$built_in_option.identifier|wash()}]" {$built_in_option.current_value|choose( '', 'checked="checked"' )}
                                       value="1" />
                                <label class="form-check-label mb-0 text-black" for="StanzaDelCittadinoBuiltin_{$built_in_option.identifier|wash()}">
                                    {$built_in_option.name|wash()}
                                </label>
                            </div>
                        {else}
                            <div class="form-group mb-4">
                                <label for="StanzaDelCittadinoBuiltin_{$built_in_option.identifier|wash()}" class="text-black p-0">{$built_in_option.name|wash()}</label>
                                <input type="text" class="form-control border-right"
                                       placeholder="{$built_in_option.placeholder|wash()}"
                                       id="StanzaDelCittadinoBuiltin_{$built_in_option.identifier|wash()}"
                                       name="StanzaDelCittadinoBuiltin[{$built_in_option.identifier|wash()}]"
                                       value="{$built_in_option.current_value|wash()}"/>
                            </div>
                        {/if}
                        {/foreach}
                        <div class="text-right mt-1">
                            <button class="btn btn-primary" type="submit">Aggiorna</button>
                        </div>
                    </fieldset>
                </form>
            </div>

            <div class="mb-4">
                <form method="post" action="{'bootstrapitalia/info'|ezurl(no)}" class="form bg-white rounded p-3">
                    <fieldset>
                        <legend class="h5 px-0">Pagina di accesso all'area personale</legend>
                        <input type="hidden" name="AccessPageSettings" value="1">
                        <div class="form-group form-check m-0 ps-1 bg-white">
                            <input id="AccessPageSettingsSpidEnable"
                                   class="form-check-input"
                                   type="checkbox"
                                   name="AccessPageSettingsSpidEnable" {$access_spid|choose( '', 'checked="checked"' )}
                                   disabled="disabled"
                                   value="" />
                            <label class="form-check-label mb-0 text-black" for="AccessPageSettingsSpidEnable">
                                Abilita SPID
                            </label>
                        </div>
                        <div class="form-group form-check m-0 ps-1 bg-white">
                            <input id="AccessPageSettingsCieEnable"
                                   class="form-check-input"
                                   type="checkbox"
                                   name="AccessPageSettingsCieEnable" {$access_cie|choose( '', 'checked="checked"' )}
                                   value="" />
                            <label class="form-check-label mb-0 text-black" for="AccessPageSettingsCieEnable">
                                Abilita CIE
                            </label>
                        </div>
                        <div class="form-group form-check m-0 ps-1 bg-white">
                            <input id="AccessPageSettingsEidasEnable"
                                   class="form-check-input"
                                   type="checkbox"
                                   name="AccessPageSettingsEidasEnable" {$access_eidas|choose( '', 'checked="checked"' )}
                                   value="" />
                            <label class="form-check-label mb-0 text-black" for="AccessPageSettingsEidasEnable">
                                Abilita eIDAS
                            </label>
                        </div>
                        <div class="form-group form-check m-0 ps-1 bg-white">
                            <input id="AccessPageSettingsCnsEnable"
                                   class="form-check-input"
                                   type="checkbox"
                                   name="AccessPageSettingsCnsEnable" {$access_cns|choose( '', 'checked="checked"' )}
                                   value="" />
                            <label class="form-check-label mb-0 text-black" for="AccessPageSettingsCnsEnable">
                                Abilita CNS
                            </label>
                        </div>
                        <div class="text-right mt-1">
                            <button class="btn btn-primary" type="submit">Aggiorna</button>
                        </div>
                    </fieldset>
                </form>
            </div>

            <form method="post" action="{'bootstrapitalia/info'|ezurl(no)}" class="form bg-white rounded p-3">
                <fieldset>
                    <legend class="h5 px-0">Sistema di approvazione dei contenuti</legend>
                    <input type="hidden" name="Moderation" value="1" />
                    <div class="form-group form-check m-0 ps-1 pt-1 bg-white">
                        <input id="ModerationIsEnabled"
                               class="form-check-input"
                               type="checkbox"
                               name="ModerationIsEnabled" {is_approval_enabled()|choose( '', 'checked="checked"' )}
                               value="" />
                        <label class="form-check-label mb-0 text-black" for="ModerationIsEnabled">
                            Abilita il sistema di approvazione dei contenuti basato sulle versioni
                        </label>
                    </div>
                    <small class="form-text">
                        Attenzione: quando si disattiva questa funzionalità vengono rimosse tutte le configurazioni di moderazione e sarà necessario ridefinire tutti gli utenti da moderare
                    </small>
                    <div class="text-right mt-1">
                        <button class="btn btn-primary" type="submit">Aggiorna</button>
                    </div>
                </fieldset>
            </form>

        </div>
    {/if}
    {ezscript_require(array('jquery.relationsbrowse.js'))}
    <script>
        let relationI18n = {ldelim}
          clickToClose: "{'Click to close'|i18n('opendata_forms')}",
          clickToOpenSearch: "{'Click to open search engine'|i18n('opendata_forms')}",
          search: "{'Search'|i18n('opendata_forms')}",
          clickToBrowse: "{'Click to browse contents'|i18n('opendata_forms')}",
          browse: "{'Browse'|i18n('opendata_forms')}",
          createNew: "{'Create new'|i18n('opendata_forms')}",
          create: "{'Create'|i18n('opendata_forms')}",
          allContents: "{'All contents'|i18n('opendata_forms')}",
          clickToBrowseParent: "{'Click to view parent'|i18n('opendata_forms')}",
          noContents: "{'No contents'|i18n('opendata_forms')}",
          back: "{'Back'|i18n('opendata_forms')}",
          goToPreviousPage: "{'Go to previous'|i18n('opendata_forms')}",
          goToNextPage: "{'Go to next'|i18n('opendata_forms')}",
          clickToBrowseChildren: "{'Click to view children'|i18n('opendata_forms')}",
          clickToPreview: "{'Click to preview'|i18n('opendata_forms')}",
          preview: "{'Preview'|i18n('opendata_forms')}",
          closePreview: "{'Close preview'|i18n('opendata_forms')}",
          addItem: "{'Add'|i18n('opendata_forms')}",
          selectedItems: "{'Selected items'|i18n('opendata_forms')}",
          removeFromSelection: "{'Remove from selection'|i18n('opendata_forms')}",
          addToSelection: "{'Add to selection'|i18n('opendata_forms')}",
          store: "{'Store'|i18n('opendata_forms')}",
          storeLoading: "{'Loading...'|i18n('opendata_forms')}"
        {rdelim};
        {literal}
        $(document).ready(function () {
          $('.relations-searchbox').each(function () {
            let container = $(this)
            let getSelection = function (){
              let selection = [];
              container.find('input[type="checkbox"]').each(function () {
                let selected = parseInt($(this).val()) || 0;
                if (selected > 0) {
                  selection.push({contentobject_id: selected})
                }
              })
              return selection
            };
            let browserToggler = container.find('.relation_browser_toggler')
            let browser = container.find('.relation_browser')
            let maxItems = browser.data('relation_maxitems')
            let classes = browser.data('relation_classes')
            if (getSelection().length >= maxItems){
              browserToggler.hide()
            }
            let remover = container.find('.ezobject-relation-remove-button');

            browser.relationsbrowse({
              'attributeId': browser.data('relation_attribute'),
              'subtree': browser.data('relation_subtree'),
              'addCloseButton': true,
              'allowAllBrowse': true,
              'addCreateButton': false,
              'openInSearchMode': true,
              'classes': classes.length > 0 ? classes.split(',') : false,
              'i18n': relationI18n
            }).on('relationsbrowse.close', function (event, opendataBrowse) {
              browser.toggle();
            }).hide();

            browserToggler.on('click', function (e) {
              e.preventDefault();
              browser.data('plugin_relationsbrowse').setSelection(getSelection());
              browser.toggle();
            });

            browser.on('relationbrowse.change', function (e, relationBrowser) {
              if (relationBrowser.selection.length > 0){
                remover.show()
                if (relationBrowser.selection.length >= maxItems){
                  browserToggler.hide()
                  browser.hide()
                }
              } else {
                remover.hide()
              }
            })

            remover.on('click', function (e) {
              e.preventDefault();
              let isDone = false
              container.find('input[type="checkbox"]:checked').each(function () {
                $(this).parents('tr').remove();
                isDone = true
              });
              if (isDone) {
                browserToggler.show()
                if (getSelection().length > 0) {
                  remover.show()
                } else {
                  remover.hide()
                }
                browser.data('plugin_relationsbrowse').setSelection(getSelection());
              }
            })
          })
        })
        {/literal}
    </script>
    <style>
        .relations-searchbox .fa-stack.text-info{ldelim}
            display:none !important;
        {rdelim}
    </style>