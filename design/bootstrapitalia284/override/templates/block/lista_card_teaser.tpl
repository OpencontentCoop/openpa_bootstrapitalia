{def $openpa = object_handler($block)}

{set_defaults(hash('items_per_row', 3))}
{if $openpa.has_content}
    {include uri='design:parts/block_name.tpl'}
    {include uri='design:atoms/grid.tpl'
             items_per_row=$items_per_row
             i_view=card_teaser
             show_icon=false()
             card_wrapper_class=cond(and(is_set($block.custom_attributes.container_style), $block.custom_attributes.container_style|eq('overlay')), 'px-0 card-overlapping', '')
             items=$openpa.content}
    {include uri='design:parts/block_show_all.tpl'}
{/if}
{unset_defaults(array('items_per_row'))}

{undef $openpa}
