{def $openpa = object_handler($block)}

{set_defaults(hash('items_per_row', 3))}

<div class="container">
    {include uri='design:parts/block_name.tpl'}

    {include uri='design:atoms/cards.tpl'
             items_per_row=auto
             i_view=card
             image_class=widemedium
             items=$openpa.content}
</div>

{unset_defaults(array('items_per_row'))}

{undef $openpa}