
{def $openpa = object_handler($node)}
{set_defaults(hash(
    'a_class', '',
    'span_class', false(),
    'text_wrap_start', '',
    'text_wrap_end', '',
    'icon_wrap_start', '',
    'icon_wrap_end', '',
    'show_icon', false(),
    'icon_class', 'icon icon-primary icon-sm me-1',
    'shorten', false(),
    'add_abstract', false(),
    'ignore_data_element', false(),
))}
{include
    uri=$openpa.control_template.text_linked
    a_class=$a_class
    span_class=$span_class
    text_wrap_start=$text_wrap_start
    text_wrap_end=$text_wrap_end
    icon_wrap_start=$icon_wrap_start
    icon_wrap_end=$icon_wrap_end
    show_icon=$show_icon
    icon_class=$icon_class
    shorten=$shorten
    add_abstract=$add_abstract
    ignore_data_element=$ignore_data_element
}
{unset_defaults(array(
    'shorten',
    'show_icon',
    'icon_class',
    'a_class',
    'span_class',
    'text_wrap_start',
    'text_wrap_end',
    'icon_wrap_start',
    'icon_wrap_end',
    'ignore_data_element'
))}
{undef $openpa}
