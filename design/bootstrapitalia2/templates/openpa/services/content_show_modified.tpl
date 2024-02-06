{if $node.object.modified|gt(0)}
    {if and(is_set($context), $context|eq('attributes'))}
        <div class="my-2">
            <h3 class="h6">{'Last modified'|i18n('bootstrapitalia')}: <span class="h6 fw-normal">{$node.object.modified|l10n( 'shortdatetime' )}</span></h3>
        </div>
    {else}
        <small class="d-block text-nowrap font-sans-serif">{'Last modified'|i18n('bootstrapitalia')}:</small>
        <p class="fw-semibold font-monospace text-nowrap">{$node.object.modified|l10n( 'shortdatetime' )}</p>
    {/if}
{/if}