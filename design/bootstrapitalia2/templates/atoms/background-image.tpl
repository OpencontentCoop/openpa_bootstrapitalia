{set_defaults( hash('image_class', 'reference'))}
{if openpaini('InstanceSettings', 'LazyLoadImages', 'disabled')|eq('enabled')}{*
*}data-bg="{if is_set($url)}{$url|preload_image()}{elseif is_set($node)}{node_image($node).full_path|ezroot(no)|preload_image()}{/if}" style="{if is_set($options)}{$options}{/if}"{*
*}{else}{*
*}style="background-image:url('{if is_set($url)}{$url|preload_image()}{elseif is_set($node)}{node_image($node).full_path|ezroot(no)|preload_image()}{/if}'){if is_set($options)};{$options}{/if}"{*
*}{/if}
{unset_defaults(array('image_class'))}
