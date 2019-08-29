{default attribute_parameters=array()}
{if and( $object.main_node_id|null|not, $object.can_read )}
    {node_view_gui content_node=$object.main_node view=card_teaser show_icon=true() image_class=medium}
{/if}
{/default}