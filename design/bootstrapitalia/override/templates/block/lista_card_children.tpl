{def $openpa = object_handler($block)}

{set_defaults(hash('items_per_row', 3))}
{if $openpa.has_content}
{include uri='design:parts/block_name.tpl'}

<div class="container">

{include uri='design:atoms/grid.tpl'
         items_per_row=$items_per_row
         i_view=card_children
         view_variation='big'
         image_class=widemedium
         items=$openpa.content}
</div>
{/if}
{unset_defaults(array('items_per_row'))}

{undef $openpa}