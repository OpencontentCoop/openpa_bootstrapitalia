{if $attribute.content|contains( 'http' )}
    <a href="{$attribute.content|wash( xhtml )}"
      target="_blank"
      rel="noopener">
        {$attribute.contentclass_attribute_name|wash( xhtml )} <i aria-hidden="true" class="fa fa-external-link"></i>
    </a>
{else}
    {$attribute.content|wash( xhtml )}
{/if}