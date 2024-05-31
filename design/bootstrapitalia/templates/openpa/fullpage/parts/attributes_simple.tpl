z\{def $summary = parse_attribute_groups($object, false())}
{if $summary.has_items}
    <section class="it-page-sections-container">
        {foreach $summary.items as $index => $item}
            <article id="{$item.slug|wash()}">
                {if and(count($summary.items)|gt(1), $item.label)}
                    <h2 class="my-3">{$item.label|wash()}</h2>
                {/if}

                <div>
                    {foreach $item.attributes as $attribute_index => $openpa_attribute}
                        {if and($openpa_attribute.full.show_label, $item.is_grouped)}
                            {if $openpa_attribute.full.collapse_label|not()}
                                <h3 class="h5 mt-4 font-sans-serif">{$openpa_attribute.label|wash()}</h3>
                            {else}
                                <span class="text-paragraph-small font-sans-serif">{$openpa_attribute.label|wash()}:</span>
                            {/if}
                        {/if}
                        {if is_set($openpa_attribute.contentobject_attribute)}
                            {attribute_view_gui attribute=$openpa_attribute.contentobject_attribute
                                                view_context=full_attributes
                                                attribute_group=$item
                                                image_class=imagelargeoverlay
                                                attribute_index=$attribute_index
                                                context_class=$node.class_identifier
                                                relation_view=list
                                                relation_has_wrapper=false
                                                show_link=true()
                                                tag_view="chip-lg mr-2 me-2"}
                        {elseif and(is_set($openpa_attribute.template), $openpa_attribute.template)}
                            {include uri=$openpa_attribute.template}
                        {/if}
                    {/foreach}
                </div>
            </article>
        {/foreach}
    </section>
{/if}