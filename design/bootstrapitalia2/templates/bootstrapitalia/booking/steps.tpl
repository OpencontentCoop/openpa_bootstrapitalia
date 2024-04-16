<div class="container">
    <div id="booking-steppers" class="steppers">
        <div class="steppers-header">
            <ul>
                {foreach $steps as $index => $step}
                    <li data-step="{$step.id|wash()}" class="text-uppercase{if $index|eq(0)} active{/if}">
                        {$step.title|wash()}
                        {display_icon('it-expand', 'svg', 'icon steppers-success invisible')}
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