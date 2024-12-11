<div class="{if $item.wrap}card-wrapper card-column my-3" data-bs-toggle="masonry{/if}"{if $item.data_element} data-element="{$item.data_element|wash()}"{/if}>

    {foreach $item.attributes as $attribute_index => $openpa_attribute}

        {if $openpa_attribute.full.highlight}
        <div class="callout important">
            {if and($openpa_attribute.full.show_label, $openpa_attribute.full.collapse_label|not(), $item.is_grouped)}
                <div class="callout-title">
                    {display_icon('it-info-circle', 'svg', 'icon')}
                    {$openpa_attribute.label|wash()}
                </div>
            {/if}
            <div class="font-serif small neutral-1-color-a7">
        {elseif and($openpa_attribute.full.show_label, $item.is_grouped)}
            {if $openpa_attribute.full.collapse_label|not()}
                <h3 class="h5 mt-4 font-sans-serif">{$openpa_attribute.label|wash()}</h3>
            {else}
                <span class="text-paragraph-small font-sans-serif">{$openpa_attribute.label|wash()}:</span>
            {/if}
        {/if}

        {if is_set($openpa_attribute.contentobject_attribute)}
            {def $need_container = cond(
                and(
                    $item.wrap|not(),
                    array('eztext', 'ezxmltext')|contains($openpa_attribute.contentobject_attribute.data_type_string)
                ),
                true(), false()
            )}
            {if $need_container}<div class="richtext-wrapper lora">{/if}
            {attribute_view_gui attribute=$openpa_attribute.contentobject_attribute
                                view_context=full_attributes
                                attribute_group=$item
                                image_class=imagelargeoverlay
                                attribute_index=$attribute_index
                                context_class=cond(is_set($node), $node.class_identifier, $openpa_attribute.contentobject_attribute.object.class_identifier)
                                relation_view=cond(is_set($relation_view), $relation_view, cond($openpa_attribute.full.show_link|not, 'list', 'banner'))
                                relation_has_wrapper=$item.wrap
                                show_link=$openpa_attribute.full.show_link
                                tag_view="chip-lg mr-2 me-2"}
            {if $need_container}</div>{/if}
            {undef $need_container}
        {elseif and(is_set($openpa_attribute.template), $openpa_attribute.template)}
            {include uri=$openpa_attribute.template context=attributes}
        {/if}

        {if $openpa_attribute.full.highlight}
            </div>
        </div>
        {elseif and($openpa_attribute.full.show_label, $item.is_grouped,$openpa_attribute.full.collapse_label)}

        {/if}
    {/foreach}
</div>