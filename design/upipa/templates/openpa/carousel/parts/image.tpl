{def $image = false()
     $aspect_ratio = false()}
{if $node|has_attribute('image')}
	{if $node|attribute('image').content[$image_class]}
	  {set $image = $node|attribute('image').content[$image_class].url}
	  {set $aspect_ratio = $node|attribute('image').content[$image_class].height|div($node|attribute('image').content[$image_class].width)|mul(100)}
	{/if}
{/if}
{if $image}
	<div class="img-responsive-wrapper">
		<div class="img-responsive">
			<div class="img-wrapper"><img src="{$image|ezroot(no, full)}" title="{$node.name|wash()}" alt="{$node.name|wash()}"></div>
		</div>
	</div>
{/if}
{undef $image}
