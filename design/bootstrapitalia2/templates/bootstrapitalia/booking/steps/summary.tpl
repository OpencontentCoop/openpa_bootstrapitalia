<div id="step-{$step.id|wash()}" class="step container"{if $hide} style="display:none"{/if}>
    <div class="row justify-content-center">
        <div class="col-12 col-lg-8">

            <div class="mb-5 warning callout callout-highlight" style="background-image:none">
                <div class="callout-title">
                    {display_icon('it-help-circle', 'svg', 'icon')}
                    <span>Attenzione</span>
                </div>
                <p class="titillium text-paragraph">Le informazioni che hai fornito hanno valore di dichiarazione.
                    <span class="d-lg-block"> Verifica che siano corrette.</span>
                </p>
            </div>
            <div class="mt-2">
                <h2 class="visually-hidden">Dettagli dell'appuntamento</h2>
                <div class="cmp-card mb-4">
                    <div class="card has-bkg-grey shadow-sm mb-0">
                        <div class="card-header border-0 p-0 mb-lg-30">
                            <div class="d-flex">
                                <h3 class="subtitle-large mb-0">Riepilogo</h3>
                            </div>
                        </div>
                        <div class="card-body p-0">
                            <div class="cmp-info-summary bg-white mb-3 mb-lg-4 p-3 p-lg-4">
                                <div class="card">
                                    <div class="card-header border-bottom border-light p-0 mb-0 d-flex justify-content-between d-flex justify-content-end">
                                        <h4 class="title-large-semi-bold mb-3">Ufficio</h4>
                                        <a href="#" class="text-decoration-none"><span
                                                    class="text-button-sm-semi t-primary"
                                                    data-goto="place">Modifica</span></a>
                                    </div>
                                    <div class="card-body p-0">
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">Tipologia ufficio</div>
                                            <div class="border-light">
                                                <p class="data-text" data-officeTitle></p>
                                            </div>
                                        </div>
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">Sede</div>
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
                                        <h4 class="title-large-semi-bold mb-3">Data e orario</h4>
                                        <a href="#" class="text-decoration-none" data-goto="datetime"><span
                                                    class="text-button-sm-semi t-primary">Modifica</span></a>
                                    </div>
                                    <div class="card-body p-0">
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">Data</div>
                                            <div class="border-light">
                                                <p class="data-text" data-openinghourDay></p>
                                            </div>
                                        </div>
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">Ora</div>
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
                                        <h4 class="title-large-semi-bold mb-3">Dettagli appuntamento</h4>
                                        <a href="#" class="text-decoration-none" data-goto="details"><span
                                                    class="text-button-sm-semi t-primary">Modifica</span></a>
                                    </div>
                                    <div class="card-body p-0">
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">Motivo</div>
                                            <div class="border-light">
                                                <p class="data-text" data-subjectText></p>
                                            </div>
                                        </div>
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">Dettagli</div>
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
                                        <h4 class="title-large-semi-bold mb-3">Richiedente</h4>
                                        <a href="#" class="text-decoration-none" data-goto="applicant"><span
                                                    class="text-button-sm-semi t-primary">Modifica</span></a>
                                    </div>
                                    <div class="card-body p-0">
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">Nome</div>
                                            <div class="border-light">
                                                <p class="data-text" data-applicantName></p>
                                            </div>
                                        </div>
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">Cognome</div>
                                            <div class="border-light">
                                                <p class="data-text" data-applicantSurname></p>
                                            </div>
                                        </div>
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">Codice fiscale</div>
                                            <div class="border-light">
                                                <p class="data-text" data-applicantFiscalCode></p>
                                            </div>
                                        </div>
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">Email</div>
                                            <div class="border-light">
                                                <p class="data-text" data-applicantEmail></p>
                                            </div>
                                        </div>
                                        <div class="single-line-info border-light">
                                            <div class="text-paragraph-small">Recapito telefonico</div>
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
                        <span class="text-button-sm t-primary">Indietro</span>
                    </button>
                    <button type="button"
                            class="btn btn-outline-primary bg-white btn-sm d-none d-lg-block save">
                        <span class="text-button-sm t-primary">Salva Richiesta</span>
                    </button>
                    <button type="button"
                            class="btn btn-outline-primary bg-white btn-sm d-block d-lg-none save center">
                        <span class="text-button-sm t-primary">Salva</span>
                    </button>
                    <button type="button" class="btn btn-primary btn-sm send">
                        <span class="text-button-sm">Invia</span>
                        <span class="text-button-sm load-button" style="display:none"><i class="fa fa-circle-o-notch fa-spin fa-fw"></i></span>
                    </button>
                </nav>
                <div id="store-message" class="alert alert-success cmp-disclaimer rounded p-3 d-inline-block float-end d-none" role="alert" style="display:none">
                    <span class="d-inline-block text-uppercase cmp-disclaimer__message">Richiesta salvata con successo</span>
                </div>
                <div id="store-error" class="alert alert-danger cmp-disclaimer rounded d-inline-block float-end d-none" role="alert">
                    <span class="d-inline-block text-uppercase cmp-disclaimer__message">Errore salvando la richiesta</span>
                </div>
            </div>
        </div>
    </div>
</div>