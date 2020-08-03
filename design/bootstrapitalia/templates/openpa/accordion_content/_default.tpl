{set_defaults(hash(
    'image_class', 'small',
    'image_css_class', "float-left"
))}
<div data-object_id="{$node.contentobject_id}" class="d-flex align-items-stretch position-relative">
    {if $node|has_attribute('image')}
        <a class="mr-3" href="{$openpa.content_link.full_link}">
            {attribute_view_gui image_class=$image_class
                                attribute=$node|attribute('image')
                                href=false()
                                fluid=false()
                                alt_text=concat("Immagine decorativa per il contenuto ", $node.name|wash())}
        </a>
    {/if}
    <div>
        {$node|abstract()}
        <a class="read-more" href="{$openpa.content_link.full_link}">
            <span class="text">{'Read more'|i18n('bootstrapitalia')}</span>
            {display_icon('it-arrow-right', 'svg', 'icon')}
        </a>
    </div>
    {if and($openpa.content_link.is_node_link|not(), $node.can_edit)}
        <a style="z-index: 10;right: 0;left: auto;bottom: 0" class="position-absolute p-1" href="{$node.url_alias|ezurl(no)}">
            <span class="fa-stack">
              <i class="fa fa-circle fa-stack-2x"></i>
              <i class="fa fa-wrench fa-stack-1x fa-inverse"></i>
            </span>
        </a>
    {/if}
</div>

{unset_defaults(array(
    'image_class',
    'image_css_class'
))}