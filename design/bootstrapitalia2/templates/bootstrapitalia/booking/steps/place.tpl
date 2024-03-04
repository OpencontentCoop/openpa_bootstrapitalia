<div id="step-{$step.id|wash()}" class="step container"{if $hide} style="display:none"{/if}>
    <div class="row">
        {include uri='design:bootstrapitalia/booking/sidebar.tpl' step=$step}
        <div class="col-12 col-lg-8 offset-lg-1">
            <div class="steppers-content" aria-live="polite">
                <div class="it-page-sections-container">
                    <section class="it-page-section" id="office">
                        <div class="cmp-card">
                            <div class="card has-bkg-grey shadow-sm p-big">
                                <div class="card-header border-0 p-0 mb-lg-30">
                                    <div class="d-flex">
                                        <h2 class="title-xxlarge mb-0">
                                            Ufficio*
                                        </h2>
                                    </div>
                                    <p class="subtitle-small mb-0">
                                        Scegli l’ufficio a cui vuoi richiedere l’appuntamento
                                    </p>
                                </div>

                                <div class="card-body p-0">
                                    <div class="select-wrapper p-0 select-partials">
                                        <label for="office-choice" class="visually-hidden">Seleziona un ufficio</label>
                                        <select id="office-choice" class="" data-focus-mouse="false">
                                            {if count($offices)|gt(1)}
                                            <option selected="selected" value="">Seleziona un ufficio</option>
                                            {/if}
                                            {foreach $offices as $office}
                                                <option value="{$office.id|wash()}">{$office.name|wash()}</option>
                                            {/foreach}
                                        </select>
                                    </div>
                                    <fieldset class="d-none">
                                        <legend class="visually-hidden">Seleziona una sede</legend>
                                        {foreach $offices as $office}
                                            {foreach $office.places as $place}
                                            <div class="cmp-info-radio radio-card d-none" data-office="{$office.id|wash()}" data-place="{$place.id|wash()}">
                                                <div class="card p-3 p-lg-4">
                                                    <div class="card-header mb-0 p-0">
                                                        <div class="form-check m-0">
                                                            <input class="radio-input" name="place" type="radio"
                                                                   id="place-{$office.id|wash()}-{$place.id|wash()}"
                                                                   data-calendars="{$place.calendars|implode(',')}">
                                                            <label for="place-{$office.id|wash()}-{$place.id|wash()}">
                                                                <h3 class="big-title" data-title>{$place.name|wash()}</h3>
                                                            </label>
                                                        </div>
                                                    </div>
                                                    <div class="card-body p-0">
                                                        <div class="info-wrapper">
                                                            <span class="info-wrapper__label">Indirizzo</span>
                                                            <p class="info-wrapper__value" data-address>
                                                                <a href="https://www.google.com/maps/dir//'{$place.address.latitude|wash()},{$place.address.longitude|wash()}'/@{$place.address.latitude|wash()},{$place.address.longitude|wash()},15z?hl=it" target="_blank" rel="noopener noreferrer"  class="text-decoration-none">
                                                                    {$place.address.address|wash()}
                                                                </a>
                                                            </p>
                                                        </div>
{*                                                        <div class="info-wrapper">*}
{*                                                            <span class="info-wrapper__label">Apertura</span>*}
{*                                                            <p class="info-wrapper__value" data-opening>*}
{*                                                                ...*}
{*                                                            </p>*}
{*                                                        </div>*}
                                                    </div>
                                                </div>
                                            </div>
                                            {/foreach}
                                        {/foreach}
                                    </fieldset>
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