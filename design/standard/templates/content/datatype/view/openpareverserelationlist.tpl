{def $item_count = fetch('bootstrapitalia', 'openpareverse_count', hash('attribute', $attribute))}
{if $item_count}
	{def $items_per_page = cond(is_set($attribute.class_content.limit), $attribute.class_content.limit, 2)}
	{def $reverse_list = fetch('bootstrapitalia', 'openpareverse_list', hash('attribute', $attribute, 'limit', $items_per_page, 'offset', cond(is_set($#view_parameters[$attribute.contentclass_attribute_identifier]), $#view_parameters[$attribute.contentclass_attribute_identifier], 0)))}
		<div class="card-wrapper card-teaser-wrapper" style="min-width:49%">
			{foreach $reverse_list as $related_node}
				{node_view_gui content_node=$related_node view=card_teaser show_icon=true() image_class=widemedium}
			{/foreach}
		</div>
		{include name=navigator
			   uri='design:navigator/google.tpl'
			   page_uri=$attribute.object.main_node.url_alias
			   item_count=$item_count
			   variable_name=$attribute.contentclass_attribute_identifier
			   view_parameters=$#view_parameters
			   item_limit=$items_per_page}
		{undef $items_per_page $reverse_list}
{/if}
{undef $item_count}