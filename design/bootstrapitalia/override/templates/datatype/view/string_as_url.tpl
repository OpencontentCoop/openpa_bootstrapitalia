{if $attribute.data_text|contains( 'http' )}
<a href="{$attribute.data_text|wash( xhtml )}" title="{'Go to page'|i18n('bootstrapitalia')}: {$attribute.data_text|wash()}">
    <strong>{$attribute.data_text|wash( xhtml )}</strong>
</a>
{else}
    {$attribute.data_text|wash( xhtml )}
{/if}