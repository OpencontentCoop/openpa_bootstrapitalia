{set_defaults(hash(
    'relation_view', 'list',
    'relation_has_wrapper', false(),
    'context_class', false()
))}

{def $node_id_list = array()}
{def $items_per_page = 30}
{def $node_list = array()}
{def $total = 0}
{def $offset = cond(is_set($#view_parameters[$attribute.contentclass_attribute_identifier]), $#view_parameters[$attribute.contentclass_attribute_identifier], 0)}

{if $attribute.has_content}
    {foreach $attribute.content.relation_list as $relation_item}
        {if $relation_item.in_trash|not()}
            {set $node_id_list = $node_id_list|append($relation_item.node_id)}
        {/if}
    {/foreach}
    {set $total = count($node_id_list)}
    {if $total|gt(0)}
        {if $total|gt($items_per_page)}
            {set $node_id_list = $node_id_list|extract( $offset, $items_per_page )}
        {/if}
        {foreach $node_id_list as $node_id}
            {def $relation_node = fetch(content, node, hash(node_id, $node_id))}
            {if $relation_node.can_read}
                {set $node_list = $node_list|append($relation_node)}
            {/if}
            {undef $relation_node}
        {/foreach}

        {if $relation_view|eq('list')}
            {include uri='design:atoms/list_with_icon.tpl' items=$node_list}
        {else}
            {if $relation_has_wrapper|not()}<div class="card-wrapper card-teaser-wrapper" style="min-width:49%">{/if}
            {def $hide_title = cond(and(count($node_list)|eq(1), openpaini('HideRelationsTitle', 'AttributeIdentifiers', array())|contains($attribute.contentclass_attribute_identifier)), true(), false())}
            {foreach $node_list as $child}
                {node_view_gui content_node=$child view=card_teaser show_icon=true() hide_title=$hide_title image_class=widemedium}
            {/foreach}
            {undef $hide_title}
            {if $relation_has_wrapper|not()}</div>{/if}
        {/if}

        {if $total|gt($items_per_page)}
            {include name=navigator
                     uri='design:navigator/google.tpl'
                     page_uri=$attribute.object.main_node.url_alias
                     item_count=$total
                     variable_name=$attribute.contentclass_attribute_identifier
                     view_parameters=$#view_parameters
        item_limit=$items_per_page}
        {/if}
    {/if}
{/if}

{undef $node_list $items_per_page $total $offset}

{unset_defaults(array('relation_view', 'relation_has_wrapper'))}