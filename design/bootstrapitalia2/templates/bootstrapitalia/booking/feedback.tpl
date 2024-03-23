<div class="container feedback-container" style="display:none">
    <div class="justify-content-center mb-50 row">
        <div class="col-12 col-lg-10">
            <div class="cmp-hero">
                <section class="it-hero-wrapper bg-white align-items-start">
                    <div class="it-hero-text-wrapper pt-0 ps-0 pb-40 pb-lg-60">
                        <div class="categoryicon-top d-flex">
                            {display_icon('it-mail', 'svg', 'icon mr-10 icon-lg')}
                            <h1 class="text-black hero-title py-2">{'Appointment confirmed'|i18n('bootstrapitalia/booking')}</h1></div>
                        <div class="hero-text">
                            <p class="pt-3 pt-lg-4">
                                {'The appointment is set for'|i18n('bootstrapitalia/booking')} <strong data-openinghourDay></strong>
                                {'from'|i18n('bootstrapitalia/booking')} <strong data-openinghourFrom></strong>
                                {'to'|i18n('bootstrapitalia/booking')} <strong data-openinghourTo></strong>
                                {'at'|i18n('bootstrapitalia/booking')} <strong data-placeTitle></strong> <strong data-placeAddress></strong>
                            </p>
                            <br>
                            <p>
                                {'We sent the summary to the email'|i18n('bootstrapitalia/booking')}:<br />
                                <strong data-applicantEmail></strong>
                            </p>
                        </div>
                    </div>
                </section>
            </div>
        </div>
    </div>
</div>