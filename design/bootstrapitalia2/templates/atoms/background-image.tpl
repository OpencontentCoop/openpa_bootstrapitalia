{set_defaults( hash('image_class', 'reference'))}
{if openpaini('ImageSettings', 'LazyLoadImages', 'disabled')|eq('enabled')}{*
*}data-bg="{if is_set($url)}{image_url($url, 'reference', true())}{elseif is_set($node)}{image_url(node_image($node).full_path|ezroot(no), false(), true())}{/if}" style="{if is_set($options)}{$options}{/if}"{*
*}{else}{*
*}style="background-image:url('{if is_set($url)}{image_url($url, 'reference', true())}{elseif is_set($node)}{image_url(node_image($node).full_path|ezroot(no), false(), true())}{/if}'){if is_set($options)};{$options}{/if}"{*
*}{/if}
{unset_defaults(array('image_class'))}
