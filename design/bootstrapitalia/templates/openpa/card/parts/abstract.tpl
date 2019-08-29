{def $main_attributes = class_extra_parameters($node.object.class_identifier, 'table_view').in_overview}
{if count($main_attributes)}
<div class="card-text">
{foreach $main_attributes as $identifier}
	{if is_set($openpa[$identifier].contentobject_attribute)}
		{if $openpa[$identifier].contentobject_attribute.data_type_string|ne('ezimage')}
			{attribute_view_gui attribute=$openpa[$identifier].contentobject_attribute}
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