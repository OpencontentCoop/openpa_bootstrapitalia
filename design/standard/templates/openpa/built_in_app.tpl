{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'has_sidemenu', false() )}

<script>
  if (localStorage) localStorage.removeItem('defaultLocale'); //temp
</script>
{def $infobox = fetch(content, object, hash(remote_id, concat('info_', $built_in_app)))}
{if and(ezhttp_hasvariable( 'edit', 'get' ), fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'config_built_in_apps' ) ))}
    <div class="container mb-5">
        <div class="row justify-content-center">
            <div class="col-12 col-lg-10">
                <div class="bg-light rounded p-4">
                    {if is_set($built_in_app_api_base_url)}
                        <pre style="white-space: break-spaces;">{*
                            *}{concat('<div id="',$built_in_app_root_id,'"></div>')|wash()}<br /><br />{*
                            *}{'<script src="'|wash()}{if is_set($built_in_app_src)}{$built_in_app_src}{else}{openpaini('StanzaDelCittadinoBridge', concat('BuiltInWidgetSource_', $built_in_app))}{/if}{'"></script>'|wash()}{*
                            *}{if $built_in_app_style|ne('')}<br /><br />{'<link rel="stylesheet" type="text/css" href="'|wash()}{$built_in_app_style}{'" />'|wash()}{/if}
                        </pre>
                    {/if}
                    <form method="post">
                        <div class="form-group">
                            <label for="built_in_app_script" class="p-0">Se vuoi inserire uno script custom per <code>{$built_in_app}</code> inserisci qui il codice:</label>
                            <p class="form-text">Attenzione: per garantire la compatibilità di tutti i browser devi esplicitare il tag di chiusura per l'inclusione del javascript:<br>
                                ad esempio <code>{'<script src="https://example.com/script.js"></script>'|wash()}</code> e non <del><code>{'<script src="https://example.com/script.js"/>'|wash()}</code></del></p>
                            <textarea rows="10" id="built_in_app_script" class="form-control"
                                      name="Config">{$built_in_app_script}</textarea>
                        </div>
                        <div class="text-right">
                            <input name="StoreConfig" type="submit" class="btn btn-success" value="Salva"/>
                        </div>
                    </form>

                    {if $infobox}<p class="form-text"><b>Nota</b>: alert configurato nel contenuto ({$infobox.content_class.name|wash()}) <a href="{$infobox.main_node.url_alias|ezurl(no)}">{$infobox.name|wash()}</a></p>{/if}
                </div>
            </div>
        </div>
    </div>
{else}
    {if $infobox}
        <div class="modal fade" tabindex="-1" role="dialog" id="infoModal" aria-labelledby="infoModalTitle">
            <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h2 class="modal-title h5" id="infoModalTitle">{attribute_view_gui attribute=$infobox.data_map.name}</h2>
                        <button class="btn-close" type="button" data-bs-dismiss="modal" aria-label="Chiudi finestra modale">
                            {display_icon('it-close', 'svg', 'icon')}
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="lead">{attribute_view_gui attribute=$infobox.data_map.description}</div>
                    </div>
                    <div class="modal-footer">
                        <button class="btn btn-primary btn-sm" data-bs-dismiss="modal" type="button">{$infobox.data_map.location.data_text|wash()}</button>
                    </div>
                </div>
            </div>
        </div>
        <script>
          $(document).ready(function(){ldelim}
            var infoModal = new bootstrap.Modal(document.getElementById('infoModal'));
            infoModal.show()
          {rdelim})
        </script>
    {/if}

    {if and($built_in_app_is_enabled, is_set($built_in_app_script), $built_in_app_script|ne(''))}
        <div class="buitinapp mb-5">
            {$built_in_app_script}
        </div>
    {elseif and($built_in_app_is_enabled, is_set($built_in_app_api_base_url))}
        <div class="buitinapp mb-5">
            <div id="{$built_in_app_root_id}"></div>
            {if $page_name}
                <script>window.OC_PAGE_NAME = "{$page_name|wash(javascript)}";</script>
            {/if}
            <script src="{$built_in_app_src}"></script>
            {debug-log var=$built_in_app_src msg='Builtin JS'}
            {if $built_in_app_style|ne('')}<link rel="stylesheet" type="text/css" href="{$built_in_app_style}" />{/if}
            {debug-log var=$built_in_app_style msg='Builtin CSS'}
        </div>
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

{if and($built_in_app_is_enabled, is_set($built_in_app_satisfy_entrypoint))}
    {include uri='design:footer/valuation.tpl' satisfy_entrypoint=$built_in_app_satisfy_entrypoint}
{/if}