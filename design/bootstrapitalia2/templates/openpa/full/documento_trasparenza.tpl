{ezpagedata_set( 'has_container', true() )}
{def $summary_text = 'Table of contents'|i18n('bootstrapitalia')
     $close_text = 'Close'|i18n('bootstrapitalia')}

<section class="container cmp-heading">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            <h1>{$node.name|wash()}</h1>

            {include uri='design:openpa/full/parts/info.tpl'}

        </div>
        <div class="col-lg-3 offset-lg-1">
            {include uri='design:openpa/full/parts/actions.tpl'}
            {include uri='design:openpa/full/parts/taxonomy.tpl'}
        </div>
    </div>
</section>


{include uri='design:openpa/full/parts/main_image.tpl'}

{def $summary = parse_documento_trasparenza_info($node.data_map.info, $node.data_map.files)}
<section class="container">
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

        <section class="{if $summary.show_index}col-lg-8 border-light {/if}it-page-sections-container mb-5">
            {foreach $summary.items as $index => $item}
                <article id="{$item.slug|wash()}" class="it-page-section anchor-offset{if $item.evidence} has-bg-grey p-3{/if}">
                    {*
                    {if and(count($summary.items)|gt(1), $item.label)}
                        <h2 class="my-3">{$item.label|wash()}</h2>
                    {else}
                        <h2 class="visually-hidden">{$item.title|wash()}</h2>
                    {/if}
                    *}

                    <div class="{if $item.wrap}card-wrapper card-column my-3" data-bs-toggle="masonry{/if}"{if $item.data_element} data-element="{$item.data_element|wash()}"{/if}>

                        {foreach $item.attributes as $attribute_index => $openpa_attribute}
                            {if is_set($openpa_attribute.id)}
                                <h3 class="h5 mt-4 font-sans-serif">{$item.label|wash()}</h3>
                                {attribute_view_gui attribute=$openpa_attribute
                                            view_context=full_attributes
                                            attribute_group=$item
                                            image_class=large
                                            attribute_index=$attribute_index
                                            context_class=$node.class_identifier
                                            relation_view=banner
                                            relation_has_wrapper=false()
                                            show_link=true()
                                            tag_view="chip-lg mr-2 me-2"}
                            {elseif and(is_set($openpa_attribute.children_count), $openpa_attribute.children_count|gt(0))}
                                {if $summary.items|gt(1)}<hr />{/if}
                                {include uri='design:atoms/list_with_icon.tpl' items=$node.children}
                            {else}
                            <h3 class="h5 mt-4 font-sans-serif">{$openpa_attribute.label|wash()}</h3>
                            <div class="richtext-wrapper lora">
                                <p>{$openpa_attribute.value}</p>
                            </div>
                            {/if}
                        {/foreach}
                    </div>
                </article>
            {/foreach}
        </section>
    </div>
</section>
