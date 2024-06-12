<div class="container">
    <div class="row justify-content-center">
        <div class="col-12 col-lg-10">
            <div class="cmp-hero">
                <section class="it-hero-wrapper bg-white align-items-start">
                    <div class="it-hero-text-wrapper pt-0 ps-0 pb-3 pb-lg-4">
                        <h1 class="text-black" data-element="page-name">{'Appointment booking'|i18n('bootstrapitalia/booking')}</h1>
                        <p class="subtitle-small text-black">
                            {'The fields characterized by the asterisk symbol are mandatory'|i18n('bootstrapitalia/booking')}
                        </p>
                        <p class="subtitle-small text-black my-3 d-none" id="spid-access">
                            {'Do you have a spid or cie digital identity?'|i18n('bootstrapitalia/booking')}
                            <a class="title-small-semi-bold text-decoration-none"
                               href="{$pal|user_api_base_url()}/login?return-url={concat('prenota_appuntamento?service_id=',$service_id)|ezurl(no,full)}">
                                {'Log in'|i18n('bootstrapitalia/booking')}
                            </a>
                        </p>
                    </div>
                </section>
            </div>
        </div>
    </div>
</div>