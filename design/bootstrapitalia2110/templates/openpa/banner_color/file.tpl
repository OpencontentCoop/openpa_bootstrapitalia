{def $colors = decode_banner_color($node)}

<div data-object_id="{$node.contentobject_id}"
     class="opencity-banner-color card card-teaser rounded mt-0 p-3 {$view_variation} {$node|access_style}">
    <div class="card-body">
        <h3 class="card-title font-sans-serif mb-1">
            <a data-element="{$openpa.data_element.value|wash()}" class="stretched-link" {if $openpa.content_link.target}target="{$openpa.content_link.target|wash()}"{/if} href="{$openpa.content_link.full_link}">
                {$node.name|wash()}
            </a>
        </h3>
        {if $node|has_attribute('file')}
        <p class="card-text text-sans-serif">
          (File {$node|attribute('file').content.mime_type|explode('application/')|implode('')} {$node|attribute('file').content.filesize|si(byte)})
        </p>
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