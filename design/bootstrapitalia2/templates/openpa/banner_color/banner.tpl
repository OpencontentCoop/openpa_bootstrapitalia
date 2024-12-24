{def $colors = decode_banner_color($node)}
{def $background_color_class = $colors.background_color_class}
{def $text_color_class = $colors.text_color_class}

<div data-object_id="{$node.contentobject_id}"
     class="opencity-banner-color card card-teaser rounded mt-0 p-3 {$background_color_class} {$view_variation} {$node|access_style}">
    <div class="avatar size-lg me-3">
        {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
    </div>
    <div class="card-body">
        <h3 class="card-title {$text_color_class} mb-1">
            <a data-element="{$openpa.data_element.value|wash()}" class="stretched-link {$text_color_class}" {if $openpa.content_link.target}target="{$openpa.content_link.target|wash()}"{/if} href="{$openpa.content_link.full_link}">
                {$node.name|wash()}
            </a>
        </h3>
        {if $node|has_attribute('description')}
        <p class="card-text text-sans-serif {$text_color_class}">{$node|attribute('description').content.output.output_text|oc_shorten(160)}</p>
        {/if}
        {if and($openpa.content_link.is_node_link|not(), $node.can_edit)}
            <a style="z-index: 10;right: 0;left: auto;bottom: 0" class="position-absolute p-1" href="{$node.url_alias|ezurl(no)}">
                <span class="fa-stack">
                  <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
                  <i aria-hidden="true" class="fa fa-wrench fa-stack-1x fa-inverse"></i>
                </span>
            </a>
        {/if}
    </div>
</div>