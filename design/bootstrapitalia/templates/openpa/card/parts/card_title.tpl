{if $view_variation|eq('alt')}
	<h5 class="card-title">
		{$node.name|wash()}
	</h5>
{else}
	<h5 class="card-title{if and($node|has_attribute('image')|not(), $view_variation|eq('big')|not())} big-heading{/if}">
	    {$node.name|wash()}
	</h5>
{/if}