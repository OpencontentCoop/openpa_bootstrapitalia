{def $openpa = object_handler($block)}

{include uri='design:parts/block_name.tpl'}

<div class="container">
	{if $items_per_row|eq('auto')}

	<div class="it-grid-list-wrapper it-image-label-grid it-masonry">
		<div class="card-columns">
		{foreach $openpa.content as $item}
			<div class="col-12">
				{node_view_gui content_node=$item view=card_image image_class=large show_icon=false()}
			</div>
		{/foreach}
		</div>
	</div>

	{else}

	{def $col = 12|div($items_per_row)}
	<div class="row mx-lg-n3">
		{foreach $openpa.content as $item}
			<div class="col-md-6 col-lg-{$col} px-lg-3 pb-lg-3 mb-3">
				{node_view_gui content_node=$item view=card_image image_class=large show_icon=false()}
			</div>
		{/foreach}
	</div>
	{undef $col}

	{/if}

</div>

{undef $openpa}