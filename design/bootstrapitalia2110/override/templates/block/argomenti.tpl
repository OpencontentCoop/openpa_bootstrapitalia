{def $parent = fetch(content, object, hash('remote_id', 'topics'))}
{if $parent}
	{set $parent = $parent.main_node}
{else}
	{set $parent = $block.valid_nodes[0].parent}
{/if}
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
<div class="section pt-5 pb-0 px-md-3 px-lg-5 position-relative">
  <div class="block-bg bg-primary">
    {if $background_image}{include name="bg" uri='design:atoms/background-image.tpl' url=$background_image}{/if}
  </div>
	<div class="container">
		{include uri='design:parts/block_name.tpl' h_level=2 css_class=cond($background_image, 'text-white bg-primary d-inline-block px-2 rounded mb-3 position-relative', 'text-white title-xlarge mb-3 position-relative')}
		<div>
			{include uri='design:atoms/grid.tpl'
		             items_per_row=3
		             i_view=card_children
		             view_variation='big'
		             image_class=imagelargeoverlay
					 exclude_classes=$exclude_classes
		             items=$valid_topics|extract_left( 3 )}
		</div>
		{def $others_count = count($valid_topics)|sub(3)}
		<div class="row pt-30">
			{if $others_count|gt(0)}
			{def $line_topics = $valid_topics|extract_right($others_count)}
			<div class="col-lg-10 col-xl-8 offset-lg-1 offset-xl-2">
				<div class="row">
					<div class="col-lg-3 col-xl-2">
						<h3 class="text-uppercase mb-3 title-xsmall-bold text text-secondary">{'Other topics'|i18n('bootstrapitalia')}</h3>
					</div>
					<div class="col-lg-9 col-xl-10">
						<ul class="d-flex flex-wrap gap-1">
						{foreach $line_topics as $topic}
							<li>
								<a class="chip chip-simple"
								   data-element="{object_handler($topic).data_element.value|wash()}"
								   href="{$topic.url_alias|ezurl(no)}">
									<span class="chip-label">{$topic.name|wash()}</span>
								</a>
							</li>
						{/foreach}
						</ul>
					</div>
				</div>
			</div>
			{undef $line_topics}
			{/if}
			<div class="col-lg-10 col-xl-8 offset-lg-1 offset-xl-2 text-center mb-4">
				<a href="{$parent.url_alias|ezurl(no)}" class="btn btn-primary mt-40">{'View all'|i18n('bootstrapitalia')}</a>
			</div>
		</div>
		{undef $others_count}
	</div>
</div>
{/if}
{undef $parent $background_image $valid_topics}