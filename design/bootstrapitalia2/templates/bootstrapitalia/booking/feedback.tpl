<div class="container feedback-container" style="display:none">
    <div class="justify-content-center mb-50 row">
        <div class="col-12 col-lg-10">
            <div class="cmp-hero">
                <section class="it-hero-wrapper bg-white align-items-start">
                    <div class="it-hero-text-wrapper pt-0 ps-0 pb-40 pb-lg-60">
                        <div class="categoryicon-top d-flex">
                            {display_icon('it-mail', 'svg', 'icon mr-10 icon-lg')}
                            <h1 class="text-black hero-title py-2 meeting-is-confirmed">{'Appointment confirmed'|i18n('bootstrapitalia/booking')}</h1>
                            <h1 class="text-black hero-title py-2 meeting-is-pending" style="display:none">{'Appointment required'|i18n('bootstrapitalia/booking')}</h1>
                        </div>
                        <div class="hero-text">
                            <p class="lead meeting-is-pending" style="display:none">{'You will receive a message if the date and time you requested is confirmed'|i18n('bootstrapitalia/booking')}</p>
                            <p class="pt-3 pt-lg-4 mb-3">
                                {'The appointment is set for'|i18n('bootstrapitalia/booking')} <strong data-openinghourDay></strong>
                                {'at'|i18n('bootstrapitalia/booking/hours')} <strong data-openinghourFrom></strong>
                                {'at'|i18n('bootstrapitalia/booking')} <strong data-placeTitle></strong> <strong data-placeAddress></strong> <strong data-placeDetail></strong>
                            </p>
                            <p id="meetingNumber" class="mb-3" style="display:none">{'Meeting number'|i18n('bootstrapitalia/booking')}: <strong></strong></p>
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