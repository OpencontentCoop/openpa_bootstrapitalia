{set_defaults(hash(
    'items_per_row', 3,
    'i_view', 'card',
    'image_class', 'large',
    'show_icon', true(),
    'view_variation', false(),
    'grid_wrapper', true(),
    'grid_wrapper_class', 'row mx-lg-n3',
    'exclude_classes', array()
))}

{if $items_per_row|eq('auto')}

    {if $grid_wrapper}<div class="card-columns">{/if}
    {foreach $items as $child }
        {node_view_gui content_node=$child view=$i_view image_class=$image_class show_icon=$show_icon view_variation=$view_variation exclude_classes=$exclude_classes}
    {/foreach}
    {if $grid_wrapper}</div>{/if}

{elseif and(array('2','3','4')|contains($items_per_row), array('card_teaser', 'banner_color')|contains($i_view))}

    {if $grid_wrapper}<div class="{$grid_wrapper_class}">{/if}
    <div class="card-wrapper px-0 card-teaser-wrapper card-teaser-wrapper-equal card-teaser-block-{$items_per_row}">
    {foreach $items as $child }
        {node_view_gui content_node=$child view=$i_view image_class=$image_class show_icon=$show_icon view_variation=$view_variation exclude_classes=$exclude_classes}
    {/foreach}
    </div>
    {if $grid_wrapper}</div>{/if}

{else}

    {def $col = 12|div($items_per_row)}
    {if $grid_wrapper}<div class="{$grid_wrapper_class}">{/if}
        {foreach $items as $child }
        <div class="col-md-6 col-lg-{$col}">
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

