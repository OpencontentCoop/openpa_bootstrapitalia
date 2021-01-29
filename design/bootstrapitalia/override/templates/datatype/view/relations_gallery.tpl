{def $images = array()
     $exclude_first = false()}
{if and(
    is_set($view_context),
    $view_context|eq('full_attributes'),
    class_extra_parameters($attribute.object.class_identifier, 'table_view').main_image|contains($attribute.contentclass_attribute_identifier)
    class_extra_parameters($attribute.object.class_identifier, 'table_view').show_link|contains($attribute.contentclass_attribute_identifier)|not()
)}
    {set $exclude_first = true()}
{/if}
{foreach $attribute.content.relation_list as $index => $item}
    {if and($index|eq(0), $exclude_first)}{skip}{/if}
    {def $object = fetch( content, object, hash( object_id, $item.contentobject_id ) )}
    {if $object.can_read}
        {set $images = $images|append($object)}
    {/if}
    {undef $object}
{/foreach}
    {include uri='design:atoms/gallery.tpl'
             items=$images}
{undef $images $exclude_first}