{def $summary_text = 'Table of contents'|i18n('bootstrapitalia')
     $close_text = 'Close'|i18n('bootstrapitalia')}
{if is_set($show_all_attributes)|not()}
    {def $show_all_attributes = false()}
{/if}

{def $summary = parse_attribute_groups($object, $show_all_attributes)}

{if $summary.has_items}
    <div class="row{if $summary.show_index} border-top border-light row-column-border row-column-menu-left{/if} attribute-list">
        {if $summary.show_index}
        <aside class="col-lg-4">
            <div class="cmp-navscroll sticky-top" aria-labelledby="accordion-title-one" data-bs-toggle="sticky" data-bs-stackable="true">
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
                                                    {foreach $summary.items as $index => $item}
                                                    {if $item.label}
                                                    <li class="nav-item">
                                                        <a class="nav-link{if $index|eq(0)} active{/if}" href="#{$item.slug|wash()}">
                                                            <span class="title-medium">{$item.title|wash()}</span>
                                                        </a>
                                                    </li>
                                                    {/if}
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
        </aside>
        {/if}

        <section class="{if $summary.show_index}col-lg-8 border-light {/if}it-page-sections-container">
            {foreach $summary.items as $index => $item}
                <article id="{$item.slug|wash()}" class="it-page-section anchor-offset">
                  {if $item.evidence} 
                    <div class="has-bg-grey p-3">
                  {/if}
                    {if and(count($summary.items)|gt(1), $item.label)}
                        <h2 class="my-3">{$item.label|wash()}</h2>
                    {else}
                        <h2 class="visually-hidden">{$item.title|wash()}</h2>
                    {/if}

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
                                                context_class=$node.class_identifier
                                                relation_view=cond($openpa_attribute.full.show_link|not, 'list', 'banner')
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
                  {if $item.evidence} 
                    </div>
                  {/if}
                </article>
            {/foreach}
        </section>
    </div>
{/if}