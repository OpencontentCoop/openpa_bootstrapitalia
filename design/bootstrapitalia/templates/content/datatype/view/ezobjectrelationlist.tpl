{set_defaults(hash(
    'relation_view', 'list',
    'relation_view_variation', false()
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
        {include uri='design:atoms/list_with_icon.tpl' items=$node_list}
    {else}
        {include uri='design:atoms/grid.tpl' items=$node_list i_view=banner items_per_row=2 items=$node_list view_variation=$relation_view_variation show_icon=false()}
    {/if}

{/if}

{undef $node_list}

{unset_defaults(array('relation_view'))}