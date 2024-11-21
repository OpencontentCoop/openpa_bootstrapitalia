{set_defaults(hash('view_variation', false(), 'view', 'card'))}
{def $openpa = object_handler($node)}
{include uri=$openpa.control_children.template view_variation=$view_variation view=$view}
{undef $openpa}
{unset_defaults(array('view_variation'))}