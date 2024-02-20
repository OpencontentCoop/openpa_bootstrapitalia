<div id="step-{$step.id|wash()}" class="step container"{if $hide} style="display:none"{/if}>
    <div class="row justify-content-center">
        <div class="col-12 col-lg-8 pb-40 pb-lg-80"><p class="text-paragraph mb-lg-4">
                Il {ezini( 'SiteSettings', 'SiteName' )|wash()} gestisce
                i dati personali forniti e liberamente comunicati sulla
                base dell’articolo 13 del Regolamento UE 2016/679 General data protection regulation
                (Gdpr) e dell'articolo 13 e successive modifiche e integrazioni del decreto legislativo
                (di seguito d.lgs) 267/2000 (Testo unico enti locali).
            </p>
            <p class="text-paragraph mb-0">
                Per i dettagli sul trattamento dei dati personali consulta l'<a class="t-primary"
                        href="{$built_in_app_variables.OC_PRIVACY_URL}"
                        target="_blank">informativa sulla privacy.</a></p>
            <div class="form-check mt-4 mb-3 mt-md-40 mb-lg-40">
                <div class="checkbox-body d-flex align-items-center">
                    <input aria-label="Ho letto e compreso l’informativa sulla privacy" type="checkbox"
                           aria-describedby="privacyDescription" class="form-control" id="privacyCheck" value="true">
                    <label for="privacyCheck" id="privacyDescription"
                           class="title-small-semi-bold pt-1 active form-label">
                        Ho letto e compreso l’informativa sulla privacy
                    </label>
                </div>
            </div>
            <button type="submit" class="mobile-full btn btn-primary disabled" disabled>
                <span class="text-button-sm">Avanti</span>
                {display_icon('it-chevron-right', 'svg', 'icon icon-white icon-sm')}
            </button>
        </div>
    </div>
</div>