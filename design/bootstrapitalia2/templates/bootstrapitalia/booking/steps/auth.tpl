<div id="step-{$step.id|wash()}" class="step container"{if $hide} style="display:none"{/if}>
    <div class="row justify-content-center">
        <div class="col-12 col-lg-8 pb-40 pb-lg-80"><p class="text-paragraph mb-lg-4">
                {'The %site_name manages the personal data provided and freely communicated on the based on article 13 of EU Regulation 2016/679 General data protection regulation (Gdpr) and article 13 and subsequent amendments and additions to the legislative decree (hereinafter legislative decree) 267/2000 (Consolidated text of local authorities).'|i18n('bootstrapitalia/booking',,hash('%site_name', ezini( 'SiteSettings', 'SiteName')|wash()))}
            </p>
            <p class="text-paragraph mb-0">
                {'For details on the processing of personal data consult the %open_privacy_link_tag Privacy Policy %close_privacy_link_tag'|i18n('bootstrapitalia/booking',, hash(
                '%open_privacy_link_tag', concat('<a class="t-primary" href="', built_in_app_variables().OC_PRIVACY_URL, '"target="_blank">'),
                '%close_privacy_link_tag', '</a>'
                ))}
            </p>
            <div class="form-check mt-4 mb-3 mt-md-40 mb-lg-40">
                <div class="checkbox-body d-flex align-items-center">
                    <input aria-label="Ho letto e compreso l’informativa sulla privacy" type="checkbox"
                           aria-describedby="privacyDescription" class="form-control" id="privacyCheck" value="true">
                    <label for="privacyCheck" id="privacyDescription"
                           class="title-small-semi-bold pt-1 active form-label">
                        {'I have read and understood the privacy policy'|i18n('bootstrapitalia/booking')}
                    </label>
                </div>
            </div>
            <button type="submit" class="mobile-full btn btn-primary disabled" disabled>
                <span class="text-button-sm">{'Next'|i18n('bootstrapitalia/booking')}</span>
                {display_icon('it-chevron-right', 'svg', 'icon icon-white icon-sm')}
            </button>
        </div>
    </div>
</div>