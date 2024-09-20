{if openpaini('Trasparenza', 'ShowChildrenAsCard', 'disabled')|eq('enabled')}
    {set_defaults(hash(
        'show_icon', false(),
        'view', 'banner'
    ))}
    {include uri='design:atoms/grid.tpl'
             items_per_row=2
             i_view=$view
             view_variation=false()
             show_icon=$show_icon
             image_class=imagelargeoverlay
             items=$nodes}
    {include name=navigator
             uri='design:navigator/google.tpl'
             page_uri=$node.url_alias
             item_count=$nodes_count
             view_parameters=$view_parameters
             item_limit=10}
    {unset_defaults(array('show_icon', 'view'))}
{else}
{include uri='design:atoms/list_with_icon.tpl' items=$nodes}
{include name=navigator
         uri='design:navigator/google.tpl'
         page_uri=$node.url_alias
         item_count=$nodes_count
         view_parameters=$view_parameters
         item_limit=openpaini( 'GestioneFigli', 'limite_paginazione', 25 )}
{/if}