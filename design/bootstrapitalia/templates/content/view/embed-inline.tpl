{default attribute_parameters=array() show_link=true()}
{if and( $object.main_node_id|null|not, $show_link )}
    {node_view_gui content_node=$object.main_node view=text_linked}
{else}
    {$object.name|wash}
{/if}
{/default}