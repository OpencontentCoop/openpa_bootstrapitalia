<div id="step-{$step.id|wash()}" class="step container"{if $hide} style="display:none"{/if}>
    <div class="row justify-content-center">
        <div class="col-12 col-lg-8">

            <div class="mb-5 warning callout callout-highlight" style="background-image:none">
                <div class="callout-title">
                    {display_icon('it-help-circle', 'svg', 'icon')}
                    <span>{'Warning'|i18n('bootstrapitalia/booking')}</span>
                </div>
                <p class="titillium text-paragraph">{'The information you have provided has the value of a declaration'|i18n('bootstrapitalia/booking')}.
                    <span class="d-lg-block"> {'Check that they are correct'|i18n('bootstrapitalia/booking')}.</span>
                </p>
            </div>
            <div class="mt-2">
                <h2 class="visually-hidden">{'Appointment details'|i18n('bootstrapitalia/booking')}</h2>
                <div class="cmp-card mb-4">
                    <div class="card has-bkg-grey shadow-sm mb-0">
                        <div class="card-header border-0 p-0 mb-lg-30">
                            <div class="d-flex">
                                <h3 class="subtitle-large mb-0">{'Summary'|i18n('bootstrapitalia/booking')}</h3>
                            </div>
                            {if $service}
                                <div class="lead my-2" data-motivation_outcome>
                                    <p>{'You can find all the necessary documents with the related instructions for use and information on the procedure to follow to use the %service service on the %open_service_link dedicated page %close_service_link'|i18n(
                                        'bootstrapitalia/booking',, hash(
                                            '%service', concat('<em>', $service.name|wash(), '</em>'),
                                            '%open_service_link', concat('<a target="_blank" href="', $service.main_node.url_alias|ezurl(no,full), '">'),
                                            '%close_service_link', '</a>'
                                        )
                                    )}</p>
                                </div>
                            {/if}
                        </div>
                        <div class="card-body p-0">
                            <div class="cmp-info-summary bg-white mb-3 mb-lg-4 p-3 p-lg-4">
                                <div class="card">
                                    <div class="card-header border-bottom border-light p-0 mb-0 d-flex justify-content-between d-flex justify-content-end">
                                        <h4 class="title-large-semi-bold mb-3">{'Office'|i18n('bootstrapitalia/booking')}</h4>
                                        <a href="#" class="text-decoration-none"><span
                                                    class="text-button-sm-semi t-primary"
                                                    data-goto="place">{'Edit'|i18n('bootstrapitalia/booking')}</span></a>
                                    </div>
                                    <div class="card-body p-0">
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">{'Typology'|i18n('bootstrapitalia/booking')}</div>
                                            <div class="border-light">
                                                <p class="data-text" data-officeTitle></p>
                                            </div>
                                        </div>
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">{'Location'|i18n('bootstrapitalia/booking')}</div>
                                            <div class="border-light">
                                                <p class="data-text" data-placeTitle></p>
                                                <p class="data-text" data-placeAddress></p>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="card-footer p-0">
                                    </div>
                                </div>
                            </div>
                            <div class="cmp-info-summary bg-white mb-3 mb-lg-4 p-3 p-lg-4">
                                <div class="card">
                                    <div class="card-header border-bottom border-light p-0 mb-0 d-flex justify-content-between d-flex justify-content-end">
                                        <h4 class="title-large-semi-bold mb-3">{'Date and time'|i18n('bootstrapitalia/booking')}</h4>
                                        <a href="#" class="text-decoration-none" data-goto="datetime"><span
                                                    class="text-button-sm-semi t-primary">{'Edit'|i18n('bootstrapitalia/booking')}</span></a>
                                    </div>
                                    <div class="card-body p-0">
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">{'Date'|i18n('bootstrapitalia/booking')}</div>
                                            <div class="border-light">
                                                <p class="data-text" data-openinghourDay></p>
                                            </div>
                                        </div>
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">{'Time'|i18n('bootstrapitalia/booking')}</div>
                                            <div class="border-light">
                                                <p class="data-text" data-openinghourHour></p>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="card-footer p-0">
                                    </div>
                                </div>
                            </div>
                            <div class="cmp-info-summary bg-white mb-3 mb-lg-4 p-3 p-lg-4">
                                <div class="card">
                                    <div class="card-header border-bottom border-light p-0 mb-0 d-flex justify-content-between d-flex justify-content-end">
                                        <h4 class="title-large-semi-bold mb-3">{'Appointment details'|i18n('bootstrapitalia/booking')}</h4>
                                        <a href="#" class="text-decoration-none" data-goto="details"><span
                                                    class="text-button-sm-semi t-primary">{'Edit'|i18n('bootstrapitalia/booking')}</span></a>
                                    </div>
                                    <div class="card-body p-0">
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">{'Reason'|i18n('bootstrapitalia/booking')}</div>
                                            <div class="border-light">
                                                <p class="data-text" data-subjectText></p>
                                            </div>
                                        </div>
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">{'Detail'|i18n('bootstrapitalia/booking')}</div>
                                            <div class="border-light">
                                                <p class="data-text" data-detailsText></p>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="card-footer p-0">
                                    </div>
                                </div>
                            </div>
                            <div class="cmp-info-summary bg-white p-3 p-lg-4 mb-0">
                                <div class="card">
                                    <div class="card-header border-bottom border-light p-0 mb-0 d-flex justify-content-between d-flex justify-content-end">
                                        <h4 class="title-large-semi-bold mb-3">{'Applicant'|i18n('bootstrapitalia/booking')}</h4>
                                        <a href="#" class="text-decoration-none" data-goto="applicant"><span
                                                    class="text-button-sm-semi t-primary">{'Edit'|i18n('bootstrapitalia/booking')}</span></a>
                                    </div>
                                    <div class="card-body p-0">
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">{'Name'|i18n('bootstrapitalia/booking')}</div>
                                            <div class="border-light">
                                                <p class="data-text" data-applicantName></p>
                                            </div>
                                        </div>
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">{'Surname'|i18n('bootstrapitalia/booking')}</div>
                                            <div class="border-light">
                                                <p class="data-text" data-applicantSurname></p>
                                            </div>
                                        </div>
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">{'Fiscal code'|i18n('bootstrapitalia/booking')}</div>
                                            <div class="border-light">
                                                <p class="data-text" data-applicantFiscalCode></p>
                                            </div>
                                        </div>
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">{'Email'|i18n('bootstrapitalia/booking')}</div>
                                            <div class="border-light">
                                                <p class="data-text" data-applicantEmail></p>
                                            </div>
                                        </div>
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">{'Telephone number'|i18n('bootstrapitalia/booking')}</div>
                                            <div class="border-light">
                                                <p class="data-text" data-applicantPhone></p>
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
            </div>

            <div class="cmp-nav-steps">
                <nav class="steppers-nav pb-3" aria-label="Step">
                    <button type="button" class="btn btn-sm steppers-btn-prev p-0">
                        {display_icon('it-chevron-left', 'svg', 'icon icon-primary icon-sm')}
                        <span class="text-button-sm t-primary">{'Back'|i18n('bootstrapitalia/booking')}</span>
                    </button>
                    <button type="button"
                            class="btn btn-outline-primary bg-white btn-sm d-none d-lg-block save">
                        <span class="text-button-sm t-primary">{'Save request'|i18n('bootstrapitalia/booking')}</span>
                    </button>
                    <button type="button"
                            class="btn btn-outline-primary bg-white btn-sm d-block d-lg-none save center">
                        <span class="text-button-sm t-primary">{'Save request'|i18n('bootstrapitalia/booking')}</span>
                    </button>
                    <button type="button" class="btn btn-primary btn-sm send">
                        <span class="text-button-sm">{'Submit'|i18n('bootstrapitalia/booking')}</span>
                        <span class="text-button-sm load-button" style="display:none"><i class="fa fa-circle-o-notch fa-spin fa-fw"></i></span>
                    </button>
                </nav>
                <div id="store-message" class="alert alert-success cmp-disclaimer rounded p-3 d-inline-block float-end d-none" role="alert" style="display:none">
                    <span class="d-inline-block text-uppercase cmp-disclaimer__message">{'Request saved successfully'|i18n('bootstrapitalia/booking')}</span>
                </div>
                <div id="store-error" class="alert alert-danger cmp-disclaimer rounded d-inline-block float-end d-none" role="alert">
                    <span class="d-inline-block text-uppercase cmp-disclaimer__message">{'Error saving the request'|i18n('bootstrapitalia/booking')}</span>
                </div>
            </div>
        </div>
    </div>
</div>