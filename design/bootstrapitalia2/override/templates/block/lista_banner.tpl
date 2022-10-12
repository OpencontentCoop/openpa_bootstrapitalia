{def $openpa = object_handler($block)}

{set_defaults(hash('items_per_row', 3))}
{if $openpa.has_content}
{include uri='design:parts/block_name.tpl'}
{include uri='design:atoms/grid.tpl'
         items_per_row=$items_per_row
         i_view=banner
         image_class=large
         view_variation='banner-round banner-shadow h-100'
         items=$openpa.content}
{include uri='design:parts/block_show_all.tpl'}
{/if}
{unset_defaults(array('items_per_row'))}

{undef $openpa}