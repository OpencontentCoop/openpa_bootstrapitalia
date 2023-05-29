{if $node.object.modified|gt(0)}
    {if and(is_set($context), $context|eq('attributes'))}
        <div class="my-2">
            <span class="text-paragraph-small font-sans-serif">
                {'Last modified'|i18n('bootstrapitalia')} {$node.object.modified|l10n( 'shortdate' )}
            </span>
        </div>
    {else}
        <small class="d-block text-nowrap font-sans-serif">{'Last modified'|i18n('bootstrapitalia')}:</small>
        <p class="fw-semibold font-monospace text-nowrap">{$node.object.modified|l10n( 'shortdatetime' )}</p>
    {/if}
{/if}