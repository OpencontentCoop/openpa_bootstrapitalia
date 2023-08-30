{if count($attribute.content.objects)}
	<div class="card-wrapper card-teaser-wrapper" style="min-width:49%">
		{foreach $attribute.content.objects as $object }
			{node_view_gui content_node=$object.main_node view=card_teaser show_icon=true() image_class=widemedium}
		{/foreach}
	</div>
	{include name=navigator
		   uri='design:navigator/google.tpl'
		   page_uri=$attribute.object.main_node.url_alias
		   item_count=$attribute.content.count
		   variable_name=$attribute.contentclass_attribute_identifier
		   view_parameters=$#view_parameters
		   item_limit=$attribute.content.items_per_page}
{/if}
