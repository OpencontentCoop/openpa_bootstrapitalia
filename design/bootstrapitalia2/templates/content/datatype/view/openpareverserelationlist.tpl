{if count($attribute.content.objects)}
	<div class="card-wrapper card-teaser-wrapper my-3" style="min-width:49%">
	{foreach $attribute.content.objects as $object }
	    {node_view_gui content_node=$object.main_node view=card_teaser show_icon=false() show_category=true() image_class=widemedium}
	{/foreach}
	</div>
{/if}
{if $attribute.content.pages|gt(1)}
	{def $main_node = $attribute.object.main_node
		 $attribute_identifier = $attribute.contentclass_attribute_identifier}

	<ul class="pagination justify-content-center">
		<li class="page-item {if $attribute.content.current_page|eq(1)}disabled{/if}">
		  <a class="page-link" href="{if $attribute.content.current_page|eq(1)}#{else}{concat($main_node.url_alias, '/(', $attribute_identifier, ')/', $attribute.content.current_page|dec())|ezurl(no)}{/if}" tabindex="-1" aria-hidden="true">
		    {display_icon('it-chevron-left', 'svg', 'icon')}
		    <span class="sr-only">{"Previous"|i18n("design/admin/navigator")}</span>
		  </a>
		</li>
		
		{for 1 to $attribute.content.pages as $counter}
		<li class="page-item">
		  <a class="page-link" 
		  	 href="{concat($main_node.url_alias, '/(', $attribute_identifier, ')/', $counter)|ezurl(no)}" 
		  	 {if $attribute.content.current_page|eq($counter)}aria-current="page"{/if}
		  	 style="font-family: 'Titillium Web', Geneva, Tahoma, sans-serif;text-decoration:none"> {*todo*}
		    <span class="d-inline-block d-sm-none">Pagina </span>{$counter}
		  </a>
		</li>
		{/for}

		<li class="page-item {if $attribute.content.current_page|eq($attribute.content.pages)}disabled{/if}">
		  <a class="page-link" href="{if $attribute.content.current_page|eq($attribute.content.pages)}#{else}{concat($main_node.url_alias, '/(', $attribute_identifier, ')/', $attribute.content.current_page|inc())|ezurl(no)}{/if}" tabindex="-1" aria-hidden="true">
		    <span class="sr-only">{"Next"|i18n("design/admin/navigator")}</span>
		    {display_icon('it-chevron-right', 'svg', 'icon')}
		  </a>
		</li>
	</ul>
	{undef $main_node $attribute_identifier}
{/if}
