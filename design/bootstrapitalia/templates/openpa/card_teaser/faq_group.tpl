{set_defaults(hash(
    'show_icon', true(),
    'image_class', 'medium',
    'view_variation', false(),
    'hide_title', false()
))}

{def $attributes = class_extra_parameters($node.object.class_identifier, 'card_small_view')}

<div data-object_id="{$node.contentobject_id}" class="card card-teaser shadow {$node|access_style} rounded {$view_variation}">
    {if and($show_icon, $openpa.content_icon.icon, $node|has_attribute('image')|not())}
        {display_icon($openpa.content_icon.icon.icon_text, 'svg', 'icon')}
    {/if}
    <div class="card-body{if $node|has_attribute('image')} pr-3{/if}">
        {if $hide_title|not()}
        <h5 class="card-title mb-1">
            {$node.name|wash()}
            {if $node.can_edit}
                <a href="{$node.url_alias|ezurl(no)}">
				<span class="fa-stack">
				  <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
				  <i aria-hidden="true" class="fa fa-wrench fa-stack-1x fa-inverse"></i>
				</span>
                </a>
            {/if}
        </h5>
        {/if}
        <div class="card-text">

            {include uri='design:openpa/card_teaser/parts/attributes.tpl'}
            {include uri='design:parts/faq_accordion.tpl' node=$node}

            {def $parent = $node.parent}
            {if and($attributes.show|contains('content_show_read_more'), $parent.class_identifier|eq('faq_section'))}
            <p class="mt-5">
                <a class="read-more position-static" href="{$node.url_alias|ezurl(no)}" title="{'Go to content'|i18n('bootstrapitalia')} {$parent.name|wash()}">
                    {if $openpa.content_icon.class_icon}{display_icon($openpa.content_icon.class_icon.icon_text, 'svg', 'icon')}{/if}
                    {$parent.name|wash()}
                </a>
            </p>
            {/if}
            {undef $parent}
        </div>
    </div>
    {if and($attributes.show|contains('image'), $node|has_attribute('image'))}
        <div class="avatar size-xl">
            {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
        </div>
    {/if}
</div>

{undef $attributes}
{unset_defaults(array('show_icon', 'image_class', 'view_variation', 'hide_title'))}