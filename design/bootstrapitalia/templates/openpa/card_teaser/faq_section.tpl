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
            {include uri='design:openpa/card_teaser/parts/card_title.tpl'}
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

            {def $faq_groups = fetch(content, list, hash('parent_node_id', $node.node_id, 'class_filter_type', 'include', 'class_filter_array', array('faq_group')))}
            {foreach $faq_groups as $faq_group}
                <div class="my-4">
                    <h6>
                        {$faq_group.name|wash()}
                        {if $faq_group.can_edit}
                            <a href="{$faq_group.url_alias|ezurl(no)}">
                                <span class="fa-stack">
                                  <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
                                  <i aria-hidden="true" class="fa fa-wrench fa-stack-1x fa-inverse"></i>
                                </span>
                            </a>
                        {/if}
                    </h6>
                    {if $faq_group|has_attribute('description')}
                        {attribute_view_gui attribute=$faq_group|attribute('description')}
                    {/if}
                    {include uri='design:parts/faq_accordion.tpl' node=$faq_group}
                </div>
            {/foreach}

            {if $attributes.show|contains('content_show_read_more')}
                <p class="mt-3"><a href="{$openpa.content_link.full_link}" title="{'Go to content'|i18n('bootstrapitalia')} {$node.name|wash()}">{'Further details'|i18n('bootstrapitalia')}</a></p>
            {/if}
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
