{def $images = array()}
{foreach $attribute.content.relation_list as $index => $item}
    {def $object = fetch( content, object, hash( object_id, $item.contentobject_id ) )}
    {if $object.can_read}
        {set $images = $images|append($object)}
    {/if}
    {undef $object}
{/foreach}
<div class="mb-3">
  {foreach $images as $image}
    {attribute_view_gui attribute=$image|attribute('image')
    image_class='reference'
    inline_style='max-height: 200px;'
    fluid=true()}
  {/foreach}
</div>
{undef $images}