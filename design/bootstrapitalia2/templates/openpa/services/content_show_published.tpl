{if $node.object.published|gt(0)}
    {if and(is_set($context), $context|eq('attributes'))}
        <div class="my-2">
            <span class="text-paragraph-small font-sans-serif">
                {'Publication date'|i18n('openpa/search')} {$node.object.published|l10n( 'shortdate' )}
            </span>
        </div>
    {else}
        <small class="d-block text-nowrap font-sans-serif">{'Publication date'|i18n('openpa/search')}:</small>
        <p class="fw-semibold font-monospace text-nowrap">{$node.object.published|l10n( 'shortdate' )}</p>
    {/if}
{/if}