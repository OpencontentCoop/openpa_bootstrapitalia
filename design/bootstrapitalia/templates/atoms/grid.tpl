{set_defaults(hash(
    'items_per_row', 3,
    'i_view', 'card',
    'image_class', 'large',
    'show_icon', true(),
    'view_variation', false(),
    'grid_wrapper', true(),
    'exclude_classes', array()
))}

{if $items_per_row|eq('auto')}

    {if $grid_wrapper}<div class="card-columns">{/if}
    {foreach $items as $child }
        {node_view_gui content_node=$child view=$i_view image_class=$image_class show_icon=$show_icon view_variation=$view_variation exclude_classes=$exclude_classes}
    {/foreach}
    {if $grid_wrapper}</div>{/if}

{else}

    {def $col = 12|div($items_per_row)}
    {if $grid_wrapper}<div class="row mx-lg-n3">{/if}
        {foreach $items as $child }
        <div class="col-md-6 col-lg-{$col} px-lg-3 pb-lg-3">
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
    'exclude_classes'
))}

