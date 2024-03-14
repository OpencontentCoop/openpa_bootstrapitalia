{def $attributes = class_extra_parameters($node.object.class_identifier, 'card_small_view')}
{def $has_image = cond($node|has_attribute('image'), true(), false())}
{set_defaults(hash('attribute_index', 0, 'data_element', ''))}
<div data-shared_link="{$node.contentobject_id}" data-shared_link_view="banner" data-object_id="{$node.contentobject_id}" href="{$openpa.content_link.full_link}"
     class="shared_link-banner font-sans-serif card card-teaser border border-light rounded shadow-sm p-3">
    <div class="card-body {if $has_image}pe-3{/if}">
        <p class="card-title text-paragraph-regular-medium-semi mb-3">
            <a class="text-decoration-none" href="{$openpa.content_link.full_link}" data-element="{$data_element}" data-focus-mouse="false">
                {include uri='design:openpa/card_teaser/parts/card_title.tpl'}
            </a>
            {if and($openpa.content_link.is_node_link|not(), $node.can_edit)}
            <a style="z-index: 10;right: 0;left: auto;bottom: 0" class="position-absolute p-1" href="{$node.url_alias|ezurl(no)}">
                <span class="fa-stack">
                  <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
                  <i aria-hidden="true" class="fa fa-wrench fa-stack-1x fa-inverse"></i>
                </span>
            </a>
            {/if}
        </p>
        {if $node|has_abstract()}
        <div class="card-text u-main-black">
            <p>{$node|abstract()|oc_shorten(160)}</p>
        </div>
        {/if}
    </div>
    {if $has_image}
    <div class="avatar size-xl">
        {attribute_view_gui attribute=$node|attribute('image') image_class=large}
    </div>
    {/if}
</div>
{unset_defaults(array('attribute_index', 'data_element'))}
{undef $attributes $has_image}