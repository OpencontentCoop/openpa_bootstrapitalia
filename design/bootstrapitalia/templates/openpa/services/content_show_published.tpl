{if $node.object.published|gt(0)}
<p class="info-date my-3 text-sans-serif">
    <span class="d-block text-nowrap text-sans-serif">{'Publication date'|i18n('openpa/search')}:</span>
    <strong class="text-nowrap">{$node.object.published|l10n( 'date' )}</strong>
</p>
{/if}
