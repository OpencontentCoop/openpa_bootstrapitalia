{def $main_attributes = class_extra_parameters($node.object.class_identifier, 'table_view').in_overview}
{foreach $main_attributes as $identifier}
	{if is_set($openpa[$identifier].contentobject_attribute)}
		{attribute_view_gui attribute=$openpa[$identifier].contentobject_attribute image_class=reference alignment=center}
	{else}
	    {include uri=$openpa[$identifier].template}
	{/if}
{/foreach}
{undef $main_attributes}