{set_defaults(hash('view_variation', false(), 'exclude_classes', array()))}
{def $openpa = object_handler($node)}
{include uri=$openpa.control_template.card_children view_variation=$view_variation exclude_classes=$exclude_classes}
{undef $openpa}
{unset_defaults(array('view_variation', 'exclude_classes'))}