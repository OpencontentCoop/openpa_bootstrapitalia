{set_defaults(hash(
    'relation_view', 'list',
    'relation_has_wrapper', false(),
    'context_class', false(),
    'attribute_index', 0,
    'show_link', true()
))}

{def $node_list = array()}
{if $attribute.has_content}
    {foreach $attribute.content.relation_list as $relation_item}
        {if $relation_item.in_trash|not()}
            {def $content_object = fetch( content, object, hash( object_id, $relation_item.contentobject_id ) )}
            {if $content_object.can_read}
                {set $node_list = $node_list|append($content_object.main_node)}
            {/if}
            {undef $content_object}
        {/if}
    {/foreach}
{/if}

{if count($node_list)|gt(0)}
    {if $relation_view|eq('list')}
        {if $attribute.contentclass_attribute_identifier|eq('topics')}
            {include uri='design:atoms/chip_list.tpl' items=$node_list data_element=cond($attribute.object.class_identifier|eq('public_service'), 'service-topic', false())}
        {else}
            {include uri='design:atoms/list_with_icon.tpl' items=$node_list show_link=$show_link}
        {/if}
    {else}
        {if $relation_has_wrapper|not()}<div class="card-wrapper card-column my-3" data-bs-toggle="masonry">{/if}
        {def $hide_title = cond(and(count($node_list)|eq(1), openpaini('HideRelationsTitle', 'AttributeIdentifiers', array())|contains($attribute.contentclass_attribute_identifier)), true(), false())}
        {foreach $node_list as $index => $child}
            {node_view_gui
                content_node=$child
                view=card_teaser_info
                hide_title=$hide_title
                attribute_index=sum($attribute_index, $index)
                data_element=cond($attribute.object.class_identifier|eq('public_service'), 'service-area', false())
                image_class=widemedium}
        {/foreach}
        {undef $hide_title}
        {if $relation_has_wrapper|not()}</div>{/if}
    {/if}

{/if}

{undef $node_list}

{unset_defaults(array('relation_view', 'relation_has_wrapper', 'attribute_index', 'show_link'))}