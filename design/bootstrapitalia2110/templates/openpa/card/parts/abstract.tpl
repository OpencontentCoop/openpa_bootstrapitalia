{set_defaults(hash('wrapper_class', 'card-text text-secondary'))}
{def $main_attributes = class_extra_parameters($node.object.class_identifier, 'table_view').in_overview}
{def $main_labels = class_extra_parameters($node.object.class_identifier, 'table_view').show_label}
{if count($main_attributes)}
<div class="d-none d-md-block">
{foreach $main_attributes as $identifier}
	{if is_set($openpa[$identifier].contentobject_attribute)}
		{if and($openpa[$identifier].contentobject_attribute.data_type_string|ne('ezimage'), $openpa[$identifier].contentobject_attribute.has_content)}
			{if $identifier|eq('reading_time')}
				{if $openpa[$identifier].contentobject_attribute.content|ne('0')}
				<p class="{$wrapper_class} info-date my-3 text-sans-serif">
					<span class="d-block text-nowrap text-sans-serif">{'Reading time'|i18n('bootstrapitalia')}:</span>
					<strong class="text-nowrap">{$openpa[$identifier].contentobject_attribute.content|wash()} min</strong>
				</p>
				{/if}
			{elseif and(array('ezdate', 'ezdatetime')|contains($openpa[$identifier].contentobject_attribute.data_type_string), $openpa[$identifier].contentobject_attribute.has_content)}
				<p class="{$wrapper_class} info-date my-3 text-sans-serif">
					<span class="d-block text-nowrap text-sans-serif">{$openpa[$identifier].contentobject_attribute.contentclass_attribute_name|wash()}:</span>
					<strong class="text-nowrap">{$openpa[$identifier].contentobject_attribute.content.timestamp|l10n( 'date' )}</strong>
				</p>
			{else}
				<div>
					{if $main_labels|contains($identifier)}
						<span class="d-block text-nowrap text-sans-serif">{$openpa[$identifier].contentobject_attribute.contentclass_attribute_name}: </span>
					{/if}
					{if array('eztext', 'ezstring')|contains($openpa[$identifier].contentobject_attribute.data_type_string)}<p class="{$wrapper_class}">{else}<div class="{$wrapper_class}">{/if}
					{attribute_view_gui attribute=$openpa[$identifier].contentobject_attribute view_context=card_abstract}
					{if array('eztext', 'ezstring')|contains($openpa[$identifier].contentobject_attribute.data_type_string)}</p>{else}</div>{/if}
				</div>
			{/if}
		{/if}
	{elseif $identifier|ne('content_show_published')}
		<p class="{$wrapper_class}">{include uri=$openpa[$identifier].template}</p>
	{/if}
{/foreach}
</div>
{/if}
{undef $main_attributes}
{unset_defaults(array('wrapper_class'))}
