<div id="step-{$step.id|wash()}" class="step container"{if $hide} style="display:none"{/if}>
    <div class="row">
        {include uri='design:bootstrapitalia/booking/sidebar.tpl' step=$step}
        <div class="col-12 col-lg-8 offset-lg-1">
            <div class="steppers-content" aria-live="polite">
                <div class="it-page-sections-container">
                    <section class="it-page-section" id="reason">
                        <div class="cmp-card mb-40">
                            <div class="card has-bkg-grey shadow-sm p-big">
                                <div class="card-header border-0 p-0 mb-lg-30 mb-3">
                                    <div class="d-flex">
                                        <h2 class="title-xxlarge mb-0">
                                            {'Reason'|i18n('bootstrapitalia/booking')}*
                                        </h2>
                                    </div>
                                    <p class="subtitle-small mb-0">
                                        {'Choose reason for appointment'|i18n('bootstrapitalia/booking')}
                                    </p>
                                </div>
                                <div class="card-body p-0">
                                    <div class="select-wrapper p-0 select-partials">
                                        <label for="motivo-appuntamento" class="visually-hidden">{'Reason for the appointment'|i18n('bootstrapitalia/booking')}</label>
                                        {if $service}
                                            <span class="p-1 d-block border-bottom">{$service.name|wash()}</span>
                                            <input type="hidden" id="motivo-appuntamento" name="subject-precompiled" value="{$service.name|wash()}">
                                        {else}
                                            <input type="text" id="motivo-appuntamento" name="subject" data-focus-mouse="false" value="">
                                        {/if}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </section>
                    <section class="it-page-section" id="details">
                        <div class="cmp-card">
                            <div class="card has-bkg-grey shadow-sm p-big">
                                <div class="card-header border-0 p-0 mb-lg-30 m-0">
                                    <div class="d-flex">
                                        <h2 class="title-xxlarge mb-0">{'Detail'|i18n('bootstrapitalia/booking')}*</h2>
                                    </div>
                                    <p class="subtitle-small mb-0 mb-3">{'Add more details'|i18n('bootstrapitalia/booking')}</p>
                                </div>
                                <div class="card-body p-0">
                                    <div class="cmp-text-area p-0">
                                        <div class="form-group">
                                            <label for="form-details" class="visually-hidden">
                                                {'Add more details'|i18n('bootstrapitalia/booking')}
                                            </label>
                                            <textarea name="detail" class="text-area form-control" id="form-details" rows="2"></textarea>
                                            <span style="position: absolute;right: 0;bottom: 0;" class="cmp-input__text"><span class="detail-length">200</span>/200</span>
                                            <span class="form-text cmp-input__text">{'Enter up to 200 characters'|i18n('bootstrapitalia/booking')}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </section>
                </div>
                {include uri='design:bootstrapitalia/booking/buttons.tpl' step=$step}
            </div>
        </div>
    </div>
</div>