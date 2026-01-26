<div class="container">
    <div id="booking-steppers" class="steppers">
        <div class="steppers-header">
            <ul>
                {foreach $steps as $index => $step}
                    <li
                      data-step="{$step.id|wash()}"
                      {if $step.focus}data-focus="{$step.focus|wash()}"{/if}
                      class="text-uppercase{if $index|eq(0)} active{/if}"
                      >
                        {$step.title|wash()}
                        {display_icon('it-check', 'svg', 'icon steppers-success invisible')}
                        <span
                          class="visually-hidden"
                          data-status="step-status-active"
                          aria-hidden="true">
                          {'Active'|i18n('bootstrapitalia')}</span>
                        <span
                          class="visually-hidden"
                          data-status="step-status-confirmed"
                          aria-hidden="true">
                          {'Confirmed'|i18n('bootstrapitalia')}</span>
                    </li>
                {/foreach}
            </ul>
            <span class="steppers-index" aria-hidden="true">1/{count($steps)}</span>
        </div>
    </div>
    <p class="title-xsmall d-lg-none my-5">
        {'The fields characterized by the asterisk symbol are mandatory'|i18n('bootstrapitalia/booking')}
    </p>
</div>