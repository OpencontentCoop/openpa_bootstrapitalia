{def $background_color_class = 'bg-light'}
{if $node|has_attribute('background_color')}
    {foreach $node|attribute('background_color').class_content.options as $option}
        {if $node|attribute('background_color').content|contains($option.id)}
            {set $background_color_class = $option.name|wash(xhtml)}
            {break}
        {/if}
    {/foreach}
{/if}

<div data-object_id="{$node.contentobject_id}" class="shared_link-banner_color card card-teaser rounded {$background_color_class} {$view_variation}">
    {if $node|has_attribute('image')}
        <div class="avatar size-lg mr-3">
            {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
        </div>
    {/if}
    <div class="card-body">
        <h5 class="card-title text-{$background_color_class}">
            <a data-shared_link="{$node.contentobject_id}" data-shared_link_view="banner_color" class="stretched-link text-decoration-none text-{$background_color_class}" href="{$openpa.content_link.full_link}">
                {$node.name|wash()}
                {include uri='design:parts/card_title_suffix.tpl'}
            </a>
        </h5>
    </div>
</div>
