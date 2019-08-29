{if class_extra_parameters($node.object.class_identifier, 'table_view').show|contains('content_show_published')}
    {include uri=$openpa['content_show_published'].template}
{/if}