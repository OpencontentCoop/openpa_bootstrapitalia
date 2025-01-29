{set_defaults(hash('view_variation', false(), 'context_object_id', false()))}
{def $openpa = object_handler($node)}
{include uri=$openpa.control_template.card_teaser_info view_variation=$view_variation context_object_id=$context_object_id}
{undef $openpa}
{unset_defaults(array('view_variation'))}