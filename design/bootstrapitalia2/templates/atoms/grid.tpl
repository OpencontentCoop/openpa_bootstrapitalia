{set_defaults(hash(
    'items_per_row', 3,
    'i_view', 'card',
    'image_class', 'imagelargeoverlay',
    'show_icon', false(),
    'show_category', true(),
    'view_variation', false(),
    'grid_wrapper', true(),
    'grid_wrapper_class', 'row mx-lg-n3',
    'exclude_classes', array()
))}

{def $need_card_wrapper = cond(array('card_teaser', 'banner_color', 'card_children')|contains($i_view), true(), false())}

{if $items_per_row|eq('auto')}

    {if $grid_wrapper}<div class="{$grid_wrapper_class}" data-bs-toggle="masonry">{/if}
    {foreach $items as $child }
        <div class="col-sm-6 col-lg-4 mb-4{if $need_card_wrapper} card-wrapper card-teaser-wrapper card-teaser-masonry-wrapper{/if}">
            {node_view_gui content_node=$child view=$i_view image_class=$image_class show_icon=$show_icon view_variation=$view_variation exclude_classes=$exclude_classes}
        </div>
    {/foreach}
    {if $grid_wrapper}</div>{/if}

{elseif and(array('2','3','4')|contains($items_per_row), $need_card_wrapper)}

    {if $grid_wrapper}<div class="{$grid_wrapper_class}">{/if}
    {if and(count($items)|eq(2),count($items)|lt($items_per_row))}
        {set $items_per_row = 2}
    {/if}
    <div class="card-wrapper card-teaser-wrapper card-teaser-wrapper-equal card-teaser-block-{$items_per_row}">
    {foreach $items as $child }
        {node_view_gui content_node=$child view=$i_view image_class=$image_class show_icon=$show_icon show_category=$show_category view_variation=$view_variation exclude_classes=$exclude_classes}
    {/foreach}
    </div>
    {if $grid_wrapper}</div>{/if}

{else}

    {def $col = 12|div($items_per_row)}
    {if $grid_wrapper}<div class="{$grid_wrapper_class}">{/if}
        {foreach $items as $child}
        {if and(fetch('user', 'current_user').is_logged_in|not(),$child.class_identifier|eq('topic'), fetch(content, reverse_related_objects_count, hash('object_id', $child.contentobject_id, 'all_relations', true()))|eq(0))}
            {skip}
        {/if}
        {if and(fetch('user', 'current_user').is_logged_in|not(),$child.object.remote_id|eq('custom_topics'), $child.children_count|eq(0))}
            {skip}
        {/if}
        <div class="col-md-6 col-lg-{$col} mb-4{if $need_card_wrapper} card-wrapper card-teaser-wrapper card-teaser-masonry-wrapper{/if}">
            {node_view_gui content_node=$child view=$i_view image_class=$image_class show_icon=$show_icon view_variation=$view_variation exclude_classes=$exclude_classes}
        </div>
        {/foreach}
    {if $grid_wrapper}</div>{/if}
    {undef $col}

{/if}

{unset_defaults(array(
    'items_per_row',
    'i_view',
    'image_class',
    'view_variation',
    'exclude_classes',
    'grid_wrapper_class'
))}

