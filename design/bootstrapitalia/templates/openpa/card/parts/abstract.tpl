{def $main_attributes = class_extra_parameters($node.object.class_identifier, 'table_view').in_overview}
{if count($main_attributes)}
<div class="card-text">
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
					<strong class="text-nowrap">{$openpa[$identifier].contentobject_attribute.content.timestamp|datetime( 'custom', '%j %F %Y' )} min</strong>
				</p>
			{else}
				<div>
					{*if class_extra_parameters($node.object.class_identifier, 'table_view').show_label|contains($identifier)}
						<span class="font-weight-bold text-nowrap text-sans-serif">{$openpa[$identifier].contentobject_attribute.contentclass_attribute_name}: </span>
					{/if*}
					{attribute_view_gui attribute=$openpa[$identifier].contentobject_attribute}
				</div>
			{/if}
		{/if}
	{else}
	    {include uri=$openpa[$identifier].template}
	{/if}
{/foreach}
</div>
{/if}
{undef $main_attributes}

{*if $node|has_attribute('topics')}
<div class="my-3">
    {foreach $node|attribute('topics').content.relation_list as $item}
        {def $object = fetch(content, object, hash(object_id, $item.contentobject_id))}
        <a href="{$object.main_node.url_alias|ezurl(no)}"><div class="badge badge-pill badge-outline-secondary"><span class="chip-label">{$object.name|wash()}</span></div></a>
        {undef $object}
    {/foreach}
</div>    
{/if*}