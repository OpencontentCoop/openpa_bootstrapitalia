{set_defaults( hash('image_class', 'reference'))}
<img src="{if is_set($url)}{render_image($url).src}{elseif is_set($node)}{render_image(node_image($node)).src}{/if}" style="object-fit: cover;" class="h-100 w-100" role="presentation" />
{unset_defaults(array('image_class'))}
