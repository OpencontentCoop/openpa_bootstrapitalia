{def $background_color_class = 'bg-light'}
{if $node|has_attribute('background_color')}
    {foreach $node|attribute('background_color').class_content.options as $option}
        {if $node|attribute('background_color').content|contains($option.id)}
            {set $background_color_class = $option.name|wash(xhtml)}
            {break}
        {/if}
    {/foreach}
{/if}

<div data-object_id="{$node.contentobject_id}" class="card card-teaser rounded {$background_color_class} {$view_variation}">
    {if $node|has_attribute('image')}
    <div class="avatar size-lg mr-3">
        {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
    </div>
    {/if}
    <div class="card-body">
        <h5 class="card-title text-{$background_color_class}">
            <a class="stretched-link text-decoration-none text-{$background_color_class}" href="{$openpa.content_link.full_link}">
                {$node.name|wash()}
            </a>
        </h5>
        {if $node|has_attribute('description')}
        <p class="card-text text-sans-serif text-{$background_color_class}">{$node|attribute('description').content.output.output_text|oc_shorten(60)}</p>
        {/if}
        {if and($openpa.content_link.is_node_link|not(), $node.can_edit)}
            <a style="z-index: 10;right: 0;left: auto;bottom: 0" class="position-absolute p-1" href="{$node.url_alias|ezurl(no)}">
                <span class="fa-stack">
                  <i class="fa fa-circle fa-stack-2x"></i>
                  <i class="fa fa-wrench fa-stack-1x fa-inverse"></i>
                </span>
            </a>
        {/if}
    </div>
</div>