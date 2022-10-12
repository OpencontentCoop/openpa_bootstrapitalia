{default attribute_parameters=array()}
{set_defaults(hash(
    'show_icon', true(),
    'image_class', 'widemedium',
    'view_variation', 'w-100',
    'hide_title', false()
))}
{if and( $object.main_node_id|null|not, $object.can_read )}
    {node_view_gui content_node=$object.main_node view=card_teaser_info show_icon=$show_icon image_class=$image_class view_variation=$view_variation hide_title=$hide_title}
{/if}
{unset_defaults(array('show_icon', 'image_class', 'view_variation', 'hide_title'))}
{/default}