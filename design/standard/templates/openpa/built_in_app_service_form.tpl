{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'has_sidemenu', false() )}

<script>
  if (localStorage) localStorage.removeItem('defaultLocale'); //temp
</script>

{if and(ezhttp_hasvariable( 'edit', 'get' ), fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'config_built_in_apps' ) ))}
    <div class="container mb-5">
        <div class="row justify-content-center">
            <div class="col-12 col-lg-10">
                <div class="bg-light rounded p-4">
                    {if is_set($built_in_app_api_base_url)}
                        <pre style="white-space: break-spaces;">{*
                            *}{concat('<widget-formio service-id="', $service_id, '" base-url="', $built_in_app_api_base_url, '" formserver-url="', $formserver_url, '" pdnd-url="', $pdnd_url, '"></widget-formio>')|wash()}<br /><br />{*
                            *}{'<script src="'|wash()}{if is_set($built_in_app_src)}{$built_in_app_src}{else}{openpaini('StanzaDelCittadinoBridge', concat('BuiltInWidgetSource_', $built_in_app))}{/if}{'"/>'|wash()}{*
                            *}{if $built_in_app_style|ne('')}<br /><br />{'<link rel="stylesheet" type="text/css" href="'|wash()}{$built_in_app_style}{'" />'|wash()}{/if}
                        </pre>
                    {/if}
                    <form method="post">
                        <div class="form-group">
                            <label for="built_in_app_script">Se vuoi inserire uno script custom per <code>{$built_in_app}</code> inserisci qui il codice:</label>
                            <textarea rows="10" id="built_in_app_script" class="form-control"
                                      name="Config">{$built_in_app_script}</textarea>
                        </div>
                        <div class="text-right">
                            <input name="StoreConfig" type="submit" class="btn btn-success" value="Salva"/>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
{else}
    {if $service_id}
        {if and($built_in_app_is_enabled, is_set($built_in_app_script), $built_in_app_script|ne(''))}
            <div class="buitinapp mb-5">
                {$built_in_app_script}
            </div>
        {elseif and($built_in_app_is_enabled, is_set($built_in_app_api_base_url))}
            <div class="buitinapp mb-5">
                <widget-formio
                        service-id="{$service_id}"
                        base-url="{$built_in_app_api_base_url}"
                        formserver-url="{$formserver_url}"
                        pdnd-url="{$pdnd_url}">
                </widget-formio>
                <script defer src="{$built_in_app_src}"></script>
                {if $built_in_app_style|ne('')}<link rel="stylesheet" type="text/css" href="{$built_in_app_style}" />{/if}
            </div>
        {/if}
    {else}
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-12 col-lg-10">
                    <div class="cmp-heading pb-3 pb-lg-4">
                        <div class="alert alert-danger">
                            <p class="lead m-0">Servizio momentaneamente non disponibile</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    {/if}
{/if}