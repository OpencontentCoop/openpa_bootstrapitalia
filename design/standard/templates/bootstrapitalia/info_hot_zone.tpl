{def $has_moderation_group = fetch(content, object, hash(remote_id, 'moderation'))}

<div class="border border-danger rounded p-3 my-5">

  <small class="float-end"><a class="btn btn-xs btn-outline-primary" href="{'ocsupport/dashboard'|ezurl(no)}">Visualizza moduli installati</a></small>
  <h4 class="text-danger" id="hotzone">
    Impostazioni avanzate
  </h4>
  <div class="row mt-4 mb-5">
    <div class="col-3">
      <ul class="nav nav-tabs nav-tabs-vertical" role="tablist" aria-orientation="vertical">
        <li class="nav-item"><a class="nav-link ps-0 active" data-toggle="tab" data-bs-toggle="tab" href="#import" data-focus-mouse="false" style="max-width: 100%">Importa informazioni</a></li>

        {if count($partners)}
        <li class="nav-item"><a class="nav-link ps-0" data-toggle="tab" data-bs-toggle="tab" href="#partner" data-focus-mouse="false" style="max-width: 100%">Partner/distributore</a></li>
        {/if}

        <li class="nav-item"><a class="nav-link ps-0" data-toggle="tab" data-bs-toggle="tab" href="#performance" data-focus-mouse="false" style="max-width: 100%">Performance interfaccia di redazione</a></li>

        {if has_bridge_connection()}
        <li class="nav-item"><a class="nav-link ps-0" data-toggle="tab" data-bs-toggle="tab" href="#area-personale" data-focus-mouse="false" style="max-width: 100%">Area personale: canali digitali</a></li>
        {/if}

        <li class="nav-item"><a class="nav-link ps-0" data-toggle="tab" data-bs-toggle="tab" href="#openagenda" data-focus-mouse="false" style="max-width: 100%">OpenAgenda</a></li>

        <li class="nav-item"><a class="nav-link ps-0" data-toggle="tab" data-bs-toggle="tab" href="#Booking" data-focus-mouse="false" style="max-width: 100%">Calendari e prenotazione appuntamenti</a></li>

        <li class="nav-item"><a class="nav-link ps-0" data-toggle="tab" data-bs-toggle="tab" href="#Builtin" data-focus-mouse="false" style="max-width: 100%">Integrazione con area personale (servizi builtin e evo)</a></li>

        <li class="nav-item"><a class="nav-link ps-0" data-toggle="tab" data-bs-toggle="tab" href="#logins" data-focus-mouse="false" style="max-width: 100%">Pagina di accesso all'area personale</a></li>

        {if $has_moderation_group}
        <li class="nav-item"><a class="nav-link ps-0" data-toggle="tab" data-bs-toggle="tab" href="#moderation" data-focus-mouse="false" style="max-width: 100%">Sistema di approvazione dei contenuti</a></li>
        {/if}

        <li class="nav-item"><a class="nav-link ps-0" data-toggle="tab" data-bs-toggle="tab" href="#oauth" data-focus-mouse="false" style="max-width: 100%">Client oAuth per l'autenticazione dei redattori</a></li>

        {if ezini_hasvariable('GeneralSettings', 'ApiUrl', 'sendy.ini')}
        <li class="nav-item"><a class="nav-link ps-0" data-toggle="tab" data-bs-toggle="tab" href="#sendy" data-focus-mouse="false" style="max-width: 100%">Newsletter Sendy</a></li>
        {/if}

        <li class="nav-item"><a class="nav-link ps-0" data-toggle="tab" data-bs-toggle="tab" href="#csp" data-focus-mouse="false" style="max-width: 100%">Content Security Policy</a></li>

        <li class="nav-item"><a class="nav-link ps-0" data-toggle="tab" data-bs-toggle="tab" href="#google" data-focus-mouse="false" style="max-width: 100%">Credenziali Google</a></li>
      </ul>
    </div>
    <div class="col-9 tab-content">

      <div class="position-relative clearfix tab-pane active" id="import">
        <form method="post" action="{'bootstrapitalia/info#import'|ezurl(no)}" class="form">
          <fieldset>
            <legend class="h4 px-0 pb-3">Importa informazioni</legend>
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

      {if count($partners)}
      <div class="position-relative clearfix tab-pane" id="partner">
        <form method="post" action="{'bootstrapitalia/info#partner'|ezurl(no)}" class="form">
          <fieldset>
            <legend class="h4 px-0 pb-3">Partner/distributore</legend>
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

      <div class="position-relative clearfix tab-pane" id="performance">
        <form method="post" action="{'bootstrapitalia/info#performance'|ezurl(no)}" class="form">
          <fieldset>
            <legend class="h4 px-0 pb-3">Performance interfaccia di redazione</legend>
            <div class="form-group mb-0">
              <label for="UpdateBridgeTargetUser" class="p-0">Monitoraggio performance redazione</label>
              <small class="form-text">Inserisci il valore di `src` del <a class="" href="https://docs.sentry.io/platforms/javascript/install/loader/">Sentry JavaScript Loader</a></small>
              <div class="input-group">
                <input type="text" class="form-control border-right" id="EditorPerformanceMonitor" name="EditorPerformanceMonitor" placeholder="https://js.sentry-cdn.com/xyz...min.js" value="{$sentry_script_loader_url}"/>
                <div class="input-group-append">
                  <button class="btn btn-primary" type="submit">Salva</button>
                </div>
              </div>
            </div>
          </fieldset>
        </form>
      </div>

      {if has_bridge_connection()}
      <div class="position-relative clearfix tab-pane" id="area-personale">
        <form method="post" action="{'bootstrapitalia/info#area-personale'|ezurl(no)}" class="form">
          <fieldset>
            <legend class="h4 px-0 pb-3">Area personale</legend>
            <input type="hidden" name="StanzadelcittadinoBridge" value="1" />
            <div class="form-group form-check m-0 ps-1 pt-1 bg-white">
              <input id="RuntimeServiceStatusCheck"
                     class="form-check-input"
                     type="checkbox"
                     name="RuntimeServiceStatusCheck" {$sdc_status_check|choose( '', 'checked="checked"' )}
                     value="" />
              <label class="form-check-label mb-0 text-black" for="RuntimeServiceStatusCheck" style="white-space: normal;">
                Mostra/nasconde i canali di erogazione nelle schede di servizio in base allo stato del servizio corrispondente in area personale
              </label>
            </div>
            <div class="text-right mt-1">
              <button class="btn btn-primary" type="submit">Salva</button>
            </div>
          </fieldset>
        </form>
      </div>
      {/if}

      <div class="position-relative clearfix tab-pane" id="openagenda">
        <form method="post" action="{'bootstrapitalia/info#openagenda'|ezurl(no)}" class="form">
          <fieldset>
            <legend class="h4 px-0 pb-3">OpenAgenda</legend>
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
              <label class="form-check-label mb-0 text-black" for="OpenAgendaMainCalendar" style="white-space: normal;">
                Visualizza i prossimi eventi di OpenAgenda in /Vivere-il-comune/Eventi
              </label>
            </div>
            <div class="form-group form-check m-0 ps-1 bg-white">
              <input id="OpenAgendaTopicCalendar"
                     class="form-check-input"
                     type="checkbox"
                     name="OpenAgendaTopicCalendar" {$openagenda_embed_topic|choose( '', 'checked="checked"' )}
                     value="" />
              <label class="form-check-label mb-0 text-black" for="OpenAgendaTopicCalendar" style="white-space: normal;">
                Visualizza i prossimi eventi di OpenAgenda nelle pagine argomento
              </label>
            </div>
            <div class="form-group form-check m-0 ps-1 bg-white">
              <input id="OpenAgendaOrganization"
                     class="form-check-input"
                     type="checkbox"
                     name="OpenAgendaOrganization" {$openagenda_embed_organization|choose( '', 'checked="checked"' )}
                     value="" />
              <label class="form-check-label mb-0 text-black" for="OpenAgendaOrganization" style="white-space: normal;">
                Visualizza le associazioni in /Amministrazione/Enti-e-fondazioni
              </label>
            </div>
            <div class="form-group form-check m-0 ps-1 bg-white">
              <input id="OpenAgendaPushPlace"
                     class="form-check-input"
                     type="checkbox"
                     name="OpenAgendaPushPlace" {$openagenda_push_place|choose( '', 'checked="checked"' )}
                     value="" />
              <label class="form-check-label mb-0 text-black" for="OpenAgendaPushPlace" style="white-space: normal;">
                Abilita il bottone di invio dei luoghi in OpenAgenda
              </label>
            </div>
              {*<div class="form-group form-check m-0 ps-1 bg-white">
                  <input id="OpenAgendaPlaceCalendar"
                         class="form-check-input"
                         type="checkbox"
                         name="OpenAgendaPlaceCalendar" {$openagenda_embed_place|choose( '', 'checked="checked"' )}
                         value="" />
                  <label class="form-check-label mb-0 text-black" for="OpenAgendaPlaceCalendar" style="white-space: normal;">
                      Visualizza i prossimi eventi di OpenAgenda nelle pagine luogo
                  </label>
              </div>*}
            <div class="text-right mt-1">
              <button class="btn btn-primary" type="submit">Salva</button>
            </div>
          </fieldset>
        </form>
      </div>

      <div class="position-relative clearfix tab-pane" id="Booking">
        <form method="post" action="{'bootstrapitalia/info#booking'|ezurl(no)}" class="form">
          <fieldset>
            <legend class="h4 px-0 pb-3">Calendari e prenotazione appuntamenti</legend>
            <input type="hidden" name="StanzaDelCittadinoBooking" value="1">
            <div class="form-group form-check m-0 ps-1 bg-white">
              <input id="StanzaDelCittadinoBookingEnable"
                     class="form-check-input"
                     type="checkbox"
                     name="StanzaDelCittadinoBookingEnable" {$stanzadelcittadino_booking|choose( '', 'checked="checked"' )}
                     value="" />
              <label class="form-check-label mb-0 text-black" for="StanzaDelCittadinoBookingEnable" style="white-space: normal;">
                Abilita la configurazione dei calendari e il relativo widget di prenotazione
              </label>
            </div>
            <div class="form-group form-check m-0 ps-1 bg-white">
              <input id="StanzaDelCittadinoBookingStoreAsApplication"
                     class="form-check-input"
                     type="checkbox"
                     name="StanzaDelCittadinoBookingStoreAsApplication" {$stanzadelcittadino_booking_store_as_application|choose( '', 'checked="checked"' )}
                     value="" />
              <label class="form-check-label mb-0 text-black" for="StanzaDelCittadinoBookingStoreAsApplication" style="white-space: normal;">
                Salva in area personale gli appuntamenti come pratiche (applications)
              </label>
            </div>
            <div class="form-group form-check m-0 ps-1 bg-white">
              <input id="StanzaDelCittadinoBookingServiceDiscover"
                     class="form-check-input"
                     type="checkbox"
                     name="StanzaDelCittadinoBookingServiceDiscover" {$stanzadelcittadino_booking_service_discover|choose( '', 'checked="checked"' )}
                     value="" />
              <label class="form-check-label mb-0 text-black" for="StanzaDelCittadinoBookingServiceDiscover" style="white-space: normal;">
                Visualizza il selettore dei servizi invece che il widget di appuntamento generico
              </label>
            </div>
            <div class="form-group form-check m-0 ps-1 bg-white">
              <input id="StanzaDelCittadinoBookingScheduler"
                     class="form-check-input"
                     type="checkbox"
                     name="StanzaDelCittadinoBookingScheduler" {$stanzadelcittadino_booking_scheduler|choose( '', 'checked="checked"' )}
                     value="" />
              <label class="form-check-label mb-0 text-black" for="StanzaDelCittadinoBookingScheduler" style="white-space: normal;">
                Visualizza il calendario settimanale come selettore della data
              </label>
            </div>
            <div class="form-group form-check m-0 ps-1 bg-white">
              <input id="StanzaDelCittadinoBookingShowHowTo"
                     class="form-check-input"
                     type="checkbox"
                     name="StanzaDelCittadinoBookingShowHowTo" {$stanzadelcittadino_booking_how_to|choose( '', 'checked="checked"' )}
                     value="" />
              <label class="form-check-label mb-0 text-black" for="StanzaDelCittadinoBookingShowHowTo" style="white-space: normal;">
                Visualizza il contenuto della sezione "Cosa serve" della scheda servizio
              </label>
            </div>
            <div class="text-right mt-1">
              <button class="btn btn-primary" type="submit">Salva</button>
            </div>
          </fieldset>
        </form>
      </div>

      <div class="position-relative clearfix tab-pane" id="Builtin">
        <form method="post" action="{'bootstrapitalia/info#builtin'|ezurl(no)}" class="form">
          <fieldset>
            <legend class="h4 px-0 pb-3">Integrazione con area personale (servizi builtin e evo)</legend>
              {foreach $grouped_built_in_options as $label => $built_in_options_group}
                <h6 class="mb-1">{$label|wash()}</h6>
                <div class="border mb-4 py-1 px-3 rounded">
                    {foreach $built_in_options_group as $built_in_option}
                        {if $built_in_option.type|eq('boolean')}
                          <p class="font-weight-bold mt-2 mb-1 d-none">{$built_in_option.name|wash()}</p>
                          <div class="form-group form-check mt-1 mb-4 ps-1 bg-white">
                            <input id="StanzaDelCittadinoBuiltin_{$built_in_option.identifier|wash()}"
                                   class="form-check-input"
                                   type="checkbox"
                                   name="StanzaDelCittadinoBuiltin[{$built_in_option.identifier|wash()}]" {$built_in_option.current_value|choose( '', 'checked="checked"' )}
                                   value="1" />
                            <label class="form-check-label mb-0 text-black" for="StanzaDelCittadinoBuiltin_{$built_in_option.identifier|wash()}" style="white-space: normal;">
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
                </div>
              {/foreach}
            <div class="text-right mt-1">
              <button class="btn btn-primary" type="submit">Salva</button>
            </div>
          </fieldset>
        </form>
      </div>

      <div class="position-relative clearfix tab-pane" id="logins">
        <form method="post" action="{'bootstrapitalia/info#logins'|ezurl(no)}" class="form">
          <fieldset>
            <legend class="h4 px-0 pb-3">Pagina di accesso all'area personale</legend>
            <input type="hidden" name="AccessPageSettings" value="1">
            <div class="form-group form-check m-0 ps-1 bg-white">
              <input id="AccessPageSettingsSpidEnable"
                     class="form-check-input"
                     type="checkbox"
                     name="AccessPageSettingsSpidEnable" {$access_spid|choose( '', 'checked="checked"' )}
                     disabled="disabled"
                     value="" />
              <label class="form-check-label mb-0 text-black" for="AccessPageSettingsSpidEnable" style="white-space: normal;">
                Abilita SPID
              </label>
            </div>
            <div class="form-group form-check m-0 ps-1 bg-white">
              <input id="AccessPageSettingsCieEnable"
                     class="form-check-input"
                     type="checkbox"
                     name="AccessPageSettingsCieEnable" {$access_cie|choose( '', 'checked="checked"' )}
                     value="" />
              <label class="form-check-label mb-0 text-black" for="AccessPageSettingsCieEnable" style="white-space: normal;">
                Abilita CIE
              </label>
            </div>
            <div class="form-group form-check m-0 ps-1 bg-white">
              <input id="AccessPageSettingsEidasEnable"
                     class="form-check-input"
                     type="checkbox"
                     name="AccessPageSettingsEidasEnable" {$access_eidas|choose( '', 'checked="checked"' )}
                     value="" />
              <label class="form-check-label mb-0 text-black" for="AccessPageSettingsEidasEnable" style="white-space: normal;">
                Abilita eIDAS
              </label>
            </div>
            <div class="form-group form-check m-0 ps-1 bg-white">
              <input id="AccessPageSettingsCnsEnable"
                     class="form-check-input"
                     type="checkbox"
                     name="AccessPageSettingsCnsEnable" {$access_cns|choose( '', 'checked="checked"' )}
                     value="" />
              <label class="form-check-label mb-0 text-black" for="AccessPageSettingsCnsEnable" style="white-space: normal;">
                Abilita CNS
              </label>
            </div>
            <div class="text-right mt-1">
              <button class="btn btn-primary" type="submit">Salva</button>
            </div>
          </fieldset>
        </form>
      </div>

      {if $has_moderation_group}
      <div class="position-relative clearfix tab-pane" id="moderation">
        <form method="post" action="{'bootstrapitalia/info#moderation'|ezurl(no)}" class="form">
          <fieldset>
            <legend class="h4 px-0 pb-3">Sistema di approvazione dei contenuti</legend>
            <input type="hidden" name="Moderation" value="1" />
            <div class="form-group form-check m-0 ps-1 pt-1 bg-white">
              <input id="ModerationIsEnabled"
                     class="form-check-input"
                     type="checkbox"
                     name="ModerationIsEnabled" {is_approval_enabled()|choose( '', 'checked="checked"' )}
                     value="" />
              <label class="form-check-label mb-0 text-black" for="ModerationIsEnabled" style="white-space: normal;">
                Abilita il sistema di approvazione dei contenuti basato sulle versioni
              </label>
            </div>
            <small class="form-text">
              Attenzione: quando si disattiva questa funzionalità vengono rimosse tutte le configurazioni di moderazione e sarà necessario ridefinire tutti gli utenti da moderare
            </small>
            <div class="text-right mt-1">
              <button class="btn btn-primary" type="submit">Salva</button>
            </div>
          </fieldset>
        </form>
      </div>
      {/if}

      <div class="position-relative clearfix tab-pane" id="oauth">
        <form method="post" action="{'bootstrapitalia/info'|ezurl(no)}" class="form">
          <fieldset>
            <legend class="h4 px-0 pb-3">Client oAuth per l'autenticazione dei redattori</legend>
              {foreach $oauth_options as $oauth_option}
                  {if $oauth_option.type|eq('boolean')}
                    <p class="font-weight-bold mt-2 mb-1 d-none">{$oauth_option.name|wash()}</p>
                    <div class="form-group form-check m-0 mb-4 ps-1 bg-white">
                      <input id="LoginOauth_{$oauth_option.identifier|wash()}"
                             class="form-check-input"
                             type="checkbox"
                             name="LoginOauth[{$oauth_option.identifier|wash()}]" {$oauth_option.current_value|choose( '', 'checked="checked"' )}
                             value="1" />
                      <label class="form-check-label mb-0 text-black" for="LoginOauth_{$oauth_option.identifier|wash()}">
                          {$oauth_option.name|wash()}
                      </label>
                    </div>
                  {else}
                    <div class="form-group mb-4">
                      <label for="LoginOauth_{$oauth_option.identifier|wash()}" class="text-black p-0">{$oauth_option.name|wash()}</label>
                      <input type="text" class="form-control border-right"
                             placeholder="{$oauth_option.placeholder|wash()}"
                             id="LoginOauth_{$oauth_option.identifier|wash()}"
                             name="LoginOauth[{$oauth_option.identifier|wash()}]"
                             value="{$oauth_option.current_value|wash()}"/>
                    </div>
                  {/if}
              {/foreach}
            <div class="text-right mt-1">
              <button class="btn btn-primary" type="submit">Salva</button>
            </div>
          </fieldset>
        </form>
      </div>

      {if ezini_hasvariable('GeneralSettings', 'ApiUrl', 'sendy.ini')}
      <div class="position-relative clearfix tab-pane" id="sendy">
        <form method="post" action="{'bootstrapitalia/info#sendy'|ezurl(no)}" class="form">
          <fieldset>
            <legend class="h4 px-0 pb-3">Newsletter: <a href="https://{sendy_url()}/" target="_blank">Sendy <i class="fa fa-external-link"></i> </a></legend>
            <div class="form-group mb-4">
              <label for="SendyBrandId" class="p-0">Id del brand</label>
              <small class="form-text">Inserisci l'id del brand creato per questa istanza</small>
              <input type="text" class="form-control border-right" id="SendyBrandId" name="SendyBrandId" value="{sendy_brand_id()}"/>
            </div>
            <div class="form-group form-check m-0 mb-4 ps-1 bg-white">
              <input id="SendySendSingleContent"
                     class="form-check-input"
                     type="checkbox"
                     name="SendySendSingleContent" {can_create_sendy_campaign()|choose( '', 'checked="checked"' )}
                     value="1" />
              <label class="form-check-label mb-0 text-black" for="SendySendSingleContent" style="white-space: normal;">
                Permetti la creazione di una campagna da un comunicato
              </label>
            </div>
            <div class="text-right mt-1">
              <button class="btn btn-primary" type="submit">Salva</button>
            </div>
          </fieldset>
        </form>
      </div>
      {/if}

      <div class="position-relative clearfix tab-pane" id="csp">
        <fieldset>

          {foreach $csp as $name => $values}
            <legend class="h4 px-0 pb-3">{$name|wash()}</legend>
            {if count($values)|eq(0)}
                <p class="lead"><em>Valori custom disabilitati: verrà ereditata la configurazione di default del server</em></p>
            {else}
              <dl class="row">
                {foreach $values as $directive => $value}
                  <dt class="col-sm-3 border-bottom my-2 py-2">{$directive}</dt>
                  <dd class="col-sm-9 border-bottom my-2 py-2">
                    {if is_array($value)|not()}
                        {set $value = array($value)}
                    {/if}
                    <ul>
                    {foreach $value as $item}
                      <li>{$item}</li>
                    {/foreach}
                    </ul>
                  </dd>
                {/foreach}
              </dl>
            {/if}
          {/foreach}
        </fieldset>
      </div>

      <div class="position-relative clearfix tab-pane" id="google">
        <form method="post" action="{'bootstrapitalia/info#google'|ezurl(no)}" class="form">
          <fieldset>
            <legend class="h4 px-0 pb-3">Impostazioni del account di servizio Google per import da Spreadsheet</legend>
            {if $google_user}
                <p>
                  Account corrente:<br />
                  <code>{$google_user|wash()}</code>
                  {if $google_user_source|eq('CUSTOM')}
                    <button class="btn btn-xs btn-danger mr-2 ms-2" type="submit" name="RemoveGoogleSheetCredentials"><i class="fa fa-trash"></i></button>
                  {else}
                    (default)
                  {/if}
                </p>
            {/if}
            <div class="richtext-wrapper">
              <p>Per creare e configurare un nuovo account di servizio:</p>
              <ol>
                <li>Accedi alla <a href="https://console.cloud.google.com">console Google cloud</a></li>
                <li>Crea un nuovo progetto in Api e servizi</li>
                <li>Abilita le Google Sheets API per i progetto creato</li>
                <li>In Credenziali crea account di servizio</li>
                <li>Aggiungi una chiave in JSON per l'account di servizio</li>
                <li>Incolla qui il contenuto JSON e salva</li>
              </ol>
            </div>
            <div class="form-group form-check m-0 ps-1 pt-1 bg-white">
              <textarea id="GoogleSheetCredentials"
                     class="form-input" name="GoogleSheetCredentials"></textarea>
            </div>
            <div class="text-right mt-1">
              <button class="btn btn-primary" type="submit">Salva</button>
            </div>
          </fieldset>
        </form>
      </div>

    </div>
  </div>

</div>
{literal}
<script>
  $(document).ready(function (){
    var triggerFirstTabEl = document.querySelector('[href="' + location.hash + '"]')
    var tab = bootstrap.Tab.getOrCreateInstance(triggerFirstTabEl);
    if (tab) {
      tab.show()
      $(window).scrollTop(($('#hotzone').offset().top - 200));
    }
  })
</script>
{/literal}
