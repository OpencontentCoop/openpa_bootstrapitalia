<div class="container error-container" style="display:none">
    <div class="justify-content-center mb-50 row">
        <div class="col-12 col-lg-10">
            <div class="cmp-hero">
                <section class="it-hero-wrapper bg-white align-items-start">
                    <div class="it-hero-text-wrapper pt-0 ps-0 pb-40 pb-lg-60">
                        <div class="categoryicon-top d-flex">
                            {display_icon('it-error', 'svg', 'icon mr-10 icon-lg')}
                            <h1 class="text-black hero-title py-2">Errore</h1></div>
                        <div class="hero-text">
                            <p class="pt-3 pt-lg-4">
                                È stato rilevato un errore nella ricerca delle disponibilità del calendario o nell'elaborazione della richiesta.
                            </p>
                            <br>
                            <p>
                                Ci scusiamo per l'inconveniente e vi invitiamo a riprovare più tardi.
                                <br />
                                <br />
                                {if $service}
                                    <a class="btn btn-outline-primary btn-xs me-3" href="{concat('prenota_appuntamento?service_id=', $service.id)|ezurl(no)}"><strong>Riprova</strong></a>
                                    <a class="btn btn-outline-primary btn-xs" href="{$service.main_node.url_alias|ezurl(no)}"><strong>Torna alla scheda del servizio</strong></a>
                                {else}
                                    <a class="btn btn-outline-primary btn-xs me-3" href="{'prenota_appuntamento'|ezurl(no)}"><strong>Riprova</strong></a>
                                    <a class="btn btn-outline-primary btn-xs" href="{'/'|ezurl(no)}"><strong>Torna alla home</strong></a>
                                {/if}
                            </p>
                        </div>
                    </div>
                </section>
            </div>
        </div>
    </div>
</div>