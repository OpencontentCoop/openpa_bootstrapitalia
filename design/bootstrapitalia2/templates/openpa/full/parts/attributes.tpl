{def $summary_text = 'Table of contents'|i18n('bootstrapitalia')
     $close_text = 'Close'|i18n('bootstrapitalia')}
{if is_set($show_all_attributes)|not()}
    {def $show_all_attributes = false()}
{/if}
{def $summary_items = array()}
{def $attribute_groups = class_extra_parameters($object.class_identifier, 'attribute_group')}
{def $hide_index = $attribute_groups.hide_index}
{if $show_all_attributes}
    {foreach $object.data_map as $attribute_identifier => $attribute}
        {if or($attribute.has_content, $attribute.data_type_string|eq('ezuser'))}
            {set $summary_items = $summary_items|append(
                hash( 'slug', $attribute_identifier, 'title', $openpa[$attribute_identifier].label, 'attributes', array($openpa[$attribute_identifier]), 'is_grouped', false(), 'wrap', false() )
            )}
        {/if}
    {/foreach}
{elseif $attribute_groups.enabled}
    {foreach $attribute_groups.group_list as $slug => $name}
        {if count($attribute_groups[$slug])|gt(0)}
            {def $openpa_attributes = array()
                 $wrapped = true()}
            {foreach $attribute_groups[$slug] as $attribute_identifier}
                {if and( is_set($openpa[$attribute_identifier]), $openpa[$attribute_identifier].full.exclude|not(), or($openpa[$attribute_identifier].has_content, $openpa[$attribute_identifier].full.show_empty))}

                    {*workaround per ezboolean*}
                    {if and(
                        is_set($openpa[$attribute_identifier].contentobject_attribute),
                        $openpa[$attribute_identifier].contentobject_attribute.data_type_string|eq('ezboolean'),
                        $openpa[$attribute_identifier].contentobject_attribute.data_int|ne(1)
                    )}
                        {skip}
                    {/if}

                    {*evita di duplicare l'immagine principale nella galleria*}
                    {if and(
                        class_extra_parameters($object.class_identifier, 'table_view').main_image|contains($attribute_identifier),
                        class_extra_parameters($object.class_identifier, 'table_view').show_link|contains($attribute_identifier)|not(),
                        is_set($openpa[$attribute_identifier].contentobject_attribute)
                    )}
                        {if and($openpa[$attribute_identifier].contentobject_attribute.data_type_string|eq('ezobjectrelationlist'), count($openpa[$attribute_identifier].contentobject_attribute.content.relation_list)|le(1))}
                            {skip}
                        {/if}
                    {/if}

                    {set $openpa_attributes = $openpa_attributes|append($openpa[$attribute_identifier])}
                    {if and($wrapped, $openpa[$attribute_identifier].full.show_link|not())}{set $wrapped = false()}{/if}
                    {if and($wrapped, $openpa[$attribute_identifier].full.show_label)}{set $wrapped = false()}{/if}
                {/if}
            {/foreach}
            {if count($openpa_attributes)|gt(0)}
                {set $summary_items = $summary_items|append(
                    hash( 'slug', $slug, 'title', $attribute_groups.current_translation[$slug], 'attributes', $openpa_attributes, 'is_grouped', true(), 'wrap', cond($wrapped, count($openpa_attributes)|gt(1),true(),false()) )
                )}
            {/if}
            {undef $openpa_attributes $wrapped}
        {/if}
    {/foreach}
{else}
    {def $table_view = class_extra_parameters($object.class_identifier, 'table_view')}
    {foreach $table_view.show as $attribute_identifier}
        {if and($openpa[$attribute_identifier].full.exclude|not(), or($openpa[$attribute_identifier].has_content, $openpa[$attribute_identifier].full.show_empty))}
            {set $summary_items = $summary_items|append(
                hash( 'slug', $attribute_identifier, 'title', $openpa[$attribute_identifier].label, 'attributes', array($openpa[$attribute_identifier]), 'is_grouped', false(), 'wrap', false() )
            )}
        {/if}
    {/foreach}
    {undef $table_view}
{/if}

{if count($summary_items)|gt(0)}
    <div class="row{if and(count($summary_items)|gt(1), $hide_index|not())} row-column-menu-left mt-4 mt-lg-80 pb-lg-80 pb-40{/if} attribute-list">
        {if and(count($summary_items)|gt(1), $hide_index|not())}
        <div class="col-12 col-lg-3 mb-4 border-col">
            <div class="cmp-navscroll sticky-top" aria-labelledby="accordion-title-one">
                <nav class="navbar it-navscroll-wrapper navbar-expand-lg" data-bs-navscroll="">
                    <div class="navbar-custom" id="navbarNavProgress">
                        <div class="menu-wrapper">
                            <div class="link-list-wrapper">
                                <div class="accordion">
                                    <div class="accordion-item">
                                      <span class="accordion-header" id="accordion-title-one">
                                        <button class="accordion-button pb-10 px-3 text-uppercase" type="button"
                                                data-bs-toggle="collapse"
                                                data-bs-target="#collapse-one" aria-expanded="true"
                                                aria-controls="collapse-one"
                                                data-focus-mouse="false">
                                            {$summary_text|wash()}
                                            {display_icon('it-expand', 'svg', 'icon icon-xs right')}
                                        </button>
                                      </span>
                                        <div class="progress">
                                            <div class="progress-bar it-navscroll-progressbar" role="progressbar"
                                                 aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"
                                                 style="width: 0;"></div>
                                        </div>
                                        <div id="collapse-one" class="accordion-collapse collapse show" role="region" aria-labelledby="accordion-title-one">
                                            <div class="accordion-body">
                                                <ul class="link-list" data-element="page-index">
                                                    {foreach $summary_items as $index => $item}
                                                    <li class="nav-item">
                                                        <a class="nav-link{if $index|eq(0)} active{/if}" href="#{$item.slug|wash()}">
                                                            <span class="title-medium">{$item.title|wash()}</span>
                                                        </a>
                                                    </li>
                                                    {/foreach}
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </nav>
            </div>
        </div>
        {/if}

        <div class="{if or(count($summary_items)|eq(1), $hide_index)}col w-100 px-lg-4 pb-lg-4{else}col-12 col-lg-8 offset-lg-1{/if}">
            <div class="it-page-sections-container">
            {foreach $summary_items as $index => $item}
                <section id="{$item.slug|wash()}" class="it-page-section mb-30{if $attribute_groups.evidence_list|contains($item.slug)} has-bg-grey p-3{/if}">
                    {if and(count($summary_items)|gt(1), $attribute_groups.hidden_list|contains($item.slug)|not())}
                    <h2 class="title-xxlarge mb-3">{$item.title|wash()}</h2>
                    {/if}

                    <div class="{if $item.wrap}card-wrapper card-teaser-wrapper" data-bs-toggle="masonry{/if}">

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
                                <h3 class="my-3 subtitle-medium font-sans-serif">{$openpa_attribute.label|wash()}</h3>
                            {else}
                                <span class="text-paragraph-small font-sans-serif">{$openpa_attribute.label|wash()}:</span>
                            {/if}
                        {/if}

                        {if is_set($openpa_attribute.contentobject_attribute)}
                            {def $need_container = cond(
                                and(
                                    $item.wrap|not(),
                                    array('ezobjectrelationlist', 'ezmatrix')|contains($openpa_attribute.contentobject_attribute.data_type_string)|not()
                                ),
                                true(), false()
                            )}
                            {if $need_container}<div class="richtext-wrapper lora">{/if}
                            {attribute_view_gui attribute=$openpa_attribute.contentobject_attribute
                                                view_context=full_attributes
                                                image_class=medium
                                                attribute_index=$attribute_index
                                                context_class=$node.class_identifier
                                                relation_view=cond($openpa_attribute.full.show_link|not, 'list', 'banner')
                                                relation_has_wrapper=$item.wrap
                                                show_link=$openpa_attribute.full.show_link
                                                tag_view="chip-lg mr-2 me-2"}
                            {if $need_container}</div>{/if}
                            {undef $need_container}
                        {elseif and(is_set($openpa_attribute.template), $openpa_attribute.template)}
                            {include uri=$openpa_attribute.template context='attributes'}
                        {/if}

                        {if $openpa_attribute.full.highlight}
                            </div>
                        </div>
                        {elseif and($openpa_attribute.full.show_label, $item.is_grouped,$openpa_attribute.full.collapse_label)}

                        {/if}
                    {/foreach}

                    </div>

                </section>
            {/foreach}
            </div>
        </div>
    </div>
{/if}
