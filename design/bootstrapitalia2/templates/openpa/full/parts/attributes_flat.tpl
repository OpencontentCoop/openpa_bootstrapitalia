{def $summary_text = 'Table of contents'|i18n('bootstrapitalia')
     $close_text = 'Close'|i18n('bootstrapitalia')}
{if is_set($show_all_attributes)|not()}
    {def $show_all_attributes = false()}
{/if}

{def $summary = parse_attribute_groups($object, $show_all_attributes)}

{if $summary.has_items}
    <div class="row attribute-list">

        <section class="it-page-sections-container">
            {foreach $summary.items as $index => $item}
                <article id="{$item.slug|wash()}" class="it-page-section anchor-offset{if $item.evidence} has-bg-grey p-3{/if}">
                    {if and(count($summary.items)|gt(1), $item.label)}
                        <h3 class="my-3 h5">{$item.label|wash()}</h3>
                    {else}
                        <h3 class="visually-hidden">{$item.title|wash()}</h3>
                    {/if}

                    <div class="{if $item.wrap}card-wrapper card-column my-3" data-bs-toggle="masonry{/if}"{if $item.data_element} data-element="{$item.data_element|wash()}"{/if}>

                    {foreach $item.attributes as $attribute_index => $openpa_attribute}

                        {if and($openpa_attribute.full.show_label, $item.is_grouped)}
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
                                                image_class=medium
                                                attribute_index=$attribute_index
                                                context_class=$node.class_identifier
                                                relation_view='list'
                                                relation_has_wrapper=$item.wrap
                                                show_link=false()
                                                tag_view="chip-lg mr-2 me-2"}
                            {if $need_container}</div>{/if}
                            {undef $need_container}
                        {elseif and(is_set($openpa_attribute.template), $openpa_attribute.template)}
                            {include uri=$openpa_attribute.template}
                        {/if}
                    {/foreach}
                    </div>
                </article>
            {/foreach}
        </section>
    </div>
{/if}