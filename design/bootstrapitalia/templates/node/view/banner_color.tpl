{set_defaults(hash('view_variation', 'banner-round banner-shadow'))}
{def $openpa = object_handler($node)}
{include uri=$openpa.control_template.banner_color view_variation=$view_variation}
{undef $openpa}
{unset_defaults(array('view_variation'))}