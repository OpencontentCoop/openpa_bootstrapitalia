{def $images = array()}
{foreach $attribute.content.relation_list as $item}
    {def $object = fetch( content, object, hash( object_id, $item.contentobject_id ) )}
    {if $object.can_read}
        {set $images = $images|append($object)}
    {/if}
    {undef $object}
{/foreach}
    {include uri='design:atoms/gallery.tpl'
             items=$images}
{undef $images}