{set_defaults( hash('image_class', 'reference'))}
{def $background_image_src = ''}
{if and(is_set($url), $url)}
    {set $background_image_src = render_image($url).src}
{elseif is_set($node)}
    {def $node_main_image = node_image($node)}
    {if $node_main_image}
        {set $background_image_src = render_image($node_main_image).src}
    {/if}
    {undef $node_main_image}
{/if}
{if $background_image_src}
<img
  src="{$background_image_src}"
  style="object-fit: cover;"
  class="h-100 w-100"
  role="presentation"
  loading="lazy" />
{/if}
{undef $background_image_src}
{unset_defaults(array('image_class'))}
