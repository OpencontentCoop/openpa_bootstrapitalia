{set_defaults(hash(
    'show_icon', false(),
    'image_class', 'medium',
    'view_variation', 'border-light',
    'custom_css_class', '',
    'hide_title', false()
))}
{def $attributes = class_extra_parameters($node.object.class_identifier, 'card_small_view')}
{def $has_image = false()}
<div data-object_id="{$node.contentobject_id}"
     class="font-sans-serif card card-teaser{if $has_image} card-teaser-image card-flex{/if} no-after rounded shadow-sm mb-0 border border-light {$node|access_style} {$custom_css_class}">
    {if $has_image}
    <div class="shared_link-card_teaser card-image-wrapper{if $attributes.show|contains('content_show_read_more')} with-read-more{/if}">
    {/if}
        <div class="card-body {if $has_image}p-3 {/if}pb-5">
        {if $openpa.content_icon.context_icon.node}
        <div class="category-top">
            {if $show_icon}{display_icon($openpa.content_icon.icon.icon_text, 'svg', 'icon icon-sm')}{/if}
            <span class="title-xsmall-semi-bold fw-semibold">{$openpa.content_icon.context_icon.node.name|wash()}</span>
        </div>
        {/if}
        <h3 class="card-title text-paragraph-medium u-grey-light">
            {include uri='design:openpa/card_teaser/parts/card_title.tpl'}
        </h3>
        <div class="text-paragraph-card u-grey-light m-0">
            <a data-shared_link="{$node.contentobject_id}" data-shared_link_view="card_teaser" target="_blank" rel="noopener noreferrer" href="{$openpa.content_link.full_link}" title="{'Go to content'|i18n('bootstrapitalia')} {$node.name|wash()}">
                {'Further details'|i18n('bootstrapitalia')}
                {display_icon('it-external-link', 'svg', 'icon icon-sm')}
            </a>
        </div>
    </div>
    {if $has_image}
        <div class="card-image card-image-rounded pb-5">
            {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
        </div>
    </div>
    {/if}
    {if $attributes.show|contains('content_show_read_more')}
        <a class="read-more{if $has_image} ps-3 position-absolute bottom-0 mb-3{/if}" href="{$openpa.content_link.full_link}" title="{'Go to content'|i18n('bootstrapitalia')} {$node.name|wash()}">
            <span class="text">{'Further details'|i18n('bootstrapitalia')}</span>
            {display_icon('it-arrow-right', 'svg', 'icon ms-0', 'Read more'|i18n('bootstrapitalia'))}
        </a>
    {/if}
</div>
{undef $attributes $has_image}
{unset_defaults(array('show_icon', 'image_class', 'view_variation', 'hide_title'))}