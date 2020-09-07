{def $parent = $block.valid_nodes[0].parent}
{def $background_image = false()}
{if and(is_set($block.custom_attributes.image), $block.custom_attributes.image|ne(''))}
    {def $image = fetch(content, node, hash(node_id, $block.custom_attributes.image))}
    {if and($image, $image.class_identifier|eq('image'), $image|has_attribute('image'))}
    	{set $background_image = $image|attribute('image').content.original.full_path|ezroot(no)}
	{/if}
    {undef $image}
{/if}
<div class="py-5 position-relative">
<div class="block-topics-bg bg-primary" {if $background_image}style="background-image: url({$background_image});"{/if}></div>
	<div class="container">	
		{include uri='design:parts/block_name.tpl' css_class='text-white'}
		<div class="container">
		    {include uri='design:atoms/grid.tpl'
		             items_per_row=3
		             i_view=card_children
		             view_variation='big'
		             image_class=imagelargeoverlay
		             items=$block.valid_nodes|extract_left( 3 )}

			{def $others_count = count($block.valid_nodes)|sub(3)}
			{if $others_count|gt(0)}
				{def $line_topics = $block.valid_nodes|extract_right($others_count)}
				<div class="row">
					<div class="col-sm-12 col-md-3 text-right">
						<span class="etichetta d-inline">{'Other topics'|i18n('bootstrapitalia')}</span>
					</div>
					<div class="col-sm-12 col-md-7 text-left">
						{foreach $line_topics as $topic}    	
					    	<a class="text-decoration-none" href="{$topic.url_alias|ezurl(no)}"><span class="chip chip-simple chip-primary"><span class="chip-label">{$topic.name|wash()}</span></span></a>    	
					    {/foreach}
					</div>
				</div>
				{undef $line_topics}
			{/if}
			{undef $others_count}
			<div class="row">
				<div class="col text-center">
					<a class="btn btn-primary" href="{$parent.url_alias|ezurl(no)}">{'View all'|i18n('bootstrapitalia')}</a>
				</div>
			</div>
		</div>	
	</div>	
</div>	
{undef $parent $background_image}