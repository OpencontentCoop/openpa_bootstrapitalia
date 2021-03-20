{def $recaptcha_public_key = openpa_recaptcha_public_key(3)}
{if and($recaptcha_public_key|ne(''), $recaptcha_public_key|ne('no-public'))}
<script src="https://www.google.com/recaptcha/api.js?render={$recaptcha_public_key}"></script>
<div class="it-footer-valuation bg-light border-top position-relative">
    <div class="container">
        <section style="padding: 0 16px">
            <div class="row feedback-input">
                <div class="col-sm-12 py-2 text-center text-lg-left">
                    <span class="pr-3 pb-2 text-dark h6">{$openpa_valuation.data_map.useful.contentclass_attribute_name|wash()}</span>
                    <div class="d-inline-block nowrap">
                        <a data-sitekey="{$recaptcha_public_key|wash()}" data-feedback="yes" class="btn btn-outline-dark btn-sm mr-2 text-uppercase bg-white rounded-0" href="#">{'Yes'|i18n('design/admin/class/view')}</a>
                        <a data-sitekey="{$recaptcha_public_key|wash()}" data-feedback="no" class="btn btn-outline-dark btn-sm text-uppercase bg-white rounded-0" href="#">{'No'|i18n('design/admin/class/view')}</a>
                    </div>
                </div>
            </div>
            <div class="row feedback-thanks hide">
                <div class="col-sm-12 py-2">
                    <p class="h6 mt-2 font-weight-normal">{'Thanks for your feedback'|i18n("bootstrapitalia/valuation")} <i aria-hidden="true" class="fa fa-heart"></i></p>
                </div>
            </div>
            <div class="row feedback-survey hide"
                 data-next="{"Next"|i18n("design/admin/navigator")}"
                 data-previous="{"Previous"|i18n("design/admin/navigator")}"
                 data-submit="{"Submit"|i18n("survey")}">
                <div class="col-lg-9 py-2">
                    <div class="my-1">
                        <p class="h6 mt-2 font-weight-normal">{$openpa_valuation.name|wash()}</p>
                        <form class="form text-left">
                            <input type="submit" class="sr-only d-none" title="{$openpa_valuation.name|wash()}" />
                        </form>
                    </div>
                </div>
            </div>
        </section>
    </div>
</div>
{/if}
{undef $recaptcha_public_key}