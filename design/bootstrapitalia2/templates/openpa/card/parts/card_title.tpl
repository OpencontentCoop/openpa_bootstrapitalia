{if $view_variation|eq('alt')}
	<h3 class="card-title">
		<a data-element="{$openpa.data_element.value|wash()}" class="text-decoration-none" href="{$openpa.content_link.full_link}">{$node.name|wash()}</a>
		{include uri='design:parts/card_title_suffix.tpl'}
		{if and($openpa.content_link.is_node_link|not(), $node.can_edit)}
			<a href="{$node.url_alias|ezurl(no)}">
				<span class="fa-stack">
				  <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
				  <i aria-hidden="true" class="fa fa-wrench fa-stack-1x fa-inverse"></i>
				</span>
			</a>
		{/if}
	</h3>
{else}
	<h3 class="card-title{if and($has_media|not(), $view_variation|eq('big')|not())} big-heading{/if}">
		<a data-element="{$openpa.data_element.value|wash()}" class="text-decoration-none" href="{$openpa.content_link.full_link}">{$node.name|wash()}</a>
		{include uri='design:parts/card_title_suffix.tpl'}
		{if and($openpa.content_link.is_node_link|not(), $node.can_edit)}
			<a href="{$node.url_alias|ezurl(no)}">
				<span class="fa-stack">
				  <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
				  <i aria-hidden="true" class="fa fa-wrench fa-stack-1x fa-inverse"></i>
				</span>
			</a>
		{/if}
	</h3>
{/if}
