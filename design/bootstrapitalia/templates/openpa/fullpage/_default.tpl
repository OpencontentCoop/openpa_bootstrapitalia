<h1>{$node.name|wash()}</h1>

{if $node|has_attribute('short_title')}
    <h2 class="h4 py-2">{$node|attribute('short_title').content|wash()}</h2>
{/if}

{include uri='design:openpa/full/parts/main_attributes.tpl'}

{include uri='design:openpa/full/parts/main_image.tpl'}

{include uri='design:openpa/fullpage/parts/attributes_simple.tpl' object=$node.object}