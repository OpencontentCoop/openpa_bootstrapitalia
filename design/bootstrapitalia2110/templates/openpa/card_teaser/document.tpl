{set_defaults(hash(
    'show_icon', true(),
    'image_class', 'imagelargeoverlay',
    'view_variation', 'border-light',
    'custom_css_class', '',
    'hide_title', false()
))}
{def $attributes = class_extra_parameters($node.object.class_identifier, 'card_small_view')}
{def $has_image = cond(and($attributes.show|contains('image'), $node|has_attribute('image')), true(), false())}
<div data-object_id="{$node.contentobject_id}"
     class="font-sans-serif card card-teaser{if $has_image} card-teaser-image card-flex{/if} no-after rounded shadow-sm mb-0 border border-light {$node|access_style} {$custom_css_class}">
    {if $has_image}
    <div class="card-image-wrapper{if $attributes.show|contains('content_show_read_more')} with-read-more{/if}">
    {/if}
        <div class="card-body {if $has_image}p-3 {/if}pb-5">
        {if $openpa.content_icon.context_icon.node}
        <div class="categoryicon-top">
            {display_icon($openpa.content_icon.icon.icon_text, 'svg', 'icon icon-sm')}
            <span class="text fw-semibold">{$openpa.content_icon.context_icon.node.name|wash()}</span>
        </div>
        {/if}
        {if $hide_title|not()}
        <h3 class="card-title h4 u-grey-light">
            <a data-element="{$openpa.data_element.value|wash()}" class="text-decoration-none stretched-link" href="{$openpa.content_link.full_link}" title="{'Go to content'|i18n('bootstrapitalia')} {$node.name|wash()}">
            {include uri='design:openpa/card_teaser/parts/card_title.tpl'}
            </a>
            {if and($openpa.content_link.is_node_link|not(), $node.can_edit)}
                <a href="{$node.url_alias|ezurl(no)}">
				<span class="fa-stack">
				  <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
				  <i aria-hidden="true" class="fa fa-wrench fa-stack-1x fa-inverse"></i>
				</span>
                </a>
            {/if}
        </h3>
        {/if}
        <div class="card-text">
            {include uri='design:openpa/card_teaser/parts/attributes.tpl'}
        </div>
    </div>
    {if $has_image}
        <div class="card-image card-image-rounded pb-5" style="width: 130px;">
            {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class context='card_teaser'}
        </div>
    </div>
    {/if}

</div>
{undef $attributes $has_image}
{unset_defaults(array('show_icon', 'image_class', 'view_variation', 'hide_title'))}