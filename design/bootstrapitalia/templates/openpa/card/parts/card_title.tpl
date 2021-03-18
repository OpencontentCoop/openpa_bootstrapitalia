{if $view_variation|eq('alt')}
	<h5 class="card-title">
		<a class="text-decoration-none" href="{$openpa.content_link.full_link}">{$node.name|wash()}</a>
		{if and($openpa.content_link.is_node_link|not(), $node.can_edit)}
			<a href="{$node.url_alias|ezurl(no)}">
				<span class="fa-stack">
				  <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
				  <i aria-hidden="true" class="fa fa-wrench fa-stack-1x fa-inverse"></i>
				</span>
			</a>
		{/if}
	</h5>
{else}
	<h5 class="card-title{if and($has_media|not(), $view_variation|eq('big')|not())} big-heading{/if}">
		<a class="text-decoration-none" href="{$openpa.content_link.full_link}">{$node.name|wash()}</a>
		{if and($openpa.content_link.is_node_link|not(), $node.can_edit)}
			<a href="{$node.url_alias|ezurl(no)}">
				<span class="fa-stack">
				  <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
				  <i aria-hidden="true" class="fa fa-wrench fa-stack-1x fa-inverse"></i>
				</span>
			</a>
		{/if}
	</h5>
{/if}