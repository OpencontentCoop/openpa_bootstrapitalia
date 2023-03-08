{set_defaults(hash('wrapper_class', 'card-text pb-3'))}
{def $main_attributes = class_extra_parameters($node.object.class_identifier, 'table_view').in_overview}
{def $main_labels = class_extra_parameters($node.object.class_identifier, 'table_view').show_label}
{if count($main_attributes)}
<div class="{$wrapper_class} d-none d-md-block">
{foreach $main_attributes as $identifier}
	{if is_set($openpa[$identifier].contentobject_attribute)}
		{if and($openpa[$identifier].contentobject_attribute.data_type_string|ne('ezimage'), $openpa[$identifier].contentobject_attribute.has_content)}
			{if $identifier|eq('reading_time')}
				{if $openpa[$identifier].contentobject_attribute.content|ne('0')}
				<p class="info-date my-3 text-sans-serif">
					<span class="d-block text-nowrap text-sans-serif">{'Reading time'|i18n('bootstrapitalia')}:</span>
					<strong class="text-nowrap">{$openpa[$identifier].contentobject_attribute.content|wash()} min</strong>
				</p>
				{/if}
			{elseif and(array('ezdate', 'ezdatetime')|contains($openpa[$identifier].contentobject_attribute.data_type_string), $openpa[$identifier].contentobject_attribute.has_content)}
				<p class="info-date my-3 text-sans-serif">
					<span class="d-block text-nowrap text-sans-serif">{$openpa[$identifier].contentobject_attribute.contentclass_attribute_name|wash()}:</span>
					<strong class="text-nowrap">{$openpa[$identifier].contentobject_attribute.content.timestamp|l10n( 'date' )}</strong>
				</p>
			{else}
				<div>
					{if $main_labels|contains($identifier)}
						<span class="d-block text-nowrap text-sans-serif">{$openpa[$identifier].contentobject_attribute.contentclass_attribute_name}: </span>
					{/if}
					{attribute_view_gui attribute=$openpa[$identifier].contentobject_attribute}
				</div>
			{/if}
		{/if}
	{elseif $identifier|ne('content_show_published')}
	    {include uri=$openpa[$identifier].template}
	{/if}
{/foreach}
</div>
{/if}
{undef $main_attributes}
{unset_defaults(array('wrapper_class'))}
