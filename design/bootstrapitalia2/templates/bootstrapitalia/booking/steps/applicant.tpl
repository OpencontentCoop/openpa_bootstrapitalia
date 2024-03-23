<div id="step-{$step.id|wash()}" class="step container"{if $hide} style="display:none"{/if}>
    <div class="row">
        {include uri='design:bootstrapitalia/booking/sidebar.tpl' step=$step}
        <div class="col-12 col-lg-8 offset-lg-1">
            <div class="steppers-content" aria-live="polite">
                <div class="it-page-sections-container">
                    <section class="it-page-section" id="applicant">
                        <div class="cmp-card">
                            <div class="card has-bkg-grey shadow-sm p-big">
                                <div class="card-header border-0 p-0 mb-lg-30 m-0">
                                    <div class="d-flex">
                                        <h2 class="title-xxlarge mb-3">{'Applicant'|i18n('bootstrapitalia/booking')}</h2>
                                    </div>
                                </div>
                                <div class="card-body p-0">
                                    <div class="form-wrapper bg-white p-4">
                                        <div class="form-group cmp-input mb-0">
                                            <label class="cmp-input__label active" for="name">{'Name'|i18n('bootstrapitalia/booking')}*</label>
                                            <input type="text" class="form-control" id="name" name="name" required=""
                                                   data-focus-mouse="false">
                                            <button type="button" class="clean-input d-none"
                                                    aria-label="{'Delete the text'|i18n('bootstrapitalia/booking')}">
                                                    {display_icon('it-close', 'svg', 'icon')}
                                            </button>
                                            <div class="d-flex">
                                                <span class="form-text cmp-input__text">
                                                {'Insert your name'|i18n('bootstrapitalia/booking')}
                                                </span>
                                            </div>
                                        </div>
                                        <div class="form-group cmp-input mb-0">
                                            <label class="cmp-input__label active" for="surname">{'Surname'|i18n('bootstrapitalia/booking')}*</label>
                                            <input type="text" class="form-control" id="surname" name="surname"
                                                   required="" data-focus-mouse="false">
                                            <button type="button" class="clean-input d-none"
                                                    aria-label="{'Delete the text'|i18n('bootstrapitalia/booking')}">
                                                {display_icon('it-close', 'svg', 'icon')}
                                            </button>
                                            <div class="d-flex">
                                                <span class="form-text cmp-input__text">
                                                    {'Insert your surname'|i18n('bootstrapitalia/booking')}
                                                </span>
                                            </div>
                                        </div>
                                        <div class="form-group cmp-input mb-0">
                                            <label class="cmp-input__label active" for="fiscalcode">{'Fiscal code'|i18n('bootstrapitalia/booking')}*</label>
                                            <input type="text" class="form-control" id="fiscalcode" name="fiscalcode"
                                                   required="" data-focus-mouse="false">
                                            <button type="button" class="clean-input d-none"
                                                    aria-label="{'Delete the text'|i18n('bootstrapitalia/booking')}">
                                                {display_icon('it-close', 'svg', 'icon')}
                                            </button>
                                            <div class="d-flex">
                                                <span class="form-text cmp-input__text">
                                                    {'Enter your fiscal code'|i18n('bootstrapitalia/booking')}
                                                </span>
                                            </div>
                                        </div>
                                        <div class="form-group cmp-input mb-0">
                                            <label class="cmp-input__label active" for="email">{'Email'|i18n('bootstrapitalia/booking')}*</label>
                                            <input type="email" class="form-control" id="email" name="email" required=""
                                                   data-focus-mouse="false">
                                            <button type="button" class="clean-input d-none"
                                                    aria-label="{'Delete the text'|i18n('bootstrapitalia/booking')}">
                                                {display_icon('it-close', 'svg', 'icon')}
                                            </button>
                                            <div class="d-flex">
                                                <span class="form-text cmp-input__text">
                                                    {'Enter a valid email'|i18n('bootstrapitalia/booking')}
                                                </span>
                                            </div>
                                        </div>
                                        <div class="form-group cmp-input mb-0">
                                            <label class="cmp-input__label active" for="phone">{'Telephone number'|i18n('bootstrapitalia/booking')}*</label>
                                            <input type="text" class="form-control" id="phone" name="phone" required=""
                                                   data-focus-mouse="false">
                                            <button type="button" class="clean-input d-none"
                                                    aria-label="{'Delete the text'|i18n('bootstrapitalia/booking')}">
                                                {display_icon('it-close', 'svg', 'icon')}
                                            </button>
                                            <div class="d-flex">
                                                <span class="form-text cmp-input__text">
                                                    {'Please enter a valid phone number (only digits are allowed, enter at least 8 characters)'|i18n('bootstrapitalia/booking')}
                                                </span>
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