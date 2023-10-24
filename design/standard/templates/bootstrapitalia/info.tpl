{ezpagedata_set( 'has_container', true() )}
{def $pagedata = openpapagedata()}

<div class="container mb-3">
    <h2 class="mb-4">Gestioni contatti e informazioni generali</h2>

    {if is_set($message)}
        <div class="message-error">
            <p>{$message}</p>
        </div>
    {/if}

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
                    {if $pagedata.header.logo.url}
                        <img alt="{ezini('SiteSettings','SiteName')}"
                             width="82"
                             height="82"
                             class="bg-primary"
                             src="{$pagedata.header.logo.url|ezroot(no)}" />
                    {/if}
                </label>
                <div class="col-sm-9">
                    <input type="file" name="Logo" class="form-control" id="Logo" value="">
                </div>
            </div>
        </div>

        <div class="border border-light rounded p-3 mb-3">
            <h5>Favicon</h5>
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
                             src="{$_favicon|ezimage(no)|shared_asset()}" />
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
                {attribute_edit_gui attribute=$homepage.data_map.link_nell_header attribute_base=ContentObjectAttribute}
            </div>
        </div>

        <div class="border border-light rounded p-3 mb-3">
            <h5>Link footer</h5>
            <div class="row mb-3 ezcca-edit-datatype-ezobjectrelationlist">
                {attribute_edit_gui attribute=$homepage.data_map.link_nel_footer attribute_base=ContentObjectAttribute}
            </div>
        </div>

        <div class="row">
            <div class="col-12 text-right mt-3">
                <input type="submit" class="btn btn-success" name="Store" value="Salva"/>
            </div>
        </div>

    </form>

    {if $has_access_to_hot_zone}

        <div class="border border-light bg-danger rounded p-3 my-5">
            <h5 class="text-white mb-4">Impostazioni avanzate</h5>
            <div class="row">
                <form method="post" action="{'bootstrapitalia/info'|ezurl(no)}" class="form">
                <div class="form-group">
                    <label for="ImportFrom" class="text-white p-0">Importa contatti e informazioni generali da un'altra istanza OpenCity</label>
                    <div class="input-group">
                        <input type="text" class="form-control" id="ImportFrom" name="ImportFrom"
                               placeholder="https://www.comune.bugliano.pi.it" />
                        <div class="input-group-append">
                            <button class="btn btn-primary" type="submit">Importa</button>
                        </div>
                    </div>
                    <small class="form-text text-white">
                        Inserisci l'indirizzo di un'altra istanza OpenCity da cui importare le informazioni. Ad esempio: https://www.comune.bugliano.pi.it
                    </small>
                </div>
                </form>
            </div>

            {*if $bridge_connection}
            <div class="row">
                <form method="post" action="{'bootstrapitalia/info'|ezurl(no)}" class="form">
                <div class="form-group">
                    <label for="UpdateBridgeTargetUser" class="text-white p-0">Aggiorna contatti e informazioni generali nell'area personale collegata {$bridge_connection|wash()}</label>
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
            <div class="row">
                <form method="post" action="{'bootstrapitalia/info'|ezurl(no)}" class="form">
                <div class="form-group">
                    <label for="SelectPartner" class="text-white p-0">Imposta partner/distributore</label>
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
                    <small class="form-text text-white">
                        Il nome e l'url compaiono nel footer della pagina
                    </small>
                </div>
                </form>
            </div>
            {/if}

        </div>
    {/if}

    <script>{literal}
        $(document).ready(function (){
          $('.ezobject-relation-remove-button').on('click', function(e){
            e.preventDefault();
            $(this).parents('table').find('input[type="checkbox"]:checked').each(function (){
                $(this).parents('tr').remove();
            });
          })
        })
    {/literal}</script>