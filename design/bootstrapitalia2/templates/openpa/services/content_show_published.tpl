{if $node.object.published|gt(0)}
    {if and(is_set($context), $context|eq('attributes'))}
        <div class="my-2">
            <h3 class="h6">{'Publication date'|i18n('bootstrapitalia')}: <span class="h6 fw-normal">{$node.object.published|l10n( 'shortdate' )}</span></h3>
        </div>
    {else}
        <small class="d-block text-nowrap font-sans-serif">{'Publication date'|i18n('openpa/search')}:</small>
        <p class="fw-semibold font-monospace text-nowrap">{$node.object.published|l10n( 'shortdate' )}</p>
    {/if}
{/if}