{ezpagedata_set('show_path', false())}
<div class="row">
    <div class="col-md-12">
        <h1 class="h3">Valutazioni degli utenti</h1>

        <p class="lead">I feedback degli utenti sono raccolti tramite <em>Satisfy</em><br/>Per la configurazione del widget e la
            visualizzazione delle statistiche di valutazione consultare <a href="https://link.opencontent.it/satisfy">la
                dashboard dedicata</a></p>

        <form method="post" action="{'valuation/dashboard/satisfy'|ezurl(no)}" class="form">
            <fieldset>
                <div class="form-group block mb-3">
                    <label class="font-weight-bold" for="satisfyEntrypoint">Inserisci l'ID dell'entrypoint
                        Satisfy</label>
                    <input id="satisfyEntrypoint" class="form-control border box" type="text" name="SatisfyEntrypoint"
                           value="{$entrypoint_id|wash()}">
                </div>

                <p class="text-right">
                    <input type="submit" class="defaultbutton btn btn-primary btn-lg" name="Store" value="Salva"/>
                </p>
            </fieldset>
        </form>

        {if $entrypoint_id}
            <p class="lead">Anteprima di visualizzazione del widget di valutazione</p>
            {include uri='design:footer/valuation.tpl'}
        {/if}

    </div>
</div>