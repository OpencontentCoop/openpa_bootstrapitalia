{if $attribute.content|contains( 'http' )}
    <a target="_blank" href="{$attribute.content|wash( xhtml )}" title="{'Go to page'|i18n('bootstrapitalia')}: {$attribute.content|wash()}">
        {$attribute.contentclass_attribute_name|wash( xhtml )} <i class="fa fa-external-link"></i>
    </a>
{else}
    {$attribute.content|wash( xhtml )}
{/if}