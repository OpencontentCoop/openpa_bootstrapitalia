{set_defaults( hash('image_class', 'reference'))}
style="background-image:url('{if is_set($url)}{render_image($url).src}{elseif is_set($node)}{render_image(node_image($node)).src}{/if}'){if is_set($options)};{$options}{/if}"
{unset_defaults(array('image_class'))}
