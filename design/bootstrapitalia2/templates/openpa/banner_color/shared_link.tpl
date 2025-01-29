{def $colors = decode_banner_color($node)}
{def $background_color_class = $colors.background_color_class}
{def $text_color_class = $colors.text_color_class}

<div data-object_id="{$node.contentobject_id}" class="opencity-banner-color card card-teaser no-after rounded mt-0 p-3 {$background_color_class} {$view_variation}">
    <div class="avatar size-lg me-3">
        {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
    </div>
    <div class="card-body">
        <h3 class="card-title text-{$background_color_class} font-sans-serif mb-1">
            <a data-shared_link="{$node.contentobject_id}" data-shared_link_view="banner_color" class="stretched-link text-decoration-none text-{$background_color_class}" href="{$openpa.content_link.full_link}">
                {$node.name|wash()}
                {include uri='design:parts/card_title_suffix.tpl'}
            </a>
        </h3>
    </div>
</div>