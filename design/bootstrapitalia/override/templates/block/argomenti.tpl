{def $parent = $block.valid_nodes[0].parent}
{def $background_image = false()}
{if and(is_set($block.custom_attributes.image), $block.custom_attributes.image|ne(''))}
    {def $image = fetch(content, node, hash(node_id, $block.custom_attributes.image))}
    {if and($image, $image.class_identifier|eq('image'), $image|has_attribute('image'))}
    	{set $background_image = $image|attribute('image').content.original.full_path|ezroot(no)}
	{/if}
    {undef $image}
{/if}
{def $exclude_classes = array()}
{if and(is_set($block.custom_attributes.exclude_classes), $block.custom_attributes.exclude_classes|ne(''))}
	{set $exclude_classes = $block.custom_attributes.exclude_classes|explode(',')}
{/if}
{def $valid_topics = array()}
{foreach $block.valid_nodes as $valid_node}
	{if $valid_node.object.section_id|eq(1)}
		{set $valid_topics = $valid_topics|append($valid_node)}
	{/if}
{/foreach}
{if $valid_topics|count()}
<div class="py-5 position-relative">
<div class="block-topics-bg bg-primary" {if $background_image}style="background-image: url({$background_image});"{/if}></div>
	<div class="container">	
		{include uri='design:parts/block_name.tpl' css_class=cond($background_image, 'text-white bg-dark d-inline-block px-2 rounded', 'text-white')}
		<div class="container">
		    {include uri='design:atoms/grid.tpl'
		             items_per_row=3
		             i_view=card_children
		             view_variation='big'
		             image_class=imagelargeoverlay
					 exclude_classes=$exclude_classes
		             items=$valid_topics|extract_left( 3 )}

			{def $others_count = count($valid_topics)|sub(3)}
			{if $others_count|gt(0)}
				{def $line_topics = $valid_topics|extract_right($others_count)}
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
{/if}
{undef $parent $background_image $valid_topics}