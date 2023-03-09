{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'has_sidemenu', false() )}

{if and(ezhttp_hasvariable( 'edit', 'get' ), fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'config_built_in_apps' ) ))}
    <div class="container mb-5">
        <div class="row justify-content-center">
            <div class="col-12 col-lg-10">
                <div class="bg-light rounded p-4">
                    {if is_set($built_in_app_variables)}
                        <pre>{*
                            *}{'<div id="root"></div>'|wash()}<br /><br />{*
                            *}{'<script>'|wash()}<br />{foreach $built_in_app_variables as $key => $value}window.{$key} = '{$value}';{delimiter}<br />{/delimiter}{/foreach}<br />{'</script>'|wash()}<br /><br />{*
                            *}{'<script src="'|wash()}{if is_set($built_in_app_src)}{$built_in_app_src}{else}{openpaini('StanzaDelCittadinoBridge', concat('BuiltInWidgetSource_', $built_in_app))}{/if}{'"/>'|wash()}
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
    {if is_set($built_in_app_src)}
        <div class="buitinapp">
            <div id="root"></div>
            <script>{foreach $built_in_app_variables as $key => $value}window.{$key} = '{$value}';{/foreach}</script>
            <script src="{$built_in_app_src}"></script>
        </div>
    {elseif is_set($built_in_app_script)}
        {if $built_in_app_script}
            <div class="buitinapp">
                {$built_in_app_script}
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
{/if}