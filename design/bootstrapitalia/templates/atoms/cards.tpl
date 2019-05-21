{set_defaults(hash(
    'items_per_row', 3,
    'i_view', 'card',
    'image_class', 'widemedium',
    'show_icon', true()
))}

{if $items_per_row|eq('auto')}

    <div class="card-columns">
    {foreach $items as $child }
        {node_view_gui content_node=$child view=$i_view image_class=$image_class}
    {/foreach}
    </div>

{else}

    {def $col = 12|div($items_per_row)}
    <div class="row mx-lg-n3 pb-lg-3">
        {foreach $items as $child }
        <div class="col-sm-6 col-md-{$col} px-lg-3">
            {node_view_gui content_node=$child view=$i_view image_class=$image_class show_icon=$show_icon}
        </div>
        {delimiter modulo=$items_per_row}</div><div class="row mx-lg-n3 pb-lg-3">{/delimiter}
        {/foreach}
    </div>
    {undef $col}

{/if}

{unset_defaults(array(
    'items_per_row',
    'i_view',
    'image_class'
))}

