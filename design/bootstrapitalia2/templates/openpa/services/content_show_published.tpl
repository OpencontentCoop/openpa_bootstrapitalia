{if $node.object.published|gt(0)}
    <small class="d-block text-nowrap font-sans-serif">{'Publication date'|i18n('openpa/search')}:</small>
    <p class="fw-semibold font-monospace text-nowrap">{$node.object.published|l10n( 'shortdate' )}</p>
{/if}
