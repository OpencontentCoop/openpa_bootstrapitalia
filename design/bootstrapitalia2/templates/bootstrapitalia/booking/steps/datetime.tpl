<div id="step-{$step.id|wash()}" class="step container"{if $hide} style="display:none"{/if}>
    <div class="row">
        {include uri='design:bootstrapitalia/booking/sidebar.tpl' step=$step}
        <div class="col-12 col-lg-8 offset-lg-1">
            <div class="steppers-content" aria-live="polite">
                <div class="it-page-sections-container">
                    <section class="it-page-section" id="appointment-available">
                        <div class="cmp-card mb-40">
                            <div class="card has-bkg-grey shadow-sm p-big">
                                <div class="card-header border-0 p-0 mb-lg-30">
                                    <div class="d-flex">
                                        <h2 class="title-xxlarge mb-2">{'Appointments available'|i18n('bootstrapitalia/booking')}*</h2>
                                    </div>
                                </div>
                                <div id="appointment-calendars" class="card-body row mb-4 px-3 py-0"></div>
                                <div class="card-body p-0 position-relative appointment-select">
                                    <div class="select-wrapper p-0 mt-1 select-partials">
                                        <label for="appointment-month" class="visually-hidden">{'Select a month'|i18n('bootstrapitalia/booking')}</label>
                                        <select id="appointment-month" class="" data-focus-mouse="false">
                                            {foreach $months as $index => $month}
                                                <option {if $index|gt(1)}style="display:none"{/if} value="{$month.index|wash()}">{$month.name|wash()}</option>
                                            {/foreach}
                                        </select>
                                    </div>
                                    <div class="select-wrapper p-0 mt-1 select-partials">
                                        <label for="appointment-day" class="visually-hidden">{'Select a day'|i18n('bootstrapitalia/booking')}</label>
                                        <select id="appointment-day" class="" data-focus-mouse="false">
                                            <option selected="selected" value="">{'Select a day'|i18n('bootstrapitalia/booking')}</option>
                                        </select>
                                    </div>
                                    <div class="select-wrapper p-0 mt-1 select-partials">
                                        <label for="appointment-hours" class="visually-hidden">{'Select a time'|i18n('bootstrapitalia/booking')}</label>
                                        <select id="appointment-hours" class="" data-focus-mouse="false">
                                            <option selected="selected" value="">{'Select a time'|i18n('bootstrapitalia/booking')}</option>
                                        </select>
                                    </div>
                                    <div class="no-availabilities p-4 text-center" style="display:none">
                                        <p>{'There are no dates available for the selected period'|i18n('bootstrapitalia/booking')}</p>
                                        <a href="#" class="btn btn-primary">{'Select another location or another period'|i18n('bootstrapitalia/booking')}</a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </section>

                    <section class="it-page-section" id="office">
                        <div class="cmp-card">
                            <div class="card has-bkg-grey shadow-sm p-big">
                                <div class="card-header border-0 p-0 mb-lg-30">
                                    <div class="d-flex">
                                        <h2 class="title-xxlarge mb-0">{'Office'|i18n('bootstrapitalia/booking')}</h2>
                                    </div>
                                </div>
                                <div class="card-body p-0">
                                    <div class="cmp-info-summary bg-white mb-4 mb-lg-30 p-4">
                                        <div class="card">
                                            <div class="card-header border-bottom border-light p-0 mb-0 d-flex justify-content-between d-flex justify-content-end">
                                                <h4 class="title-large-semi-bold mb-3" data-placeTitle></h4>
                                            </div>
                                            <div class="card-body p-0">
                                                <div class="single-line-info border-light">
                                                    <div class="text-paragraph-small">{'Address'|i18n('bootstrapitalia/booking')}</div>
                                                    <div class="border-light">
                                                        <p class="data-text" data-placeAddress></p>
                                                    </div>
                                                </div>
                                                <div class="single-line-info border-light">
                                                    <div class="text-paragraph-small">{'Location'|i18n('bootstrapitalia/booking')}</div>
                                                    <div class="border-light">
                                                        <p class="data-text" data-placeTitle></p>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="card-footer p-0">
                                            </div>
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
