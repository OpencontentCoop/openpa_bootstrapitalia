{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'has_sidemenu', false() )}

{if and(ezhttp_hasvariable( 'edit', 'get' ), fetch( 'user', 'has_access_to', hash( 'module', 'bootstrapitalia', 'function', 'config_built_in_apps' ) ))}
    <div class="container mb-5">
        <div class="row justify-content-center">
            <div class="col-12 col-lg-10">
                <div class="bg-light rounded p-4">
                    <form method="post">
                        <div class="form-group">
                            <label for="built_in_app_script">Inserisci lo snippet per <code>{$built_in_app}</code></label>
                            <textarea rows="20" id="built_in_app_script" class="form-control"
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
{if $built_in_app_script}
    <div class="buitinapp">{$built_in_app_script}</div>
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