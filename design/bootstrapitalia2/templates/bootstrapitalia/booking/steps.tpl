<div class="container">
    <div class="steppers">
        <div class="steppers-header">
            <ul>
                {foreach $steps as $index => $step}
                    <li data-step="{$step.id|wash()}" class="{if $index|eq(0)}active{/if}">
                        {$step.title|wash()}
{*                        <span class="visually-hidden">Attivo</span>*}
                        {display_icon('it-expand', 'svg', 'icon steppers-success invisible')}
{*                        <span class="visually-hidden">Confermato</span>*}
                    </li>
                {/foreach}
            </ul>
            <span class="steppers-index" aria-hidden="true">1/{count($steps)}</span>
        </div>
    </div>
    <p class="title-xsmall d-lg-none my-5">I campi contraddistinti dal simbolo asterisco sono obbligatori</p>
</div>