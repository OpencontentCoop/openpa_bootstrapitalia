{def $openpa = object_handler($block)}

{set_defaults(hash('items_per_row', 3))}
{if $openpa.has_content}
    {include uri='design:parts/block_name.tpl'}
    {include uri='design:atoms/grid.tpl'
             items_per_row=$items_per_row
             i_view=card_simple
             view_variation=false()
             show_icon=false()
             image_class=imagelargeoverlay
             items=$openpa.content}
    {include uri='design:parts/block_show_all.tpl'}
{/if}
{unset_defaults(array('items_per_row'))}

{undef $openpa}