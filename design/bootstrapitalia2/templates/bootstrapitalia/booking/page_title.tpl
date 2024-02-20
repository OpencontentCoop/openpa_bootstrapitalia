<div class="container">
    <div class="row justify-content-center">
        <div class="col-12 col-lg-10">
            <div class="cmp-hero">
                <section class="it-hero-wrapper bg-white align-items-start">
                    <div class="it-hero-text-wrapper pt-0 ps-0 pb-3 pb-lg-4">
                        <h1 class="text-black" data-element="page-name">Prenotazione appuntamento</h1>
                        <p class="subtitle-small text-black">
                            I campi contraddistinti dal simbolo asterisco sono obbligatori.</p>
                        <p class="subtitle-small text-black my-3 d-none" id="spid-access">Hai un’identità digitale SPID o CIE?
                            <a class="title-small-semi-bold t-primary text-decoration-none" href="{$link_area_personale|user_api_base_url()}/login?return-url={concat('prenota_appuntamento?service_id=',$service_id)|ezurl(no,full)}">
                                Accedi
                            </a>
                        </p>
                    </div>
                </section>
            </div>
        </div>
    </div>
</div>