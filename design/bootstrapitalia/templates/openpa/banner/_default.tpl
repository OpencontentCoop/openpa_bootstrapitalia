{set_defaults(hash(
    'show_icon', true(),
    'image_class', 'medium',
    'view_variation', ''
))}
{if and($openpa.content_link.is_internal|not(), $node.can_edit)}
<div class="position-relative">
{/if}
<a data-object_id="{$node.contentobject_id}" href="{$openpa.content_link.full_link}" class="banner {$view_variation} {$node|access_style}">
    {if $node|has_attribute('image')}
    <div class="banner-image">
        {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
    </div>
    {elseif and($show_icon, $openpa.content_icon.icon)}
    <div class="banner-icon">
        <svg class="icon">
            {if $openpa.content_icon.icon}
                {display_icon($openpa.content_icon.icon.icon_text, 'svg', 'icon')}
            {/if}
        </svg>
        <span></span>
    </div>
    {/if}
    <div class="banner-text">
        <h4>{$node.name|wash()}</h4>
        {if $node|has_abstract()}
            <p>{$node|abstract()|oc_shorten(60)}</p>
    {/if}
    </div>
</a>
{if and($openpa.content_link.is_internal|not(), $node.can_edit)}
    <a style="z-index: 10;right: 0;left: auto;bottom: 0" class="position-absolute p-1" href="{$node.url_alias|ezurl(no)}">
        <span class="fa-stack">
          <i class="fa fa-circle fa-stack-2x"></i>
          <i class="fa fa-pencil fa-stack-1x fa-inverse"></i>
        </span>
    </a>
</div>
{/if}
{unset_defaults(array('show_icon', 'image_class', 'view_variation'))}