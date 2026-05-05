<div class="container error-container" style="display:none">
    <div class="justify-content-center mb-50 row">
        <div class="col-12 col-lg-10">
            <div class="cmp-hero">
                <section class="it-hero-wrapper bg-white align-items-start">
                    <div class="it-hero-text-wrapper pt-0 ps-0 pb-40 pb-lg-60">
                        <div class="categoryicon-top d-flex">
                            {display_icon('it-error', 'svg', 'icon mr-10 icon-lg')}
                            <h1 class="text-black hero-title py-2">{'Error'|i18n('bootstrapitalia/booking')}</h1></div>
                        <div class="hero-text">
                            <p class="pt-3 pt-lg-4 error-message-generic">
                                {'An error was detected while searching for calendar availability or processing your request.'|i18n('bootstrapitalia/booking')}
                            </p>
                            <p class="pt-3 pt-lg-4 error-message-code" data-code="reservation_limit" style="display:none">
                                {'This appointment does not comply with the booking limits configured on the calendar.'|i18n('bootstrapitalia/booking')}
                            </p>
                            <p class="pt-3 pt-lg-4 error-message-code" data-code="daily_reservation_limit" style="display:none">
                                {'You have reached the maximum number of bookable appointments for the day.'|i18n('bootstrapitalia/booking')}
                            </p>
                            <p class="pt-3 pt-lg-4 error-message-code" data-code="weekly_reservation_limit" style="display:none">
                                {'You have reached the maximum number of bookable appointments for the week.'|i18n('bootstrapitalia/booking')}
                            </p>
                            <p class="pt-3 pt-lg-4 error-message-code" data-code="monthly_reservation_limit" style="display:none">
                                {'You have reached the maximum number of bookable appointments for the month.'|i18n('bootstrapitalia/booking')}
                            </p>
                            <p class="pt-3 pt-lg-4 error-message-code" data-code="yearly_reservation_limit" style="display:none">
                                {'You have reached the maximum number of bookable appointments for the year.'|i18n('bootstrapitalia/booking')}
                            </p>
                            <div class="error-message-generic">
                                <br>
                                <p>
                                    {'We apologize for the inconvenience and invite you to try again later.'|i18n('bootstrapitalia/booking')}
                                    <br />
                                    <br />
                                    {if $service}
                                        <a class="btn btn-outline-primary btn-xs me-3" href="{concat('prenota_appuntamento?service_id=', $service.id)|ezurl(no)}"><strong>{'Retry'|i18n('bootstrapitalia/booking')}</strong></a>
                                    {else}
                                        <a class="btn btn-outline-primary btn-xs me-3" href="{'prenota_appuntamento'|ezurl(no)}"><strong>{'Retry'|i18n('bootstrapitalia/booking')}</strong></a>
                                    {/if}
                                </p>
                            </div>
                            <br>
                            <p>
                                <button class="btn btn-outline-primary btn-xs me-3 error-goto-datetime" style="display:none"><strong>{'Choose another period'|i18n('bootstrapitalia/booking')}</strong></button>
                                {if $service}
                                    <a class="btn btn-outline-primary btn-xs" href="{$service.main_node.url_alias|ezurl(no)}"><strong>{'Back to service guide'|i18n('bootstrapitalia/booking')}</strong></a>
                                {else}
                                    <a class="btn btn-outline-primary btn-xs" href="{'/'|ezurl(no)}"><strong>{'Back to homepage'|i18n('bootstrapitalia/booking')}</strong></a>
                                {/if}
                            </p>
                        </div>
                    </div>
                </section>
            </div>
        </div>
    </div>
</div>